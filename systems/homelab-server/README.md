# homelab-server

Status: Operational

The physical machine everything in this lab runs on. No hypervisor — workloads run directly as Docker containers on the host OS.

## Networking

All workload containers join the shared `lab` bridge network (`scripts/create-network.sh`), so services can reach each other by container name and a reverse proxy can route to any of them without hardcoded IPs.

[traefik](../traefik/README.md) claims host port `80` and routes `*.thegarden` subdomains to services by container name, using Docker labels. [pihole](../pihole/README.md) is authoritative DNS for the `thegarden` domain (wildcard record → this host); the [udm-se](../udm-se/README.md) hands out Pi-hole as the LAN's DNS server via DHCP.

## Storage

The [nas](../nas/README.md) (`192.168.1.156`) provides two NFSv4 exports, mounted persistently via `/etc/fstab`:

- `/mnt/docker-data` (pool `Triple-Towers`) — bulk media library and other important files. `media/movies`, `media/tv` used by `radarr`/`sonarr`/`jellyfin`; `backups/restic` is the [restic](../restic/README.md) repository target.
- `/mnt/docker-scratch` (pool `Storage`) — temp/disposable data. `downloads/torrents`, `downloads/usenet` used by `deluge`/`sabnzbd` as download staging.

Both mounts are chowned to `jamal` (uid/gid `1000`) on the host, matching the `PUID`/`PGID=1000` every media-stack container runs as. Downloads and finished media live on separate NAS filesystems by design (temp/scratch vs. main), so `radarr`/`sonarr` import by copy+delete rather than hardlink — see [decisions.md](decisions.md).

Per-service `data/` stays on this host's local disk rather than the NAS — see [decisions.md](decisions.md).

## Workloads

- [home-assistant](../home-assistant/README.md) — host networking (bypasses `lab` for device discovery)
- [matter-server](../matter-server/README.md) — Matter controller for home-assistant, host networking
- [deluge](../deluge/README.md) — torrent client, routed through a VPN
- [sabnzbd](../sabnzbd/README.md) — usenet downloader
- [radarr](../radarr/README.md) — movie collection manager
- [sonarr](../sonarr/README.md) — TV collection manager
- [jellyseerr](../jellyseerr/README.md) — request management frontend
- [jellyfin](../jellyfin/README.md) — media server
- [pihole](../pihole/README.md) — DNS + ad blocking, authoritative for the `thegarden` domain
- [homarr](../homarr/README.md) — dashboard
- [mealie](../mealie/README.md) — recipe manager
- [actual-budget](../actual-budget/README.md) — budgeting app
- [palworld](../palworld/README.md) — Palworld dedicated game server
- [traefik](../traefik/README.md) — reverse proxy, routes `*.thegarden` to the above by container name
- [restic](../restic/README.md) — scheduled backups of every service's local `data/` to the NAS
- [glances](../glances/README.md) — host stats backend for homarr, host networking
- [bindery](../bindery/README.md) — book/light-novel collection manager
- [prowlarr](../prowlarr/README.md) — indexer manager, syncs to radarr/sonarr
- [tailscale](../tailscale/README.md) — mesh VPN for remote access, installed on the host directly (not containerized)
- [immich](../immich/README.md) — photo/video library, Google Photos replacement
- [uptime-kuma](../uptime-kuma/README.md) — service monitoring and downtime alerting
