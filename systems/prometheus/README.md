# prometheus

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Time-series metrics database — scrapes [node-exporter](../node-exporter/README.md) (and eventually a personal-PC exporter, see below) on a schedule and stores the history that [grafana](../grafana/README.md) actually visualizes. Grafana can't do anything without this; it's the data layer, not the dashboard.

- Web UI: `http://<homelab-server-ip>:9090` or `https://prometheus.thegarden` (via [traefik](../traefik/README.md)) — mostly for debugging scrape targets/running ad-hoc queries; day-to-day use is through Grafana, not here.

## Scrape targets

Defined in `config/prometheus.yml`:
- `homelab-server` — [node-exporter](../node-exporter/README.md) at `192.168.1.101:9100`
- **Personal PC — not wired up yet.** Needs `windows_exporter` installed and running on that machine first (outside this repo's reach entirely, has to happen on that machine directly), then uncommenting the target in `prometheus.yml` pointed at either its LAN IP or its [tailscale](../tailscale/README.md) IP.
- **NAS — skipped for now.** TrueNAS has no native Prometheus support (Graphite only); would need either a `node_exporter` app installed through TrueNAS's own app catalog or a Graphite-to-Prometheus bridge, both of which require going through the TrueNAS UI directly, not something this repo can apply.

## Data

- `data/` — the actual metrics history (gitignored). **Owned by UID `65534` (`nobody`)**, not `jamal`/`1000` like everything else in this repo — the official image runs as that user and won't start if the mount isn't writable by it. Worth remembering if this ever gets recreated from a fresh directory.
