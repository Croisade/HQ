# thelab

A monorepo for organizing a personal home lab — servers, networking, and self-hosted services.

## What this is

A structured approach to treating a home lab as private infrastructure-as-code + historical narrative. The unit of organization is a running **system** — a physical server, network appliance, VM, or container workload — not a project.

Each system carries a small set of optional files for different concerns: operational identity, hardware specs, declarative config, runbooks, lab notes, plans, and decisions. The full convention set is in `CLAUDE.md` and `.claude/rules/homelab-conventions.md`.

## Structure

```
systems/         # One directory per running system
  <name>/
    README.md    # Required — what the system is and its current status
    hardware.md  # Physical specs or VM resource allocation
    config/      # Source-of-truth declarative IaC (Compose, Terraform, etc.)
    notes.md     # Lab notebook — date-headered entries, newest on top
    plan.md      # In-flight plan + execution checklist
    ...          # See CLAUDE.md for the full file inventory
adr/             # Cross-system Architecture Decision Records
docs/             # Cross-cutting authored reference topics
scripts/          # Cross-system reusable helper scripts
.claude/rules/    # Claude Code conventions for this repo
```

## Getting started

1. `systems/homelab-server` is the first system — the physical box everything runs on.
2. Keep only files that have real content — empty stubs are discouraged.
3. See `CLAUDE.md` for the system model and key conventions before adding a new system.

## Credit

The `systems/` structure and conventions here (status lines, `plan.md` → `build-log.md`, "one fact, one home") are adapted from [matt-bey/homelab-template](https://github.com/matt-bey/homelab-template). Thanks for the model to build from.
