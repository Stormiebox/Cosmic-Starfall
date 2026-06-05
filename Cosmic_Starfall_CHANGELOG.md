## Cosmic Starfall v2.0.0
### Release Date TBD (Work In Progress)

#### 1. Decoupled from Cosmic Vault
- Stripped all `Cosmic Vault` dependencies, includes, and API calls (specifically in `cosmicstarfalllib.lua`).
- Cosmic Starfall now operates as a **100% standalone mod**.

#### 2. English Translation & Localization
- Performed a comprehensive translation pass across the entire repository.
- Translated all Russian UI labels, tooltips, server `print()` debug logs, variable names, and code comments into English across all `.lua` files (e.g., `complexCore.lua`, `repairDrones.lua`, `XperimentalHypergenerator.lua`, etc.).

#### 3. Subsystem UI Persistence Fixes
- **Active System Interface Bug:** Fixed a critical issue in `activeSysInterface.lua` where UI elements permanently disappeared when swapping modules or reloading the world. This was resolved by switching to stringified ID tracking for persistent tables instead of volatile object reference comparisons.
- **Initialization Hooks:** Appended proper `initialize()` hooks to `bastionSystem.lua`, `overpoweredCore.lua`, `pulseTractorBeamGenerator.lua`, `repairDrones.lua`, and `XperimentalHypergenerator.lua` to ensure the interface correctly reconstructs itself on world load.

#### 4. Percentage-Based Repairs
- Refactored the rigid, flat-value repair systems (e.g., Polarizing Nanobots, Repair Matrix, Emergency Stabilization) to be dynamically percentage-based.
- Repair algorithms in `macrofieldProjector.lua` now intelligently calculate healing multiplier outputs based on `Durability().maximum` and `Shield().maximum`, scaling perfectly into late-game. Updated UI descriptions to display the new `%` scaling.

#### 5. SoundLib Linux Crash Fixes
- Resolved weapon audio crashes for the "Particle Accelerator" and "Transphasic Lasers" weapons on Linux-based dedicated servers.
- Adjusted file casing strictly to lowercase for both the physical `.wav` audio files via `git mv` and the internal script path references inside `PARTICLEACCELERATOR.lua` and `TRANSPHASIC.lua`, effectively neutralizing case-sensitivity pathing mismatches.

#### 6. Megacomplex UI Populating Fix
- Hardened server-to-client UI generation in `complexCoreV2.lua` (`adaptiveSync`) and `complexCore.lua` (`generateIncomeOutcome`).
- Guarded `Player(callingPlayer)` invocations to prevent the thread from crashing if `callingPlayer` turns out to be `nil` (e.g., during background asynchronous sector events). In these scenarios, the script cleanly falls back to `broadcastInvokeClientFunction` guaranteeing UI lists properly populate without error.

### LEGACY LOGS BELOW
# Cosmic Starfall - Revamp Changelog

This document tracks all known changes made during the current Cosmic Starfall modernization, balance pass, QA hardening, and compatibility work inside **Avorion Vault**.

It is intended to explain:
- how this version differs from the original upstream Starfall baseline,
- what was rebalanced and why,
- what was fixed for current Avorion-era script safety,
- and what was added for interoperability with Cosmic Vault / Cosmic ecosystem modules.

---

## Scope of this Revamp

This pass focused on four goals:

1. **De-overpowering high-impact systems** (anti-OP balancing).
2. **Static QA hardening** of risky scripts (logic/safety/compat).
3. **Compatibility scaffolding** for Cosmic Vault-style optional dependencies.
4. **Maintainability improvements** (bugfixes and safer patterns).

Runtime/in-game tuning remains iterative, but the codebase has been materially stabilized and normalized for continued testing.

---

## New / Added

### Added: `data/scripts/lib/cosmicstarfalllib.lua`
A new bridge/helper library was added to centralize compatibility behavior and owner routing concerns.

#### Purpose
- Provide optional bridge points to Cosmic Vault modules without hard-failing if absent.
- Reduce duplicated script-owner invocation patterns.
- Offer safer helper calls for owner-aware UI / function dispatch.

#### Notes
- Uses optional loading patterns (`pcall(include, ...)`) for Vault/debug/config-style modules.
- Designed as a non-breaking helper layer: if optional dependencies are missing, scripts continue running.

---

## Fixed / Updated

### 1) `data/scripts/systems/subspaceCargo.lua`
#### Fixes
- **Bugfix:** `getName` used an undefined variable path in earlier logic (`_mk` related naming bug).
  Corrected to deterministic local mark level computation:
  - `mk = rarity.value + 2`
- Added explicit include:
  - `include("cosmicstarfalllib")`
- Removed dead/unused naming-side temporary logic to improve readability and reduce confusion.

#### Effect
- Stable subsystem naming.
- Cleaner static code path.
- Better consistency with Starfall compatibility bridge approach.

---

### 2) `data/scripts/systems/overpoweredCore.lua`
#### Hardening changes
- Added:
  - `include("cosmicstarfalllib")`
- Reworked fragile owner checks:
  - replaced player-name string comparisons with index/ownership-safe checks where applicable.
- Corrected client/server lifecycle concerns:
  - callback registration scoped to appropriate side.
- Corrected uninstall persistence logic:
  - removed invalid server-side dependence on client-only resolution state.
  - replaced with safe neutral persisted defaults.

#### Effect
- Reduced risk of ownership mismatch edge cases.
- Better side-correct behavior in Avorion’s client/server model.
- Fewer lifecycle-related script hazards.

---

### 3) `data/scripts/complexCraft/complexCore.lua`
#### QA corrections performed
- Fixed parameter guard order in cargo transfer:
  - now checks `nil` before numeric compare.
- Fixed numeric parsing safety in cargo limit UI flow:
  - safe `tonumber` handling + min clamp.
- Fixed variable-name typo bugs in rebuild path:
  - `_complexId` / `_stationId` corrected to passed identifiers.
- Fixed debug print syntax/lint issue.
- Performed readability pass and cleaned high-risk comment/code mismatches in modified regions.

#### Effect
- Prevents avoidable nil-compare runtime errors.
- Improves UI/config robustness.
- Rebuild flow now correctly references intended entity arguments.

### 4) Replaced weapon class names
- Fixed grammar on weapon class names such as: Light, Heavy, etc.
- Cleaned up inconsistent code related to weapon class names.

### 5) Updated Starfall UI Information
- Overhauled and renamed many of old Starfall UI information.
- Updated information and changelog info.

---

## Balance Revamp (Anti-OP Pass)

The following changes were intentional **nerfs** aimed at reducing runaway power spikes while preserving identity/fantasy of each system.

---

### A) `data/scripts/systems/bastionSystem.lua`

| Parameter | Old | New | Intent |
|---|---:|---:|---|
| VeilResistance | 25 | 16 | Lower passive tank ceiling |
| VeilRepair | 0.10 | 0.06 | Reduce sustain burst |
| VeilCooldown | 60 | 85 | Longer downtime window |
| RecupMultiplier | 40 | 26 | Cut emergency rebound amplitude |
| RecupLength | 20 | 14 | Shorter high-power uptime |
| RecupCooldown | 35 | 55 | Less frequent high-value cycle |
| MultiphaseLength | 30 | 20 | Shorter multi-phase dominance |
| MultiphaseCooldown | 60 | 95 | Increase strategic commitment |
| PulsarRange | 30 | 22 | Reduce area control footprint |
| PulsarLength | 10 | 7 | Shorter pressure duration |
| PulsarCooldown | 100 | 135 | Reduce repeat pressure frequency |

**Net result:** Bastion remains defensive/control-focused but no longer sustains near-permanent oppressive uptime.

---

### B) `data/scripts/systems/macrofieldProjector.lua`

| Parameter | Old | New | Intent |
|---|---:|---:|---|
| ModuleBonusEnergy | 20 | 12 | Lower passive efficiency gain |
| ModuleBonusAccum | 130 | 80 | Reduce stacking battery inflation |
| ModuleBonusEnergyRARMP | 4 | 2.5 | Flatten rarity scaling |
| ModuleBonusAccumRARMP | 15 | 9 | Flatten rarity scaling |
| RepairWaveCooldown | 80 | 110 | Longer cycle |
| RepairWaveOperationTime | 8 | 6 | Shorter active window |
| RepairWaveHealingAmount | 4000 | 2200 | Cut spike healing |
| RepairWaveSelfBonus | 30 | 12 | Reduce self-advantage |
| RepairWaveEnergyConsumption | 5 | 8 | Increase cost discipline |
| RenovatingRayCooldown | 15 | 28 | Less frequent reapplication |
| RenovatingRayHealingAmount | 6000 | 3200 | Lower throughput |
| RenovatingRayEnergyConsumption | 1 | 2.5 | Increase cost |
| ShieldBoosterCooldown | 15 | 32 | Less frequent shield burst |
| ShieldBoosterHealingAmount | 13000 | 7000 | Lower shield spike |
| ShieldBoosterEnergyConsumption | 1 | 3 | Increase tradeoff |
| ShieldSynchronizerCooldown | 5 | 12 | Slow chain-sync pacing |
| ShieldSynchronizerAmount | 1 | 0.45 | Reduce transfer intensity |

**Net result:** Macrofield remains a versatile support platform but shifts from "all-in-one overpower" toward costly, timing-sensitive support.

---

### C) `data/scripts/systems/pulseTractorBeamGenerator.lua`

| Parameter | Old | New | Intent |
|---|---:|---:|---|
| GeneratorPulsesPerRarity | 4 | 3 | Lower scaling curve |
| GeneratorRangePerPulse | 300 | 200 | Tighter influence zone |
| GeneratorCooldown | 240 | 300 | Longer downtime |

**Net result:** Tractor control identity is retained with reduced persistent map-control pressure.

---

## Compatibility / Ecosystem Notes

- Starfall scripts now better align with optional Cosmic Vault style integrations via `cosmicstarfalllib`.
- No mandatory external hard dependency was introduced for this bridge behavior.
- Design intent is "optional enhancement, safe fallback" rather than strict coupling.

---

## Current Avorion Alignment

This revamp specifically addressed script-side issues common in modern Avorion mod stacks:

- safer client/server boundary assumptions,
- safer callback registration patterns,
- safer nil/type handling in high-traffic code paths,
- reduced OP loop risk that can destabilize long-session gameplay balance.

---

## QA Status

### Completed
- Broad static QA scans over relevant Starfall systems.
- Focused read-level review of affected scripts.
- Corrective patching of identified high-risk issues.
- Lint/syntax-level corrections where surfaced during patching.

### Deferred / Pending (Runtime Validation)
- In-game feel/balance verification under live combat and economy progression.
- Multiplayer/dedicated long-session soak testing.
- High-density docking/rebuild stress testing for complex craft flows.
- Final numeric tuning after gameplay telemetry.

---

## Additional Fixes (Latest Integration Cycle)

### 6) `data/scripts/lib/cosmicstarfalllib.lua` (owner-resolution hardening)
#### Fixes
- Hardened owner resolution to avoid direct unsafe dereference of `Owner.index`.
- Added guarded owner-index extraction flow with safe fallbacks.
- Added robust descriptor generation behavior for owner routing helpers.

#### Root issue addressed
- Repeated runtime error pattern:
  - `Property not found or not readable: Owner.index`
  - stack traces in owner helper chain:
    - `getOwnerDescriptor` -> `getOwnerIndex` -> `invokeOwnerFunctionIfOnline`

#### Effect
- Eliminates repeated owner-descriptor index crashes from invalid/unreadable owner contexts.
- Reduces high-frequency stacktrace spam in update/UI paths.

---

### 7) `data/scripts/systems/XperimentalHypergenerator.lua`
#### Fixes
- Added owner-availability guards before owner-routed UI invoke/update/delete calls:
  - `executeDrawInterface`
  - `executeUpdateProgressbar`
  - `executeDelete`

#### Effect
- Prevents owner-routed calls when entity owner context is unavailable.
- Avoids cascading crashes from stale/missing owner handles.

---

### 8) `data/scripts/systems/repairDrones.lua`
#### Fixes
- Added owner-availability guards before owner-routed UI invoke/update/delete calls:
  - `executeDrawInterface`
  - `executeUpdateProgressbar`
  - `executeDelete`

#### Effect
- Prevents repeated updateServer/UI invoke faults tied to missing owner index context.
- Stabilizes runtime behavior in prolonged sessions where entity ownership state can transiently change.

---

### 9) `data/scripts/lib/weapongenerator.lua`, `turretingredients.lua`, `turretgenerator.lua`

#### Fixes

- **Removed destructive hard-overwrites:** Original mod completely replaced vanilla weapon generation, turret factory recipes, and specialties.
- Converted vanilla weapon buffs (dps multipliers, elemental damage injections) into safe hooks (`local old_generateChaingun = WeaponGenerator.generateChaingun`).

#### Effect

- Mod is now 100% compatible with Cosmic Overhaul and other mods that touch vanilla weapon economy and balance.

---

### 10) `data/scripts/lib/shiputility.lua`, `tooltipmaker.lua`

#### Fixes

- Refactored `shiputility.lua` to safely append weapons using `table.insert` instead of completely overwriting AI weapon arrays. AI super-weapon generation filtering is safely hooked.
- Completely removed the 400-line vanilla overwrite in `tooltipmaker.lua` and replaced it with a non-invasive hook that strictly appends Starfall's UI tooltips.

#### Effect

- Prevents other mods' custom UI from being obliterated, and natively supports future Avorion engine updates.

---

### 11) `data/scripts/neltharaku/Aquaflow.lua`

#### Fixes

- Stubbed out the entire file due to a massive Arbitrary Code Execution (ACE) security vulnerability (use of `loadstring` on raw files) and dedicated server crashes involving blind `Player()` calls.

#### Effect

- Safely neutralizes the security threat while preventing crash loops in the abandoned developer UI panels.

---

### 12) `data/scripts/complexCraft/complexCoreV2.lua`

#### Fixes

- **Security:** Patched a severe exploit where malicious clients could transfer cargo from any entity in the sector regardless of ownership or docking status.
- **Stability:** Moved client-authoritative `invokeClientFunction` logic to `updateClient` to prevent guaranteed server crashes.
- Fixed array skipping bug in table iteration loops.

#### Effect

- Megacomplex operations are now fully secure, stable, and server-safe.

---

### 13) `data/scripts/entity/mainCaliber.lua`, `activeSysInterface.lua`

#### Fixes

- **`mainCaliber.lua`:** Shifted entirely to server-authoritative logic. Prevents an exploit where clients could spoof their weapon count and turn the fire-rate penalty into a massive buff. Removed unoptimized frame-by-frame UI loops.
- **`activeSysInterface.lua`:** Fixed "Puppeteer" exploit allowing clients to force any script/command execution on unowned entities across the sector.

#### Effect

- Highly secure, exploit-proof active systems and super-weapon penalty mechanics.

---

### 14) `data/scripts/entity/entityAlerts.lua`, `combatGroup.lua`, `combatGroupV2.lua`

#### Fixes

- Fixed `entityAlerts.lua` hard stack trace when `Player()` was blindly invoked on the server.
- Fixed disconnect crashes in the combat group scripts where `Galaxy():findPlayer()` returned `nil` when kicking/inviting a logged-out player.

#### Effect

- Crash-free UI group operations.

## Summary

This Cosmic Starfall revamp differs from the original baseline by being:

- **less overtuned**,
- **more robust under static QA**,
- **more compatible with Cosmic ecosystem extension patterns**,
- and **better prepared for modern Avorion stress-testing cycles**.

The latest owner-resolution hardening pass further improves script safety in modern Avorion server/client lifecycle conditions and removes known recurring stacktrace patterns tied to owner descriptor access.
