variable "tfe_organization_name" {
  type        = string
  description = "The name of the Terraform Cloud Organization."
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
}

variable "proxmox_password" {
  type        = string
  description = "The Password to use for the Proxmox Provider."
}
