#!/usr/bin/env bash
# Installs and joins this host to the tailnet. Run once; `tailscale up` will
# print a URL that needs opening in a browser to authenticate the device —
# not scriptable further than that.
set -euo pipefail

curl -fsSL https://tailscale.com/install.sh | sudo sh

sudo tailscale up --advertise-routes=192.168.1.0/24

echo
echo "Now go to https://login.tailscale.com/admin/machines and approve the"
echo "advertised 192.168.1.0/24 subnet route — advertising it doesn't make"
echo "it active by itself."
echo
echo "Then go to https://login.tailscale.com/admin/dns and add a Split DNS"
echo "nameserver: domain 'thegarden', nameserver this host's tailnet IP"
echo "(see 'tailscale status' for the current one) — not scriptable, lives"
echo "in Tailscale's own account settings."
