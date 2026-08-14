# bindery

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Book/light-novel collection manager — monitors authors/series, searches indexers, and hands wanted downloads to `sabnzbd`/`deluge`. Replaces [Readarr](https://wiki.servarr.com/readarr), which was officially retired in 2026 after its metadata source became unusable.

- Web UI: `http://<homelab-server-ip>:38084` or `https://books.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — Bindery config + SQLite DB (gitignored)
- `/mnt/docker-data/media/books` ([nas](../nas/README.md)) → `/books` — finished library
- `/mnt/docker-scratch/downloads` (parent dir, [nas](../nas/README.md)) → `/downloads` — same mount point [radarr](../radarr/README.md)/[sonarr](../sonarr/README.md) use, so it sees both `sabnzbd`'s (`/downloads/usenet`) and `deluge`'s (`/downloads/torrents`) completed downloads to import from

Unlike the `linuxserver/*` images used elsewhere in this lab, Bindery's official image is built on a distroless base and can't switch user at runtime — `user: "1000:1000"` is set directly in the compose file instead of the usual `PUID`/`PGID` env vars alone. `BINDERY_PUID`/`BINDERY_PGID` are still set, but only as a startup sanity check against the actual container user, not a switcher; a mismatch fails fast instead of silently writing as the wrong user.

**Path mapping**: `sabnzbd` and `deluge` each only mount their own subfolder (`/downloads` and `/data` respectively — see their own READMEs), so a completed-download path reported by either client's API is relative to *that* client's own filesystem view, not Bindery's shared `/downloads` mount. `BINDERY_DOWNLOAD_PATH_REMAP=/downloads:/downloads/usenet,/data:/downloads/torrents` rewrites those paths to Bindery's view — the same translation `radarr`'s `RemotePathMappings` table does for the same reason (verified against its actual mapping rows: `/downloads`→`/downloads/usenet`, `/data`→`/downloads/torrents`).

Both download clients are wired up and connection-tested via Bindery's API:
- `sabnzbd` — category `books`, added to `sabnzbd`'s config alongside its existing `movies`/`tv`/`audio`/`software` categories. `sabnzbd`'s `host_whitelist` needed the `sabnzbd` container hostname added — it only allowed its own container ID and `usenet.thegarden` before.
- `deluge` — labels `books`/`audiobooks` added to Deluge's Label plugin, which only had `movies`/`tv` before (same missing-category problem as `sabnzbd`, different mechanism — Deluge tags via labels, not a `dir`-per-category setting).

**Indexers**: one usenet indexer is left for the user to add directly in Settings → Indexers, deliberately not pulled from `radarr`/`sonarr`'s existing indexer credentials. For torrents, see [prowlarr](../prowlarr/README.md) — it manages Nyaa.si (the actual torrent source for Japanese light novels) and Bindery consumes it via Prowlarr's per-indexer Torznab feed, added manually as a `torznab`-type indexer here since Prowlarr has no native Bindery application type to auto-sync it.

Metadata coverage for Japanese light novels is the open question this deployment exists to test — worth a `notes.md` entry once there's been a real search/import to judge it by.
