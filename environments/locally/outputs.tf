output "application_url" {
  description = "Where to reach the application in a browser."
  value       = module.app-service-appconfig.application_url
}

output "appconfig_endpoint" {
  description = "The App Configuration store endpoint the application connects to."
  value       = module.app-service-appconfig.appconfig_endpoint
}
