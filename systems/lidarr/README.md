# lidarr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Music collection manager — watches for wanted albums and hands them to `deluge`/`sabnzbd`. Same role as [sonarr](../sonarr/README.md)/[radarr](../radarr/README.md), for music.

- Web UI: `http://<homelab-server-ip>:38086` or `https://lidarr.thegarden` (via [traefik](../traefik/README.md))

## Indexers

Synced from [prowlarr](../prowlarr/README.md), same as every other `*arr` app — **not** configured directly in Lidarr. Currently two usenet indexers (NZBgeek, NZBNoob) provide real music coverage; [prowlarr](../prowlarr/README.md)'s Nyaa.si torrent indexer is also synced (anime-focused, category `3000`/Audio exists in its capability list but is consistently empty in practice — not a useful music source, left enabled since it's harmless).

NZBgeek and NZBNoob used to be configured **directly in Sonarr and Radarr**, bypassing Prowlarr entirely — a real gap, since it meant Prowlarr's centralized indexer management didn't actually cover every indexer in use. Fixed as part of deploying Lidarr: both are now registered in Prowlarr proper and synced out to Sonarr, Radarr, and Lidarr from one place, so an API key rotation only needs to happen once going forward.

## Download clients

Deluge and SABnzbd, same connection details Sonarr/Radarr already use. Both use the `audio` category (SABnzbd already had this category predefined; Deluge auto-creates the equivalent label).

## Data

- `data/` — Lidarr config (gitignored)
- `/mnt/docker-data/media/music` ([nas](../nas/README.md)) → `/music` — finished library, also what [navidrome](../navidrome/README.md) serves from
- `/mnt/docker-scratch/downloads` ([nas](../nas/README.md)) → `/downloads` — same shared staging area Sonarr/Radarr/SABnzbd/Deluge use

`PUID`/`PGID` set to `1000`/`1000`, matching every other media-stack container.
