# sonarr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

TV collection manager — watches for wanted episodes and hands them to `deluge`/`sabnzbd`.

- Web UI: `http://<homelab-server-ip>:38082` or `https://tv.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — Sonarr config (gitignored)
- `/mnt/docker-data/media/tv` ([nas](../nas/README.md)) → `/tv` — finished library
- `/mnt/docker-scratch/downloads` ([nas](../nas/README.md)) → `/downloads` — sees both `deluge`'s and `sabnzbd`'s in-progress/completed downloads to import from

Downloads and media live on separate NAS datasets/filesystems (`docker-scratch` vs `docker-data`), so imports copy+delete rather than hardlink.

`PUID`/`PGID` set to `1000`/`1000` to match the host user (`jamal`) — the config this was migrated from used `PGID=998`, which mapped to a stale group on the old host.

## Config

`renameEpisodes` is enabled (Settings → Media Management), so every import gets renamed to `{Series Title} - S{season}E{episode} - {Episode Title} {Quality Full}` instead of keeping the raw scene/release-group filename. Turned on after a real episode (an Erai-raws release with no `SxxExx` pattern in its filename at all) still parsed correctly but highlighted the risk — consistent naming at import time means Sonarr's own confirmed episode identification gets baked into the filename, rather than leaving it to [jellyfin](../jellyfin/README.md)'s scanner to re-derive from an arbitrary release name later.

Note: this only renames at **import** time. Sonarr's bulk "Rename Series" command (a manual one-off maintenance action, not part of the normal per-import flow) does *not* trigger the Jellyfin library-update notification the way a normal import does — if you ever bulk-rename existing files by hand, trigger a manual refresh on the affected series in Jellyfin afterward (`POST /Items/{id}/Refresh?Recursive=true&MetadataRefreshMode=FullRefresh`) since it won't happen automatically.
