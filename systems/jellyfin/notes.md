# Notes — jellyfin

## 2026-08-11

**Recurring bug found and mitigated**: newly-imported episodes for a *brand-new* series (one Jellyfin has never indexed before) can show up as findable via a generic item search, but not through `/Shows/{id}/Episodes` — the actual endpoint the web/app clients use to render a season page. Symptom from the user's side: "Unable to find a valid media source to play," and/or only a subset of episodes visible (sometimes just one). Hit twice in one day, both times on a new anime series where [sonarr](../sonarr/README.md) imported many episodes (5, then 10) in a tight few-minute burst — the per-import `updateLibrary` notification call Sonarr fires (see [sonarr's notification setup](../sonarr/README.md)) is a small targeted update, and doesn't reliably finish building the full Series→Season→Episode relationship tree under that kind of burst load for a series with no prior tree to extend.

Fix for an already-affected series: force a full metadata refresh, not just a rescan —
```
POST /Items/{seriesId}/Refresh?Recursive=true&MetadataRefreshMode=FullRefresh&ImageRefreshMode=FullRefresh&ReplaceAllMetadata=false&ReplaceAllImages=false
```
A plain library scan (`/Library/Refresh`) is not sufficient — it finds files but doesn't reliably rebuild the relationship tree either.

**Durable mitigation applied**: Jellyfin's built-in `Scan Media Library` scheduled task defaulted to a 12-hour interval — far too infrequent to self-heal this in any reasonable time. Shortened to hourly (`IntervalTicks: 36000000000`, via `POST /ScheduledTasks/{id}/Triggers`) as a safety net, since Jellyfin's own scans are incremental/cheap when nothing's actually changed. This doesn't eliminate the underlying gap, but bounds how long a newly-added series can stay broken to about an hour without needing manual intervention.

If this recurs on a series you *can't* wait an hour for, trigger the full-refresh command above directly rather than waiting on the schedule.
