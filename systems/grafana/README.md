# grafana

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Dashboards and alerting on top of [prometheus](../prometheus/README.md)'s metrics — the actual visualization layer for `homelab-server`'s (and eventually the NAS's and a personal PC's) resource usage.

- Web UI: `http://<homelab-server-ip>:3000` or `https://grafana.thegarden` (via [traefik](../traefik/README.md))

## Config

`GF_SECURITY_ADMIN_PASSWORD` lives in `config/.env` (gitignored, only takes effect on first launch — changing it later requires resetting through the UI instead). `config/.env.example` documents the key.

**Datasource is provisioned as actual IaC**, not UI-only app state like almost everything else this repo has had to hand-edit — `config/provisioning/datasources/prometheus.yml` points Grafana at `http://prometheus:9090` (container name, same `lab` network) automatically on startup. Confirmed working: `GET /api/datasources` shows it registered with no manual UI step needed.

## Data

- `data/` — dashboards, users, alerting config (gitignored). **Owned by UID `472` (`grafana`)**, not `jamal`/`1000` — same class of gotcha as `prometheus`'s `nobody`-owned data dir; the official image runs as that user and won't start otherwise.

## Not done yet

- Dashboards themselves — none built yet, just the empty shell with a working datasource.
- Alerting → push notifications: the plan is Grafana's built-in alerting → a webhook → [home-assistant](../home-assistant/README.md)'s existing `script.notify_and_log`, reusing the phone delivery path already built rather than a separate notification channel. Not wired up yet.
- Personal PC and NAS metrics — see [prometheus](../prometheus/README.md)'s README for what's blocking each.
