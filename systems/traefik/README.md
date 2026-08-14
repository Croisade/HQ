# traefik

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Reverse proxy — routes `*.thegarden` subdomains to the right service by container name instead of by port, using Traefik's Docker provider (label-driven, auto-discovers containers on the `lab` network).

- Dashboard: `https://traefik.thegarden`

Claims host port `80`. [pihole](../pihole/README.md) used to bind host port `80` for its own web UI — that's been removed in favor of routing through Traefik as `pihole.thegarden` instead, so there's no conflict.

Pinned to `v3.7.10`, not the `v3.1` this was originally scaffolded with — `v3.1`'s bundled Docker client hardcodes API `1.24`, which this host's Docker daemon (29.7.1, API 1.55) refuses as too old, so the Docker provider retry-looped forever and never registered any routes.

## DNS

Traefik only routes traffic that already arrives addressed to a `*.thegarden` hostname — it doesn't resolve DNS itself. [pihole](../pihole/README.md) is authoritative for the `thegarden` domain (wildcard record → this host's IP), and the [udm-se](../udm-se/README.md) hands out Pi-hole as the LAN's DNS server via DHCP.

## Routing table

| Subdomain | Service |
|---|---|
| `pihole.thegarden` | [pihole](../pihole/README.md) |
| `assistant.thegarden` | [home-assistant](../home-assistant/README.md) — file provider, not a Docker label (host-networked, not on the `lab` network) |
| `torrents.thegarden` | [deluge](../deluge/README.md) |
| `usenet.thegarden` | [sabnzbd](../sabnzbd/README.md) |
| `tv.thegarden` | [sonarr](../sonarr/README.md) |
| `movies.thegarden` | [radarr](../radarr/README.md) |
| `requests.thegarden` | [jellyseerr](../jellyseerr/README.md) |
| `media.thegarden` | [jellyfin](../jellyfin/README.md) |
| `home.thegarden` | [homarr](../homarr/README.md) |
| `recipes.thegarden` | [mealie](../mealie/README.md) |
| `budget.thegarden` | [actual-budget](../actual-budget/README.md) |
| `traefik.thegarden` | traefik's own dashboard |
| `glances.thegarden` | [glances](../glances/README.md) — file provider, not a Docker label (host-networked, not on the `lab` network) |
| `books.thegarden` | [bindery](../bindery/README.md) |

Every router above is HTTPS-only (`entrypoints=websecure` + `tls=true`), via the mkcert internal CA — see [decisions.md](decisions.md). This isn't optional: the `web` entrypoint (`:80`) has a **global redirect to `websecure`** (`--entrypoints.web.http.redirections.entrypoint.to=websecure`), so any router left on plain `web` becomes unreachable by hostname — the redirect sends the browser to `:443`, where there's no matching router, and Traefik 404s. Hit this directly: 8 services were deployed with `entrypoints=web`-only routers and all 404'd until switched to `websecure`+`tls=true`. **Any new `*.thegarden` service must use `websecure`+`tls=true` from the start** (and the mkcert leaf cert needs the new hostname added as a SAN — see [decisions.md](decisions.md)).

## Data

No `data/` — Traefik is stateless here, configured entirely through the Docker provider and container labels.
