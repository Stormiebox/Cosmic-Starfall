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

## Summary

This Cosmic Starfall revamp differs from the original baseline by being:

- **less overtuned**,
- **more robust under static QA**,
- **more compatible with Cosmic ecosystem extension patterns**,
- and **better prepared for modern Avorion stress-testing cycles**.

Further iteration should be done through runtime telemetry and controlled playtest windows, but this code state is a significantly safer and more maintainable foundation than the prior snapshot.
