# grafana

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Dashboards and alerting on top of [prometheus](../prometheus/README.md)'s metrics — the actual visualization layer for `homelab-server`'s (and eventually the NAS's and a personal PC's) resource usage.

- Web UI: `http://<homelab-server-ip>:3000` or `https://grafana.thegarden` (via [traefik](../traefik/README.md))

## Config

`GF_SECURITY_ADMIN_PASSWORD` lives in `config/.env` (gitignored, only takes effect on first launch — changing it later requires resetting through the UI instead). `config/.env.example` documents the key.

**Datasource and dashboard are both provisioned as actual IaC**, not UI-only app state like almost everything else this repo has had to hand-edit — `config/provisioning/datasources/prometheus.yml` points Grafana at `http://prometheus:9090` (container name, same `lab` network) automatically on startup, and `config/provisioning/dashboards/homelab-server.json` loads the `homelab-server Overview` dashboard the same way (provider config at `config/provisioning/dashboards/dashboards.yml`). Both confirmed working via `GET /api/datasources`/`GET /api/search` with no manual UI step needed.

## Dashboards

**`homelab-server Overview`** — host CPU/memory/load ([node-exporter](../node-exporter/README.md)), per-container CPU/memory top-10 ([cadvisor](../cadvisor/README.md) — this is the panel that actually answers "which container is responsible," which host-level metrics alone can't), and NAS disk free space for both mounts. Built after a real incident this session: a misconfigured [beets](../beets/README.md) container crash-looped at 170-350% CPU for a while before it was noticed via a manual `docker stats` check — this dashboard exists specifically so that's visible without having to think to go looking.

## Data

- `data/` — dashboards, users, alerting config (gitignored). **Owned by UID `472` (`grafana`)**, not `jamal`/`1000` — same class of gotcha as `prometheus`'s `nobody`-owned data dir; the official image runs as that user and won't start otherwise.

## Not done yet

- Alerting → push notifications: the plan is Grafana's built-in alerting → a webhook → [home-assistant](../home-assistant/README.md)'s existing `script.notify_and_log`, reusing the phone delivery path already built rather than a separate notification channel. Not wired up yet — would have caught the beets crash-loop automatically instead of needing a manual check.
- NAS metrics — see [prometheus](../prometheus/README.md)'s README for what's blocking it.
