# nas

Status: Operational

TrueNAS box, first physical hardware in the lab outside [homelab-server](../homelab-server/README.md). Provides NFSv4 exports consumed by several workloads there — see [hardware.md](hardware.md) for the pool layout.

- IP: `192.168.1.156`
- Web UI: `https://storage.thegarden` — the TrueNAS management UI itself, resolved via a plain [pihole](../pihole/README.md) local DNS record rather than a `thegarden`-wildcard/traefik route, since it's not a container this repo fronts — it serves its own UI directly on its own IP.
- Exports (NFSv4):
  - `/mnt/Triple-Towers/docker-data` — bulk media library and other important files. Mounted on `homelab-server` at `/mnt/docker-data`.
  - `/mnt/Storage/docker-scratch` — temp/disposable data (download staging). Mounted on `homelab-server` at `/mnt/docker-scratch`.

## Consumers

- [radarr](../radarr/README.md), [sonarr](../sonarr/README.md), [jellyfin](../jellyfin/README.md), [bindery](../bindery/README.md) — `docker-data/media`
- [deluge](../deluge/README.md), [sabnzbd](../sabnzbd/README.md) — `docker-scratch/downloads`
- [restic](../restic/README.md) — `docker-data/backups/restic` (backup repository target)

No shell access to this host from `homelab-server` — dataset/pool/share administration happens directly in the TrueNAS UI.
