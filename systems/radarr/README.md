# radarr

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Movie collection manager — watches for wanted movies and hands them to `deluge`/`sabnzbd`.

- Web UI: `http://<homelab-server-ip>:38083`

## Data

- `data/` — Radarr config (gitignored)

No media volume yet — a NAS is coming, and the mount will be added once its path is known.

`PUID`/`PGID` set to `1000`/`1000` to match the host user (`jamal`) — the original config this was migrated from used `PGID=1000` already correct here, unlike some of the other services in this batch which used a stale `998`.
