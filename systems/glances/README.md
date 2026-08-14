# glances

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Lightweight system-monitoring agent (`nicolargo/glances`), deployed purely as a stats backend for [homarr](../homarr/README.md)'s Health Monitoring / System Resources widgets — real CPU, memory, and per-filesystem disk usage for the physical host, not just this container's own view of things.

- API: `http://<homelab-server-ip>:61208` (no auth — add a password via `GLANCES_OPT` if this ever needs to be reachable beyond the LAN)
- Web UI: `https://glances.thegarden` (via [traefik](../traefik/README.md), file provider since this is host-networked — see [traefik](../traefik/README.md)'s routing table)

## Config

`network_mode: host` and `pid: host` are both required for accurate host-level stats — without them Glances only sees its own container's cgroup-limited view (a handful of MB of RAM, one virtual NIC) rather than the real machine. `/:/rootfs:ro` is mounted read-only so disk-usage stats reflect the host's actual filesystems.

Doesn't mount the Docker socket — this only reports host hardware stats, not per-container resource usage. Add `/var/run/docker.sock:/var/run/docker.sock:ro` later if that's ever wanted too (same read-equivalent tradeoff [homarr](../homarr/README.md) already documents for its own docker integration).

## Homarr integration

Not IaC-able — lives in Homarr's own app state like its boards do (see [homarr](../homarr/README.md)'s README). One-time setup in the UI:

1. Management → Integrations → Add → Glances → URL `http://<homelab-server-ip>:61208` (no credentials)
2. Add the Health Monitoring (or System Resources) widget to a board, pick the Glances integration as its source
