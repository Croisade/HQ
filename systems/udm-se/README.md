# udm-se

Status: Operational

Physical appliance (Ubiquiti Dream Machine SE) — router/firewall for the LAN. No `config/` here; it's managed through the UniFi Network controller UI, not IaC, so this repo can only document the decisions made there, not apply them.

## DNS handoff to Pi-hole

For `*.thegarden` to resolve on any device on the LAN (not just the docker host), the UDM-SE's DHCP needs to hand out [pihole](../pihole/README.md) (`192.168.1.101`) as the DNS server instead of its own default resolver. Set manually in UniFi Network → Settings → Networks → (LAN network) → DHCP Name Server → switch from Auto to Manual, `192.168.1.101`.

Once that's set: client → UDM-SE (DHCP) → Pi-hole (DNS, wildcard record for `thegarden`) → [traefik](../traefik/README.md) (reverse proxy on `192.168.1.101:80`) → the actual service container.
