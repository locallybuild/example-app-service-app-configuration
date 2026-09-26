# ---------------------------------------------------------------------------
# App Service Plan - houses the App Service running the custom container.
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "main" {
  name                = "${var.name_prefix}-plan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

# ---------------------------------------------------------------------------
# Linux App Service (Web App for Containers) - runs the App Configuration app.
#
# The image is pulled directly from Docker Hub (a public image), so there is no
# Container Registry to provision or push into. App Service terminates TLS at
# the platform, so the browser reaches the app over HTTPS while the container
# serves plain HTTP on WEBSITES_PORT.
# ---------------------------------------------------------------------------
resource "azurerm_linux_web_app" "main" {
  name                = local.web_app_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true
  tags                = var.tags

  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  site_config {
    health_check_path                 = "/healthz"
    health_check_eviction_time_in_min = 2

    application_stack {
      # Pulled straight from Docker Hub - a public image, so no registry
      # credentials are needed.
      docker_image_name   = local.image_name
      docker_registry_url = "https://index.docker.io"
    }
  }

  app_settings = {
    # App Service routes public traffic to the container on this port, and the
    # app binds to it (12-factor port binding).
    WEBSITES_PORT = tostring(local.app_port)
    PORT          = tostring(local.app_port)

    # The App Configuration store the app reads from and writes to.
    APP_CONFIG_ENDPOINT = azurerm_app_configuration.main.endpoint

    # Selects which managed identity DefaultAzureCredential authenticates as -
    # the user-assigned identity granted App Configuration Data Owner. No key or
    # connection string is needed.
    AZURE_CLIENT_ID = azurerm_user_assigned_identity.main.client_id
  }
}
