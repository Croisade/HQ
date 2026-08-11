# mealie

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Recipe manager / meal planner.

- Web UI: `http://<homelab-server-ip>:9925` or `http://recipes.thegarden` (via [traefik](../traefik/README.md))

Signup is disabled (`ALLOW_SIGNUP=false`) — create the first account before that lands, or flip it temporarily.

## Data

- `data/` — Mealie app data (gitignored)

`PGID` set to `1000` to match the host user (`jamal`) — the config this was migrated from used `PGID=998`, which mapped to a stale group on the old host.
