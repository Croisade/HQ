# Home lab conventions

Detailed rules for working in this repo. Summary lives in `CLAUDE.md` — this file expands on it when a rule needs more nuance than fits there.

## Choosing a system's files

Pick files based on the system's flavor (see `CLAUDE.md`), and only create a file once it has real content to hold. An empty `notes.md` or `plan.md` is worse than no file — delete it rather than leave it as a stub.

## Status transitions

- `Planned` — decided on, not yet built.
- `Building` — actively being set up; expect a `plan.md`.
- `Operational` — running and trusted.
- `Degraded` — running but with a known problem; note it in `notes.md`.
- `Retired` — decommissioned; keep the folder for history, don't delete it.

## Public vs private notes

This repo is public — `notes.md` ships with it, so write it assuming a stranger (a recruiter, a random GitHub visitor) will read it. `greenhouse.md` is its gitignored twin, same date-headered lab-notebook format, for anything that doesn't belong in public: exact geographic location, household/family detail, a credential that got pasted into a raw debugging transcript, or just unfiltered venting about a bad afternoon. When something is borderline, default to writing it in `greenhouse.md` first — it's easy to promote a note into `notes.md` later once you've confirmed it's safe, much harder to un-publish it.

Same rule as every other optional file: only create `greenhouse.md` once it has real content to hold.

## Plans and history

A `plan.md` is live direction — it should read as a checklist you're actively executing. Once the plan is done, move its content into `build-log.md` (create it if it doesn't exist) and delete `plan.md`. Don't let a finished plan linger as if it's still in flight.

## Cross-system references

Link between systems with relative paths (`../traefik/README.md`), not absolute repo paths. When a plan spans multiple systems, it lives with whichever system changed the most.

## Config vs scripts

`config/` is declarative and is the source of truth for how a system is actually deployed (Compose files, Terraform, etc.) — if it drifts from what's really running, fix the drift, don't just note it.

`scripts/` is imperative — one-off or repeatable actions (install steps, backup jobs). A script that's useful to more than one system belongs in the root `scripts/`, not duplicated per-system.
