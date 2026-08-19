# Notes

## 2026-08-19 — Ethernet throughput capped well below expected, unresolved

This host's Ethernet is measuring ~150-250 Mbps (single-stream and 4-parallel-stream tests against a nearby Cloudflare edge, cross-checked after an initial `speedtest-cli` reading was thrown out for picking servers 1,600km away). A personal machine on the same network gets ~901 down / 911 up on the same connection — so the ISP/router/modem are confirmed capable of near-gigabit; this is specific to this host.

Ruled out:
- **NIC negotiation** — `ethtool enp3s0` shows `Speed: 1000Mb/s, Duplex: Full`.
- **Cable/physical-layer errors** — `ethtool -S enp3s0` shows zero CRC errors, zero alignment errors, zero collisions, the usual signature of a bad cable.
- **CPU contention** — [palworld](../palworld/README.md) was pinning 200-265% CPU throughout this investigation; stopped it and re-ran every test. Numbers barely moved (one test improved from 236→357 Mbps, everything else stayed ~250 Mbps). Not the primary cause.

Found but doesn't fully explain the gap: 42 lifetime `rx_fifo_errors` on `enp3s0` (receive buffer overruns) over a 10-day uptime.

Needs physical access to actually chase further — next steps, easiest first: try a different port on the switch/router, swap the Ethernet cable, check for any intermediate hop (switch, powerline adapter) between this host and the router that the personal machine's comparison test didn't go through.
