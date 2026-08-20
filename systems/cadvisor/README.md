# cadvisor

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Per-container resource metrics (CPU, memory, network) for [prometheus](../prometheus/README.md)/[grafana](../grafana/README.md). [node-exporter](../node-exporter/README.md) only reports host-wide totals — it has no concept of containers at all, so it can't answer "which container is responsible for this CPU spike." cAdvisor fills that gap, exposing per-container metrics the same way `docker stats` shows live, but as scrapeable time series.

No web UI exposed — read through Grafana's `homelab-server Overview` dashboard, not cAdvisor's own port.

## Reachability

On the `lab` network only, no host port published — [prometheus](../prometheus/README.md) reaches it by container name (`cadvisor:8080`), not via `localhost`.

## Resource tuning

By default cAdvisor monitors *every* cgroup on the host, not just Docker containers — every systemd service/slice too. On first deploy this meant tracking ~80 cgroups instead of the ~30 real containers, driving cAdvisor's own usage to 7%+ CPU and **1.1GiB memory** (heavier than most of what it was monitoring). Fixed with `--docker_only=true`: dropped to ~30 tracked containers, **4% CPU, ~88MiB memory**.

Even scoped to just containers, cAdvisor's `disk`/`diskIO` metric collectors do live `du`-style disk-usage scans per container on every housekeeping cycle (visible directly in its startup logs, 1-2+ seconds per container) — this was the actual source of periodic CPU bursts up to 15%+, not a steady baseline. **Disabled** via `--disable_metrics=...,disk,diskIO` (full flag includes cAdvisor's own default-disabled set too, since the flag replaces rather than appends) — decided not worth it for a homelab that doesn't need per-container disk I/O visibility. Dropped the burst ceiling from 15%+ down to a tighter 4.5-7.5% range. Trade-off: no per-container disk I/O metrics/panel exist anymore as a result — if that's ever needed later, re-enabling means removing `disk,diskIO` from the flag.

## Known limitation

OOM event detection is disabled (`Could not configure a source for OOM detection: open /dev/kmsg: operation not permitted`) — the mounted `/dev/kmsg` device isn't accessible without `privileged: true`, which wasn't added since basic per-container CPU/memory/network metrics (the actual goal here) don't need it. Not running privileged is the safer default.

## Data

No `data/` — cAdvisor reads live from `/rootfs`, `/var/run`, `/sys`, and the Docker daemon's own state (mounted read-only), nothing persisted of its own.
