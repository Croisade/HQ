# Build log — homelab-server

## Get to a bare Docker host (completed)

- Installed Docker Engine + Compose plugin (`scripts/install-docker.sh`) — Docker 29.7.1, Compose v5.4.0
- Added `jamal` to the `docker` group; confirmed `docker run hello-world` works without sudo in a fresh login shell
- Created the shared `lab` bridge network (attachable) via `scripts/create-network.sh`, for future workloads to reach each other and be reverse-proxied by name
- Picked [home-assistant](../home-assistant/README.md) as the first workload
