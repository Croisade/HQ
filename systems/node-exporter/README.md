# node-exporter

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Prometheus exporter (`quay.io/prometheus/node-exporter`) — exposes real host-level CPU/memory/disk/network metrics for [prometheus](../prometheus/README.md) to scrape. Same role as [glances](../glances/README.md) plays for Homarr, but speaking Prometheus's metrics format instead of Homarr's own integration API — the two coexist rather than one replacing the other, since they feed different dashboards.

- Metrics endpoint: `http://<homelab-server-ip>:9100/metrics` — no web UI, nothing to browse directly, no traefik route.

## Config

`network_mode: host` and `pid: host`, same reasoning as `glances`: without them this only sees its own container's cgroup-scoped view instead of the real host. `/:/rootfs:ro` (mounted at `/host` here) for real disk stats, with `--path.rootfs=/host` telling node-exporter where to find it.
