# homarr

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Homepage dashboard with Docker integration (auto-discovers running containers) — the lab's dashboard.

- Web UI: `http://<homelab-server-ip>:7575` or `https://home.thegarden` (via [traefik](../traefik/README.md))

## Config

`SECRET_ENCRYPTION_KEY` lives in `config/.env` (gitignored). `config/.env.example` documents the key.

**Docker socket is mounted read-write** (`/var/run/docker.sock`) for the "docker integration" feature — this gives the container root-equivalent control over the host's Docker daemon.

**Two boards, split by screen size**: `dashboard` (default, full desktop layout) and `mobile` (trimmed layout). Both must be public — required for the mobile board to work as a fallback — and set under `Management → Settings → Boards`: `dashboard` as the default board, `mobile` as the mobile home board. Homarr picks between them by User-Agent automatically. A per-user "home board" preference (Settings → Your preferences) overrides this global choice for that user, so if a logged-in user sees the wrong board on desktop, check there first. This all lives in Homarr's own app state (`data/db/db.sqlite`, gitignored) — there's no compose/env equivalent, so it isn't reflected anywhere else in this repo.

## Data

- `data/` — Homarr app data
