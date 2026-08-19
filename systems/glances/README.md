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

Not IaC-able — lives in Homarr's own app state like its boards do (see [homarr](../homarr/README.md)'s README) — but done directly via a DB write rather than the UI, same pattern as everything else touching that database this session. A "Glances" app tile, a `glances`-kind integration (`secretKinds: [[]]` per Homarr's own integration definitions — no credentials needed, confirmed against source), and a Health Monitoring widget bound to it were all inserted directly.

**Integration URL is the host's LAN IP (`http://192.168.1.101:61208`), not a container name or the `glances.thegarden` traefik route** — Glances uses `network_mode: host`, which bypasses the `lab` bridge network entirely, so Homarr (on `lab`) can't resolve it by container name the way it does every other integration. Same reason `assistant.thegarden` and `books.thegarden`'s remap use the raw IP elsewhere in this repo.

Deliberately a second, separate Health Monitoring widget rather than repointing the existing one — the board already had a Health Monitoring/System Resources pair bound to the **TrueNAS** integration (from before this deployment), which was showing the NAS's stats under a widget that looked like it should've been the host's. Both now coexist: NAS stats via TrueNAS, host stats via this new Glances-backed one.
