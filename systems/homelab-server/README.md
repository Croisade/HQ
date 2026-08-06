# homelab-server

Status: Operational

The physical machine everything in this lab runs on. No hypervisor — workloads run directly as Docker containers on the host OS.

## Networking

All workload containers join the shared `lab` bridge network (`scripts/create-network.sh`), so services can reach each other by container name and a future reverse proxy can route to any of them without hardcoded IPs.

## Storage

No shared media library yet — a NAS is coming. Media-related services (`deluge`, `radarr`, `sonarr`, `sabnzbd`, `jellyfin`) don't have a media volume mounted until it arrives.

## Workloads

- [home-assistant](../home-assistant/README.md) — host networking (bypasses `lab` for device discovery)
- [matter-server](../matter-server/README.md) — Matter controller for home-assistant, host networking
- [deluge](../deluge/README.md) — torrent client, routed through a VPN
- [sabnzbd](../sabnzbd/README.md) — usenet downloader
- [radarr](../radarr/README.md) — movie collection manager
- [sonarr](../sonarr/README.md) — TV collection manager
- [overseerr](../overseerr/README.md) — request management frontend
- [jellyfin](../jellyfin/README.md) — media server
- [pihole](../pihole/README.md) — DNS + ad blocking (claims host port 80 — will conflict with a future reverse proxy)
- [homarr](../homarr/README.md) — dashboard
- [mealie](../mealie/README.md) — recipe manager
