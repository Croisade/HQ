# uptime-kuma

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Service/uptime monitoring and alerting — watches whatever URLs/services get pointed at it and notifies on downtime, instead of finding out by chance. Deployed after a pattern this lab kept hitting: real bugs (a stuck laundry-tracking boolean, a hung notification script, a silently-failing book import) sat broken for hours with nothing surfacing it.

- Web UI: `http://<homelab-server-ip>:3001` or `https://uptime.thegarden` (via [traefik](../traefik/README.md))

## Data

- `data/` — Uptime Kuma's SQLite DB + config (gitignored). Local disk, not the NAS — same NFS-intolerance rule as every other SQLite-backed app here (see [homelab-server's decisions.md](../homelab-server/decisions.md)).

## Not done yet

First-run admin account setup happens in the web UI (not scriptable, same as everywhere else in this repo). After that:
- Add monitors for the services that actually matter — every `*.thegarden` route is a candidate, but probably not worth monitoring literally everything at once; start with the ones that'd actually be bad to have silently down.
- Wire alerting into the same notification path [home-assistant](../home-assistant/README.md) already has (`script.notify_and_log`) rather than a separate channel, if Uptime Kuma's own notification integrations support it — otherwise its own built-in notification providers (webhook, etc.) are the fallback.
