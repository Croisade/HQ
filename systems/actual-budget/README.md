# actual-budget

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Self-hosted budgeting app (envelope budgeting, YNAB-style).

- Web UI: `http://<homelab-server-ip>:5006` or `https://budget.thegarden` (via [traefik](../traefik/README.md))

Server password is set on first launch via the web UI, not an env var.

Unlike every other service in this repo, the official image doesn't support `PUID`/`PGID` — no equivalent env vars are documented, so ownership of `data/` follows whatever the container's default user is.

## Multi-user / OpenID

Multi-user mode requires an OpenID provider — Actual has no separate local multi-user database, usernames come straight from the IdP. Backed by [pocket-id](../pocket-id/README.md) (`auth.thegarden`). Config lives in `config/.env` (gitignored) — `ACTUAL_MULTIUSER=true` plus `ACTUAL_OPENID_*` vars (discovery URL, client ID/secret from the Pocket ID client, server hostname). **Whoever logs in via OpenID first becomes the permanent Actual server admin** — no undo.

Real gotcha hit standing this up: Actual's Node runtime doesn't trust the repo's internal [mkcert CA](../traefik/README.md), so OIDC discovery against `https://auth.thegarden/...` failed with `UNABLE_TO_VERIFY_LEAF_SIGNATURE` until the CA root was mounted into the container and pointed to via `NODE_EXTRA_CA_CERTS` (see `config/compose.yaml`).

`ACTUAL_USER_CREATION_MODE=manual` (default) — new household members need to be added in Actual's own User Directory before their Pocket ID login will work; `login` mode would auto-provision instead.

**Known limitation, not config drift**: only one household member can have a live SimpleFIN bank-sync connection on this instance at a time — Actual stores the SimpleFIN token as a single global row, not scoped per user/budget, so a second person connecting overwrites the first. [actual-budget-akayla](../actual-budget-akayla/README.md) exists as a separate instance specifically to work around this — see its README for the full explanation.

## Data

- `data/` — Actual server data (gitignored)
