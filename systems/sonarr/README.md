# sonarr

Status: Building

Host: [homelab-server](../homelab-server/README.md)

TV collection manager — watches for wanted episodes and hands them to `deluge`/`sabnzbd`.

- Web UI: `http://<homelab-server-ip>:38082`

## Data

- `data/` — Sonarr config (gitignored)

No media volume yet — a NAS is coming, and the mount will be added once its path is known.

`PUID`/`PGID` set to `1000`/`1000` to match the host user (`jamal`) — the config this was migrated from used `PGID=998`, which mapped to a stale group on the old host.
