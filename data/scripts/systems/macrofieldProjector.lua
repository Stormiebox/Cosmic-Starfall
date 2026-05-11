package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include("basesystem")
include("utility")
include("randomext")
include("tooltipmaker")
include("Tech")
include("cosmicstarfalllib")

local _debug = false
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
local systemname = 'macrofieldprojector'
local scriptname = 'macrofieldProjector'

local subSysDesc = {}


--Basic values ​​of active phases of systems. Use it as a config, too lazy to make a separate one :)
ModuleBonusEnergy = 12                   --percentage of base enki regen gain
ModuleBonusAccum = 80                    --percentage of base increase in battery reserve
ModuleBonusEnergyRARMP = 2.5             --percentage, bonus per unit of rarity (Rarity is distributed from -1 = gray to 5 = violet)
ModuleBonusAccumRARMP = 9                --percentage, bonus per unit of rarity

RepairWaveCooldown = 110                 --seconds, repair wave CD
RepairWaveCooldownRARMP = 3              --seconds, cooldown reduction per rarity unit
RepairWaveOperationTime = 6              --seconds, wave operating time
RepairWaveHealingAmount = 2200           --hull units repaired for a selected amount of energy
RepairWaveEnergyUnit = 1                 --terajoules, selected amount of energy
RepairWaveSelfBonus = 12                 --interest, bonus recovery on your own
RepairWaveSelfBonusRARMP = 2             --interest, bonus to restoration per unit of rarity
RepairWaveEnergyConsumption = 8          --percent, battery energy burned per second
RepairWaveRange = 28                     --kilometers, wave radius

RenovatingRayCooldown = 28               --seconds, module rollback
RenovatingRayHealingAmount = 3200        --hull units repaired for a selected amount of energy
RenovatingRayEnergyUnit = 1              --terajoules, selected amount of energy
RenovatingRayEnergyConsumption = 2.5     --percent, battery energy burned per second
RenovatingRayRange = 30                  --kilometers, work radius
RenovatingRayRangeRARMP = 2              --kilometers, additional radius per unit of rarity
RenovatingRayCanUseOnSelf = false        --does the beam work on its own?

ShieldBoosterCooldown = 32               --seconds, module rollback
ShieldBoosterHealingAmount = 7000        --hull units repaired for a selected amount of energy
ShieldBoosterEnergyUnit = 1              --terajoules, selected amount of energy
ShieldBoosterEnergyConsumption = 3       --percent, battery energy burned per second
ShieldBoosterRange = 30                  --kilometers, work radius
ShieldBoosterRangeRARMP = 2              --kilometers, additional radius per unit of rarity
ShieldBoosterCanUseOnSelf = false        --does the beam work on its own?
ShieldBoosterValueTreshold = 10          --percentage, the minimum volume of the target's shield to be able to work

ShieldSynchronizerCooldown = 12          --seconds, module rollback
ShieldSynchronizerAmount = 0.45          --percentages, shield transfer volume
ShieldSynchronizerRange = 30             --kilometers, module range
ShieldSynchronizerValueTreshold = 10     --percentage, the minimum volume of the target's shield to be able to work
ShieldSynchronizerValueTresholdRARMP = 1 --percentage subtracted from ShieldSynchronizerValueTreshold for each rarity

--Dynamic values, cannot be changed manually
local RepairWaveIsReady = 0                --module readiness status, contains the remaining module recharge time
local RepairWaveIsWorking = 0              --module active phase status, contains the remaining operating time of the module
local RepairWaveHealAmount = 0             --the volume of the refilled hull per tick is automatically calculated
local RepairWaveEnergyConsumptionCV = 0    --the amount of energy spent per tick is automatically calculated
local RepairWaveEntities = {}              --scan result for possible targets for repair

local RenovatingRayIsReady = 0             --module readiness status, contains the remaining module recharge time
local RenovatingRayIsWorking = false       --module active phase status
local RenovatingRayTarget = nil            --repair beam target
local RenovatingRayAmount = 0              --the volume of the refilled hull per tick is automatically calculated
local RenovatingRayEnergyConsumptionCV = 0 --the amount of energy spent per tick is automatically calculated
local RenovatingRayInRange = false         --distance control flag

local ShieldBoosterIsReady = 0             --module readiness status, contains the remaining module recharge time
local ShieldBoosterIsWorking = false       --module active phase status, contains the remaining operating time of the module
local ShieldBoosterTarget = nil            --shield booster target
local ShieldBoosterHealAmount = 0          --the amount of shield replenished per tick is automatically calculated
local ShieldBoosterEnergyConsumptionCV = 0 --the amount of energy spent per tick is automatically calculated
local ShieldBoosterInRange = false         --distance control flag

local ShieldSynchronizerIsReady = 0        --module readiness status, contains the remaining module recharge time
local ShieldSynchronizerIsWorking = false  --module active phase status, contains the remaining operating time of the module
local ShieldSynchronizerTarget = nil       --shield synchronizer target
local ShieldSynchronizerHealAmount = 0     --the amount of shield replenished per tick is automatically calculated
local ShieldSynchronizerPercent = 0        --average percentage of shields of connected ships, automatically calculated
local ShieldSynchronizerInRange = false

--Interface Variables
local progressBars = {}

--Variable graphics
local LaserRR = nil    --repair beam variable
local LaserSB = nil    --shield amplifier variable
local LaserSS = nil    --synchronizer variable
local RefrSphere = nil --repair wave sphere

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true

if _debug then
	PermanentInstallationOnly = false
	RepairWaveCooldown = 10
	RepairWaveCooldownRARMP = 0
	RenovatingRayCooldown = 5
	ShieldBoosterCooldown = 5
	--RepairWaveOperationTime = 5
else
	PermanentInstallationOnly = true
end

function isHere(_entity)
	if _debug then
		print(_entity.id)
		print(_entity.name)
	end

	if _entity then
		if Sector():getEntity(_entity.id) then
			return true
		end
	end
	return false
end

function ConvertToJ(_value, _reverse)
	if _reverse then
		return _value / 1000000000000
	else
		return _value * 1000000000000
	end
end

function CalculateRepairAmount(_type)
	--0 repair wave
	--Renewal Beam
	--Shield Booster
	if _type == 0 then
		local _energyConsumpt = ConvertToJ(EnergySystem().capacity * (RepairWaveEnergyConsumption * 0.01), true)
		local _baseHealMultiplier = round(_energyConsumpt * RepairWaveHealingAmount)
		DebugMsg("Repair amount (repair wave): " .. tostring(_baseHealMultiplier))
		return _baseHealMultiplier
	end
	if _type == 1 then
		local _energyConsumptRR = ConvertToJ(EnergySystem().capacity * (RenovatingRayEnergyConsumption * 0.01), true)
		local _baseHealMultiplierRR = round(_energyConsumptRR * RenovatingRayHealingAmount)
		return _baseHealMultiplierRR
	end
	if _type == 2 then
		local _energyConsumptSB = ConvertToJ(EnergySystem().capacity * (ShieldBoosterEnergyConsumption * 0.01), true)
		local _baseHealMultiplierSB = round(_energyConsumptSB * ShieldBoosterHealingAmount)
		return _baseHealMultiplierSB
	end
	if _type == 3 then
		local selfPercent = Shield().filledPercentage
		local otherPercent = Shield(ShieldSynchronizerTarget.id).filledPercentage
		local midPercent = (selfPercent + otherPercent) / 2
		DebugMsg("MidPercent is " .. tostring(midPercent))
		--If your shield is larger, pumps 0.2%
		if selfPercent > midPercent + ShieldSynchronizerAmount * 0.01 then
			return Shield().maximum * (ShieldSynchronizerAmount * 0.01)
		end
		if otherPercent > midPercent + ShieldSynchronizerAmount * 0.01 then
			return Shield(ShieldSynchronizerTarget.id).maximum * (ShieldSynchronizerAmount * 0.01) * -1
		else
			return 0
		end
	end
end

--Displays enki costs
function RWgetHealAmount()
	local _energyConsumpt = ConvertToJ(EnergySystem().capacity * (RepairWaveEnergyConsumption * 0.01), true)
	DebugMsg(tostring(_energyConsumpt) .. "тДж - затраты энергии ремонтной волны")
	local _baseHealMultiplier = round(_energyConsumpt * RepairWaveHealingAmount)
	DebugMsg(tostring(_baseHealMultiplier) .. " - потенциальный ремонт корпуса")
	local _baseHealMultiplierSelf = round(_baseHealMultiplier *
		(1 + (RepairWaveSelfBonus + RepairWaveSelfBonusRARMP * _rarity) / 100))
	DebugMsg(tostring(_baseHealMultiplierSelf) .. " - потенциальный ремонт корпуса себе")

	local _energyConsumptRR = ConvertToJ(EnergySystem().capacity * (RenovatingRayEnergyConsumption * 0.01), true)
	DebugMsg(tostring(_energyConsumptRR) .. "тДж - затраты энергии обновляющего луча")
	local _baseHealMultiplierRR = round(_energyConsumptRR * RenovatingRayHealingAmount)
	DebugMsg(tostring(_baseHealMultiplierRR) .. " - потенциальный ремонт корпуса от обновляющего луча")

	local _energyConsumptSB = ConvertToJ(EnergySystem().capacity * (ShieldBoosterEnergyConsumption * 0.01), true)
	DebugMsg(tostring(_energyConsumptSB) .. "тДж - затраты энергии усилителя щита")
	local _baseHealMultiplierSB = round(_energyConsumptSB * ShieldBoosterHealingAmount)
	DebugMsg(tostring(_baseHealMultiplierSB) .. " - потенциальный реген щита от усилителя щита")
end

function DebugMsg(_text)
	if _debug then
		print(_text)
	end
end

function DoMeow()
	if _debug then
		print("Meow")
	end
end

function DebugLaserDraw(_from, _to)
	local _L = Sector():createLaser(_from, _to, _colorG, 2)
	_L.collision = false
	_L.maxAliveTime = 0.04
end

function DebugMassLaserDraw(_from, _to)
	local PlayerCache = { Sector():getPlayers() }
	if #PlayerCache < 1 then return end -- Potentially impossible, but so be it.
	for _, _player in pairs(PlayerCache) do
		invokeClientFunction(_player, 'DebugLaserDraw', _from, _to)
	end
end

callable(nil, 'DebugMassLaserDraw')

function RestoreEnergy() --for debug
	if _debug then
		if onServer() then
			EnergySystem():addEnergy(EnergySystem().capacity * 0.2)
			invokeClientFunction(Player(), "RestoreEnergy")
		else
			EnergySystem():addEnergy(EnergySystem().capacity * 0.2)
		end
	end
end

callable(nil, "RestoreEnergy")

function DamageTarget() --for debug
	local tgtId = Entity().selectedObject
	--Durability(tgtId).durability = Durability(tgtId).durability -100000
	Shield(tgtId).durability = Shield(tgtId).durability - 400000
end

callable(nil, "DamageTarget")

function DamageTargetTransfer()
	invokeServerFunction("DamageTarget")
end

function isInRangeV3(v1, v2, range)
	local modRange = (range * 100) * (range * 100)
	local calcDist2 = distance2(v1, v2) * 0.85
	if calcDist2 <= modRange and calcDist2 > 0 then
		return true
	else
		return false
	end

	--DebugMsg("Range for 'isInRange' = "..tostring(calcDist)..", when range sqrt is "..tostring(calcDist2))
end

function SyncEnergyRemove(_value)
	if onServer() then
		EnergySystem():removeEnergy(_value)
		invokeClientFunction(Player(), "SyncEnergyRemove", _value)
	else
		EnergySystem():removeEnergy(_value)
	end
end

--------------------------------------------------------------------------------------------

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
	--repair wave segment
	if RepairWaveIsReady > 0 then
		RepairWaveIsReady = math.max(0, RepairWaveIsReady - timePassed) --direct reduction of rollback
		local progress = RepairWaveIsReady / RepairWaveCooldown
		executeUpdateProgressbar(1, progress)
	end
	if RepairWaveIsWorking > 0 then
		RepairWaveIsWorking = math.max(0, RepairWaveIsWorking - timePassed)
		RepairWaveOperate()
		invokeClientFunction(Player(), "onFinishWork", RepairWaveIsWorking, 0) --Catch the moment when the module ends
	end
	--beam segment
	if RenovatingRayIsReady > 0 and RenovatingRayIsWorking == false then
		RenovatingRayIsReady = math.max(0, RenovatingRayIsReady - timePassed) --direct reduction of rollback
		local progress = RenovatingRayIsReady / RenovatingRayCooldown
		executeUpdateProgressbar(2, progress)
	end
	if RenovatingRayIsWorking then
		RenovationRayOperate()
		executeUpdateProgressbar(2, 0, true)
	end
	--amplifier segment
	if ShieldBoosterIsReady > 0 and ShieldBoosterIsWorking == false then
		ShieldBoosterIsReady = math.max(0, ShieldBoosterIsReady - timePassed) --direct reduction of rollback
		local progress = ShieldBoosterIsReady / ShieldBoosterCooldown
		executeUpdateProgressbar(3, progress)
	end
	if ShieldBoosterIsWorking then
		ShieldBoosterOperate()
		executeUpdateProgressbar(3, 0, true)
	end
	--synchronizer segment
	if ShieldSynchronizerIsReady > 0 and ShieldSynchronizerIsWorking == false then
		ShieldSynchronizerIsReady = math.max(0, ShieldSynchronizerIsReady - timePassed) --rollback reduction
		local progress = ShieldSynchronizerIsReady / ShieldSynchronizerCooldown
		executeUpdateProgressbar(4, progress)
	end
	if ShieldSynchronizerIsWorking then
		ShieldSyncOperate()
		executeUpdateProgressbar(4, 0, true)
	end
end

--------------------------------------------------------------------------------------------
function RepairWaveActivate()
	if RepairWaveIsReady == 0 then
		self = Entity()

		--Type-graphics: setting values ​​and checking for matches, drawing a sphere
		local _type = 'MPrw'
		local _source = self
		local _radius = self.radius * 1.15
		local _ivec2radius = ivec2(200, 200)
		local _color = vec3(1, 1, 1)
		local _intensity = 0.01
		local _reflectivity = 1.1
		local _reflColor = vec3(0.2, 0.9, 0.2)
		local _exitResult, _callResult = self:invokeFunction('raycast.lua', 'setSphere', _type, _source, _radius,
			_ivec2radius, _color, _intensity, _reflectivity, _reflColor)

		--Clipping if drawing the sphere does not work
		if _exitResult > 0 or _callResult > 0 then
			DebugMsg('RepairWaveActivate eroro: setSphere failure')
			return
		end

		--Setting cooldown
		RepairWaveIsReady = RepairWaveCooldown - RepairWaveCooldownRARMP * _rarity

		--Calculation of repair volume
		RepairWaveHealAmount = CalculateRepairAmount(0)

		--Energy consumption calculation
		RepairWaveEnergyConsumptionCV = EnergySystem().capacity * (RepairWaveEnergyConsumption * 0.01)

		--Setting the operating time
		RepairWaveIsWorking = RepairWaveOperationTime

		--Creating an effect icon
		invokeClientFunction(Player(), "updateStatusEffects", 0, true)

		--Turn off the beam and amplifier if they are working
		RenovatingRayTurnToFalse()
		ShieldBoosterTurnToFalse()

		local _aura = {
			getSubtechSignature(systemname, 1),
			string.format("+%i/s", CalculateRepairAmount(0)),
			RepairWaveOperationTime,
			getTechAuraDesc('hullrepair'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 1),
			false,
			true
		}
		callTechAuraSelf(_aura)

		--Sound
		invokeClientFunction(Player(), 'UIplaysound', 0)
	else
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "RepairWaveActivate")

--Turns off graphics
-- function RepairWaveDeactivate()

-- End

function RepairWaveOperate()
	if onServer() then
		if (EnergySystem().energy < RepairWaveEnergyConsumptionCV) then
			DebugMsg("RepairWaveOperate failure: low energy")
			--RepairWaveIsWorking = 1
			return
		end
		EnergySystem():removeEnergy(RepairWaveEnergyConsumptionCV)
		invokeClientFunction(Player(), "RepairWaveOperateClient", RepairWaveEnergyConsumptionCV)

		local ShipsInSector = { Sector():getEntitiesByType(EntityType.Ship) }
		for n, ship in pairs(ShipsInSector) do
			if ship.playerOrAllianceOwned and ship.isShip and isInRangeV3(ship.translationf, Entity().translationf, RepairWaveRange) then
				if _debug then
					print(ship.name)
					print("Heal tick: ", RepairWaveHealAmount)
				end
				Durability(ship.id):healDamage(RepairWaveHealAmount, Entity().id)

				--Aura
				local target = ship

				local _aura = {
					getSubtechSignature(systemname, 1) .. 'remote',
					string.format("+%i/s", CalculateRepairAmount(0)),
					0,
					getTechAuraDesc('hullrepair'),
					'buff',
					Entity().name,
					target.name,
					getSubtechIcon(systemname, 1),
					true,
					true
				}
				callTechAuraTarget(_aura, target)
			end
		end
		if Entity() then
			local selfHealMult = (RepairWaveSelfBonus + RepairWaveSelfBonusRARMP * _rarity) * 0.01 + 1
			DebugMsg("SelfHealIs: " ..
				tostring(RepairWaveHealAmount * selfHealMult) .. " where selfMult is " .. tostring(selfHealMult - 1))
			Durability(Entity().id):healDamage(RepairWaveHealAmount * selfHealMult, Entity().id)
		end
		--Turns off the refresh beam
		-- RenovatingRayTurnToFalse()
	end
end

function RepairWaveOperateClient(_amount)
	EnergySystem():removeEnergy(_amount)
end

function ActivateTransferRW()
	invokeServerFunction("RepairWaveActivate")
end

function RenovationRayActivate()
	--Reactivation to turn off a working beam
	local _shipTGT = Entity().selectedObject
	local _shipSelf = Entity()
	local _range = RenovatingRayRange + RenovatingRayRangeRARMP * _rarity

	if RenovatingRayIsWorking then
		RenovatingRayTurnToFalse()
		return
	end

	--Beam activation
	if RenovatingRayIsReady == 0 and Entity().selectedObject ~= nil and RepairWaveIsWorking == 0 then
		if not (_shipTGT) or _shipTGT.index == _shipSelf.index then return end

		local _exitResult, _callResult = _shipTGT:invokeFunction('raycast.lua', 'setLaser', 'MPrrT', _shipSelf, _shipTGT,
			_colorG, _range, 2)
		DebugMsg('RenovationRayActivate: callResult is ' .. tostring(_callResult))
		if _exitResult > 0 or _callResult > 0 then
			invokeClientFunction(Player(), 'UIplaysound', 2)
			return
		end
		local _exitResult, _callResult = _shipSelf:invokeFunction('raycast.lua', 'setLaser', 'MPrrS', _shipSelf, _shipTGT,
			_colorG, _range, 2)
		-- if Owner(_shipTGT.id).name~=Owner(_shipSelf.id).name then
		-- local _exitResult,_callResult = _shipSelf:invokeFunction('raycast.lua','setLaser','MPrrS',_shipSelf,	_shipTGT,_colorG,_range,2)
		-- end

		invokeClientFunction(Player(), 'UIplaysound', 0)
		RenovatingRayIsReady = RenovatingRayCooldown
		RenovatingRayAmount = CalculateRepairAmount(1)
		RenovatingRayEnergyConsumptionCV = EnergySystem().capacity * (RenovatingRayEnergyConsumption * 0.01)
		RenovatingRayIsWorking = true
		invokeClientFunction(Player(), "updateStatusEffects", 1, true)
		invokeClientFunction(Player(), "updateUIbarsToYellow", 1)
		RenovatingRayTarget = _shipTGT
		ShieldBoosterTurnToFalse()
		invokeClientFunction(Player(), 'UIplaysound', 0)
	else
		invokeClientFunction(Player(), 'UIplaysound', 2)
		DebugMsg("RenovationRay activation failure: on cooldown")
		DebugMsg("RepairWaveIsWorking: " .. tostring(RepairWaveIsWorking))
	end
end

callable(nil, "RenovationRayActivate")

function RenovationRayOperate()
	--Checking for inactivity during recharging
	if RenovatingRayIsWorking == false then return end

	--Check goals
	if not (valid(RenovatingRayTarget)) or RenovatingRayTarget.isShip == false then
		RenovatingRayTurnToFalse()
		DebugMsg("RenovatingRay: не могу найти цель (отсутствует или погибла)")
		return
	end

	--Checking the permissible distance to the target
	RenovatingRayInRange = isInRangeV3(RenovatingRayTarget.translationf, Entity().translationf,
		RepairWaveRange + RenovatingRayRangeRARMP * _rarity)

	--Monitoring the state of the target
	local repairNeeded = (Durability(RenovatingRayTarget.id).filledPercentage < 1)

	--Status icon control
	if RenovatingRayInRange then
		invokeClientFunction(Player(), "updateStatusEffects", 1, true)
		invokeClientFunction(Player(), "updateStatusEffects", 2, false)
	else
		invokeClientFunction(Player(), "updateStatusEffects", 1, false)
		invokeClientFunction(Player(), "updateStatusEffects", 2, true)
	end

	--Hull restoration
	if RenovatingRayInRange and repairNeeded then
		if EnergySystem().energy >= RenovatingRayEnergyConsumptionCV then
			SyncEnergyRemove(RenovatingRayEnergyConsumptionCV)
			Durability(RenovatingRayTarget.id):healDamage(RenovatingRayAmount, Entity().id)
			DebugMsg("Ship '" .. RenovatingRayTarget.name .. "' healed for " .. tostring(RenovatingRayAmount))

			--Aura
			local target = RenovatingRayTarget

			local _aura = {
				getSubtechSignature(systemname, 2),
				string.format("+%i/s", RenovatingRayAmount),
				0,
				getTechAuraDesc('hullrepair'),
				'buff',
				Entity().name,
				target.name,
				getSubtechIcon(systemname, 2),
				true,
				true
			}
			callTechAuraTarget(_aura, target)
		else
			RenovatingRayIsWorking = false
			if repairNeeded then
				DebugMsg("RenovatingRay failure: out of range")
			else
				DebugMsg("RenovatingRay failure: target durability is full")
			end
		end
	end
end

function RenovatingRayTurnToFalse()
	if RenovatingRayIsWorking then
		RenovatingRayIsWorking = false
		invokeClientFunction(Player(), "updateStatusEffects", 1, false)
		invokeClientFunction(Player(), "updateStatusEffects", 2, false)
		invokeClientFunction(Player(), 'UIplaysound', 1)
		--Laser off segment
		DebugMsg('RenovatingRaySendFalse attempt')
		Entity():invokeFunction('raycast.lua', 'removeLaser', 'MPrrS')
		if valid(RenovatingRayTarget) then
			RenovatingRayTarget:invokeFunction('raycast.lua', 'removeLaser', 'MPrrT')
		end
	end
end

function ActivateTransferRR()
	invokeServerFunction("RenovationRayActivate")
end

function ShieldBoosterActivate()
	local _shipTGT = Entity().selectedObject
	local _shipSelf = Entity()
	local _range = ShieldBoosterRange + ShieldBoosterRangeRARMP * _rarity

	--Reactivation to turn off a working beam
	if ShieldBoosterIsWorking then
		ShieldBoosterTurnToFalse()
		return
	end
	--Beam activation
	if ShieldBoosterIsReady == 0 and Entity().selectedObject ~= nil and RepairWaveIsWorking == 0 then
		if not (_shipTGT) or _shipTGT.index == _shipSelf.index then return end

		local _exitResult, _callResult = _shipTGT:invokeFunction('raycast.lua', 'setLaser', 'MPsbT', _shipSelf, _shipTGT,
			_colorB, _range, 2)
		DebugMsg('RenovationRayActivate: callResult is ' .. tostring(_callResult))
		if _exitResult > 0 or _callResult > 0 then
			invokeClientFunction(Player(), 'UIplaysound', 2)
			return
		end
		-- if Owner(_shipTGT.id).name~=Owner(_shipSelf.id).name then
		-- local _exitResult,_callResult = _shipSelf:invokeFunction('raycast.lua','setLaser','MPsbS',_shipSelf,	_shipTGT,_colorB,_range,2)
		-- end
		local _exitResult, _callResult = _shipSelf:invokeFunction('raycast.lua', 'setLaser', 'MPsbS', _shipSelf, _shipTGT,
			_colorB, _range, 2)

		ShieldBoosterIsReady = ShieldBoosterCooldown
		ShieldBoosterHealAmount = CalculateRepairAmount(2)
		ShieldBoosterEnergyConsumptionCV = EnergySystem().capacity * (ShieldBoosterEnergyConsumption * 0.01)
		ShieldBoosterIsWorking = true
		ShieldBoosterTarget = _shipTGT
		invokeClientFunction(Player(), "updateStatusEffects", 3, true)
		invokeClientFunction(Player(), "updateUIbarsToYellow", 2)
		--Invoke client function(player(),"shield booster ray graphics",shield booster target)
		RenovatingRayTurnToFalse()
		--Renovation ray graphics(renovating ray target)
		invokeClientFunction(Player(), 'UIplaysound', 0)
	else
		DebugMsg("ShieldBooster activation failure: on cooldown")
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "ShieldBoosterActivate")

function ShieldBoosterOperate()
	--Checking for inactivity during recharging
	if ShieldBoosterIsWorking == false then return end

	--Check goals
	if ShieldBoosterTarget == nil or ShieldBoosterTarget.isShip == false or Shield(ShieldBoosterTarget.id).filledPercentage < 0.1 then
		ShieldBoosterTurnToFalse()
		DebugMsg("ShieldBooster: не могу найти цель (отсутствует или погибла)")
		return
	end

	--Checking the permissible distance to the target
	ShieldBoosterInRange = isInRangeV3(ShieldBoosterTarget.translationf, Entity().translationf,
		ShieldBoosterRange + ShieldBoosterRangeRARMP * _rarity)

	--Monitoring the state of the target
	local repairNeeded = (Shield(ShieldBoosterTarget.id).filledPercentage < 1)

	--Status icon control
	if ShieldBoosterInRange then
		invokeClientFunction(Player(), "updateStatusEffects", 3, true)
		invokeClientFunction(Player(), "updateStatusEffects", 4, false)
		invokeClientFunction(Player(), "UniSetLaserWidth", 2, 2)
	else
		invokeClientFunction(Player(), "updateStatusEffects", 3, false)
		invokeClientFunction(Player(), "updateStatusEffects", 4, true)
		invokeClientFunction(Player(), "UniSetLaserWidth", 2, 0)
	end

	--Shield restoration
	if ShieldBoosterInRange and repairNeeded then
		if EnergySystem().energy >= ShieldBoosterEnergyConsumptionCV then
			SyncEnergyRemove(ShieldBoosterEnergyConsumptionCV)
			Shield(ShieldBoosterTarget.id):healDamage(ShieldBoosterHealAmount, Entity().id)
			DebugMsg("Ship '" .. ShieldBoosterTarget.name .. "' healed for " .. tostring(ShieldBoosterHealAmount))
			DebugMsg("Percent is: " .. tostring(Shield(ShieldBoosterTarget.id).filledPercentage))

			--Aura
			local target = ShieldBoosterTarget

			local _aura = {
				getSubtechSignature(systemname, 3),
				string.format("+%i/s", ShieldBoosterHealAmount),
				0,
				getTechAuraDesc('shieldrepair'),
				'buff',
				Entity().name,
				target.name,
				getSubtechIcon(systemname, 3),
				true,
				true
			}
			callTechAuraTarget(_aura, target)
		else
			ShieldBoosterIsWorking = false
			DebugMsg("ShieldBooster failure: low energy")
		end
	end
end

function ShieldBoosterTurnToFalse()
	if ShieldBoosterIsWorking then
		ShieldBoosterIsWorking = false
		invokeClientFunction(Player(), "updateStatusEffects", 3, false)
		invokeClientFunction(Player(), "updateStatusEffects", 4, false)
		invokeClientFunction(Player(), 'UIplaysound', 1)

		Entity():invokeFunction('raycast.lua', 'removeLaser', 'MPsbS')
		if ShieldBoosterTarget then
			ShieldBoosterTarget:invokeFunction('raycast.lua', 'removeLaser', 'MPsbT')
		end
	end
end

function ActivateTransferSB()
	invokeServerFunction("ShieldBoosterActivate")
end

function ShieldSyncActivate()
	local _shipTGT = Entity().selectedObject
	local _shipSelf = Entity()
	local _range = ShieldSynchronizerRange
	--Reactivation to turn off a working beam
	if ShieldSynchronizerIsWorking then
		ShieldSyncTurnToFalse()
		return
	end
	--Synchronizer activation
	if ShieldSynchronizerIsReady == 0 and Entity().selectedObject ~= nil then
		if not (_shipTGT) or _shipTGT.index == _shipSelf.index then return end

		local _exitResult, _callResult = _shipTGT:invokeFunction('raycast.lua', 'setLaser', 'MPssT', _shipSelf, _shipTGT,
			_colorC, _range, 1)
		DebugMsg('RenovationRayActivate: callResult is ' .. tostring(_callResult))
		if _exitResult > 0 or _callResult > 0 then
			invokeClientFunction(Player(), 'UIplaysound', 2)
			return
		end
		-- if Owner(_shipTGT.id).name~=Owner(_shipSelf.id).name then
		-- local _exitResult,_callResult = _shipSelf:invokeFunction('raycast.lua','setLaser','MPssS',_shipSelf,	_shipTGT,_colorB,_range,1)
		-- end
		local _exitResult, _callResult = _shipSelf:invokeFunction('raycast.lua', 'setLaser', 'MPssS', _shipSelf, _shipTGT,
			_colorC, _range, 1)
		ShieldSynchronizerTarget = _shipTGT
		ShieldSynchronizerIsReady = ShieldSynchronizerCooldown
		ShieldSynchronizerIsWorking = true
		invokeClientFunction(Player(), "updateStatusEffects", 5, true)
		invokeClientFunction(Player(), "updateUIbarsToYellow", 3)
		invokeClientFunction(Player(), 'UIplaysound', 0)
	else
		DebugMsg("ShieldSync activation failure: on cooldown")
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "ShieldSyncActivate")

function ShieldSyncOperate()
	--Checking for inactivity during recharging
	if ShieldSynchronizerIsWorking == false then return end
	--Check goals
	if not (valid(ShieldSynchronizerTarget)) then
		ShieldSyncTurnToFalse()
		return
	end

	if ShieldSynchronizerTarget == nil or ShieldSynchronizerTarget.isShip == false then
		ShieldSyncTurnToFalse()
		DebugMsg("ShieldSync: не могу найти цель (отсутствует или погибла)")
		return
	end
	--Checking the permissible distance to the target
	ShieldSynchronizerInRange = isInRangeV3(ShieldSynchronizerTarget.translationf, Entity().translationf,
		ShieldBoosterRange + ShieldSynchronizerRange)
	--Status icon control
	if ShieldSynchronizerInRange then
		invokeClientFunction(Player(), "updateStatusEffects", 5, true)
		invokeClientFunction(Player(), "updateStatusEffects", 6, false)
		invokeClientFunction(Player(), "UniSetLaserWidth", 2, 1)
	else
		invokeClientFunction(Player(), "updateStatusEffects", 5, false)
		invokeClientFunction(Player(), "updateStatusEffects", 6, true)
		invokeClientFunction(Player(), "UniSetLaserWidth", 2, 0)
	end

	--Shield restoration
	if ShieldSynchronizerInRange then
		local _amount = CalculateRepairAmount(3)
		local _treshold = (ShieldSynchronizerValueTreshold - ShieldSynchronizerValueTresholdRARMP * _rarity) * 0.01
		local _myPercent = Shield().filledPercentage < _treshold
		local _otherPercent = Shield(ShieldSynchronizerTarget.id).filledPercentage < _treshold

		--Aura on target
		local target = ShieldSynchronizerTarget

		local _aura = {
			getSubtechSignature(systemname, 4) .. 'remote',
			0,
			0,
			getTechAuraDesc('shieldsync'),
			'buff',
			Entity().name,
			target.name,
			getSubtechIcon(systemname, 4),
			true,
			true
		}
		callTechAuraTarget(_aura, target)

		--Aura on yourself
		local _aura = {
			getSubtechSignature(systemname, 4) .. 'self',
			0,
			0,
			getTechAuraDesc('shieldsync'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 4),
			true,
			true
		}
		callTechAuraSelf(_aura)

		if _amount == 0 or _myPercent or _otherPercent then
			DebugMsg("No shield transfer needed or shields too low")
			return
		end
		--If the return value is positive, the shield moves from you to the target, negative -vice versa
		Shield().durability = Shield().durability - _amount
		Shield(ShieldSynchronizerTarget.id).durability = Shield(ShieldSynchronizerTarget.id).durability + _amount
	end
end

function ShieldSyncTurnToFalse()
	if ShieldSynchronizerIsWorking then
		ShieldSynchronizerIsWorking = false
		invokeClientFunction(Player(), "updateStatusEffects", 5, false)
		invokeClientFunction(Player(), "updateStatusEffects", 6, false)
		invokeClientFunction(Player(), 'UIplaysound', 1)

		Entity():invokeFunction('raycast.lua', 'removeLaser', 'MPssS')
		if valid(ShieldSynchronizerTarget) then
			ShieldSynchronizerTarget:invokeFunction('raycast.lua', 'removeLaser', 'MPssT')
		end
	end
end

function ActivateTransferSS()
	invokeServerFunction("ShieldSyncActivate")
end

function onFinishWork(_time, _type)
	if _time <= 0 then
		if _type == 0 then
			DebugMsg("Ремонтная волна: конец работы")
			Entity():invokeFunction('raycast.lua', 'RemoveSphere', 'MPrw')
			UIplaysound(1)
		end
		if _type == 1 then
			--print("The repair network has completed its active phase")
			UIplaysound(1)
		end
		if _type == 2 then
			--print("The shield booster has completed its active phase")
			UIplaysound(1)
		end
		if _type == 3 then
			--print("Emergency stabilizer has completed its overload phase")
			UIplaysound(1)
		end
		updateStatusEffects(_type, false)
		--print (Durability().filledPercentage)
		--Durability().invincibility = Durability().invincibility -0.5
	else
		return
	end
end

function UniSetLaserWidth(_laserType, _value)
	if _laserType == 1 then
		if LaserRR == nil then return end
		DebugMsg("LaserWidth set to " .. tostring(_value))
		LaserRR.width = _value
	end
	if _laserType == 2 then
		if LaserSB == nil then return end
		DebugMsg("LaserWidth set to " .. tostring(_value))
		LaserSB.width = _value
	end
end

--------------------------------------------------------------------------------------------
function initializeUI()
	subSysDesc = {
		string.format(
			"%s\nConsumes %i%% energy per second, restoring %i hull points to surrounding player-owned allied vessels for each %i TJ of energy consumed (~%i points per second). The repair of your own ship has been increased by %i%%. It does not allow you to use %s and %s while working.\nThe radius of operation of the module is %i km.\nThe working time is %i seconds.\nCooldown - %i s." %
			_t, getSubtechName(systemname, 1), RepairWaveEnergyConsumption, RepairWaveHealingAmount, RepairWaveEnergyUnit,
			CalculateRepairAmount(0), RepairWaveSelfBonus + RepairWaveSelfBonusRARMP * _rarity,
			getSubtechName(systemname, 2), getSubtechName(systemname, 3), RepairWaveRange, RepairWaveOperationTime,
			RepairWaveCooldown - RepairWaveCooldownRARMP * _rarity),
		string.format(
			"%s\nConsumes %i%% energy per second and repairs the selected player-owned target, restoring %i hull points per second for each %i TJ of energy consumed (~%i points per second). Repair continues until the entire energy reserve is used up or the module is turned off manually. It is impossible to turn on the repair wave during operation, interrupts the operation of the shield booster.\nBeam working range: %i km.\nModule cooldown when changing targets: %i s." %
			_t, getSubtechName(systemname, 2), RenovatingRayEnergyConsumption, RenovatingRayHealingAmount,
			RenovatingRayEnergyUnit, CalculateRepairAmount(1), RenovatingRayRange + RenovatingRayRangeRARMP * _rarity,
			RenovatingRayCooldown),
		string.format(
			"%s\nConsumes %i%% of the energy per second and charges the player-owned target shield, restoring %i points per second for each consumed %i TJ of energy (~%i points per second). Charging continues until the entire energy reserve is used up or the module is turned off manually. It is impossible to turn on the repair wave during operation, interrupts the work of the renovation ray.\nThe module will not work if the target's shield drops below %i%%\nBeam working range: %i km.\nModule cooldown when changing targets: %i s." %
			_t, getSubtechName(systemname, 3), ShieldBoosterEnergyConsumption, ShieldBoosterHealingAmount,
			ShieldBoosterEnergyUnit, CalculateRepairAmount(2), ShieldBoosterValueTreshold,
			ShieldBoosterRange + ShieldBoosterRangeRARMP * _rarity, ShieldBoosterCooldown),
		string.format(
			"%s\nConnects the shields of your and the player-owned allied ship selected as the target. Tries to equalize the percentage of shields by siphoning %i%% of the shield per second from one ship to another. It can work in parallel with other modules of this system.\nThe range of the module: %i km.\nCooldown after changing the target: %i sec.\nThe module will not work if shields of one of the ships falls below %i%%" %
			_t, getSubtechName(systemname, 4), ShieldSynchronizerAmount, ShieldSynchronizerRange,
			ShieldSynchronizerCooldown,
			ShieldSynchronizerValueTreshold - ShieldSynchronizerValueTresholdRARMP * _rarity)
	}

	invokeServerFunction('executeDrawInterface', subSysDesc)
end

function executeDrawInterface(subSysDesc)
	local subsys = {}

	local subsys1 = {
		getSubtechName(systemname, 1), --Name
		getSubtechIcon(systemname, 1), --Icon
		subSysDesc[1],           --Desc
		'RepairWaveActivate',    --Command
	}
	local subsys2 = {
		getSubtechName(systemname, 2), --Name
		getSubtechIcon(systemname, 2), --Icon
		subSysDesc[2],           --Desc
		'RenovationRayActivate', --Command
	}
	local subsys3 = {
		getSubtechName(systemname, 3), --Name
		getSubtechIcon(systemname, 3), --Icon
		subSysDesc[3],           --Desc
		'ShieldBoosterActivate', --Command
	}
	local subsys4 = {
		getSubtechName(systemname, 4), --Name
		getSubtechIcon(systemname, 4), --Icon
		subSysDesc[4],           --Desc
		'ShieldSyncActivate',    --Command
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

--------------------------------------------------------------------------------------------
function onJumpDeactivate()
	DebugMsg('onJumpDeactivate')
	-- if RepairWaveIsWorking>0 then

	-- End
	if RepairWaveIsWorking > 0 then
		RepairWaveIsWorking = 0
		Entity():invokeFunction('raycast.lua', 'RemoveSphere', 'MPrw')
	end

	if RenovatingRayIsWorking then
		RenovatingRayIsWorking = false
		RenovatingRayTurnToFalse()
	end

	if ShieldBoosterIsWorking then
		ShieldBoosterIsWorking = false
		ShieldBoosterTurnToFalse()
	end

	if ShieldSynchronizerIsWorking then
		ShieldSynchronizerIsWorking = false
		ShieldSyncTurnToFalse()
	end
end

function onInstalled(seed, rarity, permanent)
	local _eRegen, _eValue = getBonuses(seed, rarity, permanent)
	--Assigns a global variable used to determine module quality
	_rarity = rarity.value
	--Adds passive bonuses upon installation
	addBaseMultiplier(StatsBonuses.GeneratedEnergy, _eRegen)
	if _debug then print(_eRegen * 100, "% Бонус регена") end
	addBaseMultiplier(StatsBonuses.EnergyCapacity, _eValue)
	if _debug then print(_eValue * 100, "% Бонус аккума") end

	--Initializing hooks
	if onServer() then
		Entity():registerCallback("onJump", "onJumpDeactivate")
		--Execute draw interface()
	end

	--Initializing Interface Elements
	if onClient() and not (BSwindow) then
		initializeUI()
		Player():registerCallback("onStateChanged", "UIshowhide")
		Player():registerCallback("onShipChanged", "UIshowhide")
		Player():registerCallback("onSectorChanged", "UIshowhide")
	end
end

function onUninstalled(seed, rarity, permanent)
	if onServer() then
		Entity():removeScriptBonuses()
		executeDelete()
	end
end

--Responsible for various related visuals (icons on the screen, glow, etc.)
function updateStatusEffects(_type, _status)
	--[[
	0 -repair wave work icon
	1 -update beam operation icon
	2 -refresh beam: out of radius
	3 -shield amplifier: work
	4 -shield booster: out of radius/low shield charge
	5 -shield synchronizer: work
	6 -shield synchronizer: out of radius/low shield charge
]]
	if _type == 0 then
		if _status then
			local _line = getSubtechName(systemname, 1) .. ' - ' .. getTechInfo('active')
			addShipProblem("RepairWave", Entity().id, _line, getSubtechIcon(systemname, 1), _colorG, false)
		else
			removeShipProblem("RepairWave", Entity().id)
		end
	end
	if _type == 1 then
		if _status then
			local _line = getSubtechName(systemname, 2) .. ' - ' .. getTechInfo('active')
			addShipProblem("RenovationRay", Entity().id, _line, getSubtechIcon(systemname, 2), ColorHSV(150, 64, 100),
				false)
		else
			removeShipProblem("RenovationRay", Entity().id)
		end
	end
	if _type == 2 then
		if _status then
			local _line = getSubtechName(systemname, 2) .. ' - ' .. getTechInfo('outofrange')
			addShipProblem("RenovationRayFailure", Entity().id, _line, getSubtechIcon(systemname, 2), _colorY, false)
		else
			removeShipProblem("RenovationRayFailure", Entity().id)
		end
	end
	if _type == 3 then
		if _status then
			local _line = getSubtechName(systemname, 3) .. ' - ' .. getTechInfo('active')
			addShipProblem("ShieldBooster", Entity().id, _line, getSubtechIcon(systemname, 3), _colorG, false)
		else
			removeShipProblem("ShieldBooster", Entity().id)
		end
	end
	if _type == 4 then
		if _status then
			local _line = getSubtechName(systemname, 3) .. ' - ' .. getTechInfo('outofrangeorshieldslow')
			addShipProblem("ShieldBoosterFailure", Entity().id, _line, getSubtechIcon(systemname, 3), _colorY, false)
		else
			removeShipProblem("ShieldBoosterFailure", Entity().id)
		end
	end
	if _type == 5 then
		if _status then
			local _line = getSubtechName(systemname, 4) .. ' - ' .. getTechInfo('active')
			addShipProblem("ShieldSync", Entity().id, _line, getSubtechIcon(systemname, 4), _colorG, false)
		else
			removeShipProblem("ShieldSync", Entity().id)
		end
	end
	if _type == 6 then
		if _status then
			local _line = getSubtechName(systemname, 4) .. ' - ' .. getTechInfo('outofrangeorshieldslow')
			addShipProblem("ShieldSyncFailure", Entity().id, _line, getSubtechIcon(systemname, 4), _colorY, false)
		else
			removeShipProblem("ShieldSyncFailure", Entity().id)
		end
	end
end

--Responsible for the progress bar, percentage and strip color
function updateUIbars(MaxCooldown, CurrentCooldown, index)
	if progressBars[index] == nil then return end
	progressBars[index].progress = 1 - CurrentCooldown / MaxCooldown
	if progressBars[index].progress == 1 then
		progressBars[index].color = _colorG
	else
		progressBars[index].color = _colorR
	end
end

--Responsible for the progressbar, percentage and color of the strip, fork for rays
function updateUIbarsToYellow(index)
	if progressBars[index] == nil then return end
	progressBars[index].color = _colorY
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

function getBonuses(seed, rarity, permanent)
	math.randomseed(seed)
	local _eRegen = (ModuleBonusEnergy + rarity.value * ModuleBonusEnergyRARMP) / 100
	local _eAmount = (ModuleBonusAccum + rarity.value * ModuleBonusAccumRARMP) / 100

	return _eRegen, _eAmount
end

function getName(seed, rarity)
	local _mk = rarity.value + 2
	return getTechName(systemname) .. " MP-" .. tostring(_mk)
end

function getIcon(seed, rarity)
	return getTechIcon(systemname)
end

function getPrice(seed, rarity)
	local _eRegen, _eValue = getBonuses(seed, rarity, permanent)
	local price = 300 * 50 * (_eRegen + rarity.value);
	return math.min((price * 2.0 ^ rarity.value) * 10, 15000)
end

function getEnergy(seed, rarity, permanent)
	local _cost = (rarity.value + 2) ^ 2 * (10 ^ 8 / 2) * 10
	return _cost
end

function getTooltipLines(seed, rarity, permanent)
	local texts = {}
	local bonuses = {}
	local _eRegen, _eValue = getBonuses(seed, rarity, permanent)

	--Bonuses
	table.insert(texts,
		{
			ltext = "Generated Energy" % _t,
			rtext = string.format("+%i%%", round(_eRegen * 100)),
			icon =
			"data/textures/icons/electric.png",
			boosted = permanent
		})
	table.insert(texts,
		{
			ltext = "Energy Capacity" % _t,
			rtext = string.format("+%i%%", round(_eValue * 100)),
			icon =
			"data/textures/icons/battery-pack-alt.png",
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
	local _eRegen, _eValue = getBonuses(seed, rarity, permanent)

	local base = {}
	local bonus = {}
	if _eRegen ~= 0 then
		table.insert(base,
			{
				name = "Generated Energy" % _t,
				key = "generated_energy",
				value = round(_eRegen * 100),
				comp =
					UpgradeComparison.MoreIsBetter
			})
	end

	if charge ~= 0 then
		table.insert(base,
			{
				name = "Recharge Rate" % _t,
				key = "recharge_rate",
				value = round(_eValue * 100),
				comp = UpgradeComparison
					.MoreIsBetter
			})
	end

	return base, bonus
end
