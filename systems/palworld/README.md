# palworld

Status: Operational

Host: [homelab-server](../homelab-server/README.md)

Palworld dedicated server, migrated from a Windows-hosted install to this Docker container using [thijsvanloef/palworld-server-docker](https://github.com/thijsvanloef/palworld-server-docker). The existing world save was carried over rather than starting fresh.

- Game port: `8211/udp`
- Query port: `27015/udp`
- RCON: enabled internally (port `25575`, not published) so the container can stop the server gracefully

## Config

`PalWorldSettings.ini` is hand-maintained at `data/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini` (gitignored — `data/` holds machine state, not IaC). `DISABLE_GENERATE_SETTINGS=true` in `config/compose.yaml` stops the container from overwriting it with env-derived values on every boot. To change server settings, edit the ini directly and restart the container.

`ADMIN_PASSWORD` in `config/.env` must match the `AdminPassword` set in the ini — the container uses it over RCON to request a graceful save-and-stop.
