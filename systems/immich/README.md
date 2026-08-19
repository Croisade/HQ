# immich

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Self-hosted photo/video library — Google Photos replacement, with mobile app auto-backup, timeline view, and facial recognition/smart search. Chosen to close a gap flagged in an earlier session: a future NAS photo library needs real backup (unlike the redownloadable movies/TV library), and there was no photo management app in this lab to actually own that data.

- Web UI: `http://<homelab-server-ip>:2283` or `https://photos.thegarden` (via [traefik](../traefik/README.md))

## Architecture

Four containers: `immich-server` (API/web), `immich-machine-learning` (facial recognition, smart search — CPU-only here, no GPU passthrough configured on this host, same tradeoff [jellyfin](../jellyfin/README.md) already documents), `redis` (job queue), `postgres` (Immich's own image, `ghcr.io/immich-app/postgres`, bundles the vector-search extension it needs).

## Data

- `data/postgres` — the database, kept on local disk deliberately. Immich's own docs are explicit that network shares aren't supported for it, which lines up with this repo's existing rule for every other Postgres/SQLite-backed app (see [homelab-server's decisions.md](../homelab-server/decisions.md)).
- `/mnt/docker-data/media/photos` ([nas](../nas/README.md)) → `/data` — the actual photo/video library. Bulk media, same pool as the movies/TV/books libraries, so it's what [restic](../restic/README.md) needs to actually cover once photos land here for real — that's the whole reason this exists.

## Config

`DB_PASSWORD` lives in `config/.env` (gitignored, alphanumeric-only per Immich's own requirement). `config/.env.example` documents the keys.

## Migration from Google Photos

Not done yet — current library (~37.6GB) still lives in Google Photos. Needs a Google Takeout export, then Immich's bulk-import tooling to bring it in with original timestamps/metadata intact. Mobile app auto-backup (the actual Google Photos replacement behavior) is a separate one-time phone-side setup once the server's confirmed working.
