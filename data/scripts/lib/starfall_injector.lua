package.path = package.path .. ";data/scripts/lib/?.lua"
local ShipUtility = include("shiputility")

local StarfallInjector = {}

function StarfallInjector.inject()
    -- Prevent double-injection if called multiple times in the same Virtual Machine
    if ShipUtility._starfall_injected then return end
    ShipUtility._starfall_injected = true

    local function insertUnique(tbl, val)
        if not tbl then return end
        for _, v in pairs(tbl) do
            if v == val then return end
        end
        table.insert(tbl, val)
    end

    -- Safely append Starfall weapons to the global AI selection pools
    insertUnique(ShipUtility.AttackWeapons, WeaponType.PULSEGUN)
    insertUnique(ShipUtility.AttackWeapons, WeaponType.PARTICLEACCELERATOR)
    insertUnique(ShipUtility.AttackWeapons, WeaponType.ASSAULTBLASTER)
    insertUnique(ShipUtility.AttackWeapons, WeaponType.PHOTON)
    insertUnique(ShipUtility.AttackWeapons, WeaponType.PRD)

    insertUnique(ShipUtility.AntiShieldWeapons, WeaponType.PRD)
    insertUnique(ShipUtility.AntiShieldWeapons, WeaponType.ASSAULTBLASTER)
    insertUnique(ShipUtility.AntiShieldWeapons, WeaponType.MANTIS)

    insertUnique(ShipUtility.AntiHullWeapons, WeaponType.PARTICLEACCELERATOR)

    insertUnique(ShipUtility.ArtilleryWeapons, WeaponType.PHOTON)
    insertUnique(ShipUtility.ArtilleryWeapons, WeaponType.PRD)
    insertUnique(ShipUtility.ArtilleryWeapons, WeaponType.MANTIS)

    -- Override addSpecializedEquipment dynamically in the cached table!
    local old_addSpecializedEquipment = ShipUtility.addSpecializedEquipment
    ShipUtility.addSpecializedEquipment = function(craft, weaponTypes, torpedoTypes, turretfactor, torpedofactor, turretRange)
        local finalWeaponTypes = weaponTypes
        if weaponTypes then
            finalWeaponTypes = {}
            for _, wType in pairs(weaponTypes) do
                if wType ~= WeaponType.SOLARTORPEDO and wType ~= WeaponType.AVALANCHE and wType ~= WeaponType.CYCLONE and wType ~= WeaponType.HYPERKINETIC then
                    table.insert(finalWeaponTypes, wType)
                end
            end
        end
        return old_addSpecializedEquipment(craft, finalWeaponTypes, torpedoTypes, turretfactor, torpedofactor, turretRange)
    end
end

return StarfallInjector