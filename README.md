<div align="center">

# Aftermath

**A single-file Luau utility script for the Roblox game [Aftermath](https://www.roblox.com/games/112237800564065) — ESP, aim assistance, survival readouts, and a diagnostics reporter.**

[![Version](https://img.shields.io/badge/version-2.1.0-brightgreen?style=flat-square)](https://github.com/ToiletStarter/Roblox-Aftermath/commits/main)
[![Language](https://img.shields.io/badge/language-Luau-blue?style=flat-square)](https://luau.org/)
[![Place ID](https://img.shields.io/badge/place-112237800564065-lightgrey?style=flat-square)](https://www.roblox.com/games/112237800564065)
[![Single file](https://img.shields.io/badge/build-none%20required-informational?style=flat-square)](#how-the-loader-works)

</div>

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/ToiletStarter/Roblox-Aftermath/main/loader.lua'))()
```

Paste that into your executor and run it. Press **Right Shift** to open the menu.

> [!NOTE]
> **Right Shift** toggles the menu · **Delete** reopens it if you lose it · **End** unloads everything instantly.

---

## Table of contents

- [Quick start](#quick-start)
- [Why this script exists](#why-this-script-exists)
- [Features](#features)
  - [Visuals](#visuals)
  - [Combat](#combat)
  - [Self](#self)
  - [Misc](#misc)
- [Keybinds](#keybinds)
- [How the loader works](#how-the-loader-works)
- [Reporting a bug](#reporting-a-bug)
- [Troubleshooting](#troubleshooting)
- [How it finds players (and why that was hard)](#how-it-finds-players-and-why-that-was-hard)
- [Project layout](#project-layout)
- [Built on](#built-on)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
- [License](#license)

---

## Quick start

1. Join **Aftermath** (place `112237800564065`).
2. Run the loadstring above in any executor that supports `loadstring`, `game:HttpGet`, and Drawing-style rendering.
3. Wait for the `Aftermath v2.1.0 — Loaded` notification.
4. Press **Right Shift**.

Player ESP with boxes, names, distance, and health bars is **on by default** — you should see it immediately. Everything else is opt-in.

Re-running the loadstring is safe: the script detects a previous instance, tears it down completely, and reloads. You never need to rejoin to update.

---

## Why this script exists

Aftermath does not populate `Player.Character`. Any ESP that iterates `Players:GetPlayers()` and reads `.Character` draws **nothing at all** in this game — which is why most generic script hubs appear to load fine here and then do nothing.

This script works around that with a rig-scanning roster and reads health from attributes rather than a `Humanoid`. See [How it finds players](#how-it-finds-players-and-why-that-was-hard) for the details.

---

## Features

Four tabs: **Visuals**, **Combat**, **Self**, **Misc**.

### Visuals

Three sub-tabs — **Players**, **Zombies**, **World**.

<details open>
<summary><b>Players &amp; Zombies ESP</b></summary>

Players and Zombies are separate toggles with independent enable state. Both draw through the same style configuration, which is edited on the **Players** sub-tab.

| Option | Type | Default | Notes |
| --- | --- | --- | --- |
| Enable Player ESP | toggle | **on** | Rigs classified as players |
| Enable Zombie ESP | toggle | off | Rigs classified as infected |
| Boxes | toggle | on | |
| Names | toggle | on | |
| Distance | toggle | on | Studs from camera |
| Health Bar | toggle | on | Read from attributes, not `Humanoid` |
| Skeleton | toggle | off | |
| Head Dot | toggle | off | |
| Tracers | toggle | off | |
| Off-screen Arrows | toggle | off | Direction indicators for targets outside view |
| Chams | toggle | off | |
| Box Style | dropdown | `corner` | `corner` · `box` · `3d` |
| Color | colour picker | purple / red | Players default purple, zombies default red |
| Range | slider | 5000 | 100–5000 studs |

> Zombies share the ESP style set on the Players sub-tab. Only the enable toggle lives on the Zombies sub-tab.

</details>

<details>
<summary><b>World ESP</b></summary>

**Loot**

| Option | Type | Default |
| --- | --- | --- |
| Items | toggle | off |
| Rarity Filter | dropdown | `All` |
| Ground Weapons | toggle | off |
| Ammo Refills | toggle | off |

The rarity filter recolours item markers to match the selected tier.

**World Objects**

| Option | Type | Default |
| --- | --- | --- |
| Airdrops / Containers | toggle | off |
| Vehicles | toggle | off |
| Bodies / Graves | toggle | off |
| Points of Interest | toggle | off |

**Tuning**

| Option | Type | Range | Default |
| --- | --- | --- | --- |
| Entity Refresh (frames) | slider | 1–10 | 3 |

Raise **Entity Refresh** if world ESP costs you frames — it refreshes world entities every *N* frames instead of every frame.

</details>

<details>
<summary><b>Panic controls</b></summary>

At the top of **Visuals → Players**:

- **UNLOAD EVERYTHING** — full teardown, same as the End key.
- **Disable All Visuals** — turns off every ESP category, restores original lighting (brightness, clock time, fog, ambient) and your original camera FOV, without unloading the menu.

</details>

### Combat

Two sub-tabs — **Players** and **Zombies** — each with an identical, **independent** set of controls. Aiming at players and aiming at zombies are configured separately.

<details open>
<summary><b>Legit — moves your camera and cursor</b></summary>

| Option | Type | Range / values | Default |
| --- | --- | --- | --- |
| Enable Legit Aim | toggle | | off |
| Aim Key | keybind | any key / mouse button | Right Mouse |
| Hitbox | dropdown | Head · Torso · Root · Nearest | Head |
| Target Priority | dropdown | fov · distance · health | fov |
| Smoothing | slider | 0.02–1.00 | 0.18 |
| Max Step (px) | slider | 5–300 | 60 |
| Range | slider | 50–3000 | 1500 |
| FOV Radius | slider | 10–600 | 130 |
| Show FOV Circle | toggle | | on |
| Sticky Target | toggle | | off |
| Wall Check | toggle | | off |
| Humanize | toggle | | off |

Lower **Smoothing** is slower and smoother. **Max Step** caps how far the cursor may travel in a single frame — it is the main knob for keeping motion plausible. **Sticky Target** holds the current target until it dies or leaves range instead of re-picking every frame.

</details>

<details>
<summary><b>Rage / Silent — no camera movement</b></summary>

| Option | Type | Range / values | Default |
| --- | --- | --- | --- |
| Enable Silent Aim | toggle | | off |
| Hitbox | dropdown | Head · Torso · Root · Nearest | Head |
| Target Priority | dropdown | distance · fov · health | distance |
| Range | slider | 50–5000 | 3000 |
| Wall Check | toggle | | off |
| Prediction | toggle | | off |
| Prediction Factor | slider | 0.000–1.000 | 0.165 |

Silent aim resolves a hit point without moving your view. **Prediction Factor** leads moving targets; it only applies while **Prediction** is enabled.

</details>

### Self

Read-only survival telemetry plus local visual overrides. All values are read from player attributes and refresh once per second.

| Section | Contents |
| --- | --- |
| **Survival** | Health, Hunger, Thirst, Stamina, and a Status line covering bleeding, broken legs, and infection level |
| **Squad** | Current squad name, or `none` |
| **Visual** | No Fog · Fullbright · Override FOV · Field of View slider (40–120) |

Original lighting and FOV values are captured at load and restored when you toggle these off or unload.

### Misc

| Section | Contents |
| --- | --- |
| **Server** | Server name, player count, live rig count, **Copy Job ID**, **UNLOAD EVERYTHING** |
| **Diagnostics** | **Copy Verbose Log**, **Stream Log to Console**, **Rescan Rigs** — see [Reporting a bug](#reporting-a-bug) |
| **Gun Modifiers** | Recoil, Accuracy (Hipfire), Accuracy (Aimed), Aim Speed, Reload Speed |

> [!WARNING]
> **Gun Modifiers are client-side.** They fire the game's own modifier events. The server may ignore or reject them, and the section is hidden entirely if the game's `GunModifiers` events are not present. Treat any effect as a bonus, not a guarantee.

A **Config** tab is also present, provided by EasyUI, for saving and loading your settings.

---

## Keybinds

| Key | Action |
| --- | --- |
| **Right Shift** | Toggle the menu |
| **Delete** | Force the menu visible again if it is hidden or lost |
| **End** | Hard unload — disconnects everything, restores lighting and FOV, removes the UI |

Keybinds are ignored while you are typing into a text box.

---

## How the loader works

The loadstring URL is **permanent**. You never need a new link.

`loader.lua` does not simply fetch the branch file, because `raw.githubusercontent.com` caches branch content for about five minutes and would happily hand you a stale script right after an update. Instead it:

1. Asks the GitHub API which commit `main` currently points at.
2. Fetches that **exact commit SHA** from `raw.githubusercontent.com` — immutable, never cached stale.
3. Falls back to jsDelivr pinned to the same SHA.
4. Falls back to a cache-busted branch URL, then to jsDelivr on `@main`, if the API is unreachable.

It then compiles the source, prints the version and short SHA it loaded, and runs it. Every failure mode — download, compile, runtime — produces a Roblox notification and a descriptive error rather than failing silently.

```
[Aftermath] loading v2.1.0 (6b14240, source 1)
```

Running the loader while a previous instance is active triggers a full teardown of the old one first, so re-running is always the correct way to update.

---

## Reporting a bug

**Do not send a screenshot.** Send the verbose log — it contains everything needed to diagnose the problem, and screenshots almost never do.

### Steps

1. Reproduce the problem.
2. Open the menu → **Misc** → **Diagnostics**.
3. Click **Copy Verbose Log**.
4. Paste it into a [new issue](https://github.com/ToiletStarter/Roblox-Aftermath/issues/new).

The report is copied to your clipboard and, if your executor supports `writefile`, also saved as **`AftermathReport.txt`** in your executor's workspace folder. The label under the button confirms the size and time, e.g. `Copied 8412 chars @ 21:04:37`.

### What the report contains

| Block | Contents |
| --- | --- |
| Header | Script version, timestamp, executor name, place ID, job ID, whether EasyESP and EasyAim loaded |
| Roster | Player-service count, total rigs, rigs classified as players vs zombies, local rig, `LocalPlayer.Character` state, every scan root with child counts |
| Rig samples | First five rigs — name, parent path, class, root part, health, player-vs-zombie classification, and the first ten children |
| ESP state | Config flags, ESP range, live draw/pool/roster/entity counts, FPS, and what the source function returns |
| Aim state | For both legit and rage instances: enabled, mode, running, and current roster size |
| World sources | Live counts of loot, weapons, ammo, containers, vehicles, corpses |
| Toggles | Every runtime state value |
| Event log | Rolling log of the last 600 internal events |

Nothing in the report identifies you beyond the in-game job ID and your executor's name.

### Other diagnostics tools

- **Rescan Rigs** — forces an immediate roster rebuild and reports `rigs=N players=N zombies=N`. Use this first if ESP looks empty.
- **Stream Log to Console** — mirrors every internal event to your executor console live, useful for catching the exact moment something breaks.

---

## Troubleshooting

<details>
<summary><b>Nothing happens / the menu never appears</b></summary>

The loader notifies on every failure — check for a Roblox notification and your executor console. Most likely causes:

- Your executor does not implement `loadstring` or `game:HttpGet`.
- HTTP requests are blocked. Confirm your executor allows outbound HTTP.
- EasyUI failed to download, in which case the script returns early with an `EasyUI failed:` notification.

Press **Delete** first — the menu may simply be hidden.

</details>

<details>
<summary><b>ESP is enabled but I see nothing</b></summary>

1. **Misc → Diagnostics → Rescan Rigs.** If it reports `rigs=0`, the script cannot see any bodies at all — send the verbose log.
2. Check the **Range** slider on Visuals → Players. It caps at 5000 studs.
3. Confirm you are in the right game. The script warns in the log if `game.PlaceId` does not match `112237800564065`, and world lookups will find nothing elsewhere.

</details>

<details>
<summary><b>Players and zombies are labelled the wrong way round</b></summary>

Rig classification is a structural heuristic — it checks whether a rig carries gear. It is inferred rather than confirmed against every possible game state, so it can be wrong.

Send the verbose log. The **RIG SAMPLES** block lists each rig's children, which is exactly what is needed to correct the heuristic.

</details>

<details>
<summary><b>The tab says "EasyESP failed to load." or "EasyAim failed to load."</b></summary>

The library download failed. The script degrades gracefully — the rest of the menu still works — but that feature is unavailable for the session. Re-run the loadstring. If it persists, the library repository may be unreachable from your network.

</details>

<details>
<summary><b>Lighting or FOV stayed changed after unloading</b></summary>

This was a bug fixed in v2.1. Update by re-running the loadstring. If it still happens, press **End** — the hard unload explicitly restores brightness, clock time, fog, ambient, outdoor ambient, and camera FOV — and file an issue with the log.

</details>

<details>
<summary><b>Gun Modifiers section is missing</b></summary>

Expected behaviour. The section only builds if the game's `GunModifiers` remote events exist under `ReplicatedStorage.GunSystem.Event`. If the game updates and moves them, the section disappears rather than erroring.

</details>

---

## How it finds players (and why that was hard)

A diagnostic run against a live 33-player server found:

- `LocalPlayer.Character` was **nil**.
- Only **15 models** existed in `game_assets.Entities` — far fewer than the player count.
- **Zero matches** across seven different strategies for linking a `Player` object to its in-world model.

So the usual approach is impossible here. Instead the script:

1. **Scans for rigs** — any model containing a `HumanoidRootPart` — across several candidate roots.
2. **Classifies each rig** by whether it carries gear, separating players from infected.
3. **Excludes the rig nearest the camera** and treats it as your own body.
4. **Reads health from attributes** (`Health` / `MaxHealth`) or a `States` configuration — never from a `Humanoid`, because the infected use an `AnimationController` *named* `Humanoid` rather than a real one.

This is why the diagnostics tooling is unusually thorough: the roster is heuristic, so the script is built to explain itself when the heuristic is wrong.

---

## Project layout

| File | Purpose |
| --- | --- |
| `loader.lua` | Permanent entry point. Commit-pinned fetch with fallbacks. **This is the only URL you need.** |
| `script.txt` | The script itself — single file, no build step. |
| `diag.luau` | Standalone ESP diagnostic. Dumps the world structure the script relies on. |
| `deep.luau` | Standalone deep link-hunt. Tests Player-to-model linking strategies exhaustively. |

`diag.luau` and `deep.luau` are development aids, run directly when investigating a game update. Normal use never needs them.

---

## Built on

Three first-party libraries, maintained in a separate repository and fetched at runtime:

| Library | Role |
| --- | --- |
| [**EasyUI**](https://github.com/ToiletStarter/CantStopMakingReposForThis/blob/main/easyui/EasyUi_Documentation.md) | Window, tabs, sub-tabs, every widget, notifications, config save/load |
| [**EasyESP**](https://github.com/ToiletStarter/CantStopMakingReposForThis/blob/main/easyesp/EasyESP_Documentation.md) | All drawing — boxes, skeletons, chams, tracers, arrows, world entities |
| [**EasyAim**](https://github.com/ToiletStarter/CantStopMakingReposForThis/blob/main/easyaim/EasyAim_Documentation.md) | Target selection, legit smoothing, silent resolution, prediction, visibility checks |

→ [ToiletStarter/CantStopMakingReposForThis](https://github.com/ToiletStarter/CantStopMakingReposForThis)

If a library fails to download the script still loads; the affected tab shows a failure label instead.

---

## Contributing

Issues and pull requests are welcome.

**Bug reports** — include the verbose log ([instructions above](#reporting-a-bug)). A report without one will usually just get a request for one.

**Feature requests** — open an issue describing what you want and, if it is game-specific, which instances or remotes it would need. The verbose log's world-source counts help a lot here.

**Pull requests** — `script.txt` is a single file with no build step, so edit it directly and test in-game before opening a PR. Please match the existing style: four-space indent, `pcall` around anything touching game state, and a `Log.info` line for anything worth seeing in a bug report. Register every connection and drawing with the session tracker so hard unload stays clean.

---

## Disclaimer

This project is provided for **educational purposes** and is not affiliated with, endorsed by, or connected to Roblox Corporation or the developers of Aftermath.

- Using third-party scripts **violates the Roblox Terms of Service** and may result in your account being suspended or permanently banned.
- You use this software entirely **at your own risk**. The author accepts no responsibility for account bans, lost items or progress, or any other consequence.
- Do not use it to harass other players or to degrade anyone else's experience.
- The only official source for this script is **this repository**. Anything else redistributing it may be modified and should not be trusted.

If you are not willing to lose the account you run this on, do not run it.

---

## License

No `LICENSE` file is currently committed, so default copyright applies — all rights reserved by the author. If you intend to reuse this code, open an issue and ask.

---

<div align="center">

**Something broken?** → **Misc → Diagnostics → Copy Verbose Log** → [open an issue](https://github.com/ToiletStarter/Roblox-Aftermath/issues/new)

</div>
