#!/usr/bin/env bash
set -euo pipefail

# Brings up the home-assistant container. Safe to re-run — no-op if already up.

cd "$(dirname "${BASH_SOURCE[0]}")/../config"
docker compose up -d
