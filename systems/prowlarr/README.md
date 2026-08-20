# prowlarr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Indexer manager (`linuxserver/prowlarr`) — holds indexer credentials in one place and syncs them out to every connected app, instead of configuring the same indexer separately in each. Chosen over [Jackett](https://github.com/Jackett/Jackett) specifically because this lab has three apps that could plausibly want the same torrent indexer (`radarr`, `sonarr`, `bindery`); Prowlarr auto-pushes to `radarr`/`sonarr` natively. Jackett has no such sync — every app needs its Torznab URL pasted in by hand.

- Web UI: `http://<homelab-server-ip>:38085` or `https://indexers.thegarden` (via [traefik](../traefik/README.md))

## Indexers

- **Nyaa.si** (`torrent`, category `Books`/`Literature`) — the actual reason this got deployed: [bindery](../bindery/README.md) needs a torrent source for Japanese light novels, and Nyaa is the standard index for that content, unlike generic public trackers. Prowlarr has a native definition for it — no Jackett/Cardigann layer needed.
  - **Nyaa is known to rate-limit/ban aggressive automated traffic.** Throttled via the indexer's own `Query Limit`/`Grab Limit` fields — originally 50 queries/day, 20 grabs/day; raised to 150 queries/day after heavy same-day API testing exhausted the original limit and started blocking real indexer-add validation calls from `sonarr`/`radarr`/`lidarr`.
  - Nyaa's `Audio` category (`3000`) exists in its capability list but returns zero results in practice — it's an anime torrent site, not a real music source. Left enabled since it's harmless, but don't expect it to actually serve `lidarr`.
- **NZBgeek**, **NZBNoob** (`usenet`) — originally configured **directly in `radarr` and `sonarr`**, bypassing Prowlarr entirely — a real gap in the "one place for indexer credentials" goal this service exists for. Migrated into Prowlarr proper when [lidarr](../lidarr/README.md) was deployed and needed the same two indexers; the direct duplicates were deleted from `radarr`/`sonarr` afterward so all three apps now get them from one synced source.

## Applications (sync targets)

- `radarr`, `sonarr`, `lidarr` — added as native Prowlarr Applications (`fullSync`), so every indexer above auto-propagates into their own indexer lists. `syncCategories` scoped to each app's actual content (movies for radarr, TV + `TV/Anime` for sonarr, `Audio` + subcategories for lidarr) so an indexer doesn't show up for categories that don't make sense there.
- `bindery` — **not** natively supported by Prowlarr (no Bindery application type exists yet). Wired manually instead: Prowlarr exposes a per-indexer Torznab feed at `http://prowlarr:9696/<indexerId>/api`, which was added directly as a `torznab`-type indexer inside Bindery's own Settings → Indexers. Functionally equivalent to what Prowlarr does for radarr/sonarr/lidarr automatically — just a one-time manual step instead of an auto-sync, and it won't pick up additional indexers added to Prowlarr later without repeating this by hand.

## Data

- `data/` — Prowlarr config + its own SQLite DB (gitignored)

No download-client config here — Prowlarr only manages indexers/search, and hands releases off to whichever app requested them (which then talks to `sabnzbd`/`deluge` itself).
