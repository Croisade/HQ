# beets

Status: Building

Host: [homelab-server](../homelab-server/README.md)

Music library organizer — identifies tracks by audio content (not filename/tags) via AcoustID fingerprinting, cross-references [MusicBrainz](https://musicbrainz.org/), and reorganizes matched files into a proper `Artist/Album/Track` structure with correct tags. Built specifically to clean up [navidrome](../navidrome/README.md)'s `YouTube` catch-all album — 356 tracks pulled via `yt-dlp`, all tagged identically as `Album: YouTube` / `AlbumArtist: YouTube` since their original per-video metadata was too inconsistent to group by directly.

No web UI — CLI only, run via `docker exec`.

## Why fingerprinting, not just tag/filename matching

The 356 tracks in `YouTube/` have messy, inconsistent source metadata — YouTube video titles, not clean `Artist - Track` strings — and their original artist tags were overwritten to a flat `YouTube` placeholder when they were bulk-grouped into one album (see [navidrome](../navidrome/README.md)). Text-based matching against that would perform poorly. AcoustID/Chromaprint fingerprints the actual audio and matches it against known recordings regardless of what the file is named or tagged, which is a much better fit here.

**Expected real-world result, not every track will match**: mainstream studio-released tracks should match well. Game OST tracks, remixes, live sessions, and other non-mainstream/unreleased-in-the-traditional-sense audio have much lower AcoustID hit rates — expect a meaningful chunk of the 356 to come back unmatched and need to stay in the flat catch-all or get tagged by hand.

## Config

`config/config.yaml.example` is the tracked template. The real file, `data/config.yaml`, is gitignored — it holds a real AcoustID API key (free, personal account at [acoustid.org](https://acoustid.org/new-application)), same reasoning as every other `.env`-holding service in this repo.

`import.move: yes` — reorganizes files in place within `/music` rather than copying, since this is a one-library, all-local-disk setup already.

## Data

- `data/library.db` — beets' own SQLite database (gitignored)
- `data/config.yaml` — real config incl. API key (gitignored)
- `data/import.log` — import history

## Not done yet

- AcoustID API key not yet added to `data/config.yaml` — nothing can run until that's in place.
- Full library import not yet run. Plan: test against a small subset first before running against all 356 tracks, since `import.move: yes` reorganizes files in place.
