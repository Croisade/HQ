# jellyfin

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Media server — plays the library that `radarr`/`sonarr`/`deluge`/`sabnzbd` build up. Chosen over Plex (open source, no account/telemetry requirement).

- Web UI: `http://<homelab-server-ip>:8096`

No GPU passthrough configured yet — transcoding runs on CPU. Revisit if playback needs outpace this box.

## Data

- `data/config` — Jellyfin app config (gitignored)
- `data/cache` — transcode/image cache (gitignored)

No media volume yet — a NAS is coming, and the mount will be added once its path is known. Jellyfin won't have anything to play until then.
