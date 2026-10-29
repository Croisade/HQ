# deluge

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

BitTorrent client (`binhex/arch-delugevpn`), routed through a PIA VPN — traffic only leaves the container over the VPN tunnel (`NET_ADMIN` + `STRICT_PORT_FORWARD`).

- Web UI: `http://<homelab-server-ip>:8112` or `https://torrents.thegarden` (via [traefik](../traefik/README.md))
- Ports: `8112` (web), `8118` (privoxy), `58846`/`58946` (daemon/incoming)

## Config

VPN credentials live in `config/.env` (gitignored — real PIA username/password). `config/.env.example` documents the required keys.

`LAN_NETWORK` is set to `192.168.1.0/24` to match this host's actual LAN — the original config this was migrated from used `192.168.0.0/24`, which was wrong for this network.

VPN server region is PIA Vancouver (`data/config/openvpn/ca_vancouver-*.ovpn`), not the geographically nearer New York — PIA no longer supports port forwarding on any US endpoint, and `STRICT_PORT_FORWARD=yes` means the container refuses to start Deluge on an endpoint that cannot forward ports. Toronto does not forward and Montreal showed heavy packet loss, so Vancouver is the closest endpoint that works. The container needs exactly one `*.ovpn` in that folder.

## Data

- `data/config` — Deluge app config, incl. `openvpn/*.ovpn` (gitignored)
- `/mnt/docker-scratch/downloads/torrents` ([nas](../nas/README.md)) → `/data` — download staging

## Executable guard

Fake releases on public indexers can be a single `.exe` named like an episode. Sonarr's import check does not reject them, so `scripts/exe-guard.sh` runs from Deluge's Execute plugin on "Torrent Complete". If the finished torrent holds an executable/script file (`.exe`, `.scr`, `.bat`, `.msi`, `.ps1`, `.sh`, ...) it removes the torrent and its data. Sonarr/Radarr then see a vanished download, mark it failed, blocklist the release and retry another.

- Source lives in `scripts/`; the live copy is `data/config/scripts/exe-guard.sh` (mounted at `/config/scripts/`, so copy it there after editing). Matches are logged to `/config/scripts/exe-guard.log`.
- The Execute plugin and its `complete` command are registered at runtime (`data/config/execute.conf`, gitignored). If the plugin is ever missing after a restart, enable it in the web UI under Preferences > Plugins.
- Not triggered for torrents added already complete (recheck goes straight to seeding), only for real downloads.

See [notes.md](notes.md) for history on the three startup blockers hit and fixed.
