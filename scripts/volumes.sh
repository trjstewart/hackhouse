#!/usr/bin/env bash

# This script expects there to be two overarching pools of storage, one fast and one large. Modify these variables to suit your setup.
FAST_STORAGE_LOCATION="/mnt/wsl/ssd"
LARGE_STORAGE_LOCATION="/mnt/wsl/hdd"

# ---------------------------------------------------------------------------------------------------------------------
# Initial Sanity Checks
# ---------------------------------------------------------------------------------------------------------------------
print_error_and_exit() { printf '%b\n\n' "\e[31m$*\e[0m"; exit 1; }

# It's expected that this script is executed from the root of the project, we'll be nice though and account for it running withing the scripts directory...
if [[ "${PWD##*/}" == "scripts" ]]; then cd ..; fi

# We're not that nice though. If we're not now in the root of the project, we'll exit.
if [[ ! "${PWD##*/}" == "hackhouse" ]]; then print_error_and_exit "This script must be run from the root of the project."; fi

# As we're going to be creating directories at the root of disks, we'll need to run this script with sudo access
if ! sudo -v; then print_error_and_exit "You must have sudo access to run this script!"; fi

# If we're running inside WSL, we expect the locations above to be mounted as disks so we need to check they are actually mounted.
if [[ -f "/proc/version" ]] && grep -q microsoft-standard-WSL2 /proc/version; then
  if ! lsblk | grep -q $FAST_STORAGE_LOCATION; then print_error_and_exit "The fast disk is not mounted!"; fi
  if ! lsblk | grep -q $LARGE_STORAGE_LOCATION; then print_error_and_exit "The large disk is not mounted!"; fi

  # Also do a sanity check that the disks are actually mounted as we expect them to be
  if [[ ! $(cat $FAST_STORAGE_LOCATION/expected-mount-path) == $FAST_STORAGE_LOCATION ]]; then print_error_and_exit "The fast disk is not mounted as expected!"; fi
  if [[ ! $(cat $LARGE_STORAGE_LOCATION/expected-mount-path) == $LARGE_STORAGE_LOCATION ]]; then print_error_and_exit "The large disk is not mounted as expected!"; fi
fi

# ---------------------------------------------------------------------------------------------------------------------
# Create the root directory for all docker volumes
# ---------------------------------------------------------------------------------------------------------------------
FAST_DOCKER_VOLUMES_ROOT="$FAST_STORAGE_LOCATION/docker-volumes"
LARGE_DOCKER_VOLUMES_ROOT="$LARGE_STORAGE_LOCATION/docker-volumes"
sudo mkdir -p $FAST_DOCKER_VOLUMES_ROOT $LARGE_DOCKER_VOLUMES_ROOT

# ---------------------------------------------------------------------------------------------------------------------
# Create directories and files to be used for volumes in the `home` project
# ---------------------------------------------------------------------------------------------------------------------
# Things for Traefik
sudo mkdir -p $FAST_DOCKER_VOLUMES_ROOT/home/traefik/letsencrypt
sudo touch $FAST_DOCKER_VOLUMES_ROOT/home/traefik/letsencrypt/acme.json
sudo chmod 600 $FAST_DOCKER_VOLUMES_ROOT/home/traefik/letsencrypt/acme.json

# ---------------------------------------------------------------------------------------------------------------------
# Create directories and files to be used for volumes in the `media` project
# ---------------------------------------------------------------------------------------------------------------------
# Things for SABnzbd
sudo mkdir -p $FAST_DOCKER_VOLUMES_ROOT/media/sabnzbd/config
sudo mkdir -p $LARGE_DOCKER_VOLUMES_ROOT/media/downloads/sabnzbd/incomplete
sudo mkdir -p $LARGE_DOCKER_VOLUMES_ROOT/media/downloads/sabnzbd/complete
sudo mkdir -p $LARGE_DOCKER_VOLUMES_ROOT/media/downloads/sabnzbd/complete/sonarr
sudo mkdir -p $LARGE_DOCKER_VOLUMES_ROOT/media/downloads/sabnzbd/complete/radarr

# Things for Prowlarr
sudo mkdir -p $FAST_DOCKER_VOLUMES_ROOT/media/prowlarr/config
sudo mkdir -p $LARGE_DOCKER_VOLUMES_ROOT/media/downloads/sabnzbd/complete/prowlarr


# ---------------------------------------------------------------------------------------------------------------------
# Ensure everything is owned by the current user
# ---------------------------------------------------------------------------------------------------------------------
sudo chown -R $(whoami):$(whoami) $FAST_DOCKER_VOLUMES_ROOT $LARGE_DOCKER_VOLUMES_ROOT
