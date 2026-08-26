# watchtower

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Checks every running container daily for a newer image and notifies via [ntfy](../ntfy/README.md) (`docker-updates` topic) rather than applying updates automatically. **`WATCHTOWER_MONITOR_ONLY=true`** by default — this repo's containers get updated deliberately (`docker compose pull && up -d` by hand), not silently overnight. Runs the actively-maintained `nicholas-fedor/watchtower` fork, not the original `containrrr/watchtower` — that project was archived December 2025, no more security patches.

No web UI, no host port — headless, mounts the Docker socket read-only to see what's running.

## Config

- Schedule: `0 0 9 * * *` (9am daily, cron syntax with a leading seconds field).
- Notification: `ntfy://ntfy/docker-updates?scheme=http` — talks to [ntfy](../ntfy/README.md) directly by container name over the `lab` network, not through Traefik/the public hostname. Confirmed working: a real startup message landed on the `docker-updates` topic on first deploy.

## Data

No `data/` — stateless, just polls image digests against what's currently running each time it wakes up.
