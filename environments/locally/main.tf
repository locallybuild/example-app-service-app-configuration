provider "azurerm" {
  features {}
}

module "app-service-appconfig" {
  source = "../../modules/app-service-appconfig"

  name_prefix = "locally-example-appconfig"
  location    = "berlin"
  tags = {
    ProvisionedVia = "Terraform"
  }
}
