# sabnzbd

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Usenet downloader — alternate download client alongside `deluge`, feeding `radarr`/`sonarr`.

- Web UI: `http://<homelab-server-ip>:38080` or `http://usenet.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — SABnzbd config (gitignored)
- `/mnt/docker-scratch/downloads/usenet` ([nas](../nas/README.md)) → `/downloads` — download staging

`PUID`/`PGID` set to `1000`/`1000` to match the host user (`jamal`) — the config this was migrated from used `PGID=998`, which mapped to a stale group on the old host.
