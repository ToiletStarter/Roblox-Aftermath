# Roblox-Aftermath

Potassium script for Aftermath (place `112237800564065`). Built on the
[EasyUI / EasyESP / EasyAim](https://github.com/ToiletStarter/CantStopMakingReposForThis)
libraries.

## Load

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/Roblox-Aftermath/refs/heads/main/script.txt"))()
```

Press **Right Shift** to toggle the menu.

## Features

### Visuals
| Tab | Contents |
| --- | --- |
| Players | Boxes, names, distance, health bars, flags, tracers, chams, box style, colour, range |
| Infected | Separate toggles and range for the zombie roster (`cfg.npc` is an independent tree) |
| World | Loot with rarity filter, ground weapons, ammo refills, airdrops, vehicles, POIs |

Loot labels read the `DisplayName` and `Rarity` attributes off each item model.
Vehicle labels read `Health` from the vehicle's `States` configuration.

### Combat
Aimbot with legit / rage / silent modes, Head / Torso / Root / Nearest hitboxes,
FOV / distance / health target selection, sticky targeting, wall checks,
prediction (factor, projectile speed) and a configurable FOV circle.
Squadmates are filtered out of the target list automatically.

### Player
Live survival readout: health, hunger, thirst, stamina, and a status line
covering bleeding, broken legs, infection and toxicity. Squad panel shows your
squad name and mate count.

### Misc
Server name / region / player count, job-ID copy button, no-fog, fullbright,
field-of-view slider, and client-side gun modifier sliders (recoil, hipfire and
aimed accuracy, aim speed, reload speed).

## Game notes

Aftermath uses a **CustomCharacter** system. Characters are GUID-named models
under `workspace.game_assets.Entities` rather than `Player.Character`, and the
infected use an `AnimationController` named `Humanoid` instead of a real
`Humanoid`. Health and survival state live in **attributes** (`Health`,
`MaxHealth`, `Dead`, `Hunger`, `Thirst`, `Stamina`, `Toxicity`, `Infection`,
`Bleeding`, `BrokenLeg`, `SquadName`). The script resolves all of this through
an adapter rather than assuming stock Roblox layout.

## Status

Verified against a mocked Aftermath world: the script loads, builds its UI, and
every entity getter, flag callback, aim adapter path and scheduled job runs
clean (57 assertions). Not yet exercised in a live server — gun modifier writes
in particular are client-side and the server may reject them.
