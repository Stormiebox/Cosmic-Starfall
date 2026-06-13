# Changelog

All notable changes to **Cosmic Starfall** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Never remove, overwrite or write above this

## v2.0.0 (CURRENT PROJECT VERSION - NO RELEASE DATE YET!)

### Bug Fixes
- **Performance & TPS Optimization:** Drastically reduced server load. Injected a hardcoded `getUpdateInterval` throttle (1.0s) into `starfall_setbonuses.lua` to prevent the engine from recalculating player set bonuses 60 times a second.
- **Desyncs & Hazards:** Replaced `math.random` with `random():getInt()` inside `starfall_spawnanomaly.lua` and other event generators. This prevents physics desyncs and invisible collisions in multiplayer when an anomaly spawns.
- **Multiplayer Synchronization:** Replaced all instances of `math.random` with Avorion's deterministic `random()` engine to prevent massive multiplayer client/server desyncs when generating loot, stats, and enemies.

### Added
- **Subsystem Set Bonuses (Synergies)**: Equip specific combinations of Starfall subsystems to unlock hidden buffs!
  - *The Aegis Matrix* (Bastion System + Overpowered Core): +20% Shield Recharge Rate and +10% Shield Durability.
  - *The Drone-Weaver Network* (Repair Drones + Pulse Tractor Beam): +25% Hull Repair Speed and +2 Max Fighters.
  - *The Void-Runner Configuration* (Xperimental Hypergenerator + Subspace Cargo): +20% Hyperspace Jump Range and +15% Velocity.
- **Turret Set Bonuses (Fleet Doctrines)**: Specialize your ship by equipping 5 or more of the same turret type (Vanilla or Modded) to unlock powerful Fleet Doctrines!
  - *Mining Doctrine* (5+ Miners): +15% Energy Generation, +15% Cargo Capacity.
  - *Salvage Doctrine* (5+ Salvagers): +20% Shield Durability.
  - *Point Defense Doctrine* (5+ PDCs/Anti-Fighter): +15% Dodge Chance, +10% Velocity.
  - *Artillery Doctrine* (5+ Cannons/Mortars/Railguns): +25% Weapon Range, +10% Damage.
  - *Laser/Plasma Doctrine* (5+ Lasers/Plasma): +15% Shield Penetration/Damage.
  - *Launcher Doctrine* (5+ Launchers/Bolters): +20% Fire Rate.
- **Active Set Bonus UI**: Added a dedicated HUD element that dynamically displays your currently active Set Bonuses and Doctrines directly on your screen!
- **Legendary Vault DoTs**: Integrated the new `CosmicVaultCombat` DoT framework into Legendary weapon generation.
- **Combat Injection Handler**: Legendary Plasma and AntiMatter weapons now correctly tag targets with `[Burn]` and `[Melt]` applying localized tick damage.
- Fully integrated with the Cosmic Vault API framework.
- Swept codebase for legacy callbacks and implemented safe pcall fallbacks.

#### 1. Native Cosmic Vault Integration

- **Cosmic Vault Requirement:** Cosmic Starfall has been officially integrated into the Cosmic Series ecosystem. It now natively requires `Cosmic Vault` to run.
- **Legacy Library Purge:** Completely removed the obsolete `cosmicstarfalllib` bridge. All systems now make native calls to the powerful new Cosmic Vault APIs.

#### 2. Cinematic UI & QoL Overhaul

- Active systems (Bastion System, Xperimental Hypergenerator, etc.) now use `CosmicVaultUI.ShowCinematicBanner` to provide stunning, responsive on-screen visual feedback when activated or toggled.
- The custom Player UI Tab (Encyclopedia) now utilizes `CosmicUIHorizontalProportionalSplitter` for perfect dynamic scaling across all monitor resolutions.

#### 3. Asynchronous Performance Processing

- High-intensity iterative loops that used to cause server lag (such as the Repair Wave and Tractor Pulses in `macrofieldProjector.lua`) have been rewritten to execute asynchronously via `CosmicVaultTask.RunAsync()`. This completely eliminates TPS drops during massive fleet battles.

#### 4. Dynamic Economy Hooks

- Megacomplexes are now fully integrated into `CosmicVaultEconomy`.
- If a Megacomplex over-accumulates resources beyond its configured limits and is forced to dump cargo into space, it now triggers a sector-wide **Market Crash** event!

#### 5. Complete Script QA Hardening

- Performed a deep codebase audit to eradicate dangerous direct dereference assumptions.
- Fixed severe silent crashes in `entity/init.lua` and `Tech.lua` where evaluating an unowned entity (e.g. an unowned wreck) would trigger `attempt to index a nil value` server exceptions. The mod is now 100% crash-safe in heavy multiplayer environments.

#### 6. English Translation & Localization

- Performed a comprehensive translation pass across the entire repository.
- Translated all Russian UI labels, tooltips, server `print()` debug logs, variable names, and code comments into English across all `.lua` files.
- **Localization Files Purge:** Wrote a custom Python script to aggressively purge redundant/orphaned translations from `template.pot` and all `.po` language files, significantly reducing their file size and memory footprint.

#### 7. SoundLib Linux Crash Fixes

- Resolved widespread weapon audio crashes (specifically affecting Particle Accelerator, Transphasic Lasers, and others) on Linux-based dedicated servers.
- Automatically batch-renamed all physical audio `.wav` files and subdirectories inside `data/sfx` to be strictly lowercase. This permanently neutralizes case-sensitivity mismatch errors when the game engine fetches `.wav` names via Lua sound scripts.

#### 8. Mod-Wide Balance Pass

- **Overpowered Core:** Stripped out the broken hardcoded stat values. It now utilizes true dynamic rarity scaling (+5% up to +15% energy stats).
- **Bastion System:** Fully reversed the faulty mathematical logic. The system now natively scales positively (+69% up to +83% shield), and the UI tooltip was patched to properly display a buff (+XX%) instead of a negative penalty.
- **Vanilla Power Creep:** Nerfed the flat exponential global damage multipliers applied to vanilla Chainguns (1.25x -> 1.10x) and Bolters (1.15x -> 1.05x) to restore late-game TTK balance.

#### 9. Native CCM Integration

- **Zero-Dependency Configs:** Stripped out the legacy, hard-coded Mod Configuration Menu (MCM) intercept scripts. Cosmic Starfall configurations now natively run through the new server-authoritative Cosmic Configuration Menu (CCM) module inside Cosmic Vault.

#### 10. Architecture Restructure & Cleanup

- Officially finalized the V2 refactoring phase. Renamed all experimental `V2` scripts back to their canonical names (`combatGroup.lua`, `complexCore.lua`), eradicated legacy and orphaned UI scripts from the filesystem, and dynamically updated 70+ internal reference pathways.

#### 11. Player Alliance Hardware Compatibility

- Hardened script owner resolution logic across `overpoweredCore.lua` and other subsystems to explicitly query `player.allianceIndex`. Active subsystem user interfaces will no longer crash or fail to render when players pilot an Alliance-owned vessel.

#### 12. Encyclopedia Codification

- Removed the legacy in-game encyclopedia UI entirely. Cosmic Starfall lore, item descriptions, and feature alerts are now fully integrated and injected directly into the central `Cosmic Codex` ecosystem UI tab.