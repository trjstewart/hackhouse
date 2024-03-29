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

# As we're going to be creating directories, we'll need to run this script with sudo access
if ! sudo -v; then print_error_and_exit "You must have sudo access to run this script!"; fi

# Create the root directory for all docker volumes and ensure everything inside it is owned by the current user
DOCKER_VOLUMES_ROOT_SSD="/mnt/ssd/docker-volumes"
DOCKER_VOLUMES_ROOT_HDD="/mnt/hdd/docker-volumes"
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD $DOCKER_VOLUMES_ROOT_HDD

# Create directories and files to be used for volumes in the `home` project and ensure everything inside them is owned by the current user
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/home/traefik/letsencrypt
sudo touch $DOCKER_VOLUMES_ROOT_SSD/home/traefik/letsencrypt/acme.json
sudo chmod 600 $DOCKER_VOLUMES_ROOT_SSD/home/traefik/letsencrypt/acme.json
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/home/homarr/configs
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/home/homarr/icons
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/home/homarr/data

# Create directories and files to be used for volumes in the `media` project
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/media/qbittorrent/config
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/media/sabnzbd/config
sudo mkdir -p $DOCKER_VOLUMES_ROOT_HDD/media/Movies
sudo mkdir -p "$DOCKER_VOLUMES_ROOT_HDD/media/TV Series"
sudo mkdir -p $DOCKER_VOLUMES_ROOT_HDD/media/Anime
sudo mkdir -p $DOCKER_VOLUMES_ROOT_HDD/media/downloads/qbittorrent/incomplete
sudo mkdir -p $DOCKER_VOLUMES_ROOT_HDD/media/downloads/sabnzbd/complete
sudo mkdir -p $DOCKER_VOLUMES_ROOT_HDD/media/downloads/sabnzbd/incomplete
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/media/prowlarr/config
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/media/sonarr/config
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/media/radarr/config
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/media/plex/config
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/media/plex/transcode
sudo mkdir -p $DOCKER_VOLUMES_ROOT_SSD/media/overseerr/config

# Ensure everything is owned by the current user
sudo chown -R $(whoami):$(whoami) $DOCKER_VOLUMES_ROOT_SSD
sudo chown -R $(whoami):$(whoami) $DOCKER_VOLUMES_ROOT_HDD
