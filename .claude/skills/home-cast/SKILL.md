---
name: home-cast
description: |
  Cast media to and inspect the two Google Nest Hubs ("Kai's Desk",
  "Kai's Bathroom") and the Cast group spanning both, at My House.
  Triggers: cast, chromecast, nest hub, nest hubs, google nest, kai's
  desk hub, kai's bathroom hub, play on the hub, cast to the hub,
  show on the hub, eureka, kitchen display, smart display.
---

# Google Cast control (Nest Hubs, My House)

Two Nest Hub displays + a Cast group, LAN-only control. No auth - the
Cast protocol is open on local network.

## Preferred CLI: go-chromecast

```bash
brew install vishen/tap/go-chromecast   # active 2026-04

go-chromecast ls                                     # discover
go-chromecast --device-name "Kai's Desk" status
go-chromecast --device-name "Kai's Desk" volume 0.5
go-chromecast --device-name "Kai's Desk" load <url>   # cast media URL
go-chromecast --device-name "Kai's Desk" tts "Dinner is ready"
go-chromecast --device-name "Kai's Desk" pause/unpause/stop
```

Targeting the Cast group: use the group name from `go-chromecast ls`,
which fans out to all members.

## Alternative: catt (simpler ergonomics)

```bash
pipx install catt
catt scan
catt -d "Kai's Desk" cast https://example.com/video.mp4
catt -d "Kai's Desk" cast_site https://news.ycombinator.com  # browser-mirror
```

## Setup-API reads (HTTPS/8443)

Useful when go-chromecast misses something:

```bash
# Full device info
curl -sk "https://10.0.0.160:8443/setup/eureka_info?options=detail" | jq

# Reboot a hub
curl -sk -X POST "https://10.0.0.160:8443/setup/reboot" \
  -H "Content-Type: application/json" -d '{"params":"now"}'
```

## What this won't do

- Trigger Assistant routines / voice commands. The mic and the
  Assistant pipeline are not exposed locally.
- Show photos from your library on the Nest Hub frame. That's
  Google-cloud-bound to your account.
- Open arbitrary apps. Cast receivers run only signed receiver apps -
  you can cast media URLs and known apps (YouTube, Spotify), not
  load arbitrary HTML beyond `cast_site`'s screen-mirror trick.

## Source of truth

- Device metadata: `network-inventory.yaml` → `homes.my_house.devices`
  (filter `type: google_nest_hub` or `google_cast_group`).
- Type-level reference: `network-inventory.yaml` →
  `device_types.google_nest_hub`.
