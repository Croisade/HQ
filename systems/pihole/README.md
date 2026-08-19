# pihole

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Network-wide DNS + ad blocking.

- Web UI: `https://pihole.thegarden` (via [traefik](../traefik/README.md))
- DNS: binds to `192.168.1.101:53` and `100.124.114.120:53` (tcp/udp, both explicitly — see [tailscale](../tailscale/README.md)) — updated from the migrated config's stale `192.168.0.104`, which doesn't exist on this network
- DHCP: `67/udp` exposed but not enabled by default — see the image's docs if you want Pi-hole handling DHCP too

## Config

`WEBPASSWORD` lives in `config/.env` (gitignored). `config/.env.example` documents the key.

Host port `80` used to be bound here for the web UI; that's been removed since [traefik](../traefik/README.md) claims it now and routes to this container as `pihole.thegarden` instead — no more port conflict.

**DNS for `thegarden`**: `config/dnsmasq.d/05-thegarden.conf` adds a wildcard record (`address=/thegarden/192.168.1.101`) so any `*.thegarden` lookup resolves to this host, where traefik does the actual routing. For this to work LAN-wide, the [udm-se](../udm-se/README.md)'s DHCP needs to hand out this host's IP as the DNS server instead of its own default — a manual step in the UniFi controller, not something this repo can apply.

**Explicit dual-IP port binding, not `0.0.0.0`**: binding port 53 to all interfaces was tried first (for [tailscale](../tailscale/README.md) reachability) and failed — `systemd-resolved` already holds `127.0.0.53`/`127.0.0.54:53` on this host, and Docker can't bind a wildcard `0.0.0.0:53` alongside an existing loopback-specific bind on the same port. Binding to the two specific IPs that actually need to reach Pi-hole (the LAN IP and homelab-server's tailnet IP) sidesteps the conflict entirely.

**Local DNS records for non-web devices**: for things that aren't traefik-routed HTTP services (their own IP, own UI/protocol), a plain A record is added instead of relying on the `thegarden` wildcard — via `pihole restartdns reload` after editing `/etc/pihole/custom.list` inside the container. Not tracked as repo IaC (lives in `data/etc-pihole`, Pi-hole's own managed state, gitignored) — current entries:
- `storage.thegarden` → `192.168.1.156` ([nas](../nas/README.md))
- `udm.thegarden` → `192.168.1.1` ([udm-se](../udm-se/README.md))

## Data

- `data/etc-pihole` — Pi-hole state/blocklists
- `data/etc-dnsmasq.d` — dnsmasq state (Pi-hole's own managed files; the `thegarden` wildcard record is separate, tracked IaC in `config/dnsmasq.d/`)
