# Plan — home-assistant

## Get a running instance

- [x] `docker compose -f config/compose.yaml up -d` — running via `scripts/up.sh`, container `home-assistant` up
- [x] Complete the onboarding wizard at `http://<homelab-server-ip>:8123`
- [x] Connect first devices — 2 Kasa smart plugs via Matter ([matter-server](../matter-server/README.md)), commissioned as Node 1 and Node 2
- [ ] Decide whether to front it with the reverse proxy (once one exists) via host-IP routing
