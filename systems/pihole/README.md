# pihole

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Network-wide DNS + ad blocking.

- Web UI: `http://<homelab-server-ip>/admin`
- DNS: binds to `192.168.1.101:53` (tcp/udp) — updated from the migrated config's stale `192.168.0.104`, which doesn't exist on this network
- DHCP: `67/udp` exposed but not enabled by default — see the image's docs if you want Pi-hole handling DHCP too

## Config

`WEBPASSWORD` lives in `config/.env` (gitignored). `config/.env.example` documents the key.

**Port 80 conflict to plan for**: Pi-hole is claiming host port 80. If a reverse proxy (e.g. Traefik) is added later, it'll also want 80/443 — that'll need resolving (move Pi-hole's web UI to a different port, or have the proxy forward `:80` to Pi-hole's real port).

## Data

- `data/etc-pihole` — Pi-hole state/blocklists
- `data/etc-dnsmasq.d` — dnsmasq config
