# pihole

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Network-wide DNS + ad blocking.

- Web UI: `http://pihole.thegarden` (via [traefik](../traefik/README.md))
- DNS: binds to `192.168.1.101:53` (tcp/udp) — updated from the migrated config's stale `192.168.0.104`, which doesn't exist on this network
- DHCP: `67/udp` exposed but not enabled by default — see the image's docs if you want Pi-hole handling DHCP too

## Config

`WEBPASSWORD` lives in `config/.env` (gitignored). `config/.env.example` documents the key.

Host port `80` used to be bound here for the web UI; that's been removed since [traefik](../traefik/README.md) claims it now and routes to this container as `pihole.thegarden` instead — no more port conflict.

**DNS for `thegarden`**: `config/dnsmasq.d/05-thegarden.conf` adds a wildcard record (`address=/thegarden/192.168.1.101`) so any `*.thegarden` lookup resolves to this host, where traefik does the actual routing. For this to work LAN-wide, the [udm-se](../udm-se/README.md)'s DHCP needs to hand out this host's IP as the DNS server instead of its own default — a manual step in the UniFi controller, not something this repo can apply.

## Data

- `data/etc-pihole` — Pi-hole state/blocklists
- `data/etc-dnsmasq.d` — dnsmasq state (Pi-hole's own managed files; the `thegarden` wildcard record is separate, tracked IaC in `config/dnsmasq.d/`)
