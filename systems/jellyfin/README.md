# jellyfin

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Media server — plays the library that `radarr`/`sonarr`/`deluge`/`sabnzbd` build up. Chosen over Plex (open source, no account/telemetry requirement).

- Web UI: `http://<homelab-server-ip>:8096` or `https://media.thegarden` (via [traefik](../traefik/README.md))

No GPU passthrough configured yet — transcoding runs on CPU. Revisit if playback needs outpace this box.

Live TV planned via [hdhomerun](../hdhomerun/README.md) — not set up yet, see that system's `plan.md`.

## Data

- `data/config` — Jellyfin app config (gitignored)
- `data/cache` — transcode/image cache (gitignored) — kept local on NVMe rather than the NAS, since transcode cache is disposable and benefits from low-latency local disk
- `/mnt/docker-data/media` ([nas](../nas/README.md)) → `/media`, read-only — the library `radarr`/`sonarr` build up
