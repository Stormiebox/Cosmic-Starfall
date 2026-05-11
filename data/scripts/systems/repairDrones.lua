package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include("basesystem")
include("utility")
include("randomext")
include("tooltipmaker")
include("Tech")
include("cosmicstarfalllib")

--Include('callable')

local _debug = false
local _prototype = true
local RDwindow
local updateSW = false
local systemname = 'repairdrones'
local scriptname = 'repairDrones'
--local isMultiplied = false

--Basic values ​​of active phases of systems. Use it as a config, too lazy to make a separate one :)
ModuleBonusDurability = 6         --percent, hull bonus upon installation (automatically changes from -3 to +15 depending on the module level)

NanobotsCooldown = 300            --seconds, rollback time (default -300)
NanobotsOperationTime = 20        -- seconds, operating time (default -20)
NanobotsHealingTreshhold = 50     --percentage, the volume of the case, above which it does not repair
NanobotsHealingAmount = 20        --interest, volume of hull repairs for the entire period of validity (default -20)
NanobotsCooldownPerWarp = 50      --seconds, cooldown reduction per warp

RepairnetworkCooldown = 250       --seconds, rollback time
RepairnetworkOperationTime = 120  -- seconds, operating time
RepairnetworkHealingAmount = 30   --interest, amount of repairs for the entire period of validity
RepairnetworkCooldownPerWarp = 50 --seconds, cooldown reduction per warp

EmergencyCooldown = 800           --seconds, rollback time
EmergencyOperationTime = 20       -- seconds, standby time
EmergencyBoosterTime = 20         --seconds, repair overload operating time
EmergencyBoosterAmount = 3        --units, the passive regeneration is increased so many times for the duration of the repair overload
EmergencyActivationTreshhold = 5  --percentage, hull strength, below which activation is triggered
EmergencyHealingAmount = 10       --interest, amount of instant repairs
EmergencyCooldownPerWarp = 0      --seconds, cooldown reduction per warp

--The magnitude of the passive effect of systems
local PassiveRepairTreshhold = 10 --interest. Case volume above which passive repair does not work (changes automatically to a value from -2 to 10, depending on the level of the installed module)
PassiveRepairAmount = 0.2         --percent, volume of repaired case per second (default -0.2%)

--Dynamic quantities of active phases of systems. Changing manually will result in breakdowns of varying degrees of severity of active systems and the entire module

local NanobotsIsReady = 0            --module readiness status, contains the remaining module recharge time
local NanobotsIsWorking = 0          --module active phase status, contains the remaining operating time of the module
local NanobotsHealingSpeed = 0       --automatically calculated amount of repair per unit of time

local RepairnetworkIsReady = 0       --module readiness status
local RepairnetworkIsWorking = 0     --module active phase status
local RepairnetworkHealingSpeed = 0  --automatically calculated amount of repair per unit of time

local EmergencyIsReady = 0           --module readiness status
local EmergencyOverloadIsWorking = 0 --module overload phase status
local EmergencyIsWorking = 0         --module active phase status
local EmergencyHeal = 0              --automatically calculated repair volume

--Interface Variables
local progressBars = {}

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true
if _debug then
	PermanentInstallationOnly = false
else
	PermanentInstallationOnly = true
end

function DebugMsg(_text)
	if _debug then
		print(_text)
	end
end

function UIplaysound(_type)
	--0 -activation
	--1 -deactivation
	--2 -error
	local soundPath = '/systems/'
	if _type == 0 then
		playSound(soundPath .. "UI_Activation", SoundType.UI, 1.5)
		return
	end
	if _type == 1 then
		playSound(soundPath .. "UI_Deactivation", SoundType.UI, 2)
		return
	end
	if _type == 2 then
		playSound(soundPath .. "UI_Incorrect", SoundType.UI, 1.5)
		return
	end
	return
	--Invoke client function(player(),'u iplaysound',2)
end

--Causes the main handler function (below) to contact the server once per second to perform active phases
function getUpdateInterval()
	return 1
end

function update(timeStep)
	if onClient() and updateSW and RDwindow then
		invokeServerFunction("UIsyncPosition", RDwindow.position)
		if Entity().selectedObject then
			--Debug msg(tostring(entity().selected object.name))
		end
	end
end

--The main function is the handler for all modules, tied to the game API
function updateServer(timePassed)
	--passive effect segment
	if Durability().filledPercentage < (PassiveRepairTreshhold / 100) then
		Entity().durability = Entity().durability + (Durability().maximum / 100 * PassiveRepairAmount)
		--Aura on yourself
		local _aura = {
			'selfrepairpassiveaura',
			string.format("+%i/s", math.floor(Durability().maximum / 100 * PassiveRepairAmount)),
			0,
			getTechAuraDesc('hullrepair'),
			'buff',
			Entity().name,
			Entity().name,
			'data/textures/icons/staRepair.png',
			true,
			true
		}
		callTechAuraSelf(_aura)
	end
	--nanobot segment
	if NanobotsIsReady > 0 then
		NanobotsIsReady = math.max(0, NanobotsIsReady - timePassed) --direct reduction of rollback
		executeUpdateProgressbar(1, NanobotsIsReady / NanobotsCooldown)
		--Invoke client function(player(),"update u ibars",nanobots cooldown,nanobots is ready,0)
	end
	if NanobotsIsWorking > 0 then
		NanobotsIsWorking = NanobotsIsWorking - timePassed
		if Durability().filledPercentage < (NanobotsHealingTreshhold / 100) then --Doesn't work if body strength is above cap
			Entity().durability = Entity().durability + NanobotsHealingSpeed
		end
		invokeClientFunction(Player(), "onFinishWork", NanobotsIsWorking, 0) --Catch the moment when the module ends
	end
	--repair network segment
	if RepairnetworkIsReady > 0 then
		RepairnetworkIsReady = math.max(0, RepairnetworkIsReady - timePassed) --direct reduction of rollback
		executeUpdateProgressbar(2, RepairnetworkIsReady / RepairnetworkCooldown)
		--Invoke client function(player(),"update u ibars",repairnetwork cooldown,repairnetwork is ready,1)
	end
	if RepairnetworkIsWorking > 0 then
		RepairnetworkIsWorking = RepairnetworkIsWorking - timePassed
		Entity().durability = Entity().durability + RepairnetworkHealingSpeed
		invokeClientFunction(Player(), "onFinishWork", RepairnetworkIsWorking, 1) --Catch the moment when the module ends
	end
	--emergency stabilizer segment
	if EmergencyIsReady > 0 then
		EmergencyIsReady = math.max(0, EmergencyIsReady - timePassed) --direct reduction of rollback
		--invokeClientFunction(Player(),"updateUIbars",EmergencyCooldown,EmergencyIsReady,2)
	end
	if EmergencyIsWorking > 0 then
		EmergencyIsWorking = EmergencyIsWorking - timePassed
		executeUpdateProgressbar(3, 0, true)
		if Durability().filledPercentage < EmergencyActivationTreshhold / 100 then
			EmergencyIsWorking = 0
			invokeClientFunction(Player(), "onFinishWork", EmergencyIsWorking, 2)
			Entity().durability = Entity().durability + EmergencyHeal
			EmergencyOverloadActivate()
		else
			invokeClientFunction(Player(), "onFinishWork", EmergencyIsWorking, 2)
		end
	else
		executeUpdateProgressbar(3, EmergencyIsReady / EmergencyCooldown)
	end
	--subsegment for overload
	if EmergencyOverloadIsWorking > 0 then
		EmergencyOverloadIsWorking = math.max(0, EmergencyOverloadIsWorking - timePassed)
		invokeClientFunction(Player(), "onFinishWork", EmergencyOverloadIsWorking, 3)
		if EmergencyOverloadIsWorking == 0 then
			PassiveRepairAmount = PassiveRepairAmount / EmergencyBoosterAmount
		end
	end
end

--function dataTransferNanobots(cooldown,operationTime,healingAmount)

function NanobotsActivate()
	if NanobotsIsReady == 0 then
		NanobotsIsReady = NanobotsCooldown                       --starts rollback
		NanobotsHealingSpeed = (Durability().maximum / 100 * NanobotsHealingAmount) /
			NanobotsOperationTime                                --assigns the amount of repair per unit of time (1 sec)
		NanobotsIsWorking =
			NanobotsOperationTime                                --we set a working time and at the same time tell the handler that the module is running
		invokeClientFunction(Player(), "updateStatusEffects", 0, true) --Enables an icon on the player's top bar
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Aura on yourself
		local _aura = {
			getSubtechSignature(systemname, 1),
			string.format("+%i/s", math.floor(NanobotsHealingSpeed)),
			NanobotsOperationTime,
			getTechAuraDesc('hullrepair'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 1),
			false,
			true
		}
		callTechAuraSelf(_aura)
	else
		print("Перезарядка не закончена! Осталось", NanobotsIsReady, "секунд")
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
	if _debug then print(Durability().maxDurabilityFactor, "maxDurFactor current") end
end

callable(nil, "NanobotsActivate")

function RepairNetworkActivate()
	if RepairnetworkIsReady == 0 then
		RepairnetworkIsReady = RepairnetworkCooldown
		RepairnetworkHealingSpeed = (Durability().maximum / 100 * RepairnetworkHealingAmount) /
			RepairnetworkOperationTime
		RepairnetworkIsWorking = RepairnetworkOperationTime
		invokeClientFunction(Player(), "updateStatusEffects", 1, true)
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Aura on yourself
		local _aura = {
			getSubtechSignature(systemname, 2),
			string.format("+%i/s", math.floor(RepairnetworkHealingSpeed)),
			RepairnetworkOperationTime,
			getTechAuraDesc('hullrepair'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 2),
			false,
			true
		}
		callTechAuraSelf(_aura)
	else
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "RepairNetworkActivate")

function EmergencyActivate()
	if EmergencyIsReady == 0 then
		EmergencyIsReady = EmergencyCooldown
		EmergencyHeal = (Durability().maximum / 100) * EmergencyHealingAmount
		EmergencyIsWorking = EmergencyOperationTime
		invokeClientFunction(Player(), "updateStatusEffects", 2, true)
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Aura on yourself
		local _aura = {
			getSubtechSignature(systemname, 3),
			0,
			EmergencyOperationTime,
			getTechAuraDesc('emergencystandby'),
			'neutral',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 3),
			false,
			true
		}
		callTechAuraSelf(_aura)
	else
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "EmergencyActivate")

--turns on when the emergency stabilizer is triggered in its active phase
function EmergencyOverloadActivate()
	EmergencyOverloadIsWorking = EmergencyBoosterTime
	PassiveRepairAmount = PassiveRepairAmount * EmergencyBoosterAmount
	invokeClientFunction(Player(), "updateStatusEffects", 3, true)
	invokeClientFunction(Player(), 'UIplaysound', 0)
	--Aura on yourself
	local _aura = {
		getSubtechSignature(systemname, 3) .. 'activate',
		string.format("+%i%%", (EmergencyBoosterAmount - 1) * 100),
		EmergencyBoosterTime,
		getTechAuraDesc('passiverepairoverclock'),
		'buff',
		Entity().name,
		Entity().name,
		getSubtechIcon(systemname, 3),
		false,
		true
	}
	callTechAuraSelf(_aura)
	--Reset previous aura
	callTechAuraInterruptSelf(getSubtechSignature(systemname, 3))
end

--Runs the main functions of active effects in "server" mode so that variables work correctly in updateServer
function NanobotsActivateTransfer()
	invokeServerFunction("NanobotsActivate")
end

function RepairNetworkActivateTransfer()
	invokeServerFunction("RepairNetworkActivate")
end

function EmergencyActivateTransfer()
	invokeServerFunction("EmergencyActivate")
end

--The function is called before onInstalled, so here you also need to add rarity.value to display the correct value in the module description
function getBonuses(seed, rarity, permanent)
	math.randomseed(seed)

	local hullBonus = ModuleBonusDurability + rarity.value * 3
	local hullRepairTreshhold = PassiveRepairTreshhold + rarity.value * 2

	return hullBonus, hullRepairTreshhold
end

function onInstalled(seed, rarity, permanent)
	--local perc, energy, shield = getBonuses(seed, rarity, permanent)
	local _cv = Entity():getValue("isRepairDrones")

	if _debug then print(_cv, "Значение _cv при старте onInstalled") end

	if _cv == 0 and _debug then
		print("No custom value isRepairDrones")
	end

	Entity():registerCallback("onHullHit", "onHitReact")

	--changes the limit of passively restored hull depending on the current module level (from -1 to +5)
	PassiveRepairTreshhold = PassiveRepairTreshhold + rarity.value * 2
	if _debug then print(PassiveRepairTreshhold, "% Лимит ремонта от качества") end

	--Changes the hull bonus depending on the current module level (from -1 to +5)
	ModuleBonusDurability = ModuleBonusDurability + rarity.value * 3
	if _debug then print(ModuleBonusDurability, "% Бонус корпуса") end

	--Checks the existence of a custom variable on the ship and if it does not exist, creates it
	if _cv == nil then
		Entity():setValue("isRepairDrones", false)
		if _debug then print("isRepairDrones успешно создана") end
	end

	--Checks to see if a similar bonus already exists. It is necessary so that when the game starts, the bonus is not applied again (when the game starts, the onInstalled function is triggered automatically for all entities where the module is already installed)
	if _cv == 0 or _cv == false then
		Entity():setValue("isRepairDrones", true)
		Durability().maxDurabilityFactor = (Durability().maxDurabilityFactor + ModuleBonusDurability / 100)
		if _debug then print("Корпус успешно увеличен при установке модуля") end
	end

	--Initializing Interface Elements
	if onClient() and not (RDwindow) then
		initializeUI()
		-- Player():registerCallback("onStateChanged", "UIshowhide")
		-- Player():registerCallback("onShipChanged", "UIshowhide")
		-- Player():registerCallback("onSectorChanged", "UIshowhide")
		--Player():registerCallback("onShipChanged", "initializeUI")
		--callback onShipChanged(playerIndex, craftId, previousId)
	end

	if _cv and _debug then
		print("repairDrones already installed")
	end
end

function onUninstalled(seed, rarity, permanent)
	if onServer() then
		Entity():removeScriptBonuses()
		executeDelete()
	end
end

function initializeUI()
	local _repairMatrixCalc = RepairnetworkHealingAmount / RepairnetworkOperationTime
	local _emergencyPercent = (EmergencyBoosterAmount - 1) * 100

	local subSysDesc = {
		string.format(
			"%s\nActivating the system will repair %i%% of the ship's hull in %i seconds.\nCooldown - %i seconds.\nThe module cannot repair hull above %i%%" %
			_t, getSubtechName(systemname, 1), NanobotsHealingAmount, NanobotsOperationTime, NanobotsCooldown,
			NanobotsHealingTreshhold),
		string.format(
			"%s\nActivation repairs %.2f%% hull per second for %i seconds.\nTaking damage or healing from repair weapons on the hull while the module is running interrupts repairs and reduces the remaining cooldown time by %i%%.\nCooldown - %i seconds" %
			_t, getSubtechName(systemname, 2), _repairMatrixCalc, RepairnetworkOperationTime, 60, RepairnetworkCooldown),
		string.format(
			"%s\nActivating the module puts it in standby mode for %i second. If during this time the ship's hull falls below %i%%, the module is triggered, restoring it by %i%%, after which it increases the automatic repair by %i%% for %i seconds.\nCooldown - %i seconds" %
			_t, getSubtechName(systemname, 3), EmergencyOperationTime, EmergencyActivationTreshhold,
			EmergencyHealingAmount,
			EmergencyBoosterTime, _emergencyPercent, EmergencyCooldown),
	}

	invokeServerFunction('executeDrawInterface', subSysDesc)
end

function executeDrawInterface(subSysDesc)
	local subsys = {}

	local subsys1 = {
		getSubtechName(systemname, 1), --Name
		getSubtechIcon(systemname, 1), --Icon
		subSysDesc[1],           --Desc
		'NanobotsActivate',      --Command
	}
	local subsys2 = {
		getSubtechName(systemname, 2), --Name
		getSubtechIcon(systemname, 2), --Icon
		subSysDesc[2],           --Desc
		'RepairNetworkActivate', --Command
	}
	local subsys3 = {
		getSubtechName(systemname, 3), --Name
		getSubtechIcon(systemname, 3), --Icon
		subSysDesc[3],           --Desc
		'EmergencyActivate',     --Command
	}

	table.insert(subsys, subsys1)
	table.insert(subsys, subsys2)
	table.insert(subsys, subsys3)


	local _table = {
		scriptname,        --System script
		getTechName(systemname), --System name
		getTechIcon(systemname), --System icon
		Entity().id,       --entityID
		subsys             --subsys
	}

	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeDraw', _table)
end

callable(nil, 'executeDrawInterface')

function executeUpdateProgressbar(_index, _progress, _isStandby)
	local entity = Entity().id
	--local selfIndex = Faction().index

	if not (_isStandby) then _isStandby = false end
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeUpdateProgress', _index,
		scriptname, entity, _progress, _isStandby)
end

function executeDelete()
	local entity = Entity().id
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeDelete', scriptname, entity)
end

--Responsible for various related visuals (icons on the screen, glow, etc.)
function updateStatusEffects(_type, _status)
	--[[
	0 -nanobot work icon
	1 -repair network operation icon
	2 -icon of the active phase of the emergency stabilizer
	3 -emergency stabilizer repair overload icon
]]
	if _type == 0 then
		if _status then
			local _line = getSubtechName(systemname, 1) .. ' - ' .. getTechInfo('active')
			addShipProblem("Nanobots", Entity().id, _line, getSubtechIcon(systemname, 1), ColorHSV(150, 64, 100), false)
		else
			removeShipProblem("Nanobots", Entity().id)
		end
	end
	if _type == 1 then
		if _status then
			local _line = getSubtechName(systemname, 2) .. ' - ' .. getTechInfo('active')
			addShipProblem("RepairNetwork", Entity().id, _line, getSubtechIcon(systemname, 2), ColorHSV(150, 64, 100),
				false)
		else
			removeShipProblem("RepairNetwork", Entity().id)
		end
	end
	if _type == 2 then
		if _status then
			local _line = getSubtechName(systemname, 3) .. ' - ' .. getTechInfo('readystate')
			addShipProblem("Emergency", Entity().id, _line, getSubtechIcon(systemname, 3), ColorHSV(60, 94, 78), false)
		else
			removeShipProblem("Emergency", Entity().id)
		end
	end
	if _type == 3 then
		if _status then
			local _line = getSubtechName(systemname, 3) .. ' - ' .. getTechInfo('active')
			addShipProblem("EmergencyOverload", Entity().id, _line, getSubtechIcon(systemname, 3), ColorHSV(150, 64, 100),
				false)
		else
			removeShipProblem("EmergencyOverload", Entity().id)
		end
	end
end

--Catch the event of the end of the active phase of the module for one-time actions for nanobots
-- 0 -nanobots
-- 1 -repair network
-- 2 -emergency repair
-- 3 -overload of repair systems
function onFinishWork(_time, _type)
	if _time <= 0 then
		if _type == 0 then
			--print("Nanobots have completed the active phase")
			updateStatusEffects(_type, false)
			UIplaysound(1)
		end
		if _type == 1 then
			--print("The repair network has completed its active phase")
			updateStatusEffects(_type, false)
			UIplaysound(1)
		end
		if _type == 2 then
			--print("Emergency stabilizer has completed its active phase")
			updateStatusEffects(_type, false)
			UIplaysound(1)
		end
		if _type == 3 then
			--print("Emergency stabilizer has completed its overload phase")
			updateStatusEffects(_type, false)
		end
		--print (Durability().filledPercentage)
		--Durability().invincibility = Durability().invincibility -0.5
	else
		return
	end
end

function onHitReact() --Needed for correct completion of the repair network when receiving damage to the hull
	if RepairnetworkIsWorking > 0 then
		if _debug then print("Работа ремонтной сети прервана") end
		RepairnetworkIsWorking = 0
		invokeClientFunction(Player(), "onFinishWork", RepairnetworkIsWorking, 1)
		RepairnetworkIsReady = RepairnetworkIsReady * 0.4
		invokeClientFunction(Player(), 'UIplaysound', 1)

		callTechAuraInterruptSelf(getSubtechSignature(systemname, 2))
	end
end

function getName(seed, rarity)
	return getTechName(systemname) .. ' T-' .. toRomanLiterals(rarity.value + 2)
end

function getIcon(seed, rarity)
	return getTechIcon(systemname)
end

function getEnergy(seed, rarity, permanent)
	local _cost = (rarity.value + 2) ^ 2 * (10 ^ 8 / 2)
	return _cost
end

function getPrice(seed, rarity)
	local _h, _r = getBonuses(seed, rarity)
	local price = 120 * 500 * (_h + rarity.value);
	return price * 2 ^ rarity.value / 10
end

function getTooltipLines(seed, rarity, permanent)
	local texts = {}
	local bonuses = {}
	local _h, _r = getBonuses(seed, rarity, permanent)
	--local _baseH, baseEnergy, baseShield = getBonuses(seed, rarity, false)

	--Bonuses
	table.insert(texts,
		{
			ltext = "Hull Durability" % _t,
			rtext = string.format("%+2i%%", round(_h)),
			icon =
			"data/textures/icons/staDurability.png",
			boosted = permanent
		})
	table.insert(texts,
		{
			ltext = "Auto-repair treshold" % _t,
			rtext = string.format("%2i%%", round(_r)),
			icon =
			"data/textures/icons/staRepair.png",
			boosted = permanent
		})
	table.insert(texts,
		{
			ltext = "Auto-repair value" % _t,
			rtext = string.format("%.1f%%", PassiveRepairAmount),
			icon =
			"data/textures/icons/staRepair.png",
			boosted = permanent
		})

	--Empty string
	table.insert(texts, { ltext = "" })

	--Abilki
	for i = 1, 3 do
		table.insert(texts,
			{ ltext = getSubtechName(systemname, i), icon = getSubtechIcon(systemname, i), boosted = permanent })
	end

	return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
	return
	{
		{ ltext = "Additional armor plates equipped with integrated repair systems" % _t, lcolor = ColorRGB(1, 0.5, 0.5) }
	}
end

function getComparableValues(seed, rarity) --I don’t understand why this is needed
	local _h, _r = getBonuses(seed, rarity, permanent)

	local base = {}
	local bonus = {}
	-- if _h ~= 0 then
	-- table.insert(base, {name = "Additional Hull Strength"%_t, key = "addhull_relative", value = round(_h *100), comp = UpgradeComparison.MoreIsBetter})
	-- table.insert(base, {name = "Auto repair limit"%_t, key = "autorepairTreshhold_relative", value = round(_r *100), comp = UpgradeComparison.MoreIsBetter})
	-- table.insert(base, {name = "Auto repair rate"%_t, key = "autorepair_relative", value = PassiveRepairAmount, comp = UpgradeComparison.MoreIsBetter})
	-- end

	return base, bonus
end
