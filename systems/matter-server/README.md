# matter-server

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Matter controller/bridge (`python-matter-server`) — Home Assistant Container has no Supervisor/add-on store, so unlike Home Assistant OS, Matter support has to run as its own container rather than a one-click add-on. `home-assistant`'s Matter integration talks to this over WebSocket.

## Networking

Runs with `network_mode: host`, same reasoning as `home-assistant` — Matter relies on mDNS on the LAN. WebSocket API is on `ws://localhost:5580/ws` from `home-assistant`'s point of view (both host-networked on the same box).

`/run/dbus` is mounted read-only for BLE-based commissioning via the host's Bluetooth radio (confirmed present: Realtek USB Bluetooth).

## Data

- `data/` — Matter fabric/commissioning state (gitignored)
