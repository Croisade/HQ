# homarr

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Homepage dashboard with Docker integration (auto-discovers running containers) — the lab's dashboard.

- Web UI: `http://<homelab-server-ip>:7575`

## Config

`SECRET_ENCRYPTION_KEY` lives in `config/.env` (gitignored). `config/.env.example` documents the key.

**Docker socket is mounted read-write** (`/var/run/docker.sock`) for the "docker integration" feature — this gives the container root-equivalent control over the host's Docker daemon.

## Data

- `data/` — Homarr app data
