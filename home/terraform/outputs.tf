output "cloudflare_tunnel_token" {
  value = resource.cloudflare_tunnel.default.tunnel_token
  sensitive = true
}
