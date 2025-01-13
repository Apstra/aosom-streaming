#!/bin/bash
# Some systems may not have docker-compose installed as docker-compose, but as docker compose

set -e

if command -v docker-compose &> /dev/null; then
  docker-compose $@
else
  docker compose $@
fi
