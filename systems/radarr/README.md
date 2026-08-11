# radarr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Movie collection manager — watches for wanted movies and hands them to `deluge`/`sabnzbd`.

- Web UI: `http://<homelab-server-ip>:38083` or `https://movies.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — Radarr config (gitignored)
- `/mnt/docker-data/media/movies` ([nas](../nas/README.md)) → `/movies` — finished library
- `/mnt/docker-scratch/downloads` ([nas](../nas/README.md)) → `/downloads` — sees both `deluge`'s and `sabnzbd`'s in-progress/completed downloads to import from

Downloads and media live on separate NAS datasets/filesystems (`docker-scratch` vs `docker-data`), so imports copy+delete rather than hardlink.

`PUID`/`PGID` set to `1000`/`1000` to match the host user (`jamal`) — the original config this was migrated from used `PGID=1000` already correct here, unlike some of the other services in this batch which used a stale `998`.
