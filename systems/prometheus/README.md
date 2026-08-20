# prometheus

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Time-series metrics database — scrapes [node-exporter](../node-exporter/README.md) (and eventually a personal-PC exporter, see below) on a schedule and stores the history that [grafana](../grafana/README.md) actually visualizes. Grafana can't do anything without this; it's the data layer, not the dashboard.

- Web UI: `http://<homelab-server-ip>:9090` or `https://prometheus.thegarden` (via [traefik](../traefik/README.md)) — mostly for debugging scrape targets/running ad-hoc queries; day-to-day use is through Grafana, not here.

## Scrape targets

Defined in `config/prometheus.yml`:
- `homelab-server` — [node-exporter](../node-exporter/README.md) at `192.168.1.101:9100`
- `personal-pc` ("Pandora") — `windows_exporter` at `192.168.1.191:9182` (LAN IP, since Pandora is normally on this network — not a DHCP reservation yet, worth setting one on the [udm-se](../udm-se/README.md) so this doesn't drift. If Pandora ever roams off-LAN, switch this target to its [tailscale](../tailscale/README.md) IP, `100.107.65.7` as of 2026-08-19, instead).
- `personal-pc-gpu` — Pandora's AMD Radeon RX 9070 XT, at `192.168.1.191:9888`. `windows_exporter` has no GPU collector at all, so this runs through a separate tool, [HardwareExporterWindows](https://github.com/naughtyGitCat/HardwareExporterWindows), which reads LibreHardwareMonitor sensors via the PawnIO driver and exposes them natively as Prometheus metrics. Key metrics: `hardware_gpu_load_gpu_core` (utilization %), `hardware_gpu_temperature_gpu_core`, `hardware_gpu_power_gpu_package`, `hardware_gpu_load_gpu_memory`.
- **NAS — skipped for now.** TrueNAS has no native Prometheus support (Graphite only); would need either a `node_exporter` app installed through TrueNAS's own app catalog or a Graphite-to-Prometheus bridge, both of which require going through the TrueNAS UI directly, not something this repo can apply.

## Data

- `data/` — the actual metrics history (gitignored). **Owned by UID `65534` (`nobody`)**, not `jamal`/`1000` like everything else in this repo — the official image runs as that user and won't start if the mount isn't writable by it. Worth remembering if this ever gets recreated from a fresh directory.
