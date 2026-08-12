# jellyseerr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Request management frontend — users request movies/shows here, forwards to `radarr`/`sonarr`. Originally deployed as Jellyseerr (replacing [overseerr](../overseerr/README.md), which only supports Plex/Emby as the media server backend); Jellyseerr itself merged into a unified successor project called **Seerr** in February 2026, so this now runs the `ghcr.io/seerr-team/seerr` image. Kept the system folder/container name (`jellyseerr`) rather than renaming — same underlying software, same role, migration was a drop-in image swap with automatic, fully-compatible data migration.

- Web UI: `http://<homelab-server-ip>:5055` or `https://requests.thegarden` (via [traefik](../traefik/README.md))

## Config

**Metadata source set to TVDB for TV/anime** (`Settings → Metadata` in the UI, or `PUT /api/v1/settings/metadata` with `{"tv": "tvdb", "anime": "tvdb"}`), matching what [sonarr](../sonarr/README.md) itself uses. This was the actual reason for migrating off Jellyseerr — by default it sources TV season data from TMDB, which frequently disagrees with TheTVDB's season/episode grouping for long-running anime (e.g. TVDB splits Bleach into 17 arc-based seasons; TMDB just has 2). Requesting "season 2" through Jellyseerr could silently hand Sonarr a request for completely different content than intended, since the season *number* meant something different on each side with no error or warning. Jellyseerr (frozen at v2.7.3) never got this fix — only Seerr has it.

## Data

- `data/` — config (gitignored). Owned by `1000:1000` — the new image runs as the `node` user rather than root (the previous Jellyseerr image's default), so ownership had to be fixed as part of the migration.

No `PUID`/`PGID` — the image doesn't support them (unlike the linuxserver-based images elsewhere in this repo).
