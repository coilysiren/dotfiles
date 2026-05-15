---
name: home-hue
description: |
  Control the Philips Hue lights at My House (Hayward) via the openhue
  CLI - list, turn on/off, dim, color-change, activate scenes. Triggers:
  hue, philips hue, hue lights, smart lights, lights, dim the lights,
  brighten the lights, turn on/off the lights, lighting, scene, scenes,
  bedroom lights, living room lights, kitchen lights, lights up,
  lights down, set the mood, lighting scene, control my lights,
  Wolfie Hue, hue bridge.
---

# Hue control via openhue

Local-only control of the Hue Bridge "Wolfie Hue" (BSB002) on the My
House LAN. Auth is the SSM-stored username `/hue/api-username`,
already wired into `~/.openhue/config.yaml` on this Mac.

## Prerequisites

- `openhue` CLI installed (`brew install openhue/cli/openhue-cli`).
- `~/.openhue/config.yaml` populated (one-time):
  ```bash
  KEY=$(cd ~/projects/coilysiren/agentic-os && coily ops aws ssm get-parameter \
    --name /hue/api-username --with-decryption --query Parameter.Value --output text)
  openhue config --bridge 10.0.0.211 --key "$KEY"
  ```
  Bridge IP drifts on DHCP renewal - re-resolve via `dns-sd -L "Hue Bridge - ABE3CA" _hue._tcp local.` if `openhue` errors out connecting.
- Must be on the My House LAN (or reaching it via Tailscale subnet
  routing). The bridge has no cloud auth path for this username.

## Quick recipes

```bash
# What's there
openhue get lights
openhue get rooms
openhue get scenes

# Single light - by name or by ID (UUID)
openhue set light "Hue Play 3" --on
openhue set light "Hue Play 3" --off
openhue set light "Hue Play 3" --brightness 50
openhue set light "Hue Play 3" --color blue

# Whole room
openhue set room "Living room" --on
openhue set room "Bedroom" --brightness 20

# Scene activation
openhue set scene "Relax"          # active recall
openhue set scene "Bright"
```

`--color` accepts named colors (`red`, `aqua_marine`, `dodger_blue`,
etc.) or hex (`#ff8800`). `--brightness` is 0-100.

## When NOT to use this skill

- Hue lights at Elizabeth's House (San Lorenzo) - different bridge,
  no inventory yet.
- Anything outside the LAN - Hue v2 cloud (api.meethue.com/route)
  needs an OAuth flow not set up here.

## Source of truth

- Bridge metadata: `network-inventory.yaml` at coilyco-ai root.
- Auth: `/hue/api-username` in SSM (SSM.md).
- Upstream CLI: <https://github.com/openhue/openhue-cli>
