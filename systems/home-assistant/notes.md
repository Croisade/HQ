# home-assistant — notes

## 2026-10-10

Added **Z-Wave** with a Zooz 800-series USB stick, run as a separate `zwave-js-ui` container in the same compose project (HA stays on host networking).

- **Why a separate container:** zwave-js-ui owns the stick and the S0/S2 security keys, and HA connects to its websocket. Restarting HA doesn't touch the Z-Wave network.
- **Access:** UI at `https://zwave.thegarden` through Traefik (no published UI port). The websocket is published on host port 3010 for HA's Z-Wave JS integration (3000 and 3001 were taken by Grafana and Uptime Kuma).
- **Config:** stick path, session secret and timezone come from `config/.env` (gitignored; `.env.example` lists the variables). State lives in the `zwave-config` Docker volume, including the keys, so back those up.
- **Traefik cert:** `zwave.thegarden` had to be added to the mkcert SAN list and Traefik restarted (see the Traefik README).
- **First device:** a Z-Wave smart lock, paired with Smart Start (DSK). The server's stick could not hear its Smart Start announcement, so it was paired by running zwave-js-ui on a laptop with the same S0/S2 keys, then moving the stick back. The server re-interviewed the node; a battery lock falls asleep mid-interview, so keep it awake (keypad) and re-interview until it completes. Link quality afterward: RSSI about -78 dBm direct, no repeaters, against a noise floor around -105 dBm. Usable, with limited margin.
- **Pitfalls:** moving the stick between machines only works if the keys match exactly. On Windows the serial port is a COM port, not the container's `/dev/zwave`.
- **Dashboard and alert:** the Home tab's House section now shows the lock, door state and lock battery (read-only, no unlock from the Home tab), plus a status line in the summary text. A new **Security** tab has lock/unlock controls, lock health sensors (battery, jammed, intrusion, keypad, hardware, Z-Wave link) and a history graph and logbook. An automation, `Front Door Unlocked Too Long`, sends a high-importance push to both phones through `script.notify_and_log` if the lock stays unlocked for 15 minutes. The lock model has no door-position sensor (its door status is always "open"), so the dashboards show the bolt state only.
- **Disk:** `/` hit 100% while setting this up. Pruning dangling images freed 6.8 GB (94% used afterward). Jellyfin config (15 GB) and the Prometheus WAL (4.8 GB) are the next candidates.

## 2026-10-07

Added a **Heat** tab to the Overview dashboard, with charts of the Nest thermostat's history and an outdoor temperature to compare against.

- **History available:** the recorder keeps per-change state for 10 days (default retention). Hourly long-term statistics for the temperature and humidity sensors are kept indefinitely, so the charts use those.
- **Cards on the tab:** the live thermostat card, a 7-day thermostat history graph, hourly min/avg/max temperature for 30 days, daily humidity for 90 days, and an indoor-vs-outdoor graph (hourly average, 30 days).
- **Outdoor temperature:** the Nest does not expose it. The Google Home app gets it from Google's own weather feed, not the thermostat. A template sensor, `sensor.outdoor_temperature`, copies the temperature attribute of a weather entity so HA records it as a long-term statistic. It started on the built-in Met.no forecast, then moved to the National Weather Service integration, which reports real observations from the nearest station (a forecast model can be off by several degrees).

  ```yaml
  - sensor:
      - name: "Outdoor Temperature"
        unique_id: outdoor_temperature
        unit_of_measurement: "°F"
        device_class: temperature
        state_class: measurement
        availability: "{{ state_attr('weather.nws_<station>', 'temperature') is number }}"
        state: "{{ state_attr('weather.nws_<station>', 'temperature') }}"
  ```

- **Entity IDs embed the location.** The NWS integration names its entities from the home latitude and longitude. In a public repo, rename the weather entity first (Settings → Devices & services → Entities → the entity's settings) so the template does not leak it.
- **Where it lives:** `data/` is gitignored, so the dashboard (`.storage/lovelace.lovelace`) and `templates.yaml` are not in this repo. Both were edited with HA stopped, because HA keeps `.storage` in memory and overwrites it, then started again. Backups sit next to the originals as `*.bak-20261006*`.
- **Statistics take time:** a new sensor has no hourly rows until the first hour after it starts, so a new chart shows only the old series until then.
- **Is the thermostat accurate?** The data is self-consistent: continuous readings with no unavailable states, a daily rhythm, and a setpoint schedule that fires on time. That shows the sensor is alive, not that it is correct. Compare against a second thermometer next to it for an hour, and watch for a warm wall or direct sun, which push a thermostat's reading high.

### Home tab, theme and light/dark switch

- **Home tab:** a sections-style dashboard view, three columns under a full-width header. The header has a time-based greeting and Day / Auto / Night buttons. The left column is a clock and 5-day forecast card plus a Markdown card of plain-language status sentences. The middle column is the heat controls (thermostat tile with mode and target, indoor / outdoor / humidity tiles, a 24-hour graph) plus house tiles. The right column is a month calendar, the notification counters and log, and the shopping list. The old auto-generated view was kept as "All Entities".
- **Grid gotcha:** `max_columns` must match the intended column count. A full-width section in a 4-column grid pushed the other sections out of place.
- **Markdown cards:** strip inline `style=`, so use `##` headings, and wrap rounding in `float(0)` so a briefly `unknown` sensor does not raise a template error.
- **Theme:** the Material You theme and its Utilities module, installed from HACS. The module overrides the card variables itself, so card contrast is adjusted with its "CSS path/URL" option and a stylesheet in `www/`, not by editing the theme file. HACS updates overwrite the theme file, a separate stylesheet survives them.
- **Custom cards:** Clock Weather Card and Browser Mod, both from HACS. Browser Mod must be added as an integration after the HACS download.
- **Light/dark mode:** `frontend.set_theme` with a `mode` does not switch the display. Reading HA's source showed it only chooses which theme name is the default for light and for dark. Dark mode is a per-browser setting, so the Day / Auto / Night buttons call `browser_mod.set_theme` with `browser_id: THIS`. The value for Auto is lowercase `auto`, and the browser must be registered in Browser Mod first.

### Bluetooth in the container

- **Symptom:** the log filled with `Failed to force stop scanner` and `'NoneType' object has no attribute 'send'` every minute or so.
- **Cause, in two layers:** the container lacked `NET_ADMIN` / `NET_RAW`, and the host had no BlueZ. After both were fixed, Docker's default AppArmor profile still blocked D-Bus calls (`apparmor="DENIED" operation="dbus_method_call"` in the kernel log).
- **Fix:** installed `bluez` on the host and enabled the `bluetooth` service. Compose gained `cap_add: [NET_ADMIN, NET_RAW]`, a read-only `/run/dbus` mount and `security_opt: apparmor=unconfined`.
- **Trade-off:** the HA container no longer has AppArmor confinement. A custom profile (the default plus a rule allowing D-Bus to `org.bluez`) would be tighter if that matters later.
- **Verified:** no scanner errors after the change, no new D-Bus denials, and a D-Bus call from inside the container reaches BlueZ.

### Calendar privacy

The Google Calendar integration cannot filter events by their Private flag. It only offers a keyword `search` and an availability setting, and anything its account can read is shown. To keep events off the dashboard, put them on a separate calendar and leave that calendar out of the card, and disable the entity HA creates for it. HA only discovers a new calendar after the integration is reloaded.

### Updates

HA updated from 2026.9.0 to 2026.10.0 by pulling the `stable` image and recreating the container. A config backup was taken first and entities, including the Nest, updated normally afterwards.

## 2026-10-01

Connected Claude Code to Home Assistant using HA's built-in Model Context Protocol Server integration.

- Added the integration from the UI (Settings → Devices & services). Its only option, "Control Home Assistant", is set to Assist.
- The endpoint is `/api/mcp` on the HA port. It returns 404 until the integration is added, then 405 to a plain GET because it only accepts POST.
- Authentication is a long-lived access token passed as a bearer header. The token lives only in the Claude Code config, never in this repo.
- Only entities exposed under Settings → Voice assistants → Expose are visible to the MCP client, so exposure is the access control. Be deliberate about control-capable entities such as power plugs.
- Verified by reading live state of the Nest thermostat and other exposed entities.
