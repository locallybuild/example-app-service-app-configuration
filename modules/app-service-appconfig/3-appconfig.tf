# ---------------------------------------------------------------------------
# App Configuration - the key-value store the app reads from and writes to.
#
# The "standard" SKU is used as data-plane access via Azure RBAC (rather than
# access keys) requires it.
# ---------------------------------------------------------------------------
resource "azurerm_app_configuration" "main" {
  name                = "${var.name_prefix}-appconfig"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "standard"
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# Data-plane role assignment.
#
# Grants the app's managed identity the built-in App Configuration Data Owner
# role on the store - Data Owner rather than Data Reader, since the app writes
# and deletes key-values as well as reading them.
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "app" {
  scope                = azurerm_app_configuration.main.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}
