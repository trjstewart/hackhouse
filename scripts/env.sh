#!/usr/bin/env bash

# It's expected that this script is executed from the root of the project, we'll be nice though and account for it running withing the scripts directory...
if [[ "${PWD##*/}" == "scripts" ]]; then
  cd ..
fi

# We're not that nice though. If we're not now in the root of the project, we'll exit.
if [[ ! "${PWD##*/}" == "hackhouse" ]]; then
  echo -e "This script must be run from the root of the project."
  exit 1
fi

# Remove any existing .env files from expected directories
find . -name '.env' -print0 | xargs -0 rm

# Output Environment Variables for the `foundation` project
touch foundation/.env
echo "TERRAFORM_CLOUD_AGENT_TOKEN=$(terraform -chdir=foundation/terraform output terraform_agent_token)" >> foundation/.env

# Output Environment Variables for the `home` project
touch home/.env
echo "EMAIL_ADDRESS=\"$(op.exe read "op://Personal/Personal Details/Internet Details/email")\"" >> home/.env
echo "DOMAIN_NAME=$(terraform -chdir=foundation/terraform output domain_name)" >> home/.env
echo "CLOUDFLARE_API_TOKEN_TRAEFIK_ZONE_READ=$(terraform -chdir=foundation/terraform output cloudflare_api_token_traefik_zone_read)" >> home/.env
echo "CLOUDFLARE_API_TOKEN_TRAEFIK_DNS_WRITE=$(terraform -chdir=foundation/terraform output cloudflare_api_token_traefik_dns_write)" >> home/.env
echo "CLOUDFLARE_TUNNEL_TOKEN=$(terraform -chdir=home/terraform output cloudflare_tunnel_token)" >> home/.env
