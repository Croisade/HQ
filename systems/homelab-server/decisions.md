# Decisions

- **2026-08-09** — Services' `data/` stays on `homelab-server`'s local disk, not the incoming NAS. SQLite-backed apps (`mealie`, `actual-budget`, `homarr`) risk locking/corruption over NFS/SMB. The NAS is for bulk media and as a [restic](../restic/README.md) backup target, not for hosting live app state.
- **2026-08-11** — Downloads (`docker-scratch`) and finished media (`docker-data`) live on separate NAS pools/filesystems, accepting copy+delete imports in `radarr`/`sonarr` instead of hardlinks. Keeps in-progress download I/O off the main media pool; simplicity over the hardlink optimization.
