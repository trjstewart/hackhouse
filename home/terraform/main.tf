data "cloudflare_zone" "default" { name = var.cloudflare_zone_name }

resource "random_password" "cloudflare_tunnel" {
  length  = 128
  special = false
}

resource "cloudflare_tunnel" "default" {
  account_id = data.cloudflare_zone.default.account_id
  name       = data.cloudflare_zone.default.name
  secret     = random_password.cloudflare_tunnel.result
}

resource "cloudflare_record" "wildcard" {
  zone_id = data.cloudflare_zone.default.id
  name    = "*"
  type    = "CNAME"
  value   = cloudflare_tunnel.default.cname
  proxied = true
}

locals {
  cloudflare_tunnel_subdomains_to_proxy = [ "traefik", "whoami" ]
}

resource "cloudflare_tunnel_config" "default" {
  account_id = data.cloudflare_zone.default.account_id
  tunnel_id  = cloudflare_tunnel.default.id

  config {
    origin_request {
      http2_origin = true
    }

    dynamic "ingress_rule" {
      for_each = local.cloudflare_tunnel_subdomains_to_proxy
      content {
        hostname = "${ingress_rule.value}.${data.cloudflare_zone.default.name}"
        service  = "https://traefik"

        origin_request {
          origin_server_name = "${ingress_rule.value}.${data.cloudflare_zone.default.name}"
        }
      }

    }

    ingress_rule {
      service = "http_status:418"
    }
  }
}
