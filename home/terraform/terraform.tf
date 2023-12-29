terraform {
  cloud {
    organization = "hackhouse"
    workspaces { name = "home" }
  }

  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = ">= 4.20.0, < 5.0.0"
    }
  }
}
