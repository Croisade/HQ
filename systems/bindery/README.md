# bindery

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Book/light-novel collection manager — monitors authors/series, searches indexers, and hands wanted downloads to `sabnzbd`. Replaces [Readarr](https://wiki.servarr.com/readarr), which was officially retired in 2026 after its metadata source became unusable; Bindery is purpose-built as its usenet-native successor.

- Web UI: `http://<homelab-server-ip>:38084` or `https://books.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — Bindery config + SQLite DB (gitignored)
- `/mnt/docker-data/media/books` ([nas](../nas/README.md)) → `/books` — finished library
- `/mnt/docker-scratch/downloads` (parent dir, [nas](../nas/README.md)) → `/downloads` — same mount point [radarr](../radarr/README.md)/[sonarr](../sonarr/README.md) use, so it sees both `sabnzbd`'s (`/downloads/usenet`) and `deluge`'s (`/downloads/torrents`) completed downloads to import from

Unlike the `linuxserver/*` images used elsewhere in this lab, Bindery's official image is built on a distroless base and can't switch user at runtime — `user: "1000:1000"` is set directly in the compose file instead of the usual `PUID`/`PGID` env vars alone. `BINDERY_PUID`/`BINDERY_PGID` are still set, but only as a startup sanity check against the actual container user, not a switcher; a mismatch fails fast instead of silently writing as the wrong user.

**Path mapping**: `sabnzbd` and `deluge` each only mount their own subfolder (`/downloads` and `/data` respectively — see their own READMEs), so a completed-download path reported by either client's API is relative to *that* client's own filesystem view, not Bindery's shared `/downloads` mount. `BINDERY_DOWNLOAD_PATH_REMAP=/downloads:/downloads/usenet,/data:/downloads/torrents` rewrites those paths to Bindery's view — the same translation `radarr`'s `RemotePathMappings` table does for the same reason (verified against its actual mapping rows: `/downloads`→`/downloads/usenet`, `/data`→`/downloads/torrents`).

`sabnzbd` is wired up as a download client (category `books`, added to `sabnzbd`'s config alongside its existing `movies`/`tv`/`audio`/`software` categories) and connection-tested successfully via Bindery's API. `sabnzbd`'s `host_whitelist` needed the `sabnzbd` container hostname added — it only allowed its own container ID and `usenet.thegarden` before. `deluge` is not yet added as a download client (no torrent indexers configured yet) — the path remap above is already in place for whenever it is.

Indexer setup happens in the web UI (Settings → Indexers) — deliberately left to the user rather than pulled from `radarr`/`sonarr`'s existing indexer credentials.

Metadata coverage for Japanese light novels is the open question this deployment exists to test — worth a `notes.md` entry once there's been a real search/import to judge it by.
