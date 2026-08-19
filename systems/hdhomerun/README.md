# hdhomerun

Status: Planned

Physical appliance (SiliconDust HDHomeRun Flex Duo) — network-attached OTA tuner, feeding live TV into [jellyfin](../jellyfin/README.md)'s Live TV feature. No `config/` here; nothing about it is IaC-able — it's a physical box with its own local web config and a Jellyfin-side tuner integration, not a container this repo deploys.

Paired with a Channel Master Flatenna 35 (non-amplified indoor antenna) — the antenna itself isn't its own system entry, it has no network presence or config at all, just a coax cable into the tuner.

## Why this, why now

Signal survey via TV Fool (6.5mi, line-of-sight, all major Philadelphia network affiliates well above the "indoor antenna sufficient" threshold — stations cluster tightly since Philly's towers are mostly co-located in Roxborough) showed reception here is strong enough that this is genuinely low-effort: no attic/roof antenna mount needed, no amplification needed. See [decisions.md](decisions.md) for the specific choices this drove.

## Architecture

```
Antenna --(coax)--> HDHomeRun Flex Duo --(ethernet)--> home network --> jellyfin (Live TV)
```

One box, one coax cable, one ethernet cable. The tuner does its own ATSC demodulation and streams over the LAN — [jellyfin](../jellyfin/README.md) (or any HDHomeRun-compatible client) talks to it directly over the network, no direct cabling to viewing devices.

**Doesn't need to sit near the router** — only needs *a* wired network path back to the LAN from wherever the antenna ends up (window placement, not attic/roof — signal's strong enough that this is fine). Direct cable run, powerline adapter, or an existing wired drop elsewhere in the house are all viable depending on the actual distance once a spot is picked.

**Survives SiliconDust disappearing, mostly**: live viewing is local-network-only once configured (no cloud dependency for day-to-day use) — confirmed via the 2019 precedent where SiliconDust discontinued their cloud DVR/guide product ("Premium") and the tuner hardware kept working for live viewing regardless. Initial setup does need internet once. Not using SiliconDust's own guide/DVR service here anyway (see decisions.md), so exposure to their continued existence is about as low as this product category gets.

## Next steps

See [plan.md](plan.md).
