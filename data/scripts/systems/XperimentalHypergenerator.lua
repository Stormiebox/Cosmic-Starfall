package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include("basesystem")
include("utility")
include("randomext")
include("Tech")
include("cosmicstarfalllib")

local _debug = false
local _prototype = true
local XHwindow
local updateSW = false
local systemname = 'xperimentalhypergenerator'
local scriptname = 'XperimentalHypergenerator'

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

--Basic values ​​of active phases of systems.

-- EnergyDrain = 40 --percentage, the base increase in the cost of charging a hyperdrive, varies from 0 to -12 depending on the quality of the module (reduced by 2% per quality level or -2 per quality level, for gold (level 5) with a base of 20, the penalty to the charging cost will be 12%, since the quality level is 4, multiplied by two and this is subtracted from the base, i.e. 20-(4*2)=12)
-- JumpCooldown = 10 percent, base amount of PD charge reduction, ranges from -3 to +15 depending on quality (+9 for gold, totaling 19% cooldown reduction)
-- JumpRange = 2 --units, additional jump range. Changes from -1 to +5 depending on the quality of the module

QuantumShieldHeal = 3                     --percentage, the amount of shield restored during operation per second
QuantumWorkingTimer = 20                  --seconds, module operating time after activation
QuantumFirerateSlow = 60                  --percentages, slowing down the rate of fire during operation
QuantumCooldown = 400                     --seconds, system recharge time (default 400)
QuantumJumpCooldown = 120                 --seconds, time added to hyperdrive cooldown

DestabilizerChargeBoost = 5               --percent, charging acceleration per unit of time
DestabilizerChargeDestruction = 2         --percent, body volume lost during module operation
DestabilizerChargeDestructionTreshold = 6 --percentage, body volume at which the destabilizer stops working
DestabilizerWorkingTimeBase = 10          --seconds, module operating time (varies from -1 to +5 depending on the quality of the module)
DestabilizerShieldTreshold = 80           --percentage, shield volume above which the module does not work
DestabilizerCooldown = 600                --seconds, module rollback time (default -600)

FocusedChargeReduction = 40               --percentage, the amount of hyperdrive charge discarded upon activation
FocusedIncrease = 120                     --percentage, volume increase jump distance
FocusedJumpCooldown = 10                  --seconds, additional reload time after jumping for each unit of additional range
FocusedCooldown = 300                     --seconds, module rollback time (default -300)

if _debug then
	DestabilizerChargeDestruction = 1
end

-- -1 0 1 2 3 4 5
-- 0 1 2 3 4 5 6
--Automatic Variables
_rarity = 0

QuantumIsWorking = 0         --module operation status
QuantumIsReady = 0           --module readiness status
QuantumHealDelta = 0         --amount of shield regeneration per second
QuantumCanRecharge = false   --is responsible for blocking reloading before jumping
QuantumDebuffFlag = false    --responsible for reducing the rate of fire
QuantumStandbyFlag = false   --responsible for standby mode

DestabilizerIsWorking = 0    --module operation status
DestabilizerIsReady = 0      --module readiness status
DestabilizerDamageToHull = 0 --damage caused by work to the body
DestabilizerSpeedUp = 0      --PD recharge acceleration units

--FocusedIsWorking = 0 --module operation status
FocusedIsReady = 0              --module readiness status
FocusedChargeReductionTimer = 0 --value to which cooldown is rolled back (100% -FocusedChargeReduction)
FocusedBonusRange = 0           --jump bonus
FocusedCanRecharge = false      --is responsible for blocking reloading before jumping
FocusedChargedFlag = false      --responsible for jump enhancement activity

--Interface Variables
local progressBars = {}
local buttons = {}
local _tooltip = {}

function xFocusActivateTransfer()
	invokeServerFunction("xFocusActivate")
end

function xFocusActivate()
	if FocusedIsReady == 0 and HyperspaceEngine().currentCooldown == 0 then
		FocusedCanRecharge = false
		FocusedIsReady = FocusedCooldown
		--Invoke client function(player(),"update u ibars",focused cooldown,focused is ready,2)
		executeUpdateProgressbar(3, 1)
		invokeClientFunction(Player(), "updateStatusEffects", 2, true)
		if FocusedChargeReduction > 0 and FocusedChargeReduction < 100 then
			FocusedChargeReductionTimer = HyperspaceEngine().cooldown / 100 * (100 - FocusedChargeReduction)
		else
			print("FocusedChargeReductionTimer является некорректным значением, возвращаю дефолт 40")
			FocusedChargeReductionTimer = HyperspaceEngine().cooldown / 100 * 60
		end

		DebugMsg(tostring(FocusedChargeReductionTimer) .. "FocusedChargeReductionTimer")
		DebugMsg(tostring(HyperspaceEngine().cooldown) .. "HyperspaceEngine().cooldown")
		DebugMsg(tostring(HyperspaceEngine().range) .. "HyperspaceEngine().range")

		HyperspaceEngine().currentCooldown = HyperspaceEngine().cooldown
		HyperspaceEngine().currentCooldown = HyperspaceEngine().currentCooldown - FocusedChargeReductionTimer
		FocusedBonusRange = HyperspaceEngine().range / 100 * FocusedIncrease

		DebugMsg(tostring(FocusedBonusRange) .. "FocusedBonusRange")

		addMultiplyableBias(StatsBonuses.HyperspaceReach, FocusedBonusRange)

		DebugMsg(tostring(HyperspaceEngine().range) .. "HyperspaceEngine().range после преобразования")

		Entity():registerCallback("onHyperspaceEntered", "xFocusJump")

		FocusedChargedFlag = true

		invokeClientFunction(Player(), 'UIplaysound', 0)
	else
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "xFocusActivate")

function xFocusJump()
	Entity():unregisterCallback("onHyperspaceEntered", "xFocusJump")
	FocusedCanRecharge = true
	addMultiplyableBias(StatsBonuses.HyperspaceReach, -FocusedBonusRange)
	DebugMsg(tostring(HyperspaceEngine().range) .. "HyperspaceEngine().range после прыжка")
	onJumpFinished(FocusedBonusRange * FocusedJumpCooldown)
	invokeClientFunction(Player(), "updateStatusEffects", 2, false)
end

--Transfers control of the main function to the server
function xQuantumActivateTransfer()
	invokeServerFunction("xQuantumActivate")
end

--Main activation function
function xQuantumActivate()
	if QuantumIsReady == 0 then
		QuantumIsReady = QuantumCooldown
		--Invoke client function(player(),"update u ibars",quantum cooldown,quantum is ready,0)
		invokeClientFunction(Player(), "updateStatusEffects", 4, true)
		--QuantumIsWorking = QuantumWorkingTimer
		QuantumHealDelta = Shield():getMaxDurability(true) / 100 * QuantumShieldHeal
		Entity():registerCallback("onJumpRouteCalculationStarted", "xQuantumTrigger")
		invokeClientFunction(Player(), "updateStatusEffects", 4, true)
		invokeClientFunction(Player(), 'UIplaysound', 0)
		QuantumStandbyFlag = true
	else
		print("xQuantum - перезарядка не окончена")
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "xQuantumActivate")

function xDestabilizerActivate()
	if DestabilizerIsReady == 0 then
		DestabilizerIsReady = DestabilizerCooldown
		--Invoke client function(player(),"update u ibars",100,1,1)
		invokeClientFunction(Player(), "updateStatusEffects", 1, true)
		DestabilizerIsWorking = DestabilizerWorkingTimeBase + _rarity
		DestabilizerDamageToHull = Durability().maximum / 100 * DestabilizerChargeDestruction
		DestabilizerSpeedUp = HyperspaceEngine().currentCooldown / HyperspaceEngine().cooldownSpeed / 100 *
			DestabilizerChargeBoost

		--Aura (charge)
		local _aura = {
			getSubtechSignature(systemname, 2),
			string.format("+%i%%", DestabilizerChargeBoost),
			DestabilizerIsWorking,
			getTechAuraDesc('jumpdrivecharging'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 2),
			false,
			true
		}
		callTechAuraSelf(_aura)

		--Aura (destruction)
		local _aura = {
			getSubtechSignature(systemname, 2) .. 'destruction',
			string.format("-%i/s", (Durability().maximum / 100 * DestabilizerChargeDestruction)),
			DestabilizerIsWorking,
			getTechAuraDesc('hulldamage'),
			'debuff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 2),
			false,
			true
		}
		callTechAuraSelf(_aura)

		if _debug then
			print(HyperspaceEngine().cooldownSpeed, "HyperspaceEngine().cooldownSpeed")
			print(HyperspaceEngine().currentCooldown, "HyperspaceEngine().currentCooldown")
			local _a = HyperspaceEngine().currentCooldown / HyperspaceEngine().cooldownSpeed
			print(_a, "_a")
			print("______________________")
			print(_rarity, "_rarity")
			print(DestabilizerDamageToHull, "DestabilizerDamageToHull")

			print(DestabilizerSpeedUp, "DestabilizerSpeedUp")
		end
		invokeClientFunction(Player(), 'UIplaysound', 0)
	else
		print("xDestabilizer - перезарядка не окончена")
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "xDestabilizerActivate")

function xDestabilizerActivateTransfer()
	invokeServerFunction("xDestabilizerActivate")
end

--Waits for the hyperjump calculation to begin and performs the appropriate actions
function xQuantumTrigger()
	Entity():unregisterCallback("onJumpRouteCalculationStarted", "xQuantumTrigger")

	if _debug then print("xQuantumTrigger поймал начало вычислений, назначаю бонусы и штрафы") end

	executeUpdateProgressbar(1, 1)

	invokeClientFunction(Player(), "updateStatusEffects", 4, false)
	invokeClientFunction(Player(), "updateStatusEffects", 3, true)
	invokeClientFunction(Player(), "updateStatusEffects", 0, true)

	Entity():registerCallback("onHyperspaceEntered", "XQuantumJump")
	QuantumIsWorking = QuantumWorkingTimer
	QuantumDebuffFlag = true
	QuantumStandbyFlag = false

	--Aura on yourself
	local _aura = {
		getSubtechSignature(systemname, 1),
		string.format("+%i/s", QuantumHealDelta),
		QuantumWorkingTimer,
		getTechAuraDesc('shieldrepair'),
		'buff',
		Entity().name,
		Entity().name,
		getSubtechIcon(systemname, 1),
		false,
		true
	}
	callTechAuraSelf(_aura)

	--Fire rate penalty
	Entity():addBaseMultiplier(StatsBonuses.FireRate, -QuantumFirerateSlow / 100)
	invokeClientFunction(Player(), 'UIplaysound', 0)
end

--Waiting to make a hyperjump in order to roll back penalties
function XQuantumJump()
	Entity():unregisterCallback("onHyperspaceEntered", "XQuantumJump")
	if _debug then print("XQuantumJump сработал, снимаю штрафы") end
	QuantumDebuffFlag = false
	invokeClientFunction(Player(), "updateStatusEffects", 3, false)
	invokeClientFunction(Player(), "updateStatusEffects", 0, false)
	QuantumCanRecharge = true
	Entity():addBaseMultiplier(StatsBonuses.FireRate, QuantumFirerateSlow / 100)
	QuantumIsWorking = 0
	invokeClientFunction(Player(), "updateStatusEffects", 0, false)
	onJumpFinished(QuantumJumpCooldown)
	invokeClientFunction(Player(), 'UIplaysound', 1)
end

--Adds additional time to PD cooldown when called
function onJumpFinished(_time)
	if _debug then print("Прыжок завершен, применяю изменения") end
	Entity().hyperspaceCooldown = Entity().hyperspaceCooldown + _time
	invokeClientFunction(Player(), 'UIplaysound', 1)
	FocusedChargedFlag = false
end

function getUpdateInterval()
	return 1
end

function update(timeStep)
	if onClient() and updateSW and XHwindow then
		invokeServerFunction("UIsyncPosition", XHwindow.position)
	end
end

function updateServer(timePassed)
	--Quantum Overload Segment
	if QuantumIsReady > 0 and QuantumCanRecharge then
		QuantumIsReady = math.max(0, QuantumIsReady - timePassed)
		--Invoke client function(player(),"update u ibars",quantum cooldown,quantum is ready,0)
		executeUpdateProgressbar(1, QuantumIsReady / QuantumCooldown)
	end

	--Standby activation of quantum aura
	if QuantumStandbyFlag then
		executeUpdateProgressbar(1, 0, true)
		local _aura = {
			getSubtechSignature(systemname, 1) .. 'standby',
			0,
			0,
			getSubtechName(systemname, 1) .. getTechAuraDesc('systemstandby'),
			'neutral',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 1),
			true,
			true
		}
		callTechAuraSelf(_aura)
	end

	--Activating the aura to reduce the rate of fire of the quantum
	if QuantumDebuffFlag then
		local _aura = {
			getSubtechSignature(systemname, 1) .. 'firerate',
			string.format("-%i%%", QuantumFirerateSlow),
			0,
			getTechAuraDesc('firerate'),
			'debuff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 1),
			true,
			true
		}
		callTechAuraSelf(_aura)
	end

	--Activating the aura to enhance the jump
	if FocusedChargedFlag then
		local _aura = {
			getSubtechSignature(systemname, 3),
			string.format("+%i%%", FocusedIncrease),
			0,
			getTechAuraDesc('jumprangeincreased'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 3),
			true,
			true
		}
		callTechAuraSelf(_aura)
	end

	if QuantumIsWorking > 0 then
		QuantumIsWorking = math.max(0, QuantumIsWorking - timePassed)
		Shield():healDamage(QuantumHealDelta)
		if QuantumIsWorking == 0 then
			invokeClientFunction(Player(), "updateStatusEffects", 0, false)
		end
	end
	--Destabilizer segment
	if DestabilizerIsReady > 0 then
		DestabilizerIsReady = math.max(0, DestabilizerIsReady - timePassed)
		executeUpdateProgressbar(2, DestabilizerIsReady / DestabilizerCooldown)
	end
	if DestabilizerIsWorking > 0 then
		invokeClientFunction(Player(), "updateStatusEffects", 1, true)
		DestabilizerIsWorking = math.max(0, DestabilizerIsWorking - timePassed)

		if Durability().filledPercentage > DestabilizerChargeDestructionTreshold / 100 and Shield().filledPercentage < DestabilizerShieldTreshold / 100 then
			Durability().durability = Durability().durability - DestabilizerDamageToHull
			HyperspaceEngine().currentCooldown = HyperspaceEngine().currentCooldown - DestabilizerSpeedUp
		else
			if _debug and Durability().filledPercentage < DestabilizerChargeDestructionTreshold / 100 then
				DebugMsg("Показатель корпуса ниже допустимого")
			elseif _debug and Shield().filledPercentage > DestabilizerShieldTreshold / 100 then
				DebugMsg("Показатель щита выше допустимого")
			end
		end

		if DestabilizerIsWorking == 0 then --fires when shutdown
			invokeClientFunction(Player(), "updateStatusEffects", 1, false)
		end
	end
	--Focus segment
	if FocusedIsReady > 0 and FocusedCanRecharge then
		FocusedIsReady = math.max(0, FocusedIsReady - timePassed)
		executeUpdateProgressbar(3, FocusedIsReady / FocusedCooldown)
	end
end

function getBonuses(seed, rarity, permanent)
	math.randomseed(seed)

	local _cooldown = math.random(8, 12) + rarity.value * 3
	local _eDrain = math.random(37, 43) - rarity.value * 2
	local _jump = math.random(1, 3) + rarity.value

	if _debug then
		print("________________")
		print(_cooldown, "_cooldown, getBonuses")
		print(_eDrain, "_eDrain, getBonuses")
		print(_jump, "_jump, getBonuses")
		print("________________")
	end

	return _cooldown, _eDrain, _jump
end

function onInstalled(seed, rarity, permanent)
	local _cooldown, _eDrain, _jump = getBonuses(seed, rarity, permanent)

	_rarity = rarity.value

	-- if onClient() then
	-- DebugMsg("Запускаю onInstalledUItooltips")
	-- onInstalledUItooltips(rarity.value)
	-- end

	addMultiplyableBias(StatsBonuses.HyperspaceReach, _jump)
	addBaseMultiplier(StatsBonuses.HyperspaceCooldown, -_cooldown / 100)
	addBaseMultiplier(StatsBonuses.HyperspaceChargeEnergy, _eDrain / 100)

	if _debug and onServer() then
		print("________________")
		print(-_cooldown / 100, "процент-бонус к откату ПД")
		print(_eDrain / 100, "процент-штраф к энергопотреблению")
		print(_jump, "бонус к дальности прыжка")
		print("________________")
	end

	Player():registerCallback("onStateChanged", "UIshowhide")
	Player():registerCallback("onShipChanged", "UIshowhide")
	Player():registerCallback("onSectorChanged", "UIshowhide")
	if onClient() and not (XHwindow) then
		initializeUI()
	end
end

function onUninstalled(seed, rarity, permanent)
	if onServer() then
		Entity():removeScriptBonuses()
		executeDelete()
	end
end

--The following function creates a button (and an item in the ship menu) that can be clicked to open the interface
function interactionPossible(playerIndex, option)
	local player = Player()
	if Entity().index == player.craftIndex then
		return true
	end

	return false
end

-- function updateUIbars(_max,_current,index)
-- progressBars[index].progress = 1 -_current /_max
-- if progressBars[index].progress == 1 then
-- progressBars[index].color = ColorHSV(150, 64, 100)
-- else
-- progressBars[index].color = ColorHSV(16, 97, 84)
-- end
-- end

function updateStatusEffects(_type, _status)
	--0 -quantum work icon
	--1 -destabilizer operation icon
	--2 -focus work icon
	--3 -quantum debuff icon
	--4 -quantum waiting icon
	--5 -icon of incorrect operation of the destabilizer (to be deleted)

	if _type == 0 then
		if _status then
			local _line = getSubtechName(systemname, 1) .. ' - ' .. getTechInfo('active')
			addShipProblem("Xquantum", Entity().id, _line, getSubtechIcon(systemname, 1), ColorHSV(150, 64, 100), false)
		else
			removeShipProblem("Xquantum", Entity().id)
		end
	elseif _type == 1 then
		local _name = "Xdestabilizer"
		if _status then
			local _line = getSubtechName(systemname, 2) .. ' - ' .. getTechInfo('active')
			if Shield().filledPercentage < DestabilizerShieldTreshold / 100 and Durability().filledPercentage > DestabilizerChargeDestructionTreshold / 100 then
				DebugMsg("Корректный тик - дестабилизатор")
				removeShipProblem(_name, Entity().id)
				addShipProblem(_name, Entity().id, _line, getSubtechIcon(systemname, 2), ColorHSV(150, 64, 100), false)
			else
				local _line = getSubtechName(systemname, 2) .. ' - ' .. getTechInfo('inactive')
				DebugMsg("Некорректный тик - дестабилизатор")
				removeShipProblem(_name, Entity().id)
				addShipProblem(_name, Entity().id, _line, getSubtechIcon(systemname, 2), ColorHSV(16, 97, 84), false)
			end
		else
			removeShipProblem(_name, Entity().id)
		end
	elseif _type == 2 then
		if _status then
			local _line = getSubtechName(systemname, 3) .. ' - ' .. getTechInfo('active')
			addShipProblem("Xfocus", Entity().id, _line, getSubtechIcon(systemname, 3), ColorHSV(150, 64, 100), false)
		else
			removeShipProblem("Xfocus", Entity().id)
		end
	elseif _type == 3 then
		if _status then
			local _line = getSubtechName(systemname, 1) .. ' - ' .. getTechInfo('fireratereduced')
			removeShipProblem("XquantumDebuff", Entity().id)
			addShipProblem("XquantumDebuff", Entity().id, _line, getSubtechIcon(systemname, 1), ColorHSV(16, 97, 84),
				false)
		else
			removeShipProblem("XquantumDebuff", Entity().id)
		end
	elseif _type == 4 then
		if _status then
			local _line = getSubtechName(systemname, 1) .. ' - ' .. getTechInfo('readystate')
			removeShipProblem("XquantumActive", Entity().id)
			addShipProblem("XquantumActive", Entity().id, _line, getSubtechIcon(systemname, 1), ColorHSV(60, 94, 78),
				false)
		else
			removeShipProblem("XquantumActive", Entity().id)
		end
	elseif _type == 5 then
		local _name = "XdestabilizerFailure"
		local _name2 = "Xdestabilizer"
		if _status then
			local _line = getSubtechName(systemname, 2) .. ' - ' .. getTechInfo('inactive')
			removeShipProblem(_name, Entity().id)
			removeShipProblem(_name2, Entity().id)
			addShipProblem(_name, Entity().id, _line, getSubtechIcon(systemname, 2), ColorHSV(16, 97, 84), false)
		else
			removeShipProblem(_name, Entity().id)
		end
	end
end

function initializeUI()
	local subSysDesc = {
		string.format(
			"%s\nActivation puts the module into standby mode. As soon as the ship's computer starts calculating the jump route, the module turns on and begins to restore %i%% of the shield charge per second, the duration is limited by %i seconds.\nThe rate of fire of the all weapons will be reduced by %i%% before the jump. Adds %i seconds to the JD recharge time after the jump.\nCooldown - %i seconds, while the recharge begins only after the jump" %
			_t, getSubtechName(systemname, 1), QuantumShieldHeal, QuantumWorkingTimer, QuantumFirerateSlow,
			QuantumJumpCooldown, QuantumCooldown),
		string.format(
			"%s\nActivation begins to accelerate the current hyperdrive recharge by %i%% per second, while destroying %i%% of the hull per second.\nThe destabilizer will run idle if the ship's shield charge exceeds %i%%, or the hull drops below %i%% \nThe module functions for %i seconds.\nCooldown - %i seconds" %
			_t, getSubtechName(systemname, 2), DestabilizerChargeBoost, DestabilizerChargeDestruction,
			DestabilizerShieldTreshold, DestabilizerChargeDestructionTreshold, (DestabilizerWorkingTimeBase + _rarity),
			DestabilizerCooldown),
		string.format(
			"%s\nActivation partially resets the hyperdrive charge and increases the maximum jump range by %i%%.\nHyperdrive recharge after a jump increases by %i seconds for each additional unit of range.\nCooldown - %i seconds and is possible only after making a jump.\nThe module can only be activated when the hyperdrive is fully charged" %
			_t, getSubtechName(systemname, 3), FocusedIncrease, FocusedJumpCooldown, FocusedCooldown),
	}

	invokeServerFunction('executeDrawInterface', subSysDesc)
end

function executeDrawInterface(subSysDesc)
	local subsys = {}

	local subsys1 = {
		getSubtechName(systemname, 1), --Name
		getSubtechIcon(systemname, 1), --Icon
		subSysDesc[1],           --Desc
		'xQuantumActivate',      --Command
	}
	local subsys2 = {
		getSubtechName(systemname, 2), --Name
		getSubtechIcon(systemname, 2), --Icon
		subSysDesc[2],           --Desc
		'xDestabilizerActivate', --Command
	}
	local subsys3 = {
		getSubtechName(systemname, 3), --Name
		getSubtechIcon(systemname, 3), --Icon
		subSysDesc[3],           --Desc
		'xFocusActivate',        --Command
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

	if not (_isStandby) then _isStandby = false end
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeUpdateProgress', _index,
		scriptname, entity, _progress, _isStandby)
end

function executeDelete()
	local entity = Entity().id
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeDelete', scriptname, entity)
end

function getName(seed, rarity)
	--local reach, cooldown, energy, radar = getBonuses(seed, rarity, true)
	local _name = ""
	if rarity.value == -1 then
		_name = "Omega" % _t
	elseif rarity.value == 0 then
		_name = "Zeta" % _t
	elseif rarity.value == 1 then
		_name = "Epsilon" % _t
	elseif rarity.value == 2 then
		_name = "Delta" % _t
	elseif rarity.value == 3 then
		_name = "Gamma" % _t
	elseif rarity.value == 4 then
		_name = "Beta" % _t
	elseif rarity.value == 5 then
		_name = "Alpha" % _t
	else
		_name = "Meow"
	end

	--return "${prefix} ${reach}${type} MK ${mark} /*ex: Unveiling R-4 Hyperspace Enhancer MK IV*/"%_t % {prefix = prefix, reach = reachStr, type = type, mark = mark}
	return getTechName(systemname) .. ' ' .. _name
end

function getIcon(seed, rarity)
	return getTechIcon(systemname)
end

function getEnergy(seed, rarity, permanent)
	local _cost = (rarity.value + 2) ^ 2 * (10 ^ 8 / 2)
	return _cost
end

function getPrice(seed, rarity)
	local _cooldown, _eDrain, _jump = getBonuses(seed, rarity, permanent)
	local price = 120 * 50 * 24 * (_jump + rarity.value);
	return price * 2 ^ rarity.value / 10
end

function getTooltipLines(seed, rarity, permanent)
	local _cooldown, _eDrain, _jump = getBonuses(seed, rarity, permanent)
	local texts = {}
	local bonuses = {}

	--Bonuses
	table.insert(texts,
		{
			ltext = "Hyperspace Cooldown" % _t,
			rtext = "-" .. tostring(_cooldown) .. "%",
			icon =
			"data/textures/icons/hourglass.png",
			boosted = permanent
		})
	table.insert(texts,
		{
			ltext = "Hyperspace Charge Energy" % _t,
			rtext = "+" .. tostring(_eDrain) .. "%",
			icon =
			"data/textures/icons/electric.png",
			boosted = permanent
		})
	table.insert(texts,
		{
			ltext = "Jump Range" % _t,
			rtext = "+" .. tostring(_jump),
			icon = "data/textures/icons/star-cycle.png",
			boosted =
				permanent
		})

	--Empty string
	table.insert(texts, { ltext = "" })

	--Abilki
	for i = 1, 3 do
		table.insert(texts,
			{ ltext = getSubtechName(systemname, i), icon = getSubtechIcon(systemname, i), boosted = permanent })
	end

	-- table.insert(texts, {ltext = "Quantum Overload"%_t, rtext = "Yes", rcolor = ColorRGB(0.3, 1.0, 0.3), icon = "data/textures/icons/SUBSYSJumpCocoon.png", boosted = permanent})
	-- table.insert(texts, {ltext = "Space Destabilizer"%_t, rtext = "Yes", rcolor = ColorRGB(0.3, 1.0, 0.3), icon = "data/textures/icons/SUBSYSDestibilizer.png", boosted = permanent})
	-- table.insert(texts, {ltext = "Focused Jump"%_t, rtext = "Yes", rcolor = ColorRGB(0.3, 1.0, 0.3), icon = "data/textures/icons/SUBSYSFocusedJump.png", boosted = permanent})

	return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
	return
	{
		{ ltext = getTechDesc(systemname), lcolor = ColorRGB(1, 0.5, 0.5) }
	}
end

function getComparableValues(seed, rarity)
	local base = {}
	local bonus = {}

	-- for _, p in pairs({{base, false}, {bonus, true}}) do
	-- local values = p[1]
	-- local permanent = p[2]

	-- local reach, cdfactor, efactor, radar = getBonuses(seed, rarity, permanent)

	-- if reach ~= 0 then
	-- table.insert(values, {name = "Jump Range"%_t, key = "jump_range", value = round(reach *100), comp = UpgradeComparison.MoreIsBetter})
	-- end

	-- if radar ~= 0 then
	-- table.insert(values, {name = "Radar Range"%_t, key = "radar_range", value = round(radar *100), comp = UpgradeComparison.MoreIsBetter})
	-- end

	-- if cdfactor ~= 0 then
	-- table.insert(values, {name = "Hyperspace Cooldown"%_t, key = "hs_cooldown", value = round(cdfactor *100), comp = UpgradeComparison.LessIsBetter})
	-- end

	-- if efactor ~= 0 then
	-- table.insert(values, {name = "Recharge Energy"%_t, key = "recharge_energy", value = round(efactor *100), comp = UpgradeComparison.LessIsBetter})
	-- end
	-- end

	return base, bonus
end
