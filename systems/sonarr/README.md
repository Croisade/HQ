# sonarr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

TV collection manager — watches for wanted episodes and hands them to `deluge`/`sabnzbd`.

- Web UI: `http://<homelab-server-ip>:38082` or `http://tv.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — Sonarr config (gitignored)
- `/mnt/docker-data/media/tv` ([nas](../nas/README.md)) → `/tv` — finished library
- `/mnt/docker-scratch/downloads` ([nas](../nas/README.md)) → `/downloads` — sees both `deluge`'s and `sabnzbd`'s in-progress/completed downloads to import from

Downloads and media live on separate NAS datasets/filesystems (`docker-scratch` vs `docker-data`), so imports copy+delete rather than hardlink.

`PUID`/`PGID` set to `1000`/`1000` to match the host user (`jamal`) — the config this was migrated from used `PGID=998`, which mapped to a stale group on the old host.
