# overseerr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Request management frontend — users request movies/shows here, Overseerr forwards to `radarr`/`sonarr`.

- Web UI: `http://<homelab-server-ip>:5055` or `http://requests.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — Overseerr config (gitignored)

`PUID`/`PGID` set to `1000`/`1000` to match the host user (`jamal`) — the config this was migrated from used `PGID=998`, which mapped to a stale group on the old host.
