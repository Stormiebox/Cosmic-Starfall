-- Safely append Starfall weapons to the global AI selection pools
if ShipUtility.AttackWeapons then
    table.insert(ShipUtility.AttackWeapons, WeaponType.PULSEGUN)
    table.insert(ShipUtility.AttackWeapons, WeaponType.PARTICLEACCELERATOR)
    table.insert(ShipUtility.AttackWeapons, WeaponType.ASSAULTBLASTER)
    table.insert(ShipUtility.AttackWeapons, WeaponType.PHOTON)
    table.insert(ShipUtility.AttackWeapons, WeaponType.PRD)
end

if ShipUtility.AntiShieldWeapons then
    table.insert(ShipUtility.AntiShieldWeapons, WeaponType.PRD)
    table.insert(ShipUtility.AntiShieldWeapons, WeaponType.ASSAULTBLASTER)
    table.insert(ShipUtility.AntiShieldWeapons, WeaponType.MANTIS)
end

if ShipUtility.AntiHullWeapons then
    table.insert(ShipUtility.AntiHullWeapons, WeaponType.PARTICLEACCELERATOR)
end

if ShipUtility.ArtilleryWeapons then
    table.insert(ShipUtility.ArtilleryWeapons, WeaponType.PHOTON)
    table.insert(ShipUtility.ArtilleryWeapons, WeaponType.PRD)
    table.insert(ShipUtility.ArtilleryWeapons, WeaponType.MANTIS)
end

function ShipUtility.isAllowedForNPC(_value)
    if _value == WeaponType.SOLARTORPEDO then return false end
    if _value == WeaponType.AVALANCHE then return false end
    if _value == WeaponType.CYCLONE then return false end
    if _value == WeaponType.HYPERKINETIC then return false end
    return true
end

local old_addSpecializedEquipment = ShipUtility.addSpecializedEquipment
function ShipUtility.addSpecializedEquipment(craft, weaponTypes, torpedoTypes, turretfactor, torpedofactor, turretRange)
    local finalWeaponTypes = weaponTypes

    -- Filter out Super-Weapons from the AI's selection pool before generating
    if weaponTypes then
        finalWeaponTypes = {}
        for _, wType in pairs(weaponTypes) do
            if ShipUtility.isAllowedForNPC(wType) then
                table.insert(finalWeaponTypes, wType)
            end
        end
    end

    return old_addSpecializedEquipment(craft, finalWeaponTypes, torpedoTypes, turretfactor, torpedofactor, turretRange)
end
