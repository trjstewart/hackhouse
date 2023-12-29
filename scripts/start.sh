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

for dir in foundation home media; do (
  cd $dir || exit
  docker-compose up --wait
) done
