```
ooooo                                      oooo  oooo              
`888'                                      `888  `888              
 888          .ooooo.   .ooooo.   .oooo.    888   888  oooo    ooo 
 888         d88' `88b d88' `\"Y8 `P  )88b   888   888   `88.  .8'
 888         888   888 888        .oP\"888   888   888    `88..8'
 888       o 888   888 888   .o8 d8(  888   888   888     `888'
o888ooooood8 `Y8bod8P' `Y8bod8P' `Y888\"\"8o o888o o888o     .8'
                                                       .o..P'
                                                       `Y8P'
```

# Example: Deploy an App Configuration-backed app to App Service within Locally

This example shows how to deploy [a small C# (ASP.NET Core) key-value editor - `tombuildsstuff/example-appservice-appconfig`](https://hub.docker.com/r/tombuildsstuff/example-appservice-appconfig) to App Service, backed by Azure App Configuration, on [Locally Build](https://locally.build).

The application is a minimal key-value editor: it lists every key-value in an App Configuration store and lets you add, update, and delete them. It's a plain [12-factor](https://12factor.net) service: one image, configured entirely through environment variables, reading from and writing to App Configuration. The image is built and published from [the application repository](https://github.com/tombuildsstuff/example-appservice-appconfig); this repository is just the infrastructure that runs it.

The app authenticates to App Configuration using a **user-assigned managed identity**, which is granted the `App Configuration Data Owner` role on the store (Data Owner rather than Data Reader, since the app writes as well as reads), so no access key or connection string is stored in app settings. Locally supports managed identity the same way Azure does, so the identical wiring works locally and in the cloud.

## Requirements

* [Locally Build](https://locally.build).
* Either [HashiCorp Terraform](https://terraform.io) or [OpenTofu](https://opentofu.org).
* Either [Docker](https://www.docker.com) or [Podman](https://podman.io) (recommended).
* The Locally Plugin for `Microsoft.AppConfiguration` installed (`locally plugin install --name Microsoft.AppConfiguration`).
* The Locally Plugin for `Microsoft.Web` installed (`locally plugin install --name Microsoft.Web`).

## Running the example

First up, we need to ensure our container runtime (Docker or Podman) is running, then launch Locally:

```bash
locally build
```

With Locally running, in another terminal we can initialise Terraform, which both downloads the providers we need and configures the module for use:

```bash
cd environments/locally
terraform init
```

> [!NOTE]
> It's possible to use OpenTofu here by substituting `terraform` for `tofu`.

With Terraform initialised, we can then provision the example by running:

```bash
locally run terraform apply
```

Once you approve the plan and the resources have been deployed, the application is running at the URL in the outputs:

```
https://locally-example-appconfig-app.furnace.locally:5663
```

[Open that URL in a browser](https://locally-example-appconfig-app.furnace.locally:5663) and you'll be able to add, update, and delete key-values; each one is stored in App Configuration.

---

As this Terraform configuration sends the App Service logs into a Log Analytics Workspace, we can then query them within [the Locally Dashboard, in the Monitoring section](https://localhost:5678/monitoring/components), by running:

```
AppServiceConsoleLogs | order by TimeGenerated desc
```

## Notes

This example has no sign-in of its own: anyone who can reach the URL can read and write the store's key-values. That keeps it focused on the App Service ↔ App Configuration wiring - a real app would sit behind authentication.

The image is a multi-arch build carrying both `linux/amd64` (Azure App Service) and `linux/arm64` (Apple Silicon), so the same image runs on Locally and on Azure.

## Tearing it down

```bash
cd environments/locally
locally run terraform destroy
```
