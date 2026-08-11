# Notes — pihole

## 2026-08-11

Upgraded from `2023.10.0` (v5.x) to `2026.07.2` (v6) — a full rewrite (Alpine-based image, config moved from `setupVars.conf`/legacy env vars to a single `/etc/pihole/pihole.toml`, gravity/history DBs auto-migrated on first start). Data verified intact post-migration: all 3 adlists (StevenBlack, HaGeZi Pro, HaGeZi TIF Medium) preserved with exact original per-list domain counts summing to 703,525; `custom.list`'s local DNS records (`storage.thegarden`, `udm.thegarden`) auto-migrated into `pihole.toml`'s `dns.hosts` array; `05-thegarden.conf` wildcard record still read correctly.

Compose changes required for v6:
- `WEBPASSWORD` → `FTLCONF_webserver_api_password` (old env var name is gone in v6)
- Added `FTLCONF_misc_etc_dnsmasq_d: 'true'` — v6 stops reading `/etc/dnsmasq.d/` by default; without this, the `thegarden` wildcard record silently stops applying even though the file is still mounted

**Real bug hit and fixed**: after migrating, this host itself (`homelab-server`) couldn't resolve any DNS through `192.168.1.101:53` — timed out on every query, even though real LAN devices querying the same address worked fine (verified via a second container's `nslookup`, and via raw conntrack showing the host's own hairpinned queries specifically marked `[UNREPLIED]`). Root cause, confirmed directly in FTL's logs: `dnsmasq: ignoring query from non-local network 192.168.1.101` — v6 defaults `dns.listeningMode` to `"LOCAL"`, which validates the *apparent source subnet* of each query against the container's own directly-attached interfaces. The host's hairpinned traffic (querying its own externally-published Docker port) arrives at the container still carrying the host's real LAN IP as the source — which the container, from its own network-namespace perspective, doesn't recognize as a "local" subnet, so v6 silently drops it. v5 never enforced this check. Fixed by setting `dns.listeningMode = "SINGLE"` via the API (`PATCH /api/config`) — "permit all origins, accept only on the specified interface," which removes the strict subnet-matching without going as far as `"ALL"` (accepts on every interface, explicitly called out in Pi-hole's own docs as making the instance a potential open resolver — unnecessary here since this container only has one interface anyway). This setting lives in `pihole.toml` (`data/etc-pihole/`), not compose env vars, so it's already persisted.

This only affected the Docker host's own OS-level DNS resolution — real LAN client devices (phones, laptops, etc., whose traffic never hairpins through the host's own loopback path) were unaffected the entire time.

Backup taken before upgrading: `data/data-backup-v5-20260811.tar.gz` (gitignored along with the rest of `data/`).
