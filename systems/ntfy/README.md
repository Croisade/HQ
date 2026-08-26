# ntfy

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Self-hosted push notification service — [watchtower](../watchtower/README.md) and [grafana](../grafana/README.md)'s alerting both publish to it, delivered to the [ntfy Android app](https://ntfy.sh/) subscribed to the relevant topic. No auth configured (default), so topic names are the only thing standing between "public" and "private" — pick non-guessable topic names if that matters, not done here since this is a home network need, not internet-exposed beyond the existing `*.thegarden`/Tailscale access model.

- Web UI / API: `http://<homelab-server-ip>:38088` or `https://ntfy.thegarden` (via [traefik](../traefik/README.md))

## Topics in use

- `docker-updates` — [watchtower](../watchtower/README.md), notified when a container has a newer image available (monitor-only, doesn't auto-update — see watchtower's README).
- `alerts` — [grafana](../grafana/README.md) alerting, once actual alert rules exist (none configured yet, just the contact point/routing plumbing).

Deliberately kept separate so update notices and "something's actually wrong" alerts don't compete for attention on the same feed.

## Reachability

Other containers on the `lab` network reach it by container name (`ntfy`, port `80`), not through Traefik/the public hostname — see [watchtower](../watchtower/README.md) and [grafana](../grafana/README.md) for how each publishes to it. This avoids depending on Pi-hole DNS resolution for purely internal service-to-service calls.

## Known limitation

Grafana's webhook contact point always wraps `title`/`message` into a JSON envelope (not raw text) — since the topic is specified in ntfy's URL path (`/alerts`), not inside the JSON body, ntfy doesn't extract those fields and instead shows the raw JSON blob as the notification text. Functional (confirmed real delivery end-to-end via `POST /api/v1/provisioning/contact-points` config + a manual publish test matching the same payload shape), just not pretty. Cleaning this up means a Custom Payload template on the Grafana contact point built against real firing-alert data (multi-line alert messages risk breaking naive JSON construction) — deferred until real alert rules exist to test against, rather than shipping an untested escaping scheme.

## Data

- `data/cache` — ntfy's message cache (gitignored)
- `data/etc` — mounted but unused currently (no `server.yml`, relying on env vars only)
