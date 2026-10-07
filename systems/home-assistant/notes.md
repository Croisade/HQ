# home-assistant — notes

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
