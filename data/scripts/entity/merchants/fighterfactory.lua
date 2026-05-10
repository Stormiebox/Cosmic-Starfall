package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

local _debug = false

function Debug(_text)
	if _debug then
		print('Fighter factory|',_text)
	end
end

local _unit = 0
local _turretName = nil
-- local isLight = Neltharaku.WeaponIsLight
-- local isHeavy = Neltharaku.WeaponIsHeavy

--Проверяет на совпадения с путями легких пушек и оставляет индекс для дальнейшего поиска по таблице бонусов
function FighterFactory.applyTypeName(turret)

	--Проверка совпадений
	local _islight,_index = isTurretLight(turret)
	
	if _islight and _index then
		_turretName = _index
	else
		_turretName = nil
	end
	
end
local applyType = FighterFactory.applyTypeName

function FighterFactory.addLightBonuses(sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
	-- Debug('setLightBonuses attempt')
	-- Debug('Unit is: '..tostring(_unit))
	-- Debug('Turretname is '.._turretName)
	local _table = getWeaponBonuses(_turretName)
	
	--Размер
	if _table[1]>0 then
		local _bonus = math.ceil(_unit * _table[1])
		sizePoints = sizePoints + _bonus
		
		Debug('addLightBonuses: sizePoints modified: '..tostring(_bonus))
		Debug(tostring(_table[1]))
	end
	
	--Прочность
	if _table[2]>0 then
		local _bonus = math.ceil(_unit * _table[2])
		durabilityPoints = durabilityPoints + _bonus
		Debug('addLightBonuses: durabilityPoints modified: '..tostring(_bonus))
		Debug(tostring(_table[2]))
	end
	
	--Маневренность
	if _table[3]>0 then
		local _bonus = math.ceil(_unit * _table[3])
		turningSpeedPoints = turningSpeedPoints + _bonus
		Debug('addLightBonuses: turningSpeedPoints modified: '..tostring(_bonus))
		Debug(tostring(_table[3]))
	end
	
	--Скорость
	if _table[4]>0 then
		local _bonus = math.ceil(_unit * _table[4])
		velocityPoints = velocityPoints + _bonus
		Debug('addLightBonuses: velocityPoints modified: '..tostring(_bonus))
		Debug(tostring(_table[4]))
	end
	
	return sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints
end

function FighterFactory.addMaterialBonuses(material, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)

    if material.value == MaterialType.Iron then

        -- iron grants extra size points
        sizePoints = sizePoints + 4

    elseif material.value == MaterialType.Titanium then

        -- titanium grants additional maneuverability and durability
        durabilityPoints = durabilityPoints + 1
        turningSpeedPoints = turningSpeedPoints + 2
        velocityPoints = velocityPoints + 1

    elseif material.value == MaterialType.Naonite then

        -- naonite grants a little of everything
        durabilityPoints = durabilityPoints + 2
        turningSpeedPoints = turningSpeedPoints + 1
        velocityPoints = velocityPoints + 1

    elseif material.value == MaterialType.Trinium then

        -- trinium grants additional maneuverability
        turningSpeedPoints = turningSpeedPoints + 3
        velocityPoints = velocityPoints + 1

    elseif material.value == MaterialType.Xanion then

        -- xanion grants additional velocity
        durabilityPoints = durabilityPoints + 1
        velocityPoints = velocityPoints + 3

    elseif material.value == MaterialType.Ogonite then

        -- xanion grants additional durability
        durabilityPoints = durabilityPoints + 5

    elseif material.value == MaterialType.Avorion then

        -- avorion grants a little of everything
        sizePoints = sizePoints + 2
        durabilityPoints = durabilityPoints + 2
        turningSpeedPoints = turningSpeedPoints + 2
        velocityPoints = velocityPoints + 2
    end
	
	if _turretName then
		sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints = FighterFactory.addLightBonuses(sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
	end

    return sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints
end

function FighterFactory.makeFighter(type, plan, turret, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
	Debug('makeFighter')
    local material = Material()
    local rarity = Rarity()

    local tech = 35
	
	--Назначение глобального модификатора бонуса легких туреток
	_unit = math.ceil(tech / 10)
	
    if turret then
        material = turret.material
        rarity = turret.rarity
        tech = turret.averageTech
		
		applyType(turret)
    else
        material = getMostUsedMaterial(plan)
        rarity = CrewShuttleRarity()
    end

    local diameter, durability, turningSpeed, maxVelocity = FighterFactory.getStats(tech, rarity, material, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)

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

        for _, weapon in pairs({turret:getWeapons()}) do
            if weapon.damage ~= 0 then 
				if isTurretLight(nil,weapon) then 
					Debug('makeFighter: light weapon detected')
					weapon.damage = weapon.damage * 1.05 / turret.slots 
				else
					weapon.damage = weapon.damage * 0.4 / turret.slots 
				end
			end
			
			if weapon.shieldRepair ~= 0 then 
				if isTurretLight(nil,weapon) then 
					Debug('makeFighter: light weapon detected')
					weapon.shieldRepair = weapon.shieldRepair * 0.8 / turret.slots 
				else
					weapon.shieldRepair = weapon.shieldRepair * 0.4 / turret.slots 
				end
			end
			
			if weapon.hullRepair ~= 0 then 
				if isTurretLight(nil,weapon) then 
					Debug('makeFighter: light weapon detected')
					weapon.hullRepair = weapon.hullRepair * 0.8 / turret.slots 
				else
					weapon.hullRepair = weapon.hullRepair * 0.4 / turret.slots 
				end
			end
			
			if weapon.holdingForce ~= 0 then 
				if isTurretLight(nil,weapon) then 
					Debug('makeFighter: light weapon detected')
					weapon.holdingForce = weapon.holdingForce * 0.8 / turret.slots 
				else
					weapon.holdingForce = weapon.holdingForce * 0.4 / turret.slots 
				end
			end
			
			
            --if weapon.shieldRepair ~= 0 then weapon.shieldRepair = weapon.shieldRepair * 0.4 / turret.slots end
            --if weapon.hullRepair ~= 0 then weapon.hullRepair = weapon.hullRepair * 0.4 / turret.slots end
            --if weapon.holdingForce ~= 0 then weapon.holdingForce = weapon.holdingForce * 0.4 / turret.slots end

            weapon.fireRate = weapon.fireRate * fireRateFactor
			
            weapon.reach = math.min(weapon.reach, 350)
			
			--Модификация дальности, уникальная для различных туреток
			if weapon.icon == getWeaponPath('assaultcannon') then
				Debug('makeFighter: assault cannon detected')
				weapon.reach = weapon.reach * 1.25
			end
			if weapon.icon == getWeaponPath('pulselaser') then
				Debug('makeFighter: pulse laser detected')
				weapon.reach = weapon.reach * 0.75
			end
			if weapon.icon == getWeaponPath('magneticmortar') then
				Debug('makeFighter: magnetic mortar detected')
				weapon.reach = weapon.reach * 2.75
			end
			if weapon.icon == getWeaponPath('nanorepair') then
				Debug('makeFighter: nanorepair detected')
				weapon.reach = weapon.reach * 1.15
			end
			if weapon.icon == getWeaponPath('chargingbeam') then
				Debug('makeFighter: chargingbeam detected')
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

function FighterFactory.refreshPointLabels(plan, turret)

    plan = plan or FighterFactory.getPlan()
    turret = turret or FighterFactory.getTurret()
    if not plan then return end
	
	applyType(turret)

    local material = Material()

    if selectedType == FighterType.Fighter then
        if not turret then return end

        material = turret.material
    else
        material = getMostUsedMaterial(plan)
    end

    local modifiedSize, modifiedDurability, modifiedTurningSpeed, modifiedVelocity = FighterFactory.addMaterialBonuses(material, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)

    remainingPointsLabel.caption = tostring(remainingPoints)

    pointsLabels[1].caption = tostring(modifiedSize)
    pointsLabels[2].caption = tostring(modifiedDurability)
    pointsLabels[3].caption = tostring(modifiedTurningSpeed)
    pointsLabels[4].caption = tostring(modifiedVelocity)

    if modifiedSize ~= sizePoints then
        pointsLabels[1].color = ColorRGB(0, 1, 0)
        pointsLabels[1].tooltip = "This property gets increased points due to the turret's material."%_t
    else
        pointsLabels[1].color = ColorRGB(1, 1, 1)
        pointsLabels[1].tooltip = nil
    end

    if modifiedDurability ~= durabilityPoints then
        pointsLabels[2].color = ColorRGB(0, 1, 0)
        pointsLabels[2].tooltip = "This property gets increased points due to the turret's material."%_t
    else
        pointsLabels[2].color = ColorRGB(1, 1, 1)
        pointsLabels[2].tooltip = nil
    end

    if modifiedTurningSpeed ~= turningSpeedPoints then
        pointsLabels[3].color = ColorRGB(0, 1, 0)
        pointsLabels[3].tooltip = "This property gets increased points due to the turret's material."%_t
    else
        pointsLabels[3].color = ColorRGB(1, 1, 1)
        pointsLabels[3].tooltip = nil
    end

    if modifiedVelocity ~= velocityPoints then
        pointsLabels[4].color = ColorRGB(0, 1, 0)
        pointsLabels[4].tooltip = "This property gets increased points due to the turret's material."%_t
    else
        pointsLabels[4].color = ColorRGB(1, 1, 1)
        pointsLabels[4].tooltip = nil
    end


    local fighter = FighterFactory.makeFighter(selectedType, plan, turret, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)

    statsLabels[1].caption = tostring(round(fighter.volume, 1))
    statsLabels[2].caption = tostring(round(fighter.durability, 1))
    statsLabels[3].caption = tostring(round(fighter.turningSpeed, 1))
    statsLabels[4].caption = tostring(round(fighter.maxVelocity * 10, 1))

    local boughtFighter = SellableFighter(fighter)

    local buyer = Player()
    local playerCraft = buyer.craft
    if playerCraft.factionIndex == buyer.allianceIndex then
        buyer = buyer.alliance
    end

    local price = FighterFactory.getPriceAndTax(boughtFighter, Faction(), buyer)

    statsLabels[5].caption = "${price} Cr"%_t % {price = createMonetaryString(price)}
end

function FighterFactory.createFighter(type, plan, turretIndex, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
	Debug('createFighter attempt')
    if not CheckFactionInteraction(callingPlayer, FighterFactory.buildFighterInteractionThreshold) then
		Debug('createFighter failure: CheckFactionInteraction error')
		return
	end

    if anynils(type, plan, turretIndex, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints) then 
		Debug('createFighter failure: anynils error')
		return 
	end

    local buyer, ship, player = getInteractingFaction(callingPlayer, AlliancePrivilege.SpendResources)
    if not(buyer) then 
		Debug('createFighter failure: buyer error')
		return
	end

    if plan.numBlocks > 200 then
        player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, "Only plans with 200 blocks or less allowed."%_t)
        return
    end

    local turret
    local rarity = Rarity()
    if type == FighterType.Fighter then
        turret = buyer:getInventory():find(turretIndex)
        if not turret then return end
		
		--Проеряет тип туретки
		applyType(turret)

        rarity = turret.rarity
    elseif type == FighterType.CrewShuttle then
        rarity = CrewShuttleRarity()
    end
    if turret then
        -- if it's a black market DLC only turret, then a player who doesn't own the DLC can't build a fighter with the turret
		Debug('createFighter')
        if turret.blackMarketDLCOnly and not player.ownsBlackMarketDLC then
            player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, "You must own the Black Market DLC to build this fighter."%_T)
            return 0
        end
		--Если вооружение принадлежит тяжелому классу - отсекание
		if isTurretHeavy(turret,nil) then
			Debug('createFighter: heavy eroro')
			player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, 'Нельзя установить тяжелое вооружение на истребители')
            return 0
		end
		--Если вооружение принадлежит классу "главный калибр" - отсекание
		if isTurretMC(turret,nil) then
			Debug('createFighter: MC eroro')
			player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, 'Орудия главного калибра нельзя устанавливать на истребители!')
            return 0
		end
        --if it's an into the rift DLC only turret, then a player who doesn't own the DLC can't build a fighter with the turret
        if turret.intoTheRiftDLCOnly and not player.ownsIntoTheRiftDLC then
            player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, "You must own the Into The Rift DLC to build this fighter."%_T)
            return 0
        end

        if turret.ancient then
            player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, "This turret can't be integrated into a fighter."%_T)
            return 0
        end
    end

    -- make sure the player doesn't cheat
    local availablePoints = FighterFactory.getMaxAvailablePoints(rarity)
    if sizePoints + durabilityPoints + turningSpeedPoints + velocityPoints > availablePoints then
        player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, "Invalid fighter stats."%_t)
        return
    end

    local maxInvestablePoints = FighterFactory.getMaxInvestablePoints(rarity)
    if sizePoints > maxInvestablePoints
            or durabilityPoints > maxInvestablePoints
            or turningSpeedPoints > maxInvestablePoints
            or velocityPoints > maxInvestablePoints  then
        player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, "Invalid fighter stats."%_t)
        return
    end

    local fighter = FighterFactory.makeFighter(type, plan, turret, sizePoints, durabilityPoints, turningSpeedPoints, velocityPoints)
    local boughtFighter = SellableFighter(fighter)

    local price, tax = FighterFactory.getPriceAndTax(boughtFighter, Faction(), buyer)

    local canPay, msg, args = buyer:canPay(price)
    if not canPay then
        player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, msg, unpack(args))
        return
    end

    local station = Entity()
    local errors = {}
    errors[EntityType.Station] = "You must be docked to the station to build fighters."%_T
    errors[EntityType.Ship] = "You must be closer to the ship to build fighters."%_T
    if not CheckPlayerDocked(player, station, errors) then
        return
    end

    local error = boughtFighter:boughtByPlayer(ship)

    if error then
        player:sendChatMessage("Fighter Factory"%_t, ChatMessageType.Error, error)
        return
    end

    if turret then
        buyer:getInventory():remove(turretIndex)
    end

    receiveTransactionTax(station, tax)

    buyer:pay("Paid %1% Credits to build a fighter."%_T, price)

    invokeClientFunction(player, "refreshUI")
end
callable(FighterFactory, "createFighter")

function FighterFactory.getPriceAndTax(fighter, stationFaction, buyerFaction)
    local price = fighter:getPrice()
    local tax = price * FighterFactory.tax

    if stationFaction.index == buyerFaction.index then
        price = price - tax
        -- don't pay out for the second time
        tax = 0
    end

    return price, tax
end

