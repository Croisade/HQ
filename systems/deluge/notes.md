# Notes — deluge

## 2026-08-11

Deployed alongside the rest of the media stack once the NAS mounts landed. Took three blockers to get to a working state:

1. Missing PIA `.ovpn` config file in `data/config/openvpn/` — resolved, file dropped in.
2. Host kernel (`7.0.0-29-generic`) was missing the `ip_tables` module, so the container's VPN killswitch (`iptables`) couldn't initialize: `modprobe: FATAL: Module ip_tables not found`. Fixed with `sudo modprobe ip_tables` on the host — the module ships in `/lib/modules/<release>/kernel/net/ipv4/netfilter/`, it just wasn't loaded because the host's `iptables` defaults to the `nf_tables` backend and nothing else had needed it yet. Kernel modules are shared host-wide, so this only needed doing once on `homelab-server`, not inside the container.
3. Started with a New York server (`us_new_york_city-*.ovpn`), which connected fine but then looped forever re-checking port forwarding every 30s and never started Deluge. Root cause: `STRICT_PORT_FORWARD=yes` combined with PIA no longer supporting port forwarding on *any* US endpoint — confirmed via the container's own log, which dumps PIA's full list of port-forward-capable endpoints (all non-US). Switched to `ca_toronto-*.ovpn` (closest supported region to home, alongside Montreal) — connected and started normally within about 90 seconds, matching the connection-retry pattern already seen with New York before the region issue was diagnosed.

Confirmed via `docker logs`: OpenVPN tunnel up, port forwarding assigned, Deluge Web UI started, Privoxy listening on 8118, `HTTP 200` from the web UI.
