# Hardware — nas

- OS: TrueNAS
- Pool `Triple-Towers`: 2× 3TB drives, mirrored — main pool, hosts `docker-data`
- Pool `Storage`: 1× 1TB drive, standalone — scratch pool, hosts `docker-scratch`. Deliberately not a second top-level vdev in `Triple-Towers`: an unmirrored disk striped alongside the mirror would let that one disk's failure take out the whole pool despite the mirror itself surviving.
