# actual-budget-akayla

Status: Building

Host: [homelab-server](../homelab-server/README.md)

A second, fully independent [Actual Budget](../actual-budget/README.md) server — not a second budget file on the shared instance. Exists solely because of a real, still-open upstream limitation: Actual stores the SimpleFIN bank-sync token as a single global row in its `secrets` table, not scoped per budget file or per user, so two people on one multi-user Actual server can't each have their own live SimpleFIN connection — the second person to connect overwrites the first (confirmed directly against `account.sqlite`, and matches [actualbudget/actual#4197](https://github.com/actualbudget/actual/issues/4197), which the maintainers auto-closed without actually fixing — community comments as late as August 2025 confirm it's still broken on current versions). The only real workaround, per that same thread, is a second full instance.

- Web UI: `https://budgetkay.thegarden` (via [traefik](../traefik/README.md))

Same shape as `actual-budget`: multi-user/OpenID against [pocket-id](../pocket-id/README.md), and the same `NODE_EXTRA_CA_CERTS` mount for the repo's internal mkcert CA (see actual-budget's README for why that's needed). Reuses `actual-budget`'s own Pocket ID client rather than a separate one — Pocket ID supports multiple redirect URIs per client, so `https://budgetkay.thegarden/openid/callback` was just added alongside `budget.thegarden`'s on that same client. Even though this instance only really needs to serve Akayla, OpenID was kept instead of falling back to a plain server password, since she already has a Pocket ID passkey and there's no reason to give her a second credential to manage.

Host port `5007` (mapped to the container's `5006`), not `5006` — that's already claimed by `actual-budget` on this host.

## Data

- `data/` — this instance's own Actual server data, entirely separate from `actual-budget`'s (gitignored)
