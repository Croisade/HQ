# home-assistant

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Home automation platform for connecting and controlling devices on the local network.

## Networking

Runs with `network_mode: host` rather than joining the shared `lab` bridge network — this lets Home Assistant's mDNS/SSDP-based device discovery (Chromecast, HomeKit, Sonos, etc.) see the LAN directly. Since it never joins the `lab` network, [traefik](../traefik/README.md)'s Docker-label auto-discovery can't route to it like every other service — instead it's routed via a static entry in Traefik's file provider (`traefik/config/dynamic/home-assistant.yml`) pointing directly at the host's LAN IP.

- Web UI: `http://<homelab-server-ip>:8123` or `https://assistant.thegarden` (via [traefik](../traefik/README.md))

Reverse-proxy access required enabling Home Assistant's own "trusted proxies" setting (Settings → System → Network in the HA UI — this is no longer YAML-configurable, `configuration.yaml`'s `http:` block is a one-time-only migration path in this version), set to `172.18.0.0/16` (the `lab` Docker network Traefik lives on) with X-Forwarded-For trusted.

## Matter

Matter devices (e.g. Kasa smart plugs) go through the [matter-server](../matter-server/README.md) companion container, connected via the Matter integration at `ws://localhost:5580/ws`.

## Data

Persistent config/state lives in `data/` (bind-mounted, gitignored — not committed, since it holds secrets and machine-specific state).
