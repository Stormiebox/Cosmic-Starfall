package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"
include("callable")
local StarfallSetBonuses = {}
local activeSets = {}

-- Cached tracking variables
local currentDamageBuff = 1.0

function StarfallSetBonuses.initialize()
    if onServer() then
        Entity():registerCallback("onSystemsChanged", "onSystemsChanged")
        Entity():registerCallback("onTurretAdded", "onSystemsChanged")
        Entity():registerCallback("onTurretDestroyed", "onSystemsChanged")
        Entity():registerCallback("onTurretRemoved", "onSystemsChanged")
        -- recalculateBonuses() is intentionally omitted here.
        -- It should be called during onRestore or onSystemsChanged.
    else
        -- Client side UI uses Ship Problems, so we don't need onPreRenderHud
    end
end

-- SERVER SIDE LOGIC
function StarfallSetBonuses.onSystemsChanged()
    StarfallSetBonuses.recalculateBonuses()
end

function StarfallSetBonuses.secure()
    return {
        currentDamageBuff = currentDamageBuff
    }
end

function StarfallSetBonuses.restore(data)
    -- Keys are volatile and invalid after restart; do not restore them
    currentDamageBuff = data.currentDamageBuff or 1.0
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
    local systemUpgrades = ShipSystem():getUpgrades()
    for upgrade, _ in pairs(systemUpgrades) do
        if type(upgrade) == "userdata" and upgrade.script then
            sysCount[upgrade.script] = true
        elseif type(upgrade) == "table" and upgrade.script then
            sysCount[upgrade.script] = true
        end
    end

    -- 2. Check Turrets
    for _, turret in pairs(turrets) do
        local template = TurretTemplate(turret)
        if template then
            local weapons = {template:getWeapons()}
            if #weapons > 0 then
                local wType = weapons[1].weaponType
                local wCat = weapons[1].weaponCategory

                if wType == WeaponType.MiningLaser or wType == WeaponType.RawMiningLaser then
                    turretCount.miner = turretCount.miner + 1
                elseif wType == WeaponType.SalvagingLaser or wType == WeaponType.RawSalvagingLaser then
                    turretCount.salvager = turretCount.salvager + 1
                elseif wType == WeaponType.PointDefenseLaser or wType == WeaponType.PointDefenseChainGun or wType == WeaponType.AntiFighter then
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
    end

    local newlyActiveSets = {}
    local previouslyActiveSets = activeSets
    activeSets = {}

    -- Removed manual damageMultiplier division
    local newDamageBuff = 1.0

    -- Clear old modifiers safely
    entity:removeScriptBonuses()

    local function applyBuff(stat, value, isMultiplier)
        if isMultiplier then
            entity:addMultiplier(stat, value)
        else
            entity:addMultiplyableBias(stat, value)
        end
    end

    -- EVALUATE SUBSYSTEM SETS
    if sysCount["data/scripts/systems/bastionSystem.lua"] and sysCount["data/scripts/systems/overpoweredCore.lua"] then
        table.insert(newlyActiveSets, {text = "Aegis Matrix (Bastion + Overpowered)", icon = "data/textures/icons/SYSbastion.png"})
        applyBuff(StatsBonuses.ShieldRecharge, 0.2, false)
        applyBuff(StatsBonuses.ShieldDurability, 0.1, false)
    end
    if sysCount["data/scripts/systems/repairDrones.lua"] and sysCount["data/scripts/systems/pulseTractorBeamGenerator.lua"] then
        table.insert(newlyActiveSets, {text = "Drone-Weaver Network (Repair + Tractor)", icon = "data/textures/icons/SYSrepairDrones.png"})
        applyBuff(StatsBonuses.FighterSquads, 2, false)
    end
    if sysCount["data/scripts/systems/XperimentalHypergenerator.lua"] and sysCount["data/scripts/systems/subspaceCargo.lua"] then
        table.insert(newlyActiveSets, {text = "Void-Runner Config (Hyperdrive + Cargo)", icon = "data/textures/icons/SYShypergenerator.png"})
        applyBuff(StatsBonuses.HyperspaceReach, 0.2, false)
        applyBuff(StatsBonuses.Velocity, 0.15, false)
    end

    if turretCount.miner >= 5 then
        table.insert(newlyActiveSets, {text = "Mining Doctrine (5+ Miners)", icon = "data/textures/icons/staDurability.png"})
        applyBuff(StatsBonuses.GeneratedEnergy, 0.15, false)
        applyBuff(StatsBonuses.CargoHold, 0.15, false)
    end

    if turretCount.salvager >= 5 then
        table.insert(newlyActiveSets, {text = "Salvage Doctrine (5+ Salvagers)", icon = "data/textures/icons/staDurability.png"})
        applyBuff(StatsBonuses.ShieldDurability, 0.20, false)
    end

    if turretCount.pdc >= 5 then
        table.insert(newlyActiveSets, {text = "Point Defense Doctrine (5+ PDCs)", icon = "data/textures/icons/ASSAULTBLASTER.png"})
        applyBuff(StatsBonuses.Velocity, 0.10, false)
        applyBuff(StatsBonuses.Acceleration, 0.15, false)
    end

    if turretCount.artillery >= 5 then
        table.insert(newlyActiveSets, {text = "Artillery Doctrine (5+ Cannons)", icon = "data/textures/icons/WPNassaultCannon.png"})
        applyBuff(StatsBonuses.Velocity, 0.10, false)
        newDamageBuff = newDamageBuff + 0.15
    end

    if turretCount.laser >= 5 then
        table.insert(newlyActiveSets, {text = "Energy Doctrine (5+ Lasers/Plasma)", icon = "data/textures/icons/PULSELASER.png"})
        applyBuff(StatsBonuses.ShieldRecharge, 0.15, false)
        newDamageBuff = newDamageBuff + 0.15
    end

    if turretCount.launcher >= 5 then
        table.insert(newlyActiveSets, {text = "Launcher Doctrine (5+ Launchers/Bolters)", icon = "data/textures/icons/SOLARTORPEDO.png"})
        newDamageBuff = newDamageBuff + 0.20
    end

    -- Apply new damage buff securely
    if newDamageBuff > 1.0 then
        applyBuff(StatsBonuses.FireRate, newDamageBuff - 1.0, false)
    end
    currentDamageBuff = newDamageBuff

    activeSets = newlyActiveSets

    -- Send update to client for UI rendering
    broadcastInvokeClientFunction("updateClientSets", activeSets)
end

function StarfallSetBonuses.updateClientSets(sets)
    if not onClient() then return end

    -- Remove old UI problems
    for _, oldSet in ipairs(activeSets) do
        removeShipProblem("SF_SetBonus_" .. oldSet.text, Entity().id)
    end

    activeSets = sets

    -- Add new UI problems
    for _, newSet in ipairs(activeSets) do
        addShipProblem("SF_SetBonus_" .. newSet.text, Entity().id, newSet.text, newSet.icon, ColorHSV(150, 0.64, 1), false)
    end
end

function initialize(...)
    if StarfallSetBonuses.initialize then return StarfallSetBonuses.initialize(...) end
end

-- Global Event Callbacks
function onSystemsChanged(...)
    if StarfallSetBonuses.onSystemsChanged then return StarfallSetBonuses.onSystemsChanged(...) end
end
function updateClientSets(sets)
    if StarfallSetBonuses.updateClientSets then return StarfallSetBonuses.updateClientSets(sets) end
end
callable(nil, "updateClientSets")
function secure()
    if StarfallSetBonuses.secure then return StarfallSetBonuses.secure() end
end
function restore(data)
    if StarfallSetBonuses.restore then return StarfallSetBonuses.restore(data) end
end
