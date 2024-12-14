variable "cloudflare_zone_name" {
  type        = string
  description = "The name of the Cloudflare Zone to use for DNS records and naming of resources."
}

variable "email_address" {
  type        = string
  description = "The email address to use for the Terraform Organization."
}

variable "home_public_ip_address" {
  type        = string
  description = "The public IPv4 Address (including netmask) of the Home Network."

  validation {
    condition     = can(cidrnetmask(var.home_public_ip_address))
    error_message = "The value of home_public_ip_address must be a valid IPv4 address with CIDR netmask."
  }
}

variable "proxmox_hostname" {
  type        = string
  description = "The hostname of the primary Proxmox Node."

  validation {
    condition     = !can(regex("https://", var.proxmox_hostname))
    error_message = "The value of proxmox_hostname must not start with 'https://'."
  }

  validation {
    condition     = !can(regex("/$", var.proxmox_hostname))
    error_message = "The value of proxmox_hostname must not end with a trailing slash."
  }

  validation {
    condition     = !can(regex(":[0-9]+", var.proxmox_hostname))
    error_message = "The value of proxmox_hostname must not contain the port."
  }
}

variable "proxmox_node_names" {
  type        = list(string)
  description = "A list of the names assigned to each Proxmox Node in the Cluster."
}

variable "proxmox_api_token" {
  type        = string
  description = "The API Token to use for the Proxmox Provider."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+@pve![a-zA-Z0-9-]+=[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$", var.proxmox_api_token))
    error_message = "The value of proxmox_api_token must be in the format \"user-name@pve!token-name=UUIDv4\"."
  }
}

variable "proxmox_username" {
  type        = string
  description = "The Username to use for the Proxmox Provider."
  default = "root"
}

variable "proxmox_password" {
  type        = string
  description = "The Password to use for the Proxmox Provider."
}
