# Notes — deluge

## 2026-08-11

Deployed alongside the rest of the media stack once the NAS mounts landed, but it's crash-looping and not actually up yet — two blockers hit in sequence:

1. Missing PIA `.ovpn` config file in `data/config/openvpn/` — resolved, file dropped in.
2. Host kernel (`7.0.0-29-generic`) is missing the `ip_tables` module, so the container's VPN killswitch (`iptables`) can't initialize: `modprobe: FATAL: Module ip_tables not found`. Not yet resolved — needs investigating on `homelab-server` directly (kernel module availability), picking back up later.
