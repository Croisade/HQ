#!/usr/bin/env bash
set -euo pipefail

# Creates the shared bridge network that all workload containers join,
# so they can reach each other (and be routed to by a reverse proxy) by name.

NETWORK=lab

if docker network inspect "$NETWORK" >/dev/null 2>&1; then
  echo "Network '$NETWORK' already exists."
else
  docker network create --driver bridge --attachable "$NETWORK"
  echo "Created network '$NETWORK'."
fi
