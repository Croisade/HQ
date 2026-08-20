#!/usr/bin/env bash
# Pull audio out of a YouTube URL and drop it into Navidrome's library, for
# songs that only exist on YouTube (no MusicBrainz release, so lidarr has
# nothing to search for). Runs yt-dlp via a one-off container rather than
# installing it on the host, matching this repo's convention of keeping
# tools containerized (see restic for the same pattern with a CLI tool).
#
# Works on both a single video URL and a playlist URL — yt-dlp downloads
# every item when given a playlist by default, no flag needed. Playlist
# items land in their own subfolder (named after the playlist); a single
# video lands directly in YouTube/.
#
# Usage: ./download-song.sh <youtube-url-or-playlist-url>
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <youtube-url-or-playlist-url>" >&2
  exit 1
fi

DEST=/mnt/docker-data/media/music/YouTube
mkdir -p "$DEST"

# jauderho/yt-dlp:latest ships a stable yt-dlp release whose android_vr
# client extraction is currently broken by a YouTube-side change (fails
# with "unable to download video data: HTTP Error 403: Forbidden" on
# basically every video — confirmed against yt-dlp/yt-dlp#17456, fixed
# upstream in nightly builds, no fixed image tag published yet). Self-update
# to nightly inside the container on every run rather than pin a specific
# nightly version, since this is a fast-moving fight against YouTube's
# anti-bot changes and stable lags behind by design.
#
# Runs as root (the image's default) so the self-update can write to
# /usr/local/bin/yt-dlp, then chowns the output back to 1000:1000 — running
# the whole thing as 1000:1000 from the start makes the self-update fail
# with a permission error instead.
docker run --rm \
  --entrypoint sh \
  -v "$DEST:/downloads" \
  jauderho/yt-dlp:latest \
  -c "yt-dlp --update-to nightly && yt-dlp \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    --embed-thumbnail \
    --add-metadata \
    --sleep-requests 2 \
    -o '/downloads/%(playlist_title&{}/|)s%(playlist_index&{}. |)s%(title)s.%(ext)s' \
    '$1' \
    && chown -R 1000:1000 /downloads"

echo "Saved to $DEST — navidrome picks it up on its next hourly scan (or trigger one manually in its UI)."
