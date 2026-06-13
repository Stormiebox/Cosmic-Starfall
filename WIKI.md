# ⚙️ Cosmic Starfall - Detailed Features

Welcome to the **Cosmic Starfall** official wiki! This page contains the full, detailed documentation for the mod, a modernization and continuation of the original **Starfall** concept for current Avorion-era mod stacks.

**Cosmic Starfall is focused on:**
- Preserving high-tech identity and flavor.
- Reducing legacy overpowered behavior.
- Hardening scripts for reliability.
- Improving compatibility with the broader Cosmic ecosystem.

---

## 📑 Table of Contents
- Mod Identity & Heritage
- Architecture Direction
- Full Feature Breakdown
  - 1) Major Balance Revamp (Anti-OP Strategy)
  - 2) Reliability & QA Hardening Pass
  - 3) Security & Anti-Exploit Overhaul
  - 4) Compatibility Helper Layer (Ecosystem Bridge)
  - 5) Deep-Dive Script Corrections & Hygiene
- Ecosystem & Server Considerations
- Installation & Troubleshooting
- Development Status

---

## 🧬 Mod Identity & Heritage
**Cosmic Starfall** is a ground-up continuation and rework of the original Starfall concept.

**Guiding Philosophy:**
1. Keep the fantasy.
2. Remove unhealthy dominance loops.
3. Improve lifecycle safety and maintainability.
4. Prepare for long-session and larger-stack reliability.

## 🏗️ Architecture Direction
The mod combines three core pillars:
1. **Balance Pass** on high-impact systems.
2. **QA Hardening** in risky script paths.
3. **Compatibility Scaffolding** via helper bridge patterns.

---

## ⚙️ Full Feature Breakdown

### ⚖️ 1) Major Balance Revamp (Anti-OP Strategy)
<details>
<summary><b>Click to expand details</b></summary>

**Target Systems:**
- `data/scripts/systems/bastionSystem.lua`
- `data/scripts/systems/macrofieldProjector.lua`
- `data/scripts/systems/pulseTractorBeamGenerator.lua`

**Intent:**
Reduce runaway power spikes while preserving each system’s gameplay identity.

**High-Level Outcomes:**
- Lower passive sustain ceilings.
- Longer cooldown commitment windows.
- Reduced burst-heal and shield spike throughput.
- More meaningful energy and cost tradeoffs.
- Reduced persistent control-zone pressure.

**Gameplay Impact:**
- Fewer “always best” loadout outcomes.
- Better strategic timing requirements.
- Improved balance headroom for long campaigns.

*For full numeric old-vs-new value tables and rationale, please refer to the `Cosmic_Starfall_CHANGELOG.md` file.*
</details>

### 🛡️ 2) Reliability & QA Hardening Pass
<details>
<summary><b>Click to expand details</b></summary>

**Key Scripts Hardened:**
- `data/scripts/systems/subspaceCargo.lua`
- `data/scripts/systems/overpoweredCore.lua`
- `data/scripts/complexCraft/complexCore.lua`

**Typical Hardening Categories:**
- Nil and type guard corrections.
- Ownership and identifier safety fixes.
- Lifecycle-safe callback behavior.
- Safer numeric parsing and clamping in UI-adjacent logic.
- Typo and path consistency corrections in rebuild flows.

**Gameplay & Ops Impact:**
- Reduced risk of avoidable runtime errors.
- Cleaner behavior in client/server lifecycle edge cases.
- Improved maintainability for future iteration.
</details>

### 🔒 3) Security & Anti-Exploit Overhaul
<details>
<summary><b>Click to expand details</b></summary>

**Key Security Patches:**
- `mainCaliber.lua`: Converted from client-authoritative to server-authoritative logic to prevent penalty-bypass and buff-spoofing exploits.
- `activeSysInterface.lua`: Hardened script execution to prevent "Puppeteer" exploits (malicious clients remotely running arbitrary code on unowned entities).
- `complexCoreV2.lua`: Patched the Megacomplex "Steal Anything" exploit allowing clients to siphon cargo from undocked/unowned ships.
- `Aquaflow.lua`: Neutralized Arbitrary Code Execution (ACE) vulnerabilities associated with unsafe file parsing.

**Impact:**
- Mod mechanics are fully secured for public dedicated multiplayer servers, ensuring a safe, exploit-free environment.
</details>

### ⚙️ 4) Compatibility Helper Layer (Ecosystem Bridge)
<details>
<summary><b>Click to expand details</b></summary>

**Added Library:** `data/scripts/lib/cosmicstarfalllib.lua`

**What it does:**
Provides helper and bridge behavior for optional ecosystem integration patterns without forcing hard runtime failures if external helpers are absent.

**Design Style:**
- Optional loading patterns (guarded `include` / `pcall` style where applicable).
- Safe fallback when external helper context is missing.
- Centralized owner-routing and helper access patterns to reduce code duplication.

**Latest Hardening in this Layer:**
A focused crash-fix pass hardened owner resolution for modern Avorion runtime contexts:
- Owner descriptor creation now uses guarded access patterns instead of unsafe direct dereference assumptions.
- Owner-index routing is protected against unavailable or unreadable owner states.
- Owner-routed `invoke` helpers now fail safely when the owner context is not valid.

**Why it matters:**
Enables smoother interoperability with broader Cosmic-series workflows while preserving standalone safety and avoiding repeated owner-context stack traces.
</details>

### 5) Deep-Dive Script Corrections & Hygiene
<details>
<summary><b>Click to expand detailed script fixes</b></summary>

#### Subspace Cargo Corrections
- **File:** `data/scripts/systems/subspaceCargo.lua`
- **Fixes:** Deterministic naming mark-level logic cleanup, dead/unused naming path cleanup, and bridge include alignment with the compatibility helper strategy.
- **Impact:** More stable subsystem naming and cleaner script path readability.

#### 🛡️ Overpowered Core Lifecycle Safety Improvements
- **File:** `data/scripts/systems/overpoweredCore.lua`
- **Fixes:** Ownership checks shifted toward safer index/owner-robust logic, side-appropriate callback behavior, and uninstall/state persistence logic adjusted to avoid invalid side assumptions.
- **Impact:** Lower ownership mismatch risk and better client/server correctness.

#### Complex Craft Core Robustness Fixes
- **File:** `data/scripts/complexCraft/complexCore.lua`
- **Fixes:** Nil-before-compare guard ordering improvements, safer `tonumber` parsing and clamping in cargo/UI paths, corrected identifier reference mismatches in rebuild paths, and debug print/lint issue corrections.
- **Impact:** Better operational safety in complex craft management and rebuild flows.

#### Engine Overwrite & Hook Cleanup
- **Files:** `weapongenerator.lua`, `turretingredients.lua`, `turretgenerator.lua`, `shiputility.lua`, `tooltipmaker.lua`
- **Fixes:** Eliminated destructive hard-overwrites of vanilla game code. Original vanilla weapon generation, AI logic, and UI tooltips are no longer replaced. Instead, Starfall's weapon buffs, custom constraints, and UI additions are dynamically applied using non-invasive hooks (`local old_function = ...`).
- **Impact:** Cosmic Starfall is now 100% compliant with the modern Avorion ecosystem, seamlessly sharing engine space with mods like Cosmic Overhaul without breaking recipes or stats.

#### UI & Group Crash Fixes
- **Files:** `entityAlerts.lua`, `combatGroup.lua`, `combatGroupV2.lua`
- **Fixes:** Eliminated guaranteed server crashes linked to UI alerts trying to blindly call `Player()` from server-entity contexts. Added safety checks for `nil` returns when kicking or inviting logged-off players.
- **Impact:** Seamless, crash-free UI rendering and group mechanics.

#### Known Stability Improvements (Latest Cycle)
Specifically addressed recurring owner-context crashes affecting:
- `data/scripts/systems/XperimentalHypergenerator.lua`
- `data/scripts/systems/repairDrones.lua`

**What Changed:** Added owner-availability guards before owner-routed UI invoke/update/delete helper calls. Hardened owner descriptor/index extraction in `cosmicstarfalllib.lua`.
**Practical Outcome:** Eliminated repeated stacktrace patterns tied to `Property not found or not readable: Owner.index`, reduced high-frequency update/UI error spam, and improved resilience under dynamic ownership/lifecycle edge cases in long sessions.

#### Maintainability-Oriented Refactor Hygiene
Reduced fragile patterns in touched areas, clearer code intent in high-risk regions, and better future patchability for subsequent balancing passes. This allows for faster and safer iteration cycles as runtime telemetry informs future tuning.
</details>

---

## ⚙️ Ecosystem & Server Considerations

### Compatibility Position in Cosmic Series
**Cosmic Starfall** aims to:
- Run smoothly as a standalone module.
- Participate in broader Cosmic ecosystem conventions where optional helper bridges are present.

It does **not** require hard coupling to external modules for core operation in its current direction.

### 🌐 Multiplayer / Server Considerations
- Additional runtime validation in dedicated server conditions is still recommended.
- Long-session soak testing remains part of ongoing stabilization.
- In mixed mod stacks, monitor logs for lifecycle edge cases and ensure consistent load order.

### 🛡️ Performance & Safety Notes
- Safety and correctness improvements were prioritized in high-risk scripts.
- Balance adjustments intentionally reduce extreme uptime loops that can destabilize encounters and progression pacing.
- Further performance and balance tuning should be telemetry-guided.

---

## 🛠️ Installation & Troubleshooting

### 🛠️ Installation
1. Place the folder in:
   - **Windows:** `%AppData%\Avorion\mods\`
   - **Linux:** `~/.avorion/mods/`
2. Enable **Cosmic Starfall** in **Settings -> Mods**.
3. Restart Avorion when prompted.

### 🛠️ Troubleshooting Checklist
- [ ] Confirm the mod is enabled in the Avorion settings.
- [ ] Review client/server logs for script errors after startup.
- [ ] Validate the behavior of high-impact systems in your current load order.
- [ ] If using larger mod stacks, test dedicated server lifecycle scenarios.
- [ ] Use the changelog tables (`Cosmic_Starfall_CHANGELOG.md`) to understand expected post-rebalance values.

---

## 📈 Development Status

Cosmic Starfall is currently an **active WIP** with ongoing runtime validation and balancing.

**Current State Priorities:**
- Strategic balance over extreme dominance.
- Script safety and reliability.
- Compatibility-minded evolution for broader Cosmic ecosystem use.


---

## 🔗 Cosmic Series Integration & Audit 3.0 Updates
<details>
<summary><b>Click to expand</b></summary>

During the Cosmic Series Final QA Audit (v3.0+), several massive backend systems were standardized across all mods:

### 📖 Cosmic Codex Integration
All deep lore, stat blocks, and dynamic recipes have been fully integrated into the in-game **Cosmic Codex**. You no longer need to tab out of the game to read these features; they will natively update and unlock inside your Codex UI as you progress!

### 🔒 Network Safety & Anti-Cheat
- **Math.Random Fix:** We systematically replaced all unstable Lua `math.random` calls with Avorion's deterministic `random():getInt()` generation sequence. This guarantees 100% synchronization on Multiplayer Dedicated Servers and prevents cascading desyncs during massive fleet spawns.
- **Callable Validation:** UI and background scripts have been fully hardened. Malicious clients can no longer spoof "free" remote calls; the server actively verifies execution contexts before processing any requests, sealing multiple Arbitrary Code Execution (ACE) vulnerabilities.

### 🛠️ Vanilla Bug Fixes
- **Scout Mission Fix:** We patched a massive, long-standing vanilla bug where Scout Missions would completely skip and ignore Faction Headquarters sectors because the native dialogue trees were missing the template definition.
</details>
