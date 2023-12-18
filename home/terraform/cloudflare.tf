data "cloudflare_zone" "default" { name = "hackhouse.sh" }

resource "random_password" "cloudflare_tunnel" {
  length  = 64
  special = false
}

resource "cloudflare_tunnel" "default" {
  account_id = data.cloudflare_zone.default.account_id
  name       = "home"
  secret     = random_password.cloudflare_tunnel.result
}

resource "cloudflare_tunnel_config" "default" {
  account_id = data.cloudflare_zone.default.account_id
  tunnel_id  = cloudflare_tunnel.default.id

  config {
    ingress_rule {
      service = "http_status:418"
    }
  }
}

resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zone.default.id
  name    = "*"
  type    = "CNAME"
  value   = cloudflare_tunnel.default.cname
  proxied = true
}
