# navidrome

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Self-hosted music server — Subsonic-API-compatible, serves the library [lidarr](../lidarr/README.md) downloads and organizes. Chosen over reusing [jellyfin](../jellyfin/README.md)'s music-library mode for a purpose-built music UX and the much broader Subsonic client ecosystem (Symfonium, Tempo, etc. — see below).

- Web UI (built-in player, browser only): `http://<homelab-server-ip>:38087` or `https://music.thegarden` (via [traefik](../traefik/README.md))
- Subsonic API (what actual client apps connect to): same URL, `/rest` path.

## Client app

**[Tempo](https://github.com/CappielloAntonio/tempo)** (Android, free/open-source) — picked over Symfonium (paid, broader multi-source support) to match this repo's FOSS lean elsewhere (bindery over a commercial reader, jellyfin over Plex). Has Android Auto support, which was the deciding requirement. Since it's just a Subsonic client talking to Navidrome over a standard API, it's swappable at any time without touching the server — Symfonium or any other Subsonic client would work identically if Tempo's maintenance ever lapses (153 open issues as of 2026-08-19, last tagged release `v3.9.0` Dec 31 2025 — active but worth rechecking periodically).

## Remote access — Tailscale HTTPS, not the mkcert `*.thegarden` route

Same class of problem [KOReader hit with bindery's OPDS catalog](../bindery/README.md): `*.thegarden` uses an internal mkcert CA that browsers trust but most Android apps don't (no user-CA trust, Android ≥API 24 default). Symfonium's self-signed-cert handling is confirmed inconsistent from current user reports; Tempo's was unverified. Rather than gamble on either, enabled Tailscale's HTTPS feature (admin console → DNS → HTTPS Certificates) and used `tailscale serve` to expose Navidrome under a genuine Let's Encrypt cert instead:

```
sudo tailscale serve --bg --https=8443 http://localhost:38087
```

Client URL: **`https://server.taild1dee8.ts.net:8443`**. Not port 443 — [traefik](../traefik/README.md)'s Docker port binding (`443:443`) claims `0.0.0.0:443`, which covers every interface on this host including the tailscale one, so `tailscaled` couldn't bind there. Verified via `curl`: real Let's Encrypt-issued cert (`issuer: C=US; O=Let's Encrypt; CN=YE2`), passes verification with no `-k` flag needed — works in Tempo/Symfonium/any client with zero cert configuration. Tailnet-only, same as everything else this lab exposes over Tailscale — not reachable from the open internet (that would need Tailscale Funnel instead of Serve, not used here).

## Library

Points at the same NAS folder [lidarr](../lidarr/README.md) downloads into — `/mnt/docker-data/media/music`, mounted read-only (Navidrome only ever reads the library; Lidarr is what writes to it). `ND_SCANSCHEDULE=1h` rescans hourly to pick up new Lidarr imports automatically.

## Playlists

YouTube Music playlist import (via Soundiiz or similar) was considered and explicitly skipped — decided to rebuild playlists manually instead, since transferring a playlist's track *list* doesn't help until every track is actually downloaded into the library first (Navidrome can only play files that exist locally; `ND_AUTOIMPORTPLAYLISTS` picks up `.m3u` files placed in the library, but only usefully once the underlying audio is there).

## One-off tracks (YouTube-only, no real release)

`scripts/download-song.sh <youtube-url>` — for a song that only exists on YouTube (no MusicBrainz release, so [lidarr](../lidarr/README.md) has nothing to search for: a remix, live version, unofficial upload, etc). Runs `yt-dlp` via a one-off container (`jauderho/yt-dlp`, bundles `ffmpeg`) rather than installing it on the host, matching this repo's convention of containerizing tools rather than polluting the host OS — same reasoning as [restic](../restic/README.md) for a CLI-only tool. Extracts audio as MP3, embeds thumbnail/metadata, saves into `/mnt/docker-data/media/music/YouTube/` (kept in its own subfolder, separate from Lidarr's artist/album structure) — picked up automatically on Navidrome's next hourly scan. Runs as `1000:1000` so file ownership matches everything else in the library; the image defaults to root otherwise.

Also accepts a **playlist URL** — yt-dlp downloads every item by default, no separate flag needed. Playlist tracks land in their own subfolder (named after the playlist, numbered by track order); a single video lands directly in `YouTube/`.

Manual/one-off by design — no automation, since there's no indexer or metadata to hook a scheduled job into.

## Data

- `data/` — Navidrome's own SQLite DB, cache, config (gitignored). Runs as `1000:1000` (`jamal`) via the compose `user:` directive — the official image doesn't support `PUID`/`PGID` env vars the way linuxserver images do, unlike most of this repo's containers.

## Not done yet

- First-run admin account creation (UI-only step).
- Install Tempo on the phone and connect it to `https://server.taild1dee8.ts.net:8443`.
- Library is currently empty — depends on [lidarr](../lidarr/README.md) actually downloading music first.
