package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"


include("basesystem")
include("utility")
include("randomext")
include("Tech")
include("cosmicstarfalllib")

local SpawnUtility = include("spawnutility")

local _debug = false

local _debugTimer = 0
local _swapLang = true
local _prototype = true
local BSwindow
local updateSW = false
local _rarity = 0
local _colorG = ColorHSV(150, 64, 100)
local _colorY = ColorHSV(60, 94, 78)
local _colorR = ColorHSV(16, 97, 84)
local _colorB = ColorHSV(240, 40, 100)
local _colorC = ColorHSV(264, 60, 100)
local updateAccum = 0
local soundPath = '/systems/'
local systemname = 'bastionsystem'
local scriptname = 'bastionSystem'


-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true

function DebugMsg(_text)
	if _debug then
		print('bastionSystem|', _text)
	end
end

local Debug = DebugMsg

function isInRangeV3(v1, v2, range)
	local modRange = (range * 100) * (range * 100)
	local calcDist2 = distance2(v1, v2) * 0.85
	if calcDist2 <= modRange and calcDist2 > 0 then
		return true
	else
		return false
	end
end

function DoMeow()
	if _debug then
		print("Meow")
		--invokeServerFunction('PulsarClearLasersInit')
		--print(Owner(Entity()).name)
		local battleships = { Sector():getEntitiesByType(EntityType.Ship) }
		for _, _ship in pairs(battleships) do
			if Entity() ~= _ship then
				print(_ship.name, '(', Owner(_ship).name, ') relation - ',
					Owner(_ship):getRelationValue(Owner(Entity()).factionIndex))
				print()
			end
		end
	end
end

function CheckForEnemy(me, target)
	--Check if torpedo
	if target.type == EntityType.Torpedo then
		local SC = Entity(Torpedo(target.index).shootingCraft)
		local torpedoTarget = Entity(TorpedoAI(target.index).target)
		if Owner(me):getRelationValue(Owner(SC).factionIndex) < -95000 or torpedoTarget.index == Entity().index then
			return true
		else
			return false
		end
	end

	--Check others
	if Owner(me):getRelationValue(Owner(target).factionIndex) < -95000 then return true end
	return false
end

function DoServerMeow()
	--Entity():registerCallback("onShieldDamaged", "RecupStoreCharge")
	--DebugMsg("Server Meow!")
end

callable(nil, "DoServerMeow")

function DamageTarget() --for debug
	local tgtId = Entity().selectedObject
	Durability(tgtId).durability = Durability(tgtId).durability - 100000
	Shield(tgtId).durability = Shield(tgtId).durability - 400000
end

callable(nil, "DamageTarget")

function DamageTargetTransfer()
	invokeServerFunction("DamageTarget")
end

function ReportResult(exitCode)
	if exitCode then
		return "Пиздец, неужели работает"
	end
	return "Опять что-то сломалось"
end

function isInRangeV3(v1, v2, range)
	local modRange = (range * 100) * (range * 100)
	local calcDist2 = distance2(v1, v2) * 0.85
	if calcDist2 <= modRange and calcDist2 > 0 then
		return true
	else
		return false
	end
end

----------------------------------------------------------------------------------------------------------------

local progressBars = {}
local buttons = {}
local _tooltip = {}

--Basic values ​​of active phases of systems.
local VeilResistance = 16  --percent, shield resist
local VeilRepair = 0.06    --percentage, the maximum amount of shield that is converted into hull repair per second
local VeilFireRate = 25    --percentages, rate of fire drop
local VeilCooldown = 85    --seconds, cd
local VeilCooldownR = 2    --seconds, cooldown reduction per rarity level

local RecupMaxValue = 25   --interest, max accumulation depending on the shield
local RecupMaxValueR = 1   --interest, bonus for rarity level
local RecupMultiplier = 26 --percentages, conversion of damage received into charge
local RecupLength = 14     --seconds, module operating time
local RecupCooldown = 55   --seconds, rollback


local MultiphaseLength = 20       --seconds, duration
local MultiphaseLengthR = 1       --seconds, additional duration per rarity level
local MultiphaseCooldown = 95     --seconds, rollback
local MultiphaseCooldownR = 1     -- seconds, reduced cooldown per rarity level
local MultiphaseChargeLength = 25 --seconds, continuous charging time after activation

local PulsarRange = 22            --kilometers, module operating radius
local PulsarRangeR = 2            --kilometers, additional range per rarity level
local PulsarLength = 7            --seconds, duration of operation
local PulsarLengthR = 1           --seconds, additional duration per rarity
local PulsarCooldown = 135        --seconds, rollback
local PulsarTreshold = 10         --percentage, limitation of the minimum volume of the shield for work

--Automatic Variables
local VeilIsReady = 0
local VeilIsWorking = false
local VeilRepairAmount = 0
local VeilRefrFX = nil

local RecupIsReady = 0
local RecupIsWorking = 0
local RecupHealAmount = 0
local RecupStoredAmount = 0
local RecupMaximumAmount = 0
local RecupBoxFX = nil

local MultiphaseIsReady = 0
local MultiphaseIsWorking = 0
local MultiphaseRefrFX = nil
local MultiphaseAlreadyImp = false
local MultiphaseStoredRechargeTime = 0

local PulsarIsReady = 0
local PulsarIsWorking = 0
local PulsarOnInnerCooldown = 0
local PulsarShieldDamage = 0
local PulsarLaserFX = {}





if _debug then
	PermanentInstallationOnly = false
	VeilCooldown = 15
	RecupCooldown = 15
	MultiphaseCooldown = 15
	--MultiphaseLength = 5
	PulsarCooldown = 16
	--print("Permanent is turned off")
else
	PermanentInstallationOnly = true
end

function getUpdateInterval()
	return 1
end

function update(timeStep)
	if onClient() and updateSW and BSwindow and updateAccum == 1 then
		updateAccum = 0
		invokeServerFunction("UIsyncPosition", BSwindow.position)
	end
	if onClient() and Entity() then
		updateAccum = updateAccum + 0.5
	end
end

function updateServer(timePassed)
	--Segment "Veils"
	local _player = Player(callingPlayer)
	if not (_player) then return end
	if VeilIsReady > 0 and not (VeilIsWorking) then
		VeilIsReady = math.max(0, VeilIsReady - timePassed) --direct reduction of rollback
		executeUpdateProgressbar(1, VeilIsReady / (VeilCooldown - VeilCooldownR * _rarity))
	end
	if VeilIsWorking then
		VeilOperate()
		executeUpdateProgressbar(1, 0, true)
	end
	--Recovery segment
	if RecupIsReady > 0 then
		RecupIsReady = math.max(0, RecupIsReady - timePassed) --direct reduction of rollback
		executeUpdateProgressbar(2, RecupIsReady / RecupCooldown)
	end
	if RecupIsWorking > 0 then
		RecupIsWorking = math.max(0, RecupIsWorking - timePassed)
		RecupOperate()
		invokeClientFunction(_player, "onFinishWork", RecupIsWorking, 1) --Catch the moment when the module ends
	else
		--DebugMsg("Attempt to call updateUIrecup")
		local _value = Entity():getValue("RecupStoredAmount")
		if _value ~= nil then
			executeUpdateSecondary(2, _value / RecupMaximumAmount)
		end
	end
	--Multiphase segment
	if MultiphaseIsReady > 0 then
		MultiphaseIsReady = math.max(0, MultiphaseIsReady - timePassed) --direct reduction of rollback
		executeUpdateProgressbar(3, MultiphaseIsReady / (MultiphaseCooldown - MultiphaseCooldownR * _rarity))
	end
	if MultiphaseIsWorking > 0 then
		MultiphaseIsWorking = math.max(0, MultiphaseIsWorking - timePassed)
		invokeClientFunction(_player, "onFinishWork", MultiphaseIsWorking, 2) --Catch the moment when the module ends
		--Resets bonuses when finishing work
		if MultiphaseIsWorking == 0 then
			MultiphaseOperateSetup()
			DebugMsg("Multiphase: trying to 'MultiphaseOperateSetup'")
		end
		--Handles shield shutdown
		if Shield().durability == 0 then
			DebugMsg("serverUpdate_Multiphase: shields down, deactivating")
			MultiphaseIsWorking = 0
			MultiphaseOperateSetup()
		end
		--Handles disabling streaming charging
		if MultiphaseIsWorking < ((MultiphaseLength + MultiphaseLengthR * _rarity) - MultiphaseChargeLength) then
			MultiphaseStreamingChargeSwitchOff()
		end
	end
	--"Protocol" segment
	if PulsarIsReady > 0 then
		PulsarIsReady = math.max(0, PulsarIsReady - timePassed) --direct reduction of rollback
		executeUpdateProgressbar(4, PulsarIsReady / PulsarCooldown)
	end
	if PulsarIsWorking > 0 then
		PulsarIsWorking = math.max(0, PulsarIsWorking - timePassed)
		PulsarOperate()
		invokeClientFunction(_player, "onFinishWork", PulsarIsWorking, 3) --Catch the moment when the module ends
	end
end

function updateStatusEffects(_type, _status)
	--0 -curtain operation icon
	--1 -recovery operation icon
	--2 -polyphase operation icon
	--3 -protocol operation icon
	if _type == 0 then
		if _status then
			addShipProblem("BastionVeil", Entity().id, getSubtechName(systemname, 1) .. ' - ' .. getTechInfo('active'),
				getSubtechIcon(systemname, 1), _colorG, false)
		else
			removeShipProblem("BastionVeil", Entity().id)
		end
	end
	if _type == 1 then
		if _status then
			addShipProblem("BastionRecup", Entity().id,
				getSubtechName(systemname, 2) .. ' - ' .. getTechInfo('shieldsrepairing'), getSubtechIcon(systemname, 2),
				_colorG, false)
		else
			removeShipProblem("BastionRecup", Entity().id)
		end
	end
	if _type == 2 then
		if _status then
			addShipProblem("BastionMultiphase", Entity().id, getSubtechName(systemname, 3) ..
				' - ' .. getTechInfo('active'), getSubtechIcon(systemname, 3), _colorG, false)
		else
			removeShipProblem("BastionMultiphase", Entity().id)
		end
	end
	if _type == 3 then
		if _status then
			addShipProblem("BastionPulsar", Entity().id, getSubtechName(systemname, 4) .. ' - ' .. getTechInfo('active'),
				getSubtechIcon(systemname, 4), _colorG, false)
		else
			removeShipProblem("BastionPulsar", Entity().id)
		end
	end
end

function getVeilRepairAmount()
	local _result = math.floor((Shield().maximum * VeilRepair * 0.01) + 0.5)
	DebugMsg('getVeilRepairAmount is ' .. tostring(_result))
	return _result
end

----------------------------------------------------------------------------------------------------------------

function VeilActivate()
	if Shield().durability == 0 then
		invokeClientFunction(Player(), 'UIplaysound', 2)
		return
	end
	if VeilIsReady > 0 and not (VeilIsWorking) then
		invokeClientFunction(Player(), 'UIplaysound', 2)
		return
	end
	if not (VeilIsWorking) and VeilIsReady == 0 then
		DebugMsg("Veil: activate")
		--Creating a sphere
		local self = Entity()

		local _type = 'BSve'
		local _source = self
		local _radius = self.radius * 1.15
		local _ivec2radius = ivec2(200, 200)
		local _color = vec3(1, 1, 1)
		local _intensity = 0.001
		local _reflectivity = 1.1
		local _reflColor = vec3(0.2, 0.2, 0.5)
		local _exitResult, _callResult = self:invokeFunction('raycast.lua', 'setSphere', _type, _source, _radius,
			_ivec2radius, _color, _intensity, _reflectivity, _reflColor)

		--Clipping if drawing the sphere does not work
		if _exitResult > 0 or _callResult > 0 then
			DebugMsg('VeilActivate eroro: setSphere failure')
			return
		end

		--Setting cooldown
		VeilIsReady = VeilCooldown - VeilCooldownR * _rarity
		--Calculation of repair volume
		VeilRepairAmount = getVeilRepairAmount()
		--Setting the work flag
		VeilIsWorking = true
		--Creating an effect icon
		invokeClientFunction(Player(), "updateStatusEffects", 0, true)
		--Enabling bonuses
		VeilOperateSetup()
		--Playing sound
		invokeClientFunction(Player(), 'UIplaysound', 0)
		return
	else
		--Cut off unnecessary triggering during CD
		if VeilIsReady == 0 then return end
		DebugMsg("Veil: deactivate")
		--Switching off the module
		VeilTurnToFalse()
		--Rollback of bonuses
		VeilOperateSetup()
		return
	end
end

callable(nil, "VeilActivate")

function VeilOperateSetup()
	--Installing bonuses upon activation
	if VeilIsWorking then
		--Setting the Resistance Index
		if Shield().damageFactor ~= 1 then
			DebugMsg("Veil - damage factor is not 1 somehow")
		end
		Shield().damageFactor = 1 - VeilResistance * 0.01
		DebugMsg("Veil: current damage factor is " .. tostring(Shield().damageFactor))
		--Setting the rate of fire
		Entity():addBaseMultiplier(StatsBonuses.FireRate, -VeilFireRate * 0.01)
		return
	end
	--Cancellation of bonuses upon deactivation
	if not (VeilIsWorking) then
		--Resist the shield
		Shield().damageFactor = Shield().damageFactor + VeilResistance * 0.01
		DebugMsg("Veil: current damage factor after cancel is " .. tostring(Shield().damageFactor))
		--Rate of fire
		Entity():addBaseMultiplier(StatsBonuses.FireRate, VeilFireRate * 0.01)
		return
	end
	return
end

function VeilOperate()
	--Bug cut-off
	if Entity() == nil or VeilRepairAmount <= 0 then return end
	--Shutdown when shield falls
	if not (Shield().isActive) or Shield().durability == 0 then
		VeilTurnToFalse()
		VeilOperateSetup()
		DebugMsg("Veil: shield offline, deactivating")
		return
	end
	--Case repair with an active module
	if VeilIsWorking then
		Durability():healDamage(VeilRepairAmount, Entity().id)
		DebugMsg("Veil: ship repaired for " .. tostring(VeilRepairAmount))

		--Aura generation
		local _aura = {
			getSubtechSignature(systemname, 1),
			string.format("+%i%%", VeilResistance),
			0,
			getTechAuraDesc('shieldresist'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 1),
			true,
			true
		}
		callTechAuraSelf(_aura)

		--Generation of aura for debuff
		local _aura = {
			getSubtechSignature(systemname, 1) .. '2',
			string.format("-%i%%", VeilFireRate),
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
end

function VeilTurnToFalse()
	if VeilIsWorking then
		VeilIsWorking = false
		--Invoke client function(player(),"veil graphics")
		Entity():invokeFunction('raycast.lua', 'RemoveSphere', 'BSve')
		invokeClientFunction(Player(), "updateStatusEffects", 0, false)
		invokeClientFunction(Player(), 'UIplaysound', 1)
	end
end

function ActivateTransferVL()
	invokeServerFunction("VeilActivate")
end

----------------------------------------------------------------------------------------------------------------

function RecupActivate()
	if RecupIsReady == 0 and Entity():getValue("RecupStoredAmount") and Shield().durability > 0 then
		DebugMsg("Recup: activate")

		--Setting cooldown
		RecupIsReady = RecupCooldown

		--Calculation of repair volume
		RecupHealAmount = Entity():getValue("RecupStoredAmount") / RecupLength
		DebugMsg("RecupHealAmount is " .. tostring(RecupHealAmount))

		--Setting the work flag
		RecupIsWorking = RecupLength

		--Creating an effect icon
		invokeClientFunction(Player(), "updateStatusEffects", 1, true)

		--Resetting accumulated charge
		Entity():setValue("RecupStoredAmount", 0)
		executeUpdateSecondary(2, 0)

		--Resetting the charge status progressbar
		invokeClientFunction(Player(), "updateUIrecup", 0, RecupMaximumAmount)
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Aura generation
		local _aura = {
			getSubtechSignature(systemname, 2),
			string.format("%i/s", RecupHealAmount),
			RecupLength,
			getTechAuraDesc('shieldrepair'),
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

callable(nil, "RecupActivate")

function RecupOperate()
	--Bug cut-off
	if Entity() == nil or RecupHealAmount <= 0 then return end
	--Shutdown when shield falls
	if not (Shield().isActive) or Shield().durability == 0 then
		DebugMsg("Recup: shield offline, cant work")
		RecupIsWorking = 0
		invokeClientFunction(Player(), "onFinishWork", RecupIsWorking, 1)
		return
	end
	--Shield repair
	if RecupIsWorking then
		Shield():healDamage(RecupHealAmount, Entity().id)
		DebugMsg("Recup: shield repaired for " .. tostring(RecupHealAmount))
	end
end

function RecupInitiation()
	if onClient() then return end
	DebugMsg("RecupInitiation!")
	Entity():registerCallback("onShieldDamaged", "RecupStoreCharge")
	--Checking the maximum volume
	if RecupMaximumAmount == 0 then
		RecupMaximumAmount = Shield().maximum * (RecupMaxValue + RecupMaxValueR * _rarity) * 0.01
		DebugMsg("Current capacitor amount is: " .. tostring(RecupMaximumAmount))
	end
	--Checking the presence of custom
	if Entity():getValue("RecupStoredAmount") == nil then
		Entity():setValue("RecupStoredAmount", 0)
	end
	--Setting the charge
	local _value = Entity():getValue("RecupStoredAmount")
	if _value and Player() then
		invokeClientFunction(Player(), "updateUIrecup", RecupStoredAmount, RecupMaximumAmount)
	end
end

callable(nil, "RecupInitiation")

function RecupStoreCharge(_id, _damage, _type, _inflictor)
	if _damage <= 0 then return end

	DebugMsg("Damage taken: " .. tostring(_damage) .. " of type: " .. tostring(_type))
	if _type == 1 or _type == 3 or _type == 4 or _debug then
		--Checking the presence of custom
		if Entity():getValue("RecupStoredAmount") == nil then
			Entity():setValue("RecupStoredAmount", 0)
		end
		--Checking the maximum volume
		if RecupMaximumAmount == 0 then
			RecupMaximumAmount = Shield().maximum * (RecupMaxValue + RecupMaxValueR * _rarity) * 0.01
			DebugMsg("Current capacitor amount is: " .. tostring(RecupMaximumAmount))
		end
		--Updating Energy Reserve Value
		local _value = Entity():getValue("RecupStoredAmount")
		_value = math.min(RecupMaximumAmount, _value + _damage * (RecupMultiplier * 0.01))
		DebugMsg("CurrentDmgStored is " .. tostring(_value) .. " | maximum amount is " .. tostring(RecupMaximumAmount))
		Entity():setValue("RecupStoredAmount", _value)
	end
end

callable(nil, "RecupStoreCharge")

function RecupStoreChargeInit(_damage, _type)
	invokeServerFunction("RecupStoreCharge", _damage, _type)
end

function ActivateTransferRC()
	invokeServerFunction("RecupActivate")
end

----------------------------------------------------------------------------------------------------------------

function MultiphaseActivate()
	if Shield().durability == 0 then
		invokeClientFunction(Player(), 'UIplaysound', 2)
		return
	end
	if MultiphaseIsReady == 0 then
		DebugMsg("Multiphase: activate from button")

		--Creating a sphere
		local self = Entity()

		local _type = 'BSmp'
		local _source = self
		local _radius = self.radius * 0.5
		local _ivec2radius = ivec2(200, 200)
		local _color = vec3(1, 1, 0.7)
		local _intensity = 0.001
		local _reflectivity = 1.1
		local _reflColor = vec3(0.7, 0.2, 0.7)
		local _exitResult, _callResult = self:invokeFunction('raycast.lua', 'setSphere', _type, _source, _radius,
			_ivec2radius, _color, _intensity, _reflectivity, _reflColor)

		--Clipping if drawing the sphere does not work
		if _exitResult > 0 or _callResult > 0 then
			DebugMsg('VeilActivate eroro: setSphere failure')
			return
		end

		--Setting cooldown
		MultiphaseIsReady = MultiphaseCooldown - MultiphaseCooldownR * _rarity
		--Setting the work flag
		MultiphaseIsWorking = MultiphaseLength + MultiphaseLengthR * _rarity
		--Creating an effect icon
		invokeClientFunction(Player(), "updateStatusEffects", 2, true)
		--Launch of bonuses
		MultiphaseOperateSetup()
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Aura generation (impenetrability)
		local _aura = {
			getSubtechSignature(systemname, 3),
			0,
			(MultiphaseLength + MultiphaseLengthR * _rarity),
			getTechAuraDesc('impenetrableshield'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 3),
			false,
			true
		}
		callTechAuraSelf(_aura)

		--Aura Generation (Cooldown Reduction)
		local _aura = {
			getSubtechSignature(systemname, 3) .. '2',
			'-95%',
			MultiphaseChargeLength,
			getTechAuraDesc('timebeforeshieldcharge'),
			'buff',
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

callable(nil, "MultiphaseActivate")

function MultiphaseOperateSetup()
	--Installing bonuses upon activation
	if MultiphaseIsWorking > 0 then
		DebugMsg("Multiphase: activate")
		--Installation of an impenetrable shield
		MultiphaseAlreadyImp = Shield().impenetrable
		if MultiphaseAlreadyImp and _debug then
			DebugMsg("Multiphase - already impenetrable")
		end
		if not (MultiphaseAlreadyImp) then
			DebugMsg("Multiphase: set up imp status")
			Shield().impenetrable = true
		end
		--Setting the time before rollback
		DebugMsg("MultiphaseOperateSetup| timeUntilRechargeAfterHit: " .. tostring(Shield().timeUntilRechargeAfterHit))

		Entity():setValue("BastionMultiphaseRestoreTimer", Shield().timeUntilRechargeAfterHit)

		local _reValue = (Shield().timeUntilRechargeAfterHit) * -1
		DebugMsg("MultiphaseOperateSetup| _reValue is " .. tostring(_reValue))
		Entity():addMultiplyableBias(StatsBonuses.ShieldTimeUntilRechargeAfterHit, _reValue)
		--Entity():add multiplyable bias(stats bonuses.shield time until recharge after hit,2)
		DebugMsg("MultiphaseOperateSetup| afterTimeUntilRechargeAfterHit: " ..
			tostring(Shield().timeUntilRechargeAfterHit))

		return
	end
	--Cancellation of bonuses upon deactivation
	if MultiphaseIsWorking == 0 then
		DebugMsg("Multiphase: deactivate")
		--Impenetrable shield rollback
		if not (MultiphaseAlreadyImp) and Shield().impenetrable then
			DebugMsg("Multiphase: set up imp status to false")
			Shield().impenetrable = false
		end
		--Reset graphics
		MultiphaseTurnToFalse()
		--Invoke client function(player(),'u iplaysound',1)
		return
	end
	return
end

function MultiphaseTurnToFalse()
	if MultiphaseIsWorking > 0 then
		MultiphaseIsWorking = 0
	end
	--Invoke client function(player(),"multiphase graphics")
	Entity():invokeFunction('raycast.lua', 'RemoveSphere', 'BSmp')
	invokeClientFunction(Player(), "updateStatusEffects", 2, false)
	invokeClientFunction(Player(), 'UIplaysound', 1)
end

function MultiphaseStreamingChargeSwitchOff()
	local _value = Entity():getValue("BastionMultiphaseRestoreTimer")
	if _value == nil then
		--DebugMsg("MultiphaseStreamingChargeSwitchOff| cant fing 'BastionMultiphaseRestoreTimer'")
		return
	end
	DebugMsg("MultiphaseStreamingChargeSwitchOff| _value: " .. tostring(_value))
	DebugMsg("MultiphaseStreamingChargeSwitchOff| deleting bonus once")
	Entity():addMultiplyableBias(StatsBonuses.ShieldTimeUntilRechargeAfterHit, _value)
	Entity():setValue("BastionMultiphaseRestoreTimer", nil)
	DebugMsg("MultiphaseStreamingChargeSwitchOff| TimeUntilRechargeAfterHit: " ..
		tostring(Shield().timeUntilRechargeAfterHit))
end

function ActivateTransferMP()
	invokeServerFunction("MultiphaseActivate")
end

----------------------------------------------------------------------------------------------------------------

function PulsarActivate()
	-- if _debug then
	-- Shield().durability = Shield().maximum
	-- end

	--Activation cutoff if shield is below limit
	if Shield().durability < PulsarTreshold * 0.01 then
		invokeClientFunction(Player(), 'UIplaysound', 2)
		return
	end
	if PulsarIsReady == 0 then
		DebugMsg("PDS: activate")
		invokeClientFunction(Player(), 'UIplaysound', 0)
		--Setting cooldown
		PulsarIsReady = PulsarCooldown
		--Setting the work flag
		PulsarIsWorking = PulsarLength + PulsarLengthR * _rarity
		--Creating an effect icon
		invokeClientFunction(Player(), "updateStatusEffects", 3, true)

		--Aura generation
		local _aura = {
			getSubtechSignature(systemname, 4),
			0,
			(PulsarLength + PulsarLengthR * _rarity),
			getTechAuraDesc('torpedodefence'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 4),
			false,
			true
		}
		callTechAuraSelf(_aura)
	else
		--Cut off unnecessary triggering during CD
		invokeClientFunction(Player(), 'UIplaysound', 2)
		if PulsarIsReady == 0 then return end
	end
end

callable(nil, "PulsarActivate")

function PulsarOperate()
	--Shutdown when shield charge is low
	if Shield().durability < PulsarTreshold * 0.01 then
		DebugMsg('PulsarOperate: shields too low, deactivating!')
		PulsarIsWorking = 1
		invokeClientFunction(Player(), 'UIplaysound', 1)
		return
	end

	local PlayerCache = { Sector():getPlayers() }
	if #PlayerCache < 1 then return end -- Potentially impossible, but so be it.
	DebugMsg('PulsarOperate: #PlayerCache = ' .. tostring(#PlayerCache))
	--Sampling of potential targets
	local potentialTargets = { Sector():getEntitiesByType(EntityType.Torpedo) }
	if #potentialTargets < 1 then return end
	DebugMsg('PulsarOperate: #potentialTargets = ' .. tostring(#potentialTargets))

	local targets = {}
	--Determining target positions for transfer and elimination of torpedoes
	for _, _torpedo in pairs(potentialTargets) do
		if CheckForEnemy(Entity(), _torpedo) and isInRangeV3(Entity().translationf, _torpedo.translationf, PulsarRange + PulsarRangeR * _rarity) then
			table.insert(targets, _torpedo.translationf)
			DebugMsg('PulsarOperate: attempt to destroy ' .. tostring(_torpedo.id))
			local TE = TorpedoAI(_torpedo.id).entity
			Durability(TE.index).durability = 0
			--TE:destroy(Entity().id,Weaponry,Fragments)
			--Torpedo(_torpedo.id):startDetonation()
		else
			if _debug then
				if not (CheckForEnemy(Entity(), _torpedo)) then DebugMsg('PulsarOperate: torpedo is friendly?') end
				if not (isInRangeV3(Entity().translationf, _torpedo.translationf, PulsarRange + PulsarRangeR * _rarity)) then
					DebugMsg('PulsarOperate: torpedo is too far away')
				end
			end
		end
	end
	--Sending information for rendering effects and initializing rendering
	if #targets > 0 then
		for _, _player in pairs(PlayerCache) do
			--DebugMsg('PulsarClearLasersInit: remote call for player "'.._player.name..'": create laser')
			invokeClientFunction(_player, 'PulsarGraphics', Entity(), targets)
		end
	end
end

callable(nil, 'PulsarOperate')

--Laser rendering
function PulsarGraphics(_entity, _targets)
	--Cutting off
	if _entity == nil or Entity() == nil or #_targets < 1 then
		DebugMsg('PulsarKillTorpedo: target or entity is nil or no targets')
		return
	end
	--Creation of a laser
	for _, _point in pairs(_targets) do
		local _laser = Sector():createLaser(_entity.translationf, _point, _colorR, 1)
		_laser.collision = false
		_laser.maxAliveTime = 0.2
	end
end

function ActivateTransferPDS()
	invokeServerFunction("PulsarActivate")
end

----------------------------------------------------------------------------------------------------------------

function onFinishWork(_time, _type)
	--0 -recovery
	--1 -multiphase
	--3 -protocol/pulsar
	if _time <= 0 then
		if _type == 0 then
			DebugMsg("Рекуперация: конец работы")
			UIplaysound(1)
		end
		if _type == 1 then
			print("Ремонтная сеть завершила активную фазу")
			UIplaysound(1)
		end
		if _type == 3 then
			print("Протокол завершил работу")
			UIplaysound(1)
		end
		updateStatusEffects(_type, false)
	else
		return
	end
end

function initializeUI()
	local subSysDesc = {
		string.format(
			"%s\nActivation of the module increases the shield's resistance to all damage by %i%%, hull is restored at a rate of %.1f%% the maximum amount of shield per second (%i/sec), but the rate of fire of all weapons drops by %i%%. Reactivation or loss of the shield turns off the module.\nCooldown - %i seconds." %
			_t, getSubtechName(systemname, 1), VeilResistance, VeilRepair, getVeilRepairAmount(), VeilFireRate,
			VeilCooldown - VeilCooldownR * _rarity),
		string.format(
			"%s\nThe energy, electric and plasma damage received by shield accumulates the charge of the module, limited to %i%% of the maximum amount of shield. The conversion rate is %i%% damage received. Activation of the module consumes the charge and restores the same volume of the shield for %i seconds. The module interrupts operation if the shield is turned off.\nCooldown - %i seconds." %
			_t, getSubtechName(systemname, 2), RecupMaxValue + RecupMaxValueR * _rarity, RecupMultiplier, RecupLength,
			RecupCooldown),
		string.format(
			"%s\nActivation applies impenetrability shields mode for %i sec., and also significantly reduces the pause of shield recharge after receiving damage.\nCooldown - %i seconds." %
			_t, getSubtechName(systemname, 3), MultiphaseLength + MultiphaseLengthR * _rarity,
			MultiphaseCooldown - MultiphaseCooldownR * _rarity),
		string.format(
			"%s\nWithin %i s. module will automatically shoot down hostile torpedoes within a radius of %i km if the ship's shield exceeds %i%%.\nCooldown - %i seconds." %
			_t, getSubtechName(systemname, 4), PulsarLength + PulsarLengthR * _rarity,
			PulsarRange + PulsarRangeR * _rarity,
			PulsarTreshold, PulsarCooldown)
	}

	invokeServerFunction('executeDrawInterface', subSysDesc)
end

function executeDrawInterface(subSysDesc)
	local subsys = {}

	local subsys1 = {
		getSubtechName(systemname, 1), --Name
		getSubtechIcon(systemname, 1), --Icon
		subSysDesc[1],           --Desc
		'VeilActivate',          --Command
	}
	local subsys2 = {
		getSubtechName(systemname, 2), --Name
		getSubtechIcon(systemname, 2), --Icon
		subSysDesc[2],           --Desc
		'RecupActivate',         --Command
	}
	local subsys3 = {
		getSubtechName(systemname, 3), --Name
		getSubtechIcon(systemname, 3), --Icon
		subSysDesc[3],           --Desc
		'MultiphaseActivate',    --Command
	}
	local subsys4 = {
		getSubtechName(systemname, 4), --Name
		getSubtechIcon(systemname, 4), --Icon
		subSysDesc[4],           --Desc
		'PulsarActivate',        --Command
	}
	table.insert(subsys, subsys1)
	table.insert(subsys, subsys2)
	table.insert(subsys, subsys3)
	table.insert(subsys, subsys4)

	local _table = {
		scriptname,        --System script
		getTechName(systemname), --System name
		getTechIcon(systemname), --System icon
		Entity().id,       --entityID
		subsys             --subsys
	}

	local _addBars = {
		[2] = { 'progressbar' }
	}

	CosmicStarfallLib.invokeOwnerFunction(Entity(), 'activeSysInterface', 'executeDraw', _table, _addBars)
end

callable(nil, 'executeDrawInterface')

function executeUpdateProgressbar(_index, _progress, _isStandby)
	local entity = Entity().id

	if not (_isStandby) then _isStandby = false end
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeUpdateProgress', _index,
		scriptname, entity, _progress, _isStandby)
end

function executeUpdateSecondary(_index, _progress)
	local entity = Entity().id
	Debug('executing update secondary from ' .. Entity().name)
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeUpdateSecondary', _index,
		scriptname, entity, _progress)
end

function executeDelete()
	local entity = Entity().id
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeDelete', scriptname, entity)
end

function UIplaysound(_type)
	--0 -activation
	--1 -deactivation
	--2 -error
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
end

----------------------------------------------------------------------------------------------------------------
function getBonuses(seed, rarity, permanent)
	math.randomseed(seed)

	local _shield = math.random(27, 31) - rarity.value * 2

	local _regen = math.random(14, 19) + rarity.value * 3

	local _timeFactor = math.random(19, 21) + rarity.value * 2

	--DebugMsg(tostring(_shield).."% _shield")
	--DebugMsg(tostring(_regen).."% _regen")

	return _shield, _regen, _timeFactor
end

function onInstalled(seed, rarity, permanent)
	local _shield, _regen, _timeFactor = getBonuses(seed, rarity, permanent)
	if not Entity() then return end
	--Assigns a global variable used to determine module quality
	_rarity = rarity.value
	--Adds passive bonuses upon installation
	addBaseMultiplier(StatsBonuses.ShieldRecharge, _regen / 100)
	addMultiplier(StatsBonuses.ShieldDurability, 1 - (_shield / 100))
	addBaseMultiplier(StatsBonuses.ShieldTimeUntilRechargeAfterHit, -(_timeFactor / 100))

	--Initializing Interface Elements
	if onClient() and not (BSwindow) then
		initializeUI()
		Player():registerCallback("onStateChanged", "UIshowhide")
		Player():registerCallback("onShipChanged", "UIshowhide")
		Player():registerCallback("onSectorChanged", "UIshowhide")
	end
	if onServer() then
		RecupInitiation()
	end
end

function onUninstalled(seed, rarity, permanent)
	--Cutting off
	if not (Shield()) or not (Entity()) then return end

	-- SpawnUtility.resetResistance(Entity())
	-- Shield().damageFactor = 1
	if onServer() then
		executeDelete()
		Entity():removeScriptBonuses()
	end
end

function getName(seed, rarity)
	--local mark = toRomanLiterals(rarity.value + 2)
	local _mk = rarity.value + 2
	return getTechName(systemname) .. ' BS-' .. tostring(_mk)
end

function getIcon(seed, rarity)
	return getTechIcon(systemname)
end

function getPrice(seed, rarity)
	local _shield, _regen, _timeFactor = getBonuses(seed, rarity, permanent)
	local price = 300 * 50 * (_regen + rarity.value);
	return price * 2.0 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)
	local _shield, _regen, _timeFactor = getBonuses(seed, rarity, permanent)
	local texts = {}
	local bonuses = {}

	--Bonuses
	table.insert(texts,
		{
			ltext = "Shield Durability" % _t,
			rtext = string.format('-%i%%', _shield),
			icon =
			"data/textures/icons/health-normal.png",
			boosted = permanent
		})
	table.insert(texts,
		{
			ltext = "Shield Recharge Rate" % _t,
			rtext = string.format("+%i%%", _regen),
			icon =
			"data/textures/icons/shield-charge.png",
			boosted = permanent
		})
	table.insert(texts,
		{
			ltext = "Time Until Recharge" % _t,
			rtext = string.format("-%i%%", _timeFactor),
			icon =
			"data/textures/icons/recharge-time.png",
			boosted = permanent
		})

	--Empty string
	table.insert(texts, { ltext = "" })

	--Abilki
	for i = 1, 4 do
		table.insert(texts,
			{ ltext = getSubtechName(systemname, i), icon = getSubtechIcon(systemname, i), boosted = permanent })
	end

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

	return base, bonus
end
