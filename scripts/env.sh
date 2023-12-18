#!/usr/bin/zsh

alias op=op.exe

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
rm -f .env foundation/.env home/.env media/.env

# Output Environment Variables for the `foundation` project
touch foundation/.env
TERRAFORM_CLOUD_AGENT=$(op item get "Terraform Cloud Agent" --vault HackHouse --format json --fields label=name,label=token)
echo "TERRAFORM_CLOUD_AGENT_NAME=$(jq '.[] | select(.label=="name") | .value' <<< $TERRAFORM_CLOUD_AGENT)" >> foundation/.env
echo "TERRAFORM_CLOUD_AGENT_TOKEN=$(jq '.[] | select(.label=="token") | .value' <<< $TERRAFORM_CLOUD_AGENT)" >> foundation/.env

# Output Environment Variables for the `home` project
touch home/.env
echo "CLOUDFLARE_TUNNEL_TOKEN=$(terraform -chdir=home/terraform output cloudflare_tunnel_token)" >> home/.env
