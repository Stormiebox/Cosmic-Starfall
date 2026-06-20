package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
local StarfallSetBonuses = {}
local activeSets = {}

-- Cached tracking variables
local lastCheckTime = 0
local activeModifiers = {}

function StarfallSetBonuses.initialize()
    if onServer() then
        Entity():registerCallback("onInstalledUpgradesChanged", "onUpgradesChanged")
        Entity():registerCallback("onTurretAdded", "onUpgradesChanged")
        Entity():registerCallback("onTurretDestroyed", "onUpgradesChanged")
        Entity():registerCallback("onTurretRemoved", "onUpgradesChanged")
        Entity():registerCallback("onTurretRemovedByPlayer", "onUpgradesChanged")
        StarfallSetBonuses.recalculateBonuses()
    else
        -- Client side for UI rendering
        Player():registerCallback("onPreRenderHud", "onPreRenderHud")
    end
end

-- SERVER SIDE LOGIC
function StarfallSetBonuses.onUpgradesChanged()
    StarfallSetBonuses.recalculateBonuses()
end

function StarfallSetBonuses.recalculateBonuses()
    local entity = Entity()
    if not entity then return end

    local sysCount = {}
    local turrets = {entity:getTurrets()}
    local turretCount = {
        miner = 0,
        salvager = 0,
        pdc = 0,
        artillery = 0,
        laser = 0,
        launcher = 0
    }

    -- 1. Check Subsystems
    local systemUpgrades = ShipSystem(entity.index):getUpgrades()
    for _, upgrade in pairs(systemUpgrades) do
        sysCount[upgrade.script] = true
    end

    -- 2. Check Turrets
    for _, turret in pairs(turrets) do
        local weapons = {turret:getWeapons()}
        if #weapons > 0 then
            local wType = weapons[1].weaponType
            local wCat = weapons[1].weaponCategory

            if wType == WeaponType.MiningLaser or wType == WeaponType.RawMiningLaser then
                turretCount.miner = turretCount.miner + 1
            elseif wType == WeaponType.SalvagingLaser or wType == WeaponType.RawSalvagingLaser then
                turretCount.salvager = turretCount.salvager + 1
            elseif wType == WeaponType.PointDefenseLaser or wType == WeaponType.PointDefenseChaingun or wType == WeaponType.AntiFighter then
                turretCount.pdc = turretCount.pdc + 1
            elseif wType == WeaponType.Cannon or wType == WeaponType.RailGun then
                turretCount.artillery = turretCount.artillery + 1
            elseif wType == WeaponType.Laser or wType == WeaponType.PlasmaGun or wType == WeaponType.LightningGun then
                turretCount.laser = turretCount.laser + 1
            elseif wType == WeaponType.RocketLauncher or wType == WeaponType.Bolter then
                turretCount.launcher = turretCount.launcher + 1
            end
        end
    end

    local newlyActiveSets = {}
    local previouslyActiveSets = activeSets
    activeSets = {}

    -- Clear old modifiers
    for k, v in pairs(activeModifiers) do
        entity:removeMultiplier(k, v)
        entity:removeMultiplyableBias(k, v)
    end
    activeModifiers = {}

    local function applyBuff(stat, value, isMultiplier)
        local key = tostring(stat)
        activeModifiers[stat] = value
        if isMultiplier then
            entity:addMultiplier(stat, value)
        else
            entity:addMultiplyableBias(stat, value)
        end
    end

    local function applyDamageBuff(value, isMultiplier)
        local damageBonuses = {StatsBonuses.EnergyDamage, StatsBonuses.ElectricDamage, StatsBonuses.PlasmaDamage, StatsBonuses.AntiMatterDamage, StatsBonuses.FragmentsDamage, StatsBonuses.PhysicalDamage}
        for _, stat in pairs(damageBonuses) do
            applyBuff(stat, value, isMultiplier)
        end
    end

    -- EVALUATE SUBSYSTEM SETS
    if sysCount["data/scripts/systems/bastionSystem.lua"] and sysCount["data/scripts/systems/overpoweredCore.lua"] then
        table.insert(newlyActiveSets, "Aegis Matrix (Bastion + Overpowered)")
        applyBuff(StatsBonuses.ShieldRecharge, 0.2, false)
        applyBuff(StatsBonuses.ShieldDurability, 0.1, false)
    end

    if sysCount["data/scripts/systems/repairDrones.lua"] and sysCount["data/scripts/systems/pulseTractorBeamGenerator.lua"] then
        table.insert(newlyActiveSets, "Drone-Weaver Network (Repair + Tractor)")
        applyBuff(StatsBonuses.FighterSquads, 2, false)
    end

    if sysCount["data/scripts/systems/XperimentalHypergenerator.lua"] and sysCount["data/scripts/systems/subspaceCargo.lua"] then
        table.insert(newlyActiveSets, "Void-Runner Config (Hyperdrive + Cargo)")
        applyBuff(StatsBonuses.HyperspaceReach, 0.2, false)
        applyBuff(StatsBonuses.Velocity, 0.15, false)
    end

    -- EVALUATE TURRET DOCTRINES (Requires 5)
    if turretCount.miner >= 5 then
        table.insert(newlyActiveSets, "Mining Doctrine (5+ Miners)")
        applyBuff(StatsBonuses.GeneratedEnergy, 0.15, false)
        applyBuff(StatsBonuses.CargoHold, 0.15, false)
    end

    if turretCount.salvager >= 5 then
        table.insert(newlyActiveSets, "Salvage Doctrine (5+ Salvagers)")
        applyBuff(StatsBonuses.ShieldDurability, 0.20, false)
    end

    if turretCount.pdc >= 5 then
        table.insert(newlyActiveSets, "Point Defense Doctrine (5+ PDCs)")
        applyBuff(StatsBonuses.Velocity, 0.10, false)
    end

    if turretCount.artillery >= 5 then
        table.insert(newlyActiveSets, "Artillery Doctrine (5+ Cannons)")
        applyDamageBuff(0.10, false)
    end

    if turretCount.laser >= 5 then
        table.insert(newlyActiveSets, "Energy Doctrine (5+ Lasers/Plasma)")
        applyDamageBuff(0.15, false)
    end

    if turretCount.launcher >= 5 then
        table.insert(newlyActiveSets, "Launcher Doctrine (5+ Launchers/Bolters)")
        applyBuff(StatsBonuses.FireRate, 0.20, false)
    end

    activeSets = newlyActiveSets

    -- Send update to client for UI rendering
    invokeClientFunction(Player(), "updateClientSets", activeSets)
end

-- CLIENT SIDE LOGIC
function StarfallSetBonuses.updateClientSets(sets)
    activeSets = sets
end

function StarfallSetBonuses.onPreRenderHud()
    if #activeSets == 0 then return end

    local res = getResolution()
    local x = res.x - 350
    local y = 200

    drawTextRect("Starfall Active Set Bonuses", Rect(x, y, x + 300, y + 20), -1, 1, ColorRGB(0.5, 0.8, 1), 15, 0, 0, 2)
    y = y + 25

    for _, set in ipairs(activeSets) do
        drawTextRect("• " .. set, Rect(x, y, x + 300, y + 20), -1, 0, ColorRGB(0.8, 1, 0.8), 13, 0, 0, 0)
        y = y + 20
    end
end

function initialize(...)
    if StarfallSetBonuses.initialize then return StarfallSetBonuses.initialize(...) end
end

-- Global Event Callbacks
function onUpgradesChanged(...)
    if StarfallSetBonuses.onUpgradesChanged then return StarfallSetBonuses.onUpgradesChanged(...) end
end
function onPreRenderHud(...)
    if StarfallSetBonuses.onPreRenderHud then return StarfallSetBonuses.onPreRenderHud(...) end
end
