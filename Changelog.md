# Changelog

All notable changes to **Cosmic Starfall** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Never remove, overwrite or write above this

## v2.0.0 UNRELEASED WORKSHOP VERSION (PROJECT UNDER DEVELOPMENT)

### 🚀 Major Overhaul Features
- **Native Cosmic Vault Integration:** Cosmic Starfall has been officially integrated into the Cosmic Series ecosystem. It now natively requires `Cosmic Vault` to run. Completely removed the obsolete `cosmicstarfalllib` bridge.
- **In-Game Wiki Updates:** Updated the in-game wiki with relevant changes done to systems, turrets, and set bonuses. Updated weapon tooltips and stats to reflect current overhaul changes.

### ✨ Added
- **UI Integration:** The massive array of Starfall lore (Weapons, Stations, etc.) has been updated and structured natively.
- **Subsystem Set Bonuses (Synergies):** Equip specific combinations of Starfall subsystems to unlock hidden buffs!
  - *The Aegis Matrix* (Bastion System + Overpowered Core): +20% Shield Recharge Rate and +10% Shield Durability.
  - *The Drone-Weaver Network* (Repair Drones + Pulse Tractor Beam): +25% Hull Repair Speed and +2 Max Fighters.
  - *The Void-Runner Configuration* (Xperimental Hypergenerator + Subspace Cargo): +20% Hyperspace Jump Range and +15% Velocity.
- **Turret Set Bonuses (Fleet Doctrines):** Specialize your ship by equipping 5 or more of the same turret type (Vanilla or Modded) to unlock powerful Fleet Doctrines!
  - *Mining Doctrine* (5+ Miners): +15% Energy Generation, +15% Cargo Capacity.
  - *Salvage Doctrine* (5+ Salvagers): +20% Shield Durability.
  - *Point Defense Doctrine* (5+ PDCs/Anti-Fighter): +15% Dodge Chance, +10% Velocity.
  - *Artillery Doctrine* (5+ Cannons/Mortars/Railguns): +25% Weapon Range, +10% Damage.
  - *Laser/Plasma Doctrine* (5+ Lasers/Plasma): +15% Shield Penetration/Damage.
  - *Launcher Doctrine* (5+ Launchers/Bolters): +20% Fire Rate.
- **Active Set Bonus UI:** Added a dedicated HUD element that dynamically displays your currently active Set Bonuses and Doctrines directly on your screen!
- **Legendary Vault DoTs:** Integrated the new `CosmicVaultCombat` DoT framework into Legendary weapon generation.
- **Dynamic Economy Hooks:** Megacomplexes are now fully integrated into `CosmicVaultEconomy`. If a Megacomplex over-accumulates resources beyond its configured limits and is forced to dump cargo into space, it now triggers a sector-wide **Market Crash** event!

### ⚙️ Changed & Balanced
- **Mod-Wide Balance Pass:**
  - *Overpowered Core:* Stripped out the broken hardcoded stat values. It now utilizes true dynamic rarity scaling (+5% up to +15% energy stats).
  - *Bastion System:* Fully reversed the faulty mathematical logic. The system now natively scales positively (+69% up to +83% shield), and the UI tooltip was patched to properly display a buff (+XX%) instead of a negative penalty.
  - *Vanilla Power Creep:* Nerfed the flat exponential global damage multipliers applied to vanilla Chainguns (1.25x -> 1.10x) and Bolters (1.15x -> 1.05x) to restore late-game TTK balance.
- **Cinematic UI & QoL Overhaul:** Active systems now use `CosmicVaultUI.ShowCinematicBanner` for stunning on-screen feedback. Custom UI tabs now utilize proportional splitters for perfect scaling.
- **Architecture Restructure:** Renamed all experimental `V2` scripts back to their canonical names, eradicated legacy UI scripts, and updated 70+ internal pathways.
- **English Translation & Localization:** Translated all Russian UI labels, tooltips, logs, and variables into English. Wrote a Python script to aggressively purge redundant/orphaned translations, reducing memory footprint.

### 🐛 Bug Fixes & Optimization
- **Redundant Vault Injections:** Scrubbed obsolete Vault UI code (`cosmicconfig`, `cosmiccodex`) that was illegally injected inside the Starfall mod namespace, avoiding UI overlap bugs.
- **In-Game Wiki Loading Crash:** Fixed missing global definitions (`rangeType`, `accuracyType`, etc.) in `infoWeapons.lua` that prevented the weapons wiki from loading correctly and crashed the UI.
- **UI Memory Leaks Sealed:** Injected `onRemove()` functions into UI scripts like the Combat Group and Active System interfaces. Previously, jumping sectors caused the UI to secretly stack invisible event listeners, leading to massive memory bloat in late-game.
- **Deterministic Subsystem Fix:** Completely rebuilt the RNG physics calculations inside all 7 new subsystems (`bastionSystem`, `macrofieldProjector`, etc.). Previously, they erroneously invoked `math.randomseed()` mixed with the C++ `random()` generator, causing their generated stats and properties to permanently desync between Multiplayer clients. They now perfectly utilize the deterministic Avorion `Random(Seed(seed))` architecture.
- **Multiplayer Network Synchronization:** Fixed a silent networking bug where UI buttons for the Overpowered Core would not respond on Dedicated Servers because the server-side functions were missing `callable()` declarations.
- **Asynchronous Performance Processing:** High-intensity iterative loops (like Repair Waves and Tractor Pulses) have been rewritten to execute asynchronously via `CosmicVaultTask.RunAsync()`, completely eliminating TPS drops during massive fleet battles.
- **Desyncs & Hazards:** Replaced `math.random` with `random():getInt()` inside `starfall_spawnanomaly.lua` and other event generators. This prevents physics desyncs and invisible collisions in multiplayer when an anomaly spawns.
- **Complete Script QA Hardening:** Eradicated dangerous direct dereference assumptions. Fixed severe silent crashes in `entity/init.lua` and `Tech.lua` where evaluating an unowned entity triggered `attempt to index a nil value` server exceptions. The mod is now 100% crash-safe in heavy multiplayer environments.
- **Player Alliance Compatibility:** Hardened script owner resolution logic to explicitly query `player.allianceIndex`. Active subsystem user interfaces will no longer crash or fail to render when players pilot an Alliance-owned vessel.
- **Combat Injection Handler:** Legendary Plasma and AntiMatter weapons now correctly tag targets with `[Burn]` and `[Melt]`, applying localized tick damage.
- **SoundLib Linux Crash Fixes:** Resolved widespread weapon audio crashes on Linux-based dedicated servers by batch-renaming all physical audio `.wav` files and subdirectories to be strictly lowercase.
- **Invalid Stat API Sweeps:** Scanned and purged the codebase of invalid vanilla API enums (e.g. `StatsBonuses.Damage`, `StatsBonuses.ShieldCapacity`) and replaced them with functional Vanilla Engine equivalents to eliminate silent math failures.
- **Zero-Overhead Subsystem Synergies:** Completely eradicated the massive 1.0-second background polling loop in `starfall_setbonuses.lua`. Subsystem synergies and Fleet Doctrines are now fully event-driven, relying exclusively on native `onTurretAdded`, `onTurretRemoved`, and `onInstalledUpgradesChanged` hooks to yield mathematically zero TPS overhead during combat.
