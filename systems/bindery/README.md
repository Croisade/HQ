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

**Indexers**: two usenet indexers (NZBGeek, NZBNoob) added directly by the user in Settings → Indexers, deliberately not pulled from `radarr`/`sonarr`'s existing indexer credentials. For torrents, see [prowlarr](../prowlarr/README.md) — Bindery has a real, dedicated Prowlarr integration (Settings → Prowlarr, not just a generic Torznab entry) that connects to a Prowlarr instance and syncs its indexers in. Registered at `http://prowlarr:9696`.

**Known bug in the Prowlarr sync**: it assigns Nyaa.si the standard Torznab ebook/audiobook subcategory IDs (`7020`, `3030`) regardless of what Nyaa's own indexer definition actually exposes (only the parent `7000` "Books" — verified directly against Prowlarr's Torznab caps XML for this indexer, no `7020`/`3030` subcategories exist there). Querying with only `7020`/`3030` silently returns zero results. Fixed by adding `7000` to the indexer's categories in Bindery — but **the sync overwrites `categories` back to its buggy default on every run** (confirmed in `internal/prowlarr/syncer.go`: category diffs are intentionally always re-applied from Prowlarr's reported state). `syncOnStartup` is set to `false` specifically to stop this from silently reverting the fix on every container restart — re-running Settings → Prowlarr → Sync manually will undo it and require re-adding `7000` to categories afterward.

Metadata coverage for Japanese light novels is the open question this deployment exists to test — worth a `notes.md` entry once there's been a real search/import to judge it by.
