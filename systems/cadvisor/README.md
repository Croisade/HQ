# cadvisor

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Per-container resource metrics (CPU, memory, disk I/O, network) for [prometheus](../prometheus/README.md)/[grafana](../grafana/README.md). [node-exporter](../node-exporter/README.md) only reports host-wide totals — it has no concept of containers at all, so it can't answer "which container is responsible for this CPU spike." cAdvisor fills that gap, exposing per-container metrics the same way `docker stats` shows live, but as scrapeable time series.

No web UI exposed — read through Grafana's `homelab-server Overview` dashboard, not cAdvisor's own port.

## Reachability

On the `lab` network only, no host port published — [prometheus](../prometheus/README.md) reaches it by container name (`cadvisor:8080`), not via `localhost`.

## Known limitation

OOM event detection is disabled (`Could not configure a source for OOM detection: open /dev/kmsg: operation not permitted`) — the mounted `/dev/kmsg` device isn't accessible without `privileged: true`, which wasn't added since basic per-container CPU/memory/network metrics (the actual goal here) don't need it. Not running privileged is the safer default.

## Data

No `data/` — cAdvisor reads live from `/rootfs`, `/var/run`, `/sys`, and the Docker daemon's own state (mounted read-only), nothing persisted of its own.
