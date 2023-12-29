variable "cloudflare_zone_name" {
  type = string
}

variable "home_public_ip_address" {
  type = string

  validation {
    condition     = can(cidrnetmask(var.home_public_ip_address))
    error_message = "The value of home_public_ip_address must be a valid IPv4 address with CIDR netmask"
  }
}

variable "cloudflare_access_allowed_email_addresses" {
  type = list(string)
}
