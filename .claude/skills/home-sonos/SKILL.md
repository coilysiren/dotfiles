---
name: home-sonos
description: |
  Control the Sonos "Desk Double" stereo pair (two Sonos One SL units)
  at My House (Hayward) - play/pause, volume, current-track readout,
  queue manipulation, AirPlay-2 routing. Triggers: sonos, desk double,
  speakers, speaker, play music, pause music, volume up, volume down,
  mute, unmute, what's playing, current track, queue, sonos one,
  airplay, stereo pair, my speakers.
---

# Sonos control (Desk Double, My House)

Two Sonos One SL units stereo-paired as "Desk Double", LAN-only control.
No auth needed; Sonos UPnP API is open on local network.

## Quick LAN reads (no install needed)

```bash
# Identify a unit / room layout
SONOS_IP=10.0.0.22   # left unit; right is 10.0.0.213; either works for the pair
curl -s "http://$SONOS_IP:1400/xml/device_description.xml" | head -30
curl -s "http://$SONOS_IP:1400/status/topology" | head -40

# Currently playing track (quick SOAP example)
curl -s -X POST "http://$SONOS_IP:1400/MediaRenderer/AVTransport/Control" \
  -H 'Content-Type: text/xml; charset="utf-8"' \
  -H 'SOAPACTION: "urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo"' \
  --data-binary '<?xml version="1.0" encoding="utf-8"?>
  <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
   <s:Body><u:GetPositionInfo xmlns:u="urn:schemas-upnp-org:service:AVTransport:1">
    <InstanceID>0</InstanceID></u:GetPositionInfo></s:Body>
  </s:Envelope>'
```

## Preferred path: soco-cli

```bash
pipx install soco-cli   # or pip install --user soco-cli

# Discovery
sonos --discover-info

# By room name (the Sonos app's room label)
sonos "Desk Double" play
sonos "Desk Double" pause
sonos "Desk Double" volume 30
sonos "Desk Double" track          # what's playing
sonos "Desk Double" status
sonos "Desk Double" queue
sonos "Desk Double" mute on/off
sonos "Desk Double" line_in        # switch source
```

`soco-cli` autodiscovers via SSDP, so no IPs need configuring.

## When to drop down to UPnP curl

- one-shot ops where adding a python dep is too much
- diagnostics when soco-cli is misbehaving
- automating from a constrained env (no python, no go)

Use `https://docs.svrooij.io/node-sonos-ts/sonos-api/` as the
SOAP-action reference.

## What this won't do

- Cloud Sonos features (Voice, Trueplay, Sonos Radio HD subscriptions) -
  those are app-only.
- Add new music services - account-bound.
- Pair with non-Sonos speakers (use AirPlay 2 from a sender for that).

## Source of truth

- Device metadata: `network-inventory.yaml` → `homes.my_house.devices`
  (filter `type: sonos_speaker`).
- Type-level reference: `network-inventory.yaml` → `device_types.sonos_speaker`.
