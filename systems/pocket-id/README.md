# pocket-id

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Self-hosted, passkey-only OIDC provider. No passwords, no TOTP — sign-in is a WebAuthn passkey (Face ID/Touch ID/Windows Hello/security key). Deployed to back [actual-budget](../actual-budget/README.md)'s multi-user mode, which requires an OpenID provider — Actual has no separate local multi-user database of its own.

- Web UI: `https://auth.thegarden` (via [traefik](../traefik/README.md))

## Setup

1. Bring the container up, then visit `https://auth.thegarden/setup` to register the first admin account via passkey — this step can't be scripted, it's a WebAuthn ceremony in-browser.
2. In Pocket ID, create an OIDC client for each app that will use it (starting with Actual Budget), which yields a `client_id`/`client_secret` pair.
3. Drop those into the consuming app's own config (see actual-budget's README for its half of this).

## Other candidates

Confirmed native OIDC support, not yet wired up: [immich](../immich/README.md), [mealie](../mealie/README.md), [homarr](../homarr/README.md), [grafana](../grafana/README.md). Jellyfin/Home Assistant/Uptime Kuma have no native OIDC — adding them would mean a plugin or a forward-auth proxy in front of Traefik, not just a Pocket ID client registration, so they're out of scope for now.

## Data

- `data/` — Pocket ID's SQLite DB, uploads, GeoLite2 IP data (gitignored)
