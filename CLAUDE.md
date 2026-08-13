# thelab — conventions

## System flavors

1. **Physical compute hosts** (e.g. `homelab-server`) — hardware that runs workloads.
2. **Physical appliances** (e.g. a router or firmware-based device) — hardware running firmware.
3. **Workloads** (e.g. `traefik`, `ollama`) — software running on a host, linked via a `Host:` field.

Dual-role systems (a VM that's both a workload and a host to other workloads) combine both templates.

## Directory structure

`systems/<name>/` holds one folder per running system. Each may include:

- `README.md` (required)
- `hardware.md` (required for physical hosts; recommended for VMs)
- `software.md`, `deployment.md`, `runbook.md` (optional)
- `notes.md` — lab notebook, date-headered entries, newest first
- `greenhouse.md` — private counterpart to `notes.md` (gitignored, same format) — see homelab-conventions.md
- `plan.md` — active direction with an execution checklist
- `build-log.md` — historical record, written once a plan completes
- `decisions.md` — one-liner decision log
- `adr/` — numbered architecture records (`001-title.md`)
- `config/` — declarative IaC, source of truth
- `scripts/` — imperative helpers specific to this system

Only create a file when it has real content. No empty stubs.

## Key conventions

**This repo is public.** Assume any tracked file is visible to anyone — no real credentials (use `.env`, gitignored), no exact home address/location, no household/family detail. Anything like that goes in `greenhouse.md` instead of `notes.md`.

**Status line** appears below each system's title:
`Status: Planned | Building | Operational | Degraded | Retired`

**One fact, one home**: direction-setting content lives in `plan.md`, `adr/`, or `decisions.md` — never duplicated into descriptive files like `README.md` or `software.md`.

**Naming**: systems are named for their role, not their implementation (`homelab-server` stays that name even if the underlying OS/hypervisor changes). Filenames are lowercase kebab-case (`hardware.md`), except tool-recognized files (`README.md`, `CLAUDE.md`).

**Workloads** are named after their tool and link to their host via a `Host:` field; hosts list inbound workloads in a `Workloads:` section.

**Commits** follow [Conventional Commits](https://www.conventionalcommits.org/) with standard types: `feat`, `fix`, `chore`, `refactor`, `docs`, `style`.
