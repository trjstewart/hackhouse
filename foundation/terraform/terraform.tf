terraform {
  cloud {
    organization = "hackhouse"
    workspaces { name = "foundation" }
  }

  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = ">=0.51.0, <1.0.0"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = ">= 4.20.0, < 5.0.0"
    }
  }
}
