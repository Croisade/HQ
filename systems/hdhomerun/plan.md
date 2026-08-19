# Plan

- [ ] Buy HDHomeRun Flex Duo
- [ ] Buy Channel Master Flatenna 35 (or equivalent non-amplified indoor antenna)
- [ ] Pick antenna placement — window, faced roughly NNE (~25° true, where Philly's towers cluster); doesn't need to be the top of the house given signal strength
- [ ] Figure out how the tuner reaches the network from that spot — direct cable run if close enough to an existing run/switch, otherwise a powerline adapter
- [ ] Physically install: antenna → coax → tuner → ethernet → network
- [ ] Add the tuner as a Live TV source in [jellyfin](../jellyfin/README.md), scan channels
- [ ] Confirm the channels found match what the TV Fool survey predicted — if something's missing, remember the survey's underlying transmitter database was last updated 2013, so a station may have moved in the FCC's 2019-2020 channel repack
- [ ] Once working, update this system's `README.md` status to Operational and move this checklist to `build-log.md`
