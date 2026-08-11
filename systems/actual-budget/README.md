# actual-budget

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Self-hosted budgeting app (envelope budgeting, YNAB-style).

- Web UI: `http://<homelab-server-ip>:5006` or `http://budget.thegarden` (via [traefik](../traefik/README.md))

Server password is set on first launch via the web UI, not an env var.

Unlike every other service in this repo, the official image doesn't support `PUID`/`PGID` — no equivalent env vars are documented, so ownership of `data/` follows whatever the container's default user is.

## Data

- `data/` — Actual server data (gitignored)
