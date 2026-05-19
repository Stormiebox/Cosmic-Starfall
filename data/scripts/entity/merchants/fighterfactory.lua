package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

local _debug = false

local function Debug(_text)
    if _debug then
        print('Fighter factory|', _text)
    end
end

local _unit = 0
local _turretName = nil

-- Vanilla helper functions that are normally local, so we must copy them to use in our makeFighter override
local function getMostUsedMaterial(plan)
    local material = Material()

    local numBlocks = plan.numBlocks
    local materials = {}
    for i = 0, numBlocks - 1 do
        local block = plan:getNthBlock(i)
        local materialIndex = block.material.value
        local amount = materials[materialIndex] or 0
        amount = amount + 1
        materials[materialIndex] = amount
    end

    local highest = 0
    for index, amount in pairs(materials) do
        if amount > highest then
            material = Material(index)
            highest = amount
        end
    end

    return material
end

local function CrewShuttleRarity()
    return Rarity(2)
end

--Checks for matches with the paths of light guns and leaves an index for further search in the bonus table
function FighterFactory.applyTypeName(turret)
    local _islight, _index = isTurretLight(turret)

    if _islight and _index then
        _turretName = _index
    else
        _turretName = nil
    end
end

local applyType = FighterFactory.applyTypeName

function FighterFactory.addLightBonuses(sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
    local _table = getWeaponBonuses(_turretName)

    if _table[1] > 0 then
        local _bonus = math.ceil(_unit * _table[1])
        sizePoints = sizePoints + _bonus
    end

    if _table[2] > 0 then
        local _bonus = math.ceil(_unit * _table[2])
        durabilityPoints = durabilityPoints + _bonus
    end

    if _table[3] > 0 then
        local _bonus = math.ceil(_unit * _table[3])
        turningSpeedPoints = turningSpeedPoints + _bonus
    end

    if _table[4] > 0 then
        local _bonus = math.ceil(_unit * _table[4])
        velocityPoints = velocityPoints + _bonus
    end

    return sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints
end

local old_addMaterialBonuses = FighterFactory.addMaterialBonuses
function FighterFactory.addMaterialBonuses(material, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
    sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints = old_addMaterialBonuses(material, sizePoints,
        durabilityPoints, turningSpeedPoints, velocityPoints)

    if _turretName then
        sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints = FighterFactory.addLightBonuses(sizePoints,
            durabilityPoints, turningSpeedPoints, velocityPoints)
    end

    return sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints
end

-- We override makeFighter completely because it defines core weapon stat modifications for fighters which cannot be easily hooked
function FighterFactory.makeFighter(type, plan, turret, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
    Debug('makeFighter')
    local material = Material()
    local rarity = Rarity()
    local tech = 35

    if turret then
        material = turret.material
        rarity = turret.rarity
        tech = turret.averageTech
        _unit = math.ceil(tech / 10)
        applyType(turret)
    else
        material = getMostUsedMaterial(plan)
        rarity = CrewShuttleRarity()
        _unit = 0
        _turretName = nil
    end

    local diameter, durability, turningSpeed, maxVelocity = FighterFactory.getStats(tech, rarity, material, sizePoints,
        durabilityPoints, turningSpeedPoints, velocityPoints)

    local fighter = FighterTemplate()

    local scale = diameter + lerp(diameter, fighter.minFighterDiameter, fighter.maxFighterDiameter, 0, 1.5)
    scale = scale / (plan.radius * 2)
    plan:scale(vec3(scale, scale, scale))
    fighter.plan = plan

    fighter.diameter = diameter
    fighter.durability = durability
    fighter.turningSpeed = turningSpeed
    fighter.maxVelocity = maxVelocity
    fighter.type = type

    if turret then
        local fireRateFactor = 1.0
        if turret.coolingType == 0 and turret.heatPerShot > 0 and tostring(turret.shootingTime) ~= "inf" then
            if turret.shotsUntilOverheated > 0 then
                fireRateFactor = turret.shootingTime / (turret.shootingTime + turret.coolingTime)
            end
        end

        for _, weapon in pairs({ turret:getWeapons() }) do
            if weapon.damage ~= 0 then
                if isTurretLight(nil, weapon) then
                    weapon.damage = weapon.damage * 1.05 / turret.slots
                else
                    weapon.damage = weapon.damage * 0.4 / turret.slots
                end
            end

            if weapon.shieldRepair ~= 0 then
                if isTurretLight(nil, weapon) then
                    weapon.shieldRepair = weapon.shieldRepair * 0.8 / turret.slots
                else
                    weapon.shieldRepair = weapon.shieldRepair * 0.4 / turret.slots
                end
            end

            if weapon.hullRepair ~= 0 then
                if isTurretLight(nil, weapon) then
                    weapon.hullRepair = weapon.hullRepair * 0.8 / turret.slots
                else
                    weapon.hullRepair = weapon.hullRepair * 0.4 / turret.slots
                end
            end

            if weapon.holdingForce ~= 0 then
                if isTurretLight(nil, weapon) then
                    weapon.holdingForce = weapon.holdingForce * 0.8 / turret.slots
                else
                    weapon.holdingForce = weapon.holdingForce * 0.4 / turret.slots
                end
            end

            weapon.fireRate = weapon.fireRate * fireRateFactor
            weapon.reach = math.min(weapon.reach, 350)

            if weapon.icon == getWeaponPath('assaultcannon') then
                weapon.reach = weapon.reach * 1.25
            end
            if weapon.icon == getWeaponPath('pulselaser') then
                weapon.reach = weapon.reach * 0.75
            end
            if weapon.icon == getWeaponPath('magneticmortar') then
                weapon.reach = weapon.reach * 2.75
            end
            if weapon.icon == getWeaponPath('nanorepair') then
                weapon.reach = weapon.reach * 1.15
            end
            if weapon.icon == getWeaponPath('chargingbeam') then
                weapon.reach = weapon.reach * 1.15
            end

            fighter:addWeapon(weapon)
        end

        for desc, value in pairs(turret:getDescriptions()) do
            fighter:addDescription(desc, value)
        end
    end

    return fighter
end

local old_refreshPointLabels = FighterFactory.refreshPointLabels
function FighterFactory.refreshPointLabels(plan, turret)
    plan = plan or FighterFactory.getPlan()
    turret = turret or FighterFactory.getTurret()

    if turret then
        _unit = math.ceil(turret.averageTech / 10)
        applyType(turret)
    else
        _unit = 0
        _turretName = nil
    end

    old_refreshPointLabels(plan, turret)
end

local old_createFighter = FighterFactory.createFighter
function FighterFactory.createFighter(type, plan, turretIndex, sizePoints, durabilityPoints, turningSpeedPoints,
                                      velocityPoints)
    local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources)
    if buyer and type == FighterType.Fighter then
        local turret = buyer:getInventory():find(turretIndex)
        if turret then
            if isTurretHeavy(turret, nil) then
                player:sendChatMessage("Fighter Factory" % _t, ChatMessageType.Error,
                    "Heavy weapons cannot be installed on fighters." % _t)
                return 0
            end
            if isTurretMC(turret, nil) then
                player:sendChatMessage("Fighter Factory" % _t, ChatMessageType.Error,
                    "Main caliber guns cannot be installed on fighters!" % _t)
                return 0
            end

            _unit = math.ceil(turret.averageTech / 10)
            applyType(turret)
        else
            _unit = 0
            _turretName = nil
        end
    else
        _unit = 0
        _turretName = nil
    end

    return old_createFighter(type, plan, turretIndex, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
end
