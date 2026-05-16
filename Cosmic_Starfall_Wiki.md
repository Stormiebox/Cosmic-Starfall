# Cosmic Starfall - Detailed Features

This page contains the full, detailed documentation for **Cosmic Starfall**, a modernization and continuation of the original Starfall concept for current Avorion-era mod stacks.

Cosmic Starfall is focused on:
- preserving high-tech identity and flavor,
- reducing legacy overpowered behavior,
- hardening scripts for reliability,
- and improving compatibility with the broader Cosmic ecosystem.

---

## Mod Identity & Heritage

Cosmic Starfall is a ground-up continuation/rework of the original Starfall concept.

### Guiding philosophy
1. Keep the fantasy.
2. Remove unhealthy dominance loops.
3. Improve lifecycle safety and maintainability.
4. Prepare for long-session and larger-stack reliability.

---

## Architecture Direction

The mod combines three pillars:

1. **Balance pass** on high-impact systems.
2. **QA hardening** in risky script paths.
3. **Compatibility scaffolding** via helper bridge patterns.

---

## Full Feature Breakdown

## 1) Major Balance Revamp (Anti-OP Strategy)

### Target systems
- `data/scripts/systems/bastionSystem.lua`
- `data/scripts/systems/macrofieldProjector.lua`
- `data/scripts/systems/pulseTractorBeamGenerator.lua`

### Intent
Reduce runaway power spikes while preserving each system’s gameplay identity.

### High-level outcomes
- lower passive sustain ceilings
- longer cooldown commitment windows
- reduced burst-heal/shield spike throughput
- more meaningful energy/cost tradeoffs
- reduced persistent control-zone pressure

### Gameplay impact
- fewer “always best” loadout outcomes
- better strategic timing requirements
- improved balance headroom for long campaigns

---

## 2) Reliability & QA Hardening Pass

### Key scripts hardened
- `data/scripts/systems/subspaceCargo.lua`
- `data/scripts/systems/overpoweredCore.lua`
- `data/scripts/complexCraft/complexCore.lua`

### Typical hardening categories
- nil/type guard corrections
- ownership/identifier safety fixes
- lifecycle-safe callback behavior
- safer numeric parsing/clamping in UI-adjacent logic
- typo/path consistency corrections in rebuild flows

### Gameplay/ops impact
- reduced risk of avoidable runtime errors
- cleaner behavior in client/server lifecycle edge cases
- improved maintainability for future iteration

---

## 3) Compatibility Helper Layer (Ecosystem Bridge)

### Added library
- `data/scripts/lib/cosmicstarfalllib.lua`

### What it does
Provides helper/bridge behavior for optional ecosystem integration patterns without forcing hard runtime failure if external helpers are absent.

### Design style
- optional loading patterns (guarded include/pcall style where applicable)
- safe fallback when external helper context is missing
- centralized owner-routing/helper access patterns to reduce duplication

### Latest hardening in this layer
A focused crash-fix pass hardened owner resolution for modern Avorion runtime contexts:
- owner descriptor creation now uses guarded access patterns instead of unsafe direct dereference assumptions.
- owner-index routing is protected against unavailable/unreadable owner state.
- owner-routed invoke helpers now fail safely when owner context is not valid.

### Why it matters
Enables smoother interoperability with broader Cosmic-series workflows while preserving standalone safety and avoiding repeated owner-context stack traces.

---

## 4) Subspace Cargo Corrections

### File
- `data/scripts/systems/subspaceCargo.lua`

### Notable corrections
- deterministic naming mark-level logic cleanup
- dead/unused naming path cleanup
- bridge include alignment with compatibility helper strategy

### Impact
More stable subsystem naming and cleaner script path readability.

---

## 5) Overpowered Core Lifecycle Safety Improvements

### File
- `data/scripts/systems/overpoweredCore.lua`

### Notable corrections
- ownership checks shifted toward safer index/owner-robust logic
- side-appropriate callback behavior
- uninstall/state persistence logic adjusted to avoid invalid side assumptions

### Impact
Lower ownership mismatch risk and better client/server correctness.

---

## 6) Complex Craft Core Robustness Fixes

### File
- `data/scripts/complexCraft/complexCore.lua`

### Notable corrections
- nil-before-compare guard ordering improvements
- safer tonumber parsing and clamping in cargo/UI path
- corrected identifier reference mismatches in rebuild path
- debug print/lint issue corrections

### Impact
Better operational safety in complex craft management/rebuild flows.

---

## 7) Maintainability-Oriented Refactor Hygiene

### What this means in practice
- reduced fragile patterns in touched areas
- clearer code intent in high-risk regions
- better future patchability for subsequent balancing passes

### Impact
Faster/safer iteration cycles as runtime telemetry informs future tuning.

---

## Detailed Balance Notes (Summary)

For full numeric old-vs-new value tables and rationale, see:
- `Cosmic_Starfall_CHANGELOG.md`

That changelog includes detailed parameter-level changes for:
- Bastion
- Macrofield Projector
- Pulse Tractor Beam Generator

---

## Compatibility Position in Cosmic Series

Cosmic Starfall aims to:
- run as a standalone module,
- and participate in broader Cosmic ecosystem conventions where optional helper bridges are present.

It does **not** require hard coupling to external modules for core operation in its current direction.

---

## Multiplayer / Server Considerations

- Additional runtime validation in dedicated server conditions is still recommended.
- Long-session soak testing remains part of ongoing stabilization.
- In mixed stacks, monitor logs for lifecycle edge cases and ensure consistent load order.

---

## Performance & Safety Notes

- Safety/correctness improvements were prioritized in high-risk scripts.
- Balance adjustments intentionally reduce extreme uptime loops that can destabilize encounters and progression pacing.
- Further performance/balance tuning should be telemetry-guided.

---

## Installation

1. Place folder in:
   - Windows: `%AppData%\Avorion\mods\`
   - Linux: `~/.avorion/mods/`
2. Enable Cosmic Starfall in **Settings -> Mods**.
3. Restart Avorion when prompted.

---

## Troubleshooting Checklist

1. Confirm mod enabled in Avorion settings.
2. Review client/server logs for script errors after startup.
3. Validate behavior of high-impact systems in your current load order.
4. If using larger stacks, test dedicated server lifecycle scenarios.
5. Use changelog tables to understand expected post-rebalance values.

---

## Known Stability Improvements (Latest Cycle)

The latest integration/fix cycle specifically addressed recurring owner-context crashes affecting:
- `data/scripts/systems/XperimentalHypergenerator.lua`
- `data/scripts/systems/repairDrones.lua`

### What was changed
- Added owner-availability guards before owner-routed UI invoke/update/delete helper calls.
- Hardened owner descriptor/index extraction in `cosmicstarfalllib.lua`.

### Practical outcome
- Eliminated repeated stacktrace pattern tied to:
  - `Property not found or not readable: Owner.index`
- Reduced high-frequency update/UI error spam in affected systems.
- Improved resilience under dynamic ownership/lifecycle edge cases in long sessions.

---

## Development Status

Cosmic Starfall is active WIP with ongoing runtime validation and balancing.

Current state priorities:
- strategic balance over extreme dominance,
- script safety and reliability,
- compatibility-minded evolution for broader Cosmic ecosystem use.
