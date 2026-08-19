# tailscale

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Mesh VPN (WireGuard-based) giving `jamal`'s own devices — phone, laptop, this host — a private, encrypted network to each other regardless of physical location, so `*.thegarden` services (and anything else on the LAN) are reachable from outside the house without port-forwarding, a public domain, or a real TLS certificate.

Installed directly on the host OS, not containerized — unlike every other system in this repo. Tailscale needs to manipulate host-level routing (subnet routes, IP forwarding) to do its job; sandboxing that inside a container is possible upstream but adds complexity (host networking + `NET_ADMIN`-equivalent capabilities either way) for no real benefit here, so it's installed as a normal system package instead.

## What's configured

- **Device**: `homelab-server` itself joined the tailnet as `server`, via `sudo tailscale up`.
- **Subnet route**: advertises `192.168.1.0/24` (`--advertise-routes=192.168.1.0/24`) — lets any tailnet device reach the whole home LAN (not just this host) by routing through `homelab-server` as a gateway. Requires `net.ipv4.ip_forward=1` (already enabled on this host) and a separate manual approval step in the Tailscale admin console (`https://login.tailscale.com/admin/machines`) — advertising a route doesn't make it active by itself.
- **DNS split for `thegarden`**: configured in the Tailscale admin console (`https://login.tailscale.com/admin/dns`, not IaC-able — same category as Homarr's integrations, see [glances](../glances/README.md)'s README) — domain `thegarden`, nameserver `100.124.114.120` (this host's tailnet IP, chosen over its LAN IP since the tailnet IP is directly reachable to any tailnet peer regardless of whether the subnet route above is active). This is what makes `*.thegarden` addresses resolve correctly for a device that's off the LAN entirely, routing the DNS query itself back to [pihole](../pihole/README.md) over the tailnet.

Net effect: a phone with the Tailscale app installed and logged into the same account can hit `https://books.thegarden` (or any other `*.thegarden` service) from anywhere with cellular data, exactly as if it were on the home WiFi — confirmed working.

## Security model

No inbound ports opened on the public-facing router — connections are outbound/NAT-traversal-based (similar to WebRTC), so there's nothing for an external scanner to find. Every device requires explicit approval on first login (browser-based OAuth through the account's identity provider, not a Tailscale-specific password), and the subnet route above needed its own separate approval beyond that. The account itself (whichever login provider was used) is the actual security boundary — worth having 2FA on it.

## Known gap

[homelab-server's Ethernet throughput is capped well below what it should be](../homelab-server/notes.md) — doesn't block anything Tailscale-related (DNS/routing both work fine), but it does mean remote access inherits that same bandwidth ceiling. Not a Tailscale problem, tracked separately.
