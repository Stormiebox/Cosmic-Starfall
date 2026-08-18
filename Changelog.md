# Changelog

All notable changes to **Cosmic Starfall** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Never remove, overwrite or write above this

## [v2.0.5] - Engine Hardening Hotfix

### 🐛 Bug Fix
- [Bugfix] **VFS Load Order Corruption:** Resolved a game-breaking architecture bug where `Cosmic Starfall` would silently corrupt vanilla export tables (like `galaxy.lua` and `turretingredients.lua`). When Avorion's Virtual File System merged Starfall's weapon probability injections, the engine occasionally parsed them *before* `weapontype.lua` was loaded. This caused the new custom weapons (e.g. `WeaponType.PULSEGUN`) to evaluate as `nil`, triggering a silent syntax error that wiped the entire `Galaxy` export from memory.
- [Bugfix] **Cross-Mod Compatibility:** By strictly enforcing `weapontype.lua` includes within appended library files, `Cosmic Starfall` will no longer crash or destabilize background scripts in other Cosmic mods (such as the "MineableBy is a nil value" crash in `Cosmic Overhaul`).

## [v2.0.4] - Hotfix

### 🐛 Bug Fix
- [Bugfixed] **Initialization Crash:** Fixed a critical issue where 28 mod scripts were missing the required string utility includes. This prevented the Avorion translation macro (`%_t`) from resolving properly on the server, causing catastrophic script failure and `"attempt to perform arithmetic on a string value"` crashes during the engine's initial script scanning phase.
- [Bugfix] **UI Localization Server Crashes:** Fixed a severe startup crash on dedicated servers affecting all Starfall UI elements. Placed a strict `if onServer() then return end` check at the top of 10+ core UI scripts (`Armory.lua`, `infoInterfaces.lua`, etc.). This prevents the server from evaluating client-only `%_t` translation strings in the global scope.
- [Bugfixed] **Library Failures:** Resolved cascading errors affecting `weapontype.lua`, `galaxy.lua`, and `weapongenerator.lua`. Because the `Armory.lua` library now successfully loads, functions like `getWeaponName` are correctly registered, preventing the server from silently failing during initial script execution.
- [Bugfixed] **HUD Rendering Crash:** Fixed an internal API error where subsystems attempted to access a non-existent `Owner.index` property, and crashed silently in the background when checking shield capacities during the initialization phase. Subsystem HUDs (like the Bastion System and Macrofield Projector) will now correctly appear on your screen and are clickable again.
- [Bugfixed] **Console Log Spam:** Fixed an issue where the game engine would constantly print `Property not found or not readable: Entity.shieldMaximum` to the server console whenever a subsystem script checked a ship that didn't have a shield generator equipped. The scripts now properly check for the presence of a shield component before querying its capacity.
- [Bugfixed] **Seed Generation Error:** Fixed a background crash where the server would print `Error constructing Seed: tried converting user data to double` when initializing random bonuses for a subsystem. This was caused by the script attempting to cast an existing `Seed` object into another `Seed`.
- [Bugfixed] **UI Update Error:** Fixed an error in the active subsystem UI manager where the script attempted to broadcast UI progress bar updates without properly specifying the target player, resulting in `Error calling invokeClientFunction: expected 'Player'`.


## [v2.0.3] - Patch

### 🐛 Bug Fix
- [Bugfixed] **Repair System T-V**: Fixed an initialization logic error where the module would permanently skip applying the hull stat bonuses upon first installation.
- [Bugfixed] **Backwards Compatibility**: Added a script injection hook to the server's `onPlayerLogIn` event. Players continuing on an existing save file will now properly receive the `activeSysInterface.lua` script, ensuring the UI correctly appears for active modules like the Bastion System and Macrofield Projector.

## [v2.0.2] - Patch

### 🐛 Bug Fix
- [Bugfixed] Fixed a UI bounding box issue in `activeSysInterface.lua` where action buttons for multi-ability items (like the Repair Drones module) were drawn outside of the clickable container space. They are now fully clickable and usable.

## [v2.0.1] - Patch

### 🐛 Bug Fix
- [Bugfixed] Fixed a critical server-side initialization error causing activatable equipment icons (such as Bastion System or Repair Drones) to fail to render on the player's UI.

## v2.0.0

### ✨ New Features & 📦 Content Additions
- [Feature] **UI Integration:** The massive array of Starfall lore (Weapons, Stations, etc.) has been updated and structured natively.
- [Feature] **Subsystem Set Bonuses (Synergies):** Equip specific combinations of Starfall subsystems to unlock hidden buffs!
  - *The Aegis Matrix* (Bastion System + Overpowered Core): +20% Shield Recharge Rate and +10% Shield Durability.
  - *The Drone-Weaver Network* (Repair Drones + Pulse Tractor Beam): +25% Hull Repair Speed and +2 Max Fighters.
  - *The Void-Runner Configuration* (Xperimental Hypergenerator + Subspace Cargo): +20% Hyperspace Jump Range and +15% Velocity.
- [Feature] **Turret Set Bonuses (Fleet Doctrines):** Specialize your ship by equipping 5 or more of the same turret type (Vanilla or Modded) to unlock powerful Fleet Doctrines!
  - *Mining Doctrine* (5+ Miners): +15% Energy Generation, +15% Cargo Capacity.
  - *Salvage Doctrine* (5+ Salvagers): +20% Shield Durability.
  - *Point Defense Doctrine* (5+ PDCs/Anti-Fighter): +15% Fighter Dodge, +10% Velocity.
  - *Artillery Doctrine* (5+ Cannons/Mortars/Railguns): +15% Damage, +10% Velocity.
  - *Laser/Plasma Doctrine* (5+ Lasers/Plasma): +15% Damage, +15% Shield Recharge Rate.
  - *Launcher Doctrine* (5+ Launchers/Bolters): +20% Fire Rate.
- [Feature] **Active Set Bonus UI:** Radically redesigned the HUD element that dynamically displays your currently active Set Bonuses and Doctrines. It now flawlessly uses the native `addShipProblem` API alongside Cosmic Vault textures to render beautiful, non-obstructive visual indicators instead of manual text rectangles!
- [Feature] **Legendary Vault DoTs:** Integrated the new `CosmicVaultCombat` DoT framework into Legendary weapon generation.
- [Feature] **Dynamic Economy Hooks:** Megacomplexes are now fully integrated into `CosmicVaultEconomy`. If a Megacomplex over-accumulates resources beyond its configured limits and is forced to dump cargo into space, it now triggers a sector-wide **Market Crash** event!

### ⚙️ Changed & ⚖️ Balanced
- [Changed] **Native Cosmic Vault Integration:** Cosmic Starfall has been officially integrated into the Cosmic Series ecosystem. It now natively requires `Cosmic Vault` to run. Completely removed the obsolete `cosmicstarfalllib` bridge.
- [Changed] **Cinematic UI & QoL Overhaul:** Active systems now use `CosmicVaultUI.ShowCinematicBanner` for stunning on-screen feedback. Custom UI tabs now utilize proportional splitters for perfect scaling.
- [Changed] **Architecture Restructure & API Compliance:** Renamed all experimental `V2` scripts back to their canonical names, eradicated legacy UI scripts, and updated 70+ internal pathways to ensure global API compliance.
- [Changed] **In-Game Wiki Updates:** Updated the in-game wiki with relevant changes done to systems, turrets, and set bonuses. Updated weapon tooltips and stats to reflect current overhaul changes.
- [Balanced] **Core Subsystem Rebalance:** Overpowered Core stripped of broken hardcoded values, now utilizing true dynamic rarity scaling (+5% up to +15% energy stats).
- [Balanced] **Vanilla Power Creep:** Nerfed the flat exponential global damage multipliers applied to vanilla Chainguns (1.25x -> 1.10x) and Bolters (1.15x -> 1.05x) to restore late-game TTK balance.
- [Balanced] **Global Weapon Balance Pass:** Normalized all custom Starfall weapon DPS multipliers (previously up to 2.3x) down to +15-25% over vanilla to eliminate power creep. Rebalanced the MANTIS rockets to reduce visual spam and normalize damage output.

### 🐛 Bug Fixes & 🛠️ Optimization
- [Optimized] **English Translation & Localization:** Translated all Russian UI labels, tooltips, logs, and variables into English. Wrote a Python script to aggressively purge redundant/orphaned translations, reducing memory footprint.
- [Optimized] **Zero-Overhead Subsystem Synergies:** Completely eradicated the massive 1.0-second background polling loop in `starfall_setbonuses.lua`. Subsystem synergies and Fleet Doctrines are now fully event-driven, relying exclusively on native `onTurretAdded`, `onTurretRemoved`, and `onInstalledUpgradesChanged` hooks to yield mathematically zero TPS overhead during combat.
- [Optimized] **Asynchronous Performance Processing:** High-intensity iterative loops (like Repair Waves and Tractor Pulses) have been rewritten to execute asynchronously via `CosmicVaultTask.RunAsync()`, completely eliminating TPS drops during massive fleet battles.
- [Optimized] **UI Memory Leaks Sealed:** Injected `onRemove()` functions into UI scripts like the Combat Group and Active System interfaces. Previously, jumping sectors caused the UI to secretly stack invisible event listeners, leading to massive memory bloat in late-game.
- [Optimized] **PCall Wrapper Purge:** Swept core system scripts (`repairDrones.lua`, `subscapeCargo.lua`, `XperimentalHypergenerator.lua`) and all item generators (`weapongenerator.lua`, `turretgenerator.lua`, etc.) to remove unneeded and dangerous `pcall` wrappers, restoring natural stack trace logging and resolving logical errors.
- [Bugfixed] **Bastion System Math Fix:** Fully reversed the faulty mathematical logic. The system now natively scales positively (+69% up to +83% shield), and the UI tooltip was patched to properly display a buff (+XX%) instead of a negative penalty.
- [Bugfixed] **Weapon Multi-Projectile Math Fix:** Fixed broken multi-projectile engine math on the Pulse Laser, Cyclone, and Avalanche that was causing unintended DPS doubling.
- [Bugfixed] **Multiplayer RNG Synchronization:** Completely rebuilt the RNG physics calculations inside all 7 new subsystems and anomaly generators. By replacing `math.random` with the deterministic Avorion `Random(Seed(seed))` architecture, physics and stats no longer permanently desync between Multiplayer clients.
- [Bugfixed] **Complete Script QA Hardening:** Eradicated dangerous direct dereference assumptions. Fixed severe silent crashes in `entity/init.lua` and `Tech.lua` where evaluating an unowned entity triggered `attempt to index a nil value` server exceptions. The mod is now 100% crash-safe in heavy multiplayer environments.
- [Bugfixed] **Player Alliance Compatibility:** Hardened script owner resolution logic to explicitly query `player.allianceIndex`. Active subsystem user interfaces will no longer crash or fail to render when players pilot an Alliance-owned vessel.
- [Bugfixed] **Combat Injection Handler:** Legendary Plasma and AntiMatter weapons now correctly tag targets with `[Burn]` and `[Melt]`, applying localized tick damage.
- [Bugfixed] **Set Bonus UI & Logic:** Eradicated vestigial local variables (`lastCheckTime`, `activeModifiers`) leftover from deprecated polling loops. Fixed a severe vanilla engine enum capitalization typo (`WeaponType.PointDefenseChainGun`) that was causing Point Defense Chainguns to fail to register for the Point Defense Doctrine. Standardized the initialization of `ShipSystem()` to match vanilla syntax.
- [Bugfixed] **SoundLib Linux Crash Fixes:** Resolved widespread weapon audio crashes on Linux-based dedicated servers by batch-renaming all physical audio `.wav` files and explicitly downcasing all string references inside the Lua weaponsound scripts.
- [Bugfixed] **Invalid Stat API Sweeps:** Scanned and purged the codebase of invalid vanilla API enums (e.g. `StatsBonuses.Damage`, `StatsBonuses.ShieldCapacity`) and replaced them with functional Vanilla Engine equivalents to eliminate silent math failures.
- [Bugfixed] **Memory Leak Patch:** Fixed a critical bug in `starfall_setbonuses.lua` and `XperimentalHypergenerator.lua` where unpurged volatile keys caused infinite stat stacking upon server restart. Replaced with native `Entity():removeScriptBonuses()` for flawless buff cleanup.
- [Bugfixed] **Phantom Property Patch:** Removed a dangerous write operation to `entity.damageMultiplier` in `starfall_setbonuses.lua` (which is a read-only phantom property that crashes the internal Lua VM) and correctly redirected the buff to `StatsBonuses.FireRate`.
- [Bugfixed] **Generator Math Fixes:** Fixed a game-breaking `ColorHSV` parameter error in `weapongenerator.lua` that was crashing vanilla generation math, and removed an invalid `return TurretIngredients` in `turretingredients.lua` to prevent fatal loading errors.
- [Bugfixed] **AI Ship Sync Fixes:** Resolved an issue in `starfall_setbonuses.lua` where `invokeClientFunction` would crash the server when processing AI/NPC ships by swapping to `broadcastInvokeClientFunction` and implementing strict `Player().craftIndex` UI gating.
- [Bugfixed] **UI Bloom Glitch Patch:** Fixed a severe typo in `ColorLib.lua` where the fallback UI color value was mistakenly set to 100 (10000% brightness), causing massive unpredictable UI bloom and glow artifacts when active systems were rendered.
- [Bugfixed] **Redundant Vault Injections:** Scrubbed obsolete Vault UI code (`cosmicconfig`, `cosmiccodex`) that was illegally injected inside the Starfall mod namespace, avoiding UI overlap bugs.
- [Bugfixed] **In-Game Wiki Loading Crash:** Fixed missing global definitions (`rangeType`, `accuracyType`, etc.) in `infoWeapons.lua` that prevented the weapons wiki from loading correctly and crashed the UI.
- [Bugfixed] **Multiplayer Network Synchronization:** Fixed a silent networking bug where UI buttons for the Overpowered Core would not respond on Dedicated Servers because the server-side functions were missing `callable()` declarations.
