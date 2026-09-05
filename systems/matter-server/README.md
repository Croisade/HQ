# matter-server

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Matter controller/bridge (`python-matter-server`) — Home Assistant Container has no Supervisor/add-on store, so unlike Home Assistant OS, Matter support has to run as its own container rather than a one-click add-on. `home-assistant`'s Matter integration talks to this over WebSocket.

## Networking

Runs with `network_mode: host`, same reasoning as `home-assistant` — Matter relies on mDNS on the LAN. WebSocket API is on `ws://localhost:5580/ws` from `home-assistant`'s point of view (both host-networked on the same box).

`/run/dbus` is mounted read-only for BLE-based commissioning via the host's Bluetooth radio (confirmed present: Realtek USB Bluetooth).

**`--primary-interface enp3s0`** pinned explicitly in `command:` — this host has multiple active network interfaces (LAN ethernet `enp3s0`, WiFi `wlp2s0`, Tailscale, several Docker bridges), and Matter's commissioning handshake runs over IPv6 link-local addresses, which are scoped to a single interface. Without this pin, a real TP-Link Tapo plug repeatedly failed commissioning — `PASESession timed out`, `Secure Pairing Failed` — despite mDNS discovery succeeding and getting the device's IP; matter-server's own logs showed it detecting both `enp3s0` and `wlp2s0` as candidate interfaces, meaning link-local traffic could get routed out the wrong one with no explicit pin. Confirmed fixed: post-fix logs show the target address with an explicit scope suffix (`fe80::...%enp3s0`) that was absent in every failed attempt beforehand, and commissioning succeeded on the next retry.

## Data

- `data/` — Matter fabric/commissioning state (gitignored)
