# Build log — matter-server

## Get Matter working with Home Assistant (completed)

- Brought up `matter-server` via `docker compose up -d`, host networking, `/run/dbus` mounted for BLE commissioning
- Added the Matter (BETA) integration in Home Assistant, pointed at `ws://localhost:5580/ws`
- Paired both Kasa smart plugs via their Matter share codes from the Kasa app — commissioned as Node 1 and Node 2, both interviewed and subscribed successfully
- One log line worth knowing about: matter-server logs `Failed to advertise records: Network is unreachable` for mDNS on startup — turned out to be benign, both plugs commissioned fine despite it
