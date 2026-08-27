# watchtower

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Checks every running container daily for a newer image and notifies via [ntfy](../ntfy/README.md) (`docker-updates` topic) rather than applying updates automatically. **`WATCHTOWER_MONITOR_ONLY=true`** by default — this repo's containers get updated deliberately (`docker compose pull && up -d` by hand), not silently overnight. Runs the actively-maintained `nicholas-fedor/watchtower` fork, not the original `containrrr/watchtower` — that project was archived December 2025, no more security patches.

No web UI, no host port — headless, mounts the Docker socket read-only to see what's running.

## Config

- Schedule: `0 0 9 * * *` (9am daily, cron syntax with a leading seconds field).
- Notification: `ntfy://ntfy/docker-updates?scheme=http` — talks to [ntfy](../ntfy/README.md) directly by container name over the `lab` network, not through Traefik/the public hostname.
- **Notification content**: `WATCHTOWER_NOTIFICATION_REPORT=true` + a custom template listing each container's actual name and image, not the generic "Found new image" the plain log-based template produces. Real gotcha hit building this: the report template context is `.Report.Stale` for monitor-only setups, **not** `.Report.Updated` — `Updated` only ever populates for containers actually updated in-place, which never happens here since updates are applied by hand. Verified with a one-off `docker run --rm ... -e WATCHTOWER_RUN_ONCE=true` test before touching the real service; a harmless `nil pointer evaluating types.Report.Stale` error appears in logs on every container start (an early notification attempt fires before any scan data exists) but doesn't actually send anything — confirmed via the real topic staying empty until the actual scheduled scan completes.

Full template: `{{if .Report.Stale}}Updates available:{{range .Report.Stale}}{{println}}- {{.Name}} ({{.ImageName}}){{end}}{{else}}All containers up to date{{end}}`

## Data

No `data/` — stateless, just polls image digests against what's currently running each time it wakes up.
