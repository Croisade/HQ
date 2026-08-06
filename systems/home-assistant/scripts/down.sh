#!/usr/bin/env bash
set -euo pipefail

# Stops the home-assistant container (data in ../data is untouched).

cd "$(dirname "${BASH_SOURCE[0]}")/../config"
docker compose down
