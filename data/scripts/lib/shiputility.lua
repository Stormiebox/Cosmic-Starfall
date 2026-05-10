local DefenseWeapons =
{
    WeaponType.PointDefenseChainGun,
    WeaponType.PointDefenseLaser,
    WeaponType.AntiFighter,
}
ShipUtility.DefenseWeapons = DefenseWeapons

local AttackWeapons =
{
    WeaponType.ChainGun,
    WeaponType.Bolter,
    WeaponType.PlasmaGun,
    WeaponType.Laser,
    WeaponType.PulseCannon,
    WeaponType.Cannon,
    WeaponType.RocketLauncher,
    WeaponType.LightningGun,
    WeaponType.TeslaGun,
    WeaponType.RailGun,
	WeaponType.PULSEGUN,
	WeaponType.PARTICLEACCELERATOR,
	WeaponType.ASSAULTBLASTER,
	WeaponType.PHOTON,
	WeaponType.PRD,
}
ShipUtility.AttackWeapons = AttackWeapons

local AntiShieldWeapons =
{
    WeaponType.PlasmaGun,
    WeaponType.PulseCannon,
    WeaponType.LightningGun,
    WeaponType.TeslaGun,
	WeaponType.PRD,
	WeaponType.ASSAULTBLASTER,
	WeaponType.MANTIS,
}
ShipUtility.AntiShieldWeapons = AntiShieldWeapons

local AntiHullWeapons =
{
    WeaponType.Bolter,
    WeaponType.RailGun,
	WeaponType.PARTICLEACCELERATOR,
}
ShipUtility.AntiHullWeapons = AntiHullWeapons

local ArtilleryWeapons =
{
    WeaponType.Cannon,
    WeaponType.RocketLauncher,
	WeaponType.PHOTON,
	WeaponType.PRD,
	WeaponType.MANTIS,
}
ShipUtility.ArtilleryWeapons = ArtilleryWeapons

function ShipUtility.isAllowedForNPC(_value)
	if _value == WeaponType.SOLARTORPEDO then return false end
	if _value == WeaponType.AVALANCHE then return false end
	if _value == WeaponType.CYCLONE then return false end
	if _value == WeaponType.HYPERKINETIC then return false end
	return true
end

function ShipUtility.addSpecializedEquipment(craft, weaponTypes, torpedoTypes, turretfactor, torpedofactor, turretRange)
	print('addSpecializedEquipment at my side')
    turretfactor = turretfactor or 1
    torpedofactor = torpedofactor or 0
    weaponTypes = weaponTypes or {}
    torpedoTypes = torpedoTypes or {}

    local faction = Faction(craft.factionIndex)
    local x, y

    -- let the torpedo and turret generator seeds be based on the home sector of a faction
    -- this makes sure that factions always have the same kinds of weapons
    if faction then
        x, y = faction:getHomeSectorCoordinates()
    else
        x, y = Sector():getCoordinates()
    end

    local seed = SectorSeed(x, y)

    if #weaponTypes > 0 and turretfactor > 0 then
        local turrets = Balancing_GetEnemySectorTurrets(Sector():getCoordinates()) * turretfactor + 2

        -- select a weapon out of the weapon types that can be used in this sector
        local weaponProbabilities = Balancing_GetWeaponProbability(x, y)
        local tmp = weaponTypes
        weaponTypes = {}

        for _, type in pairs(tmp) do
            if weaponProbabilities[type] and weaponProbabilities[type] > 0 and ShipUtility.isAllowedForNPC(type) then
                table.insert(weaponTypes, type)
            end
        end

        local weaponType = randomEntry(random(), weaponTypes)

        -- equip turrets
        local generator = SectorTurretGenerator(seed)
        generator.maxRarity = Rarity(RarityType.Rare)
        generator.coaxialAllowed = false

        local rarity = nil
        if weaponType == WeaponType.PointDefenseChainGun then
            rarity = ShipUtility.getPDCRarity()
        end

        if weaponType then
            local turret = generator:generate(x, y, 0, rarity, weaponType)

            if turretRange then
                turret:setRange(turretRange)
            end

            ShipUtility.addTurretsToCraft(craft, turret, turrets)
        end
    end

    if #torpedoTypes > 0 and torpedofactor > 0 then
        local torpedoes = Balancing_GetEnemySectorTurrets(Sector():getCoordinates()) * torpedofactor + 1

        -- select a torpedo out of the torpedo types that can be used in this sector
        local generator = TorpedoGenerator(seed)
        local torpedoProbabilities = generator:getWarheadProbability(x, y)
        local tmp = torpedoTypes
        torpedoTypes = {}

        for _, type in pairs(tmp) do
            if torpedoProbabilities[type] and torpedoProbabilities[type] > 0 then
                table.insert(torpedoTypes, type)
            end
        end

        if #torpedoTypes > 0 then
            local torpedoType = randomEntry(random(), torpedoTypes)

            -- equip torpedoes
            local torpedo = generator:generate(x, y, 0, nil, torpedoType, nil)
            ShipUtility.addTorpedoesToCraft(craft, torpedo, torpedoes)
        end
    end
end