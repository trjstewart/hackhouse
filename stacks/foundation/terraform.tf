terraform {
  cloud {
    organization = "hackhouse"
    workspaces { name = "foundation" }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.66.3, < 1.0.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 4.46.0, < 5.0.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = ">=0.60.0, <1.0.0"
    }

    talos = {
      source = "siderolabs/talos"
      version = ">=0.6.1, <1.0.0"
    }
  }
}
