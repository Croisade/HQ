# deluge

Status: Building

Host: [homelab-server](../homelab-server/README.md)

BitTorrent client (`binhex/arch-delugevpn`), routed through a PIA VPN — traffic only leaves the container over the VPN tunnel (`NET_ADMIN` + `STRICT_PORT_FORWARD`).

- Web UI: `http://<homelab-server-ip>:8112` or `http://torrents.thegarden` (via [traefik](../traefik/README.md))
- Ports: `8112` (web), `8118` (privoxy), `58846`/`58946` (daemon/incoming)

## Config

VPN credentials live in `config/.env` (gitignored — real PIA username/password). `config/.env.example` documents the required keys.

`LAN_NETWORK` is set to `192.168.1.0/24` to match this host's actual LAN — the original config this was migrated from used `192.168.0.0/24`, which was wrong for this network.

## Data

- `data/config` — Deluge app config, incl. `openvpn/*.ovpn` (gitignored)
- `/mnt/docker-scratch/downloads/torrents` ([nas](../nas/README.md)) → `/data` — download staging

See [notes.md](notes.md) for the current startup blocker.
