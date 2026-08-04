# Roblox-Aftermath

Potassium script for Aftermath (place `112237800564065`), built on the
[EasyUI / EasyESP / EasyAim](https://github.com/ToiletStarter/CantStopMakingReposForThis)
libraries.

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/Roblox-Aftermath/main/loader.lua"))()
```

That URL is permanent. The loader asks the GitHub API which commit `main`
points at and fetches that exact blob, so the raw CDN's five minute branch
cache can never hand you a stale script. It falls back to jsDelivr and then to
a cache-busted branch URL if the API is unreachable, and prints the version and
short SHA it loaded.

Press **Right Shift** to toggle the menu. Re-running the loader unloads the
previous instance first.

## Features

### Visuals
Separate **Players** and **Zombies** tabs, each with boxes, names, distance,
health bars, skeletons, head dots, tracers, off-screen arrows, chams, box
style, colour and range.

**World** covers rarity-filtered loot, ground weapons, ammo refills, airdrops
and containers, vehicles with live health, bodies and graves, points of
interest, and an entity refresh tuning slider.

### Combat
Split by target type (**Players** / **Zombies**), each with two modes:

- **Legit** — conventional aimbot that moves your camera and cursor:
  smoothing, max step, FOV radius and circle, hitbox, target priority, sticky
  target, wall check, humanisation.
- **Rage / Silent** — resolves a hit point without moving your view: hitbox,
  target priority, range, wall check, prediction factor.

### Self
Live health, hunger, thirst, stamina and a status line covering bleeding,
broken legs and infection. Squad readout. No-fog, fullbright and an opt-in FOV
override.

### Misc
Server info, job-ID copy, client-side gun modifier sliders, and a
**Diagnostics** section — see below.

## Reporting a problem

Misc → Diagnostics → **Copy Verbose Log**. That copies a full report to your
clipboard and writes `AftermathReport.txt` into the Potassium workspace. It
contains roster counts, rig samples with their children and health, ESP and aim
internals, world source counts, every toggle value, and a rolling event log.
Paste that when something misbehaves — it is far more useful than a screenshot.

**Rescan Rigs** forces an immediate roster rebuild and reports the counts.

## Game notes

Aftermath does not populate `Player.Character`. A diagnostic against a live
33-player server found `LocalPlayer.Character` nil, only 15 models in
`game_assets.Entities`, and zero matches across seven different Player-to-model
linking strategies. Any ESP that walks `Players:GetPlayers()` and reads
`.Character` will therefore draw nothing.

This script instead scans for rigs — models containing a `HumanoidRootPart` —
classifies them by whether they carry gear, and excludes the rig nearest the
camera as the local body. Health is read from attributes (`Health` /
`MaxHealth`) or a `States` configuration, never from a `Humanoid`, because the
infected use an `AnimationController` named `Humanoid` rather than a real one.

## Status

Verified against a mocked Aftermath world: 18 smoke assertions covering panel
construction, the verbose report builder, both aim instances and the scheduled
jobs; 89 widgets build clean. The rig classification heuristic is inferred from
structure rather than confirmed by a live sample — if players and zombies are
labelled the wrong way round, the verbose log contains the rig children needed
to correct it.
