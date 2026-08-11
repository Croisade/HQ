# jellyseerr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Request management frontend — users request movies/shows here, Jellyseerr forwards to `radarr`/`sonarr`. Replaces [overseerr](../overseerr/README.md), which only supports Plex/Emby as the media server backend — this lab runs Jellyfin, and Jellyseerr is the Jellyfin-compatible fork of the same project.

- Web UI: `http://<homelab-server-ip>:5055` or `https://requests.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — Jellyseerr config (gitignored)

No `PUID`/`PGID` — the image doesn't support them (unlike the linuxserver-based images elsewhere in this repo); it just runs as its own baked-in user.
