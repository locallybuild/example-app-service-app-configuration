# ---------------------------------------------------------------------------
# User-Assigned Managed Identity - the identity the app runs as.
#
# The app authenticates to App Configuration as this identity, so no access key
# or connection string is stored in app settings. A user-assigned identity (rather
# than system-assigned) exists before the web app does, so its role assignment
# can be granted up front - the app has access from its very first request.
# ---------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "main" {
  name                = "${var.name_prefix}-id"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  tags                = var.tags
}
