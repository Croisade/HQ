#!/bin/bash
# Daily JellyBridge discover-content sync.
#
# The plugin's own scheduled task doesn't work — confirmed by testing it
# directly: a schedule-triggered run completes in ~0ms with nothing
# processed.
#
# IMPORTANT: /JellyBridge/SyncDiscover takes NO request body (confirmed
# from the plugin's source — the controller method has zero parameters).
# It runs entirely off the plugin's *persisted* configuration, fetched via
# GET/POST /Plugins/{pluginId}/Configuration. Every setting that matters
# (MaxDiscoverPages, NetworkMap, DefaultMoviesPromo, DefaultSeriesPromo,
# UseMixedMediaLibrary) must be saved there ahead of time — passing them
# in the SyncDiscover call body (what this script used to do) is silently
# ignored. Change persisted config once via:
#   curl -X POST ".../Plugins/$PLUGIN_ID/Configuration?api_key=..." -d '{...full config...}'
# This script just also clears the .ignore markers the plugin reapplies
# to every synced item on every sync (not a duplicate-detection feature
# working as documented — just its default behavior).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.env"

JELLYFIN_URL="http://localhost:8096"

echo "[$(date -Is)] Starting JellyBridge sync"

curl -sf -X POST "$JELLYFIN_URL/JellyBridge/SyncDiscover?api_key=$JELLYFIN_API_KEY" -o /dev/null

echo "[$(date -Is)] Sync request sent, clearing .ignore markers"

docker exec jellyfin sh -c 'find /jellybridge/Movies /jellybridge/Shows -name ".ignore" -delete'

echo "[$(date -Is)] Refreshing Discover libraries"

curl -sf -X POST "$JELLYFIN_URL/Library/Refresh?api_key=$JELLYFIN_API_KEY" -o /dev/null

echo "[$(date -Is)] Done"
