#!/usr/bin/env bash

# It's expected that this script is executed from the root of the project, we'll be nice though and account for it running withing the scripts directory...
if [[ "${PWD##*/}" == "scripts" ]]; then cd ..; fi

# We're not that nice though. If we're not now in the root of the project, we'll exit.
if [[ ! "${PWD##*/}" == "hackhouse" ]]; then print_error_and_exit "This script must be run from the root of the project."; fi

# Ensure we've got all the volumes we need ready before we start any containers.
if [[ -e ./scripts/volumes.sh ]]; then . ./scripts/volumes.sh; else error_message_and_close "Couldn't load volumes (this should never actually happen)"; fi

for dir in foundation home media; do (
  cd $dir || exit
  docker-compose pull
  docker-compose up --wait --remove-orphans
) done
