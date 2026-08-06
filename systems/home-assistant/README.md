# home-assistant

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Home automation platform for connecting and controlling devices on the local network.

## Networking

Runs with `network_mode: host` rather than joining the shared `lab` bridge network — this lets Home Assistant's mDNS/SSDP-based device discovery (Chromecast, HomeKit, Sonos, etc.) see the LAN directly. A future reverse proxy will route to it via the host IP rather than by container name.

- Web UI: `http://<homelab-server-ip>:8123`

## Matter

Matter devices (e.g. Kasa smart plugs) go through the [matter-server](../matter-server/README.md) companion container, connected via the Matter integration at `ws://localhost:5580/ws`.

## Data

Persistent config/state lives in `data/` (bind-mounted, gitignored — not committed, since it holds secrets and machine-specific state).
