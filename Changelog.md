# Changelog

All notable changes to **Cosmic Starfall** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

--

## v2.0.0 (CURRENT PROJECT VERSION - NO RELEASE DATE YET!)

### Added
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

### LEGACY LOGS BELOW - KEPT HERE FOR HISTORICAL LOGGING PURPOSES!

# Cosmic Starfall - Revamp Changelog

This document tracks all known changes made during the current Cosmic Starfall modernization, balance pass, QA hardening, and compatibility work inside **Avorion Vault**.

It is intended to explain:

- how this version differs from the original upstream Starfall baseline,
- what was rebalanced and why,
- what was fixed for current Avorion-era script safety,
- and what was added for interoperability with Cosmic Vault / Cosmic ecosystem modules.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

## Scope of this Revamp

This pass focused on four goals:

1. **De-overpowering high-impact systems** (anti-OP balancing).
2. **Static QA hardening** of risky scripts (logic/safety/compat).
3. **Compatibility scaffolding** for Cosmic Vault-style optional dependencies.
4. **Maintainability improvements** (bugfixes and safer patterns).

Runtime/in-game tuning remains iterative, but the codebase has been materially stabilized and normalized for continued testing.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

## Balance Revamp (Anti-OP Pass)

The following changes were intentional **nerfs** aimed at reducing runaway power spikes while preserving identity/fantasy of each system.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

### A) `data/scripts/systems/bastionSystem.lua`

| Parameter | Old | New | Intent |
|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---:|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---:|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---|
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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

### B) `data/scripts/systems/macrofieldProjector.lua`

| Parameter | Old | New | Intent |
|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---:|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---:|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---|
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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

### C) `data/scripts/systems/pulseTractorBeamGenerator.lua`

| Parameter | Old | New | Intent |
|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---:|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---:|

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.
---|
| GeneratorPulsesPerRarity | 4 | 3 | Lower scaling curve |
| GeneratorRangePerPulse | 300 | 200 | Tighter influence zone |
| GeneratorCooldown | 240 | 300 | Longer downtime |

**Net result:** Tractor control identity is retained with reduced persistent map-control pressure.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

## Compatibility / Ecosystem Notes

- Starfall scripts now better align with optional Cosmic Vault style integrations via `cosmicstarfalllib`.
- No mandatory external hard dependency was introduced for this bridge behavior.
- Design intent is "optional enhancement, safe fallback" rather than strict coupling.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

## Current Avorion Alignment

This revamp specifically addressed script-side issues common in modern Avorion mod stacks:

- safer client/server boundary assumptions,
- safer callback registration patterns,
- safer nil/type handling in high-traffic code paths,
- reduced OP loop risk that can destabilize long-session gameplay balance.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

### 9) `data/scripts/lib/weapongenerator.lua`, `turretingredients.lua`, `turretgenerator.lua`

#### Fixes

- **Removed destructive hard-overwrites:** Original mod completely replaced vanilla weapon generation, turret factory recipes, and specialties.
- Converted vanilla weapon buffs (dps multipliers, elemental damage injections) into safe hooks (`local old_generateChaingun = WeaponGenerator.generateChaingun`).

#### Effect

- Mod is now 100% compatible with Cosmic Overhaul and other mods that touch vanilla weapon economy and balance.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

### 10) `data/scripts/lib/shiputility.lua`, `tooltipmaker.lua`

#### Fixes

- Refactored `shiputility.lua` to safely append weapons using `table.insert` instead of completely overwriting AI weapon arrays. AI super-weapon generation filtering is safely hooked.
- Completely removed the 400-line vanilla overwrite in `tooltipmaker.lua` and replaced it with a non-invasive hook that strictly appends Starfall's UI tooltips.

#### Effect

- Prevents other mods' custom UI from being obliterated, and natively supports future Avorion engine updates.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

### 11) `data/scripts/neltharaku/Aquaflow.lua`

#### Fixes

- Stubbed out the entire file due to a massive Arbitrary Code Execution (ACE) security vulnerability (use of `loadstring` on raw files) and dedicated server crashes involving blind `Player()` calls.

#### Effect

- Safely neutralizes the security threat while preventing crash loops in the abandoned developer UI panels.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

### 12) `data/scripts/complexCraft/complexCoreV2.lua`

#### Fixes

- **Security:** Patched a severe exploit where malicious clients could transfer cargo from any entity in the sector regardless of ownership or docking status.
- **Stability:** Moved client-authoritative `invokeClientFunction` logic to `updateClient` to prevent guaranteed server crashes.
- Fixed array skipping bug in table iteration loops.

#### Effect

- Megacomplex operations are now fully secure, stable, and server-safe.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

---

### 13) `data/scripts/entity/mainCaliber.lua`, `activeSysInterface.lua`

#### Fixes

- **`mainCaliber.lua`:** Shifted entirely to server-authoritative logic. Prevents an exploit where clients could spoof their weapon count and turn the fire-rate penalty into a massive buff. Removed unoptimized frame-by-frame UI loops.
- **`activeSysInterface.lua`:** Fixed "Puppeteer" exploit allowing clients to force any script/command execution on unowned entities across the sector.

#### Effect

- Highly secure, exploit-proof active systems and super-weapon penalty mechanics.

#### 7. Initialization Compliance

- Wrapped all init.lua injection files safely into the vanilla initialize() callback to ensure they do not accidentally wipe out vanilla logic upon load.

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
