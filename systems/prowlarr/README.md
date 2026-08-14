# prowlarr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Indexer manager (`linuxserver/prowlarr`) — holds indexer credentials in one place and syncs them out to every connected app, instead of configuring the same indexer separately in each. Chosen over [Jackett](https://github.com/Jackett/Jackett) specifically because this lab has three apps that could plausibly want the same torrent indexer (`radarr`, `sonarr`, `bindery`); Prowlarr auto-pushes to `radarr`/`sonarr` natively. Jackett has no such sync — every app needs its Torznab URL pasted in by hand.

- Web UI: `http://<homelab-server-ip>:38085` or `https://indexers.thegarden` (via [traefik](../traefik/README.md))

## Indexers

- **Nyaa.si** (`torrent`, category `Books`/`Literature`) — the actual reason this got deployed: [bindery](../bindery/README.md) needs a torrent source for Japanese light novels, and Nyaa is the standard index for that content, unlike generic public trackers. Prowlarr has a native definition for it — no Jackett/Cardigann layer needed.
  - **Nyaa is known to rate-limit/ban aggressive automated traffic.** Throttled via the indexer's own `Query Limit`/`Grab Limit` fields — 50 queries/day, 20 grabs/day — rather than left unlimited.
  - `radarr`'s and `sonarr`'s existing usenet indexers (NZBgeek, NZBNoob) were left as-is, configured directly in each app — not migrated into Prowlarr. Only Nyaa is Prowlarr-managed for now.

## Applications (sync targets)

- `radarr`, `sonarr` — added as native Prowlarr Applications (`fullSync`), so Nyaa (and anything else added to Prowlarr later) auto-propagates into their own indexer lists. `syncCategories` scoped to each app's actual content (movies for radarr, TV + the `TV/Anime` subcategory for sonarr) so Nyaa doesn't show up for categories that don't make sense there.
- `bindery` — **not** natively supported by Prowlarr (no Bindery application type exists yet). Wired manually instead: Prowlarr exposes a per-indexer Torznab feed at `http://prowlarr:9696/<indexerId>/api`, which was added directly as a `torznab`-type indexer inside Bindery's own Settings → Indexers. Functionally equivalent to what Prowlarr does for radarr/sonarr automatically — just a one-time manual step instead of an auto-sync, and it won't pick up additional indexers added to Prowlarr later without repeating this by hand.

## Data

- `data/` — Prowlarr config + its own SQLite DB (gitignored)

No download-client config here — Prowlarr only manages indexers/search, and hands releases off to whichever app requested them (which then talks to `sabnzbd`/`deluge` itself).
