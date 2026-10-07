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

## 2026-10-01

Connected Claude Code to Home Assistant using HA's built-in Model Context Protocol Server integration.

- Added the integration from the UI (Settings → Devices & services). Its only option, "Control Home Assistant", is set to Assist.
- The endpoint is `/api/mcp` on the HA port. It returns 404 until the integration is added, then 405 to a plain GET because it only accepts POST.
- Authentication is a long-lived access token passed as a bearer header. The token lives only in the Claude Code config, never in this repo.
- Only entities exposed under Settings → Voice assistants → Expose are visible to the MCP client, so exposure is the access control. Be deliberate about control-capable entities such as power plugs.
- Verified by reading live state of the Nest thermostat and other exposed entities.
