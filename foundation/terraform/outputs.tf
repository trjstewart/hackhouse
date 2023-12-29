output "terraform_agent_token" {
  value = tfe_agent_token.default.token
  description = "The token used by the Terraform agent to communicate with Terraform Cloud"
  sensitive = true
}

output "domain_name" {
  value = data.cloudflare_zone.default.name
  description = "The Domain Name to be used by downstream services"
}

output "cloudflare_api_token_traefik_zone_read" {
  value = cloudflare_api_token.traefik_zone_read.value
  description = "The API Token used by Traefik to read the Cloudflare Zone for Certificate Management"
  sensitive = true
}

output "cloudflare_api_token_traefik_dns_write" {
  value = cloudflare_api_token.traefik_dns_write.value
  description = "The API Token used by Traefik to write DNS records in the Cloudflare Zone for Certificate Management"
  sensitive = true
}
