# Traefik uses the Let’s Encrypt client and ACME library (LEGO) to automatically request certificates.
# We'll opt to use the strict API Token configuration - https://go-acme.github.io/lego/dns/cloudflare

resource "cloudflare_api_token" "traefik_zone_read" {
  name = "traefik-${local.base_resource_name}-zone-read"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["Zone Read"],
    ]

    resources = {
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.default.id}" = "*"
    }
  }

  condition {
    request_ip {
      in = [var.home_public_ip_address]
    }
  }
}

resource "cloudflare_api_token" "traefik_dns_write" {
  name = "traefik-${local.base_resource_name}-dns-write"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
    ]

    resources = {
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.default.id}" = "*"
    }
  }

  condition {
    request_ip {
      in = [var.home_public_ip_address]
    }
  }
}
