# Cosmic Starfall

Cosmic Starfall is a **work-in-progress Avorion revamp** based on the original mod:
https://steamcommunity.com/sharedfiles/filedetails/?id=2977686775

This version in Avorion Vault focuses on:
- gameplay rebalance (anti-OP tuning),
- script QA hardening and bug fixes,
- compatibility prep for broader Cosmic ecosystem usage (including optional Cosmic Vault bridges),
- and modernization for current Avorion-era scripting expectations.

---

## Current Status

- **Development State:** Active WIP
- **Primary Goal:** Transform Starfall from a high-volatility/overpowered state into a more stable, strategic, and maintainable module set.
- **Testing State:** Static QA and targeted fixes completed; runtime/live-session balancing remains iterative.

---

## What Was Updated

### 1) Major Balance Pass (Conservative Nerf Strategy)
High-impact systems were re-tuned to reduce runaway power spikes while preserving their gameplay identity:

- `bastionSystem.lua`
- `macrofieldProjector.lua`
- `pulseTractorBeamGenerator.lua`

This pass reduced excessive uptime, burst healing/shield spikes, and low-cost dominance loops.

### 2) QA & Reliability Fixes
Targeted script hardening and bug fixes were performed in:

- `subspaceCargo.lua`
- `overpoweredCore.lua`
- `complexCraft/complexCore.lua`

Includes safer nil/type guards, corrected identifier usage, cleaner ownership checks, and lifecycle-safe adjustments.

### 3) Compatibility Layer Added
A shared helper bridge was added:

- `data/scripts/lib/cosmicstarfalllib.lua`

This provides optional compatibility routing and safer helper patterns for cross-mod ecosystem usage without introducing hard-fail dependency behavior.

---

## Changelog

A full detailed revamp log is available in:

- **`Cosmic_Starfall_CHANGELOG.md`**

It includes:
- all applied balance values (old vs new),
- QA fixes,
- compatibility additions,
- and modernization rationale.

---

## Design Direction

Cosmic Starfall is being aligned to the broader **Cosmic mod ecosystem** philosophy:

- Keep unique fantasy and high-tech identity.
- Remove unhealthy “always best” module behavior.
- Improve script safety for long-running saves and larger mod stacks.
- Preserve extension points for future integration with Cosmic Overhaul / Cosmic Vault-adjacent workflows.

---

## Notes

- This is not yet the final public balance state.
- Additional runtime validation (singleplayer + dedicated server soak) is expected.
- Values may continue to be tuned based on practical playtest telemetry.
