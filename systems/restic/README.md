# restic

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Scheduled backups of every system's `data/` directory (gitignored, persistent container state), using [restic](https://restic.net/) via the [mazzolino/restic](https://github.com/mazzolino/restic) scheduler image.

`data/` intentionally stays on `homelab-server`'s local disk rather than the NAS (SQLite-backed apps like `mealie`, `actual-budget`, and `homarr` don't tolerate NFS/SMB well) — see [homelab-server's decisions.md](../homelab-server/decisions.md). This is what actually protects that state: the NAS's own redundancy never touches it.

- Repository: a restic repo on the NAS, at `/mnt/docker-data/backups/restic` (NFS, `192.168.1.156`, pool `Triple-Towers`)
- Source: the whole `systems/` tree, mounted read-only (captures every system's `data/`; `config/` gets swept in too but that's already tracked in git, so it's just redundant, not harmful)
- Schedule: nightly, via `BACKUP_CRON`
- Retention: 7 daily / 4 weekly / 6 monthly snapshots, via `RESTIC_FORGET_ARGS`

## Config

`RESTIC_PASSWORD` lives in `config/.env` (gitignored). `config/.env.example` documents the key.

Not yet deployed — needs a real `RESTIC_PASSWORD` set in `config/.env` first.

## Data

No `data/` dir of its own — reads other systems' `data/` directories read-only and writes snapshots out to the NAS-backed repository.
