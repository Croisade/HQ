#!/bin/bash
# Deluge Execute-plugin script, event "Torrent Complete".
# Args from Deluge: $1 = torrent id, $2 = torrent name, $3 = save path.
# If the finished torrent contains an executable/script file, remove the torrent
# and its data. Sonarr/Radarr then see the download vanish, mark it failed,
# blocklist the release and (with autoRedownloadFailed) try another one.
# Runs inside the delugevpn container; installed to /config/scripts/ (see README).

id="$1"; name="$2"; path="$3"
log=/config/scripts/exe-guard.log
bad='\.(exe|scr|com|bat|cmd|msi|ps1|vbs|vbe|js|jse|wsf|lnk|pif|jar|apk|dll|hta|sh)$'

hits=$(find "$path/$name" -type f 2>/dev/null | grep -iE "$bad")
[ -z "$hits" ] && exit 0

echo "$(date -Is) BLOCKED $name ($id)" >> "$log"
echo "$hits" | sed 's/^/    /' >> "$log"

# Detach so the plugin handler returns before the torrent is removed.
(
  sleep 5
  pw=$(grep -v '^#' /config/auth | grep -m1 '^localclient' | cut -d: -f2)
  deluge-console "connect 127.0.0.1:58846 localclient $pw; rm -c --remove_data $id" >> "$log" 2>&1
  echo "$(date -Is) removed $id" >> "$log"
) >/dev/null 2>&1 &
