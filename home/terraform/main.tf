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
  cloudflare_tunnel_subdomains_to_proxy = [ "traefik", "whoami", "qbittorrent" ]
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

resource "cloudflare_access_application" "default" {
  zone_id                   = data.cloudflare_zone.default.id
  name                      = data.cloudflare_zone.default.name
  domain                    = cloudflare_record.wildcard.hostname
  type                      = "self_hosted"
  session_duration          = "24h"

  cors_headers {
    allow_all_origins = true
    allow_all_methods = true
  }
}

resource "cloudflare_access_policy" "allow_home_public_ip_address" {
  account_id = data.cloudflare_zone.default.account_id
  application_id = cloudflare_access_application.default.id
  name           = "allow-home-public-ip-address"
  decision       = "bypass"
  precedence     = "1"

  include {
    ip = [ var.home_public_ip_address ]
  }
}

resource "cloudflare_access_policy" "allow_approved_email_addresses" {
  account_id = data.cloudflare_zone.default.account_id
  application_id = cloudflare_access_application.default.id
  name           = "allow-approved-email-addresses"
  decision       = "allow"
  precedence     = "2"

  include {
    email = var.cloudflare_access_allowed_email_addresses
  }

  depends_on = [ cloudflare_access_policy.allow_home_public_ip_address ]
}
