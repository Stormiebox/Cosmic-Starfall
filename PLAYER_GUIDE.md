# Cosmic Starfall - Player Guide

Welcome to **Cosmic Starfall**, an expansive sci-fi fantasy arsenal and subsystem mod that brings powerful, high-tech weaponry and advanced utility modules to your Avorion universe!

## What is Cosmic Starfall?
Cosmic Starfall adds a massive suite of new, custom-built weapons and starship subsystems designed to look spectacular and offer new ways to conquer the galaxy. Whether you are building an invincible shield-tanking dreadnought, a carrier loaded with nanobot repair beams, or a rapid-fire plasma artillery platform, Starfall provides the tools you need.

---

## 🚀 How to Acquire Starfall Tech
Starfall equipment seamlessly integrates into the vanilla game. You do not need to do anything special to find it:
* **Loot:** Destroying enemy ships and bosses has a chance to drop Starfall weapons and subsystems.
* **Equipment Docks:** Vendors will naturally stock Starfall tech alongside vanilla items.
* **Turret Factories:** You can craft your own custom Starfall turrets! (See the Weapon Arsenal below).
* **AI Enemies:** Be warned—hostile military fleets, pirates, and headhunters can (and will) spawn using Starfall weapons against you!

---

## ⚔️ The Weapon Arsenal
Cosmic Starfall introduces over a dozen new weapon types. Here are some of the heavy hitters you can expect to find:

### Energy & Shield Breakers
* **Pulse Guns & Pulse Lasers:** Rapid-fire energy weapons that excel at stripping shields.
* **Photon Blasters & Cannons:** Heavy, devastating bursts of raw energy.
* **Transphasic Lasers:** Advanced beams that bypass traditional defenses.
* **Mantis Beams:** specialized energy projectors for sustained damage.

### Kinetics & Armor Piercers
* **Particle Accelerators:** High-velocity kinetic slugs that punch through thick hull armor.
* **Magnetic Mortars:** Slow-moving but explosive area-of-effect payloads.
* **Hyperkinetic Cannons:** Extreme long-range artillery for sniping capital ships.
* **Plasma Flak:** Defensive burst-cannons designed to shred incoming fighter swarms.

### Utility & Support
* **Nano-Repair Beams:** Fire these at your allied ships (or your own fighters) to rapidly repair their hull damage mid-combat!
* **Charging Beams:** Specialized support weapons that restore allied energy shields.

---

## 🛡️ Advanced Subsystems
Cosmic Starfall provides several new permanent ship upgrade modules (Systems) that offer unique, high-tier bonuses.

### ⚙️ The Bastion System
A defensive powerhouse. When installed, it massively multiplies your total **Shield Durability** (up to +83% at Legendary!). However, this sheer power draws heavily from your reactor, causing a massive reduction in shield recharge speed. Best used on heavy dreadnoughts that need to survive massive burst damage.

### The Overpowered Core
A hyper-efficient reactor enhancement. It provides a pure, unadulterated boost to both **Generated Energy** and **Energy Capacity** (scaling from +5% to +15% based on rarity). A must-have for ships running energy-hungry weapon setups.

### Microfield Projectors
A specialized utility module that optimizes your ship's internal volume, granting scaling bonuses to mobility, cargo space, or turret slots depending on its generation seed.

### Megacomplex Cores
For the economic moguls. Installing a Megacomplex core allows you to vastly streamline your station management by merging production lines and significantly boosting your factory output efficiency.

---

## 🛠️ Frequently Asked Questions (FAQ)

**Does this mod require Cosmic Overhaul or Cosmic Vault?**
Yes! As of v2.0.0, Cosmic Starfall natively integrates with the Cosmic Series ecosystem. It **requires Cosmic Vault** to run. This allows the mod to utilize advanced API features like dynamic market crashes, cinematic UI banners and async performance processing.

**Is it balanced for late-game?**
Yes. As of Update v2.0.0, Starfall has been heavily audited. Weapons scale fairly into the late-game Ogonite/Avorion tiers, and modules use dynamic rarity scaling so you are always rewarded for hunting down Legendary (Violet) drops.

**Can I use this on a Multiplayer Server?**
Absolutely. Cosmic Starfall utilizes strict Virtual File System (VFS) hooks and has been optimized specifically to prevent desyncs and UI crashes on dedicated servers.

---

## 📈 v3.0.0 Update Additions

### ⚙️ Subsystem Synergies (Set Bonuses)
Cosmic Starfall now supports hidden set bonuses. By installing specific combinations of Starfall subsystems, you can unlock massive, permanent buffs for your ship:
*   **The Aegis Matrix** (Bastion System + Overpowered Core): Counteracts the Bastion's native recharge penalty. Grants +20% Shield Recharge Rate and +10% Shield Durability.
*   **The Drone-Weaver Network** (Repair Drones + Pulse Tractor Beam): Grants +25% Hull Repair Speed and +2 Max Fighters.
*   **The Void-Runner Configuration** (Xperimental Hypergenerator + Subspace Cargo): Grants +20% Hyperspace Jump Range and +15% Velocity.

### Turret Synergies (Fleet Doctrines)
To reward players who heavily specialize their ships, equipping 5 or more of the same turret type (Vanilla or Modded) will unlock "Fleet Doctrine" set bonuses.
*   **Mining Doctrine (5+ Miners):** +15% Energy Generation, +15% Cargo Capacity.
*   **Salvage Doctrine (5+ Salvagers):** +20% Shield Durability.
*   **Point Defense Doctrine (5+ PDCs/Anti-Fighter):** +15% Dodge Chance, +10% Velocity.
*   **Artillery Doctrine (5+ Cannons/Mortars/Railguns):** +25% Weapon Range, +10% Damage.
*   **Energy Doctrine (5+ Lasers/Plasma):** +15% Shield Penetration/Damage.
*   **Launcher Doctrine (5+ Launchers/Bolters):** +20% Fire Rate.

*All active set bonuses are now clearly visible on your main HUD.*


---

## 🔗 Cosmic Series Integration & Audit 3.0 Updates
<details>
<summary><b>Click to expand</b></summary>

During the Cosmic Series Final QA Audit (v3.0+), several massive backend systems were standardized across all mods:

### 🔒 Network Safety & Anti-Cheat
- **Math.Random Fix:** We systematically replaced all unstable Lua `math.random` calls with Avorion's deterministic `random():getInt()` generation sequence. This guarantees 100% synchronization on Multiplayer Dedicated Servers and prevents cascading desyncs during massive fleet spawns.
- **Callable Validation:** UI and background scripts have been fully hardened. Malicious clients can no longer spoof "free" remote calls; the server actively verifies execution contexts before processing any requests, sealing multiple Arbitrary Code Execution (ACE) vulnerabilities.

### 🛠️ Vanilla Bug Fixes
- **Scout Mission Fix:** We patched a massive, long-standing vanilla bug where Scout Missions would completely skip and ignore Faction Headquarters sectors because the native dialogue trees were missing the template definition.
</details>
