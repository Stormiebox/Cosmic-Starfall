# Cosmic Starfall - Detailed Features

Welcome to the **Cosmic Starfall** official wiki! This page contains the full, detailed documentation for the mod, a modernization and continuation of the original **Starfall** concept for current Avorion-era mod stacks.

**As of v2.0.0, Cosmic Starfall is natively integrated into the Cosmic Series.** It uses the advanced APIs provided by **Cosmic Vault**.

**Cosmic Starfall is focused on:**
- Preserving high-tech identity and flavor.
- Replacing legacy overpowered behavior with balanced, strategic mechanics.
- Achieving 100% crash-free stability through asynchronous processing and direct QA hardening.
- Operating seamlessly alongside Cosmic Overhaul and Cosmic War.

---

## Table of Contents
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

## Mod Identity & Heritage
**Cosmic Starfall** is a ground-up continuation and rework of the original Starfall concept.

**Guiding Philosophy:**
1. Keep the fantasy.
2. Remove unhealthy dominance loops.
3. Improve lifecycle safety and maintainability.
4. Prepare for long-session and larger-stack reliability.

## Architecture Direction
The mod combines three core pillars:
1. **Balance Pass** on high-impact systems.
2. **QA Hardening** in risky script paths.
3. **Compatibility Scaffolding** via helper bridge patterns.

---

## Full Feature Breakdown

### 1) Major Balance Revamp (Anti-OP Strategy)
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

### 2) Reliability & QA Hardening Pass
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

### 3) Security & Anti-Exploit Overhaul
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

### 4) Native Cosmic Vault Integration
<details>
<summary><b>Click to expand details</b></summary>

**What it does:**
Cosmic Starfall has completely eliminated its legacy compatibility library (`cosmicstarfalllib`) and now hooks directly into the **Cosmic Vault**.

**Key Integration Points:**
- **Dynamic Economy:** Megacomplexes trigger sector-wide `CosmicVaultEconomy` market crash events when forced to dump over-accumulated cargo.
- **Cinematic Feedback:** Systems broadcast their status via `CosmicVaultUI.ShowCinematicBanner` for immersive, lag-free UI overlays.
- **Asynchronous Processing:** Heavy logic like Repair Waves or Tractor Pulses are scheduled safely onto `CosmicVaultTask.RunAsync()`, protecting the server's TPS rate during massive fleet clashes.

**Why it matters:**
Enables seamless interoperability with the entire Cosmic Series while simultaneously granting extreme performance uplifts that were not possible with vanilla scripts alone.
</details>


### 5) Deep-Dive Script Corrections & Hygiene
<details>
<summary><b>Click to expand details</b></summary>

- **Virtual File System (VFS) Compliance:** Fixed a major architectural flaw where shiputility.lua was blindly overriding the vanilla script and destroying compatibility with other mods. The AI Weapon Pool injection now properly utilizes modern Avorion 2.0 VFS hook techniques.
- **UI Restoration:** Fixed fatal silent crashes in the player infoTab modules caused by missing utility includes. The built-in Starfall Wiki interface has been fully restored and updated.
- **Math Logic Fixes:** Identified and resolved completely reversed math inside the Bastion System (where tooltips displayed negative penalties despite providing positive buffs).
- **Injection Safety:** All script injections in init.lua arrays now use rigorous data/scripts/... absolute pathways to prevent load failures on dedicated servers.

</details>


---
### 6) Arsenal & Subsystem Statistics
<details>
<summary><b>Click to expand full numeric details</b></summary>

#### Advanced Subsystems

**1. The Overpowered Core (overpoweredCore.lua)**
- **Function:** Dramatically increases energy generation and capacity.
- **Rarity Scaling:** Dynamically scales based on rarity tier.
  - **Petty (Grey):** +5% Energy Generation & Capacity
  - **Common (White):** +7% Energy Generation & Capacity
  - **Uncommon (Green):** +9% Energy Generation & Capacity
  - **Rare (Blue):** +11% Energy Generation & Capacity
  - **Exceptional (Yellow):** +13% Energy Generation & Capacity
  - **Legendary (Purple):** +15% Energy Generation & Capacity

**2. The Bastion System (astionSystem.lua)**
- **Function:** Massively multiplies base shield durability at the cost of shield regeneration delay.
- **Rarity Scaling:**
  - **Shield Durability Bonus:** Positively scales from +69% up to +83% (Legendary).
  - **Recharge Penalty:** Increases recharge delay after taking a hit.

#### Vanilla Weapon Modifications (weapongenerator.lua)
Cosmic Starfall slightly augments the baseline strength of some vanilla physical weapons to ensure they remain competitive alongside the new energy-heavy arsenal.
- **Chainguns:** Base Damage x 1.10, Reach + Tech * 3, Recoil heavily increased. 15% chance to spawn with Antimatter or Plasma damage, 5% chance for Electric.
- **Bolters:** Base Damage x 1.05, Damage Type natively converted to Antimatter.

</details>


## Ecosystem & Server Considerations

### Compatibility Position in Cosmic Series
**Cosmic Starfall** aims to:
- Run smoothly as a standalone module.
- Participate in broader Cosmic ecosystem conventions where optional helper bridges are present.

It does **not** require hard coupling to external modules for core operation in its current direction.

### Multiplayer / Server Considerations
- Additional runtime validation in dedicated server conditions is still recommended.
- Long-session soak testing remains part of ongoing stabilization.
- In mixed mod stacks, monitor logs for lifecycle edge cases and ensure consistent load order.

### Performance & Safety Notes
- Safety and correctness improvements were prioritized in high-risk scripts.
- Balance adjustments intentionally reduce extreme uptime loops that can destabilize encounters and progression pacing.
- Further performance and balance tuning should be telemetry-guided.

---

## Installation & Troubleshooting

### Installation
1. Place the folder in:
   - **Windows:** `%AppData%\Avorion\mods\`
   - **Linux:** `~/.avorion/mods/`
2. Enable **Cosmic Starfall** in **Settings -> Mods**.
3. Restart Avorion when prompted.

### Troubleshooting Checklist
- [ ] Confirm the mod is enabled in the Avorion settings.
- [ ] Review client/server logs for script errors after startup.
- [ ] Validate the behavior of high-impact systems in your current load order.
- [ ] If using larger mod stacks, test dedicated server lifecycle scenarios.
- [ ] Use the changelog tables (`Cosmic_Starfall_CHANGELOG.md`) to understand expected post-rebalance values.

---

## Development Status

Cosmic Starfall is currently an **active WIP** with ongoing runtime validation and balancing.

**Current State Priorities:**
- Strategic balance over extreme dominance.
- Script safety and reliability.
- Compatibility-minded evolution for broader Cosmic ecosystem use.

