#!/usr/bin/env bash
# Removes stale plugin versions left behind when Jellyfin's auto-update
# installs a new version without cleaning up the old one (seen with
# Jellyfin Enhanced, whose dynamically-generated manifest name breaks
# Jellyfin's normal version-reconciliation). Run with sudo — plugin
# folders are owned by root inside the container's bind mount.
set -euo pipefail

PLUGINS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../data/config/plugins" && pwd)"

stale=$(python3 - "$PLUGINS_DIR" <<'PYEOF'
import json, sys
from pathlib import Path

plugins_dir = Path(sys.argv[1])
by_guid = {}

for entry in plugins_dir.iterdir():
    meta = entry / "meta.json"
    if not entry.is_dir() or not meta.exists():
        continue
    try:
        data = json.loads(meta.read_text())
    except Exception:
        continue
    guid = data.get("guid")
    version = data.get("version", "0")
    if not guid:
        continue
    by_guid.setdefault(guid, []).append((version, entry))

def version_key(v):
    return tuple(int(p) if p.isdigit() else 0 for p in v.split("."))

for guid, versions in by_guid.items():
    if len(versions) <= 1:
        continue
    versions.sort(key=lambda x: version_key(x[0]))
    for version, path in versions[:-1]:
        print(path)
PYEOF
)

if [ -z "$stale" ]; then
    echo "No duplicate plugin versions found."
    exit 0
fi

echo "$stale" | while IFS= read -r path; do
    echo "Removing stale plugin version: $path"
    rm -rf "$path"
done

echo "Done. Restart the jellyfin container if it was already running with the duplicate loaded:"
echo "  docker restart jellyfin"
