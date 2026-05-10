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


--Базовые величины активных фаз систем. Используйте как конфиг, отдельный делать лень :)
ModuleBonusEnergy = 20                   --процент базового усиления регена энки
ModuleBonusAccum = 130                   --процент базового повышения запаса аккума
ModuleBonusEnergyRARMP = 4               --процент, бонус за единицу редкости (Редкость распределяется от -1 = серый до 5 = фиол)
ModuleBonusAccumRARMP = 15               --процент, бонус за единицу редкости

RepairWaveCooldown = 80                  --секунды, кд ремонтной волны
RepairWaveCooldownRARMP = 3              --секунды, снижение отката за единицу редкости
RepairWaveOperationTime = 8              --секунды, время работы волны
RepairWaveHealingAmount = 4000           --единицы корпуса, ремонтируемые за выбранный объем энергии
RepairWaveEnergyUnit = 1                 --тераджоули, выбранный объем энергии
RepairWaveSelfBonus = 30                 --проценты, бонусное восстановление по себе
RepairWaveSelfBonusRARMP = 2             --проценты, бонус к восстановлению за единицу редкости
RepairWaveEnergyConsumption = 5          --проценты, сжигаемая энергия аккума за секунду
RepairWaveRange = 28                     --километры, радиус работы волны

RenovatingRayCooldown = 15               --секунды, откат модуля
RenovatingRayHealingAmount = 6000        --единицы корпуса, ремонтируемые за выбранный объем энергии
RenovatingRayEnergyUnit = 1              --тераджоули, выбранный объем энергии
RenovatingRayEnergyConsumption = 1       --проценты, сжигаемая энергия аккума за секунду
RenovatingRayRange = 30                  --километры, радиус работы
RenovatingRayRangeRARMP = 2              --километры, доп радиус за единицу редкости
RenovatingRayCanUseOnSelf = false        --работает ли луч по себе

ShieldBoosterCooldown = 15               --секунды, откат модуля
ShieldBoosterHealingAmount = 13000       --единицы корпуса, ремонтируемые за выбранный объем энергии
ShieldBoosterEnergyUnit = 1              --тераджоули, выбранный объем энергии
ShieldBoosterEnergyConsumption = 1       --проценты, сжигаемая энергия аккума за секунду
ShieldBoosterRange = 30                  --километры, радиус работ
ShieldBoosterRangeRARMP = 2              --километры, доп радиус за единицу редкости
ShieldBoosterCanUseOnSelf = false        --работает ли луч по себе
ShieldBoosterValueTreshold = 10          --проценты, минимальный объем щита цели для возможности работы

ShieldSynchronizerCooldown = 5           --секунды, откат модуля
ShieldSynchronizerAmount = 1             --проценты, объем передачи щита
ShieldSynchronizerRange = 30             --километры, радиус действия модуля
ShieldSynchronizerValueTreshold = 10     --проценты, минимальный объем щита цели для возможности работы
ShieldSynchronizerValueTresholdRARMP = 1 --проценты, вычитаемые из ShieldSynchronizerValueTreshold за каждую единицу редкости

--Динамические величины, изменять вручную нельзя
local RepairWaveIsReady = 0                --статус готовности модуля, содержит оставшееся время перезарядки модуля
local RepairWaveIsWorking = 0              --статус активной фазы модуля, содержит оставшееся время работы модуля
local RepairWaveHealAmount = 0             --объем восполняемого корпуса за тик, автоматически вычисляется
local RepairWaveEnergyConsumptionCV = 0    --объем затрачиваемой энергии за тик, автоматически вычисляется
local RepairWaveEntities = {}              --результат сканирования на предмет возможных целей для ремонта

local RenovatingRayIsReady = 0             --статус готовности модуля, содержит оставшееся время перезарядки модуля
local RenovatingRayIsWorking = false       --статус активной фазы модуля
local RenovatingRayTarget = nil            --цель ремонтного луча
local RenovatingRayAmount = 0              --объем восполняемого корпуса за тик, автоматически вычисляется
local RenovatingRayEnergyConsumptionCV = 0 --объем затрачиваемой энергии за тик, автоматически вычисляется
local RenovatingRayInRange = false         --флаг контроля расстояния

local ShieldBoosterIsReady = 0             --статус готовности модуля, содержит оставшееся время перезарядки модуля
local ShieldBoosterIsWorking = false       --статус активной фазы модуля, содержит оставшееся время работы модуля
local ShieldBoosterTarget = nil            --цель усилителя щита
local ShieldBoosterHealAmount = 0          --объем восполняемого щита за тик, автоматически вычисляется
local ShieldBoosterEnergyConsumptionCV = 0 --объем затрачиваемой энергии за тик, автоматически вычисляется
local ShieldBoosterInRange = false         --флаг контроля расстояния

local ShieldSynchronizerIsReady = 0        --статус готовности модуля, содержит оставшееся время перезарядки модуля
local ShieldSynchronizerIsWorking = false  --статус активной фазы модуля, содержит оставшееся время работы модуля
local ShieldSynchronizerTarget = nil       --цель синхронизатора щитов
local ShieldSynchronizerHealAmount = 0     --объем восполняемого щита за тик, автоматически вычисляется
local ShieldSynchronizerPercent = 0        --средний процент щитов связанных кораблей, автоматически вычисляется
local ShieldSynchronizerInRange = false

--Переменные интерфейса
local progressBars = {}

--Переменные графики
local LaserRR = nil    --переменная ремонтного луча
local LaserSB = nil    --переменная усилителя щита
local LaserSS = nil    --переменная сихнронизатора
local RefrSphere = nil --сферка ремонтной волны

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
	--0 ремонтная волна
	--Обновляющий луч
	--Усилитель щита
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
		--Если свой щит больше, перекачивает 0.2%
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

--Отображает затраты энки
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
	if #PlayerCache < 1 then return end -- Потенциально невозможно, но пусть будет.
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
	--Durability(tgtId).durability = Durability(tgtId).durability - 100000
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
	--сегмент ремонтной волны
	if RepairWaveIsReady > 0 then
		RepairWaveIsReady = math.max(0, RepairWaveIsReady - timePassed) --непосредственно сокращение отката
		local progress = RepairWaveIsReady / RepairWaveCooldown
		executeUpdateProgressbar(1, progress)
	end
	if RepairWaveIsWorking > 0 then
		RepairWaveIsWorking = math.max(0, RepairWaveIsWorking - timePassed)
		RepairWaveOperate()
		invokeClientFunction(Player(), "onFinishWork", RepairWaveIsWorking, 0) --Ловит момент окончания работы модуля
	end
	--сегмент луча
	if RenovatingRayIsReady > 0 and RenovatingRayIsWorking == false then
		RenovatingRayIsReady = math.max(0, RenovatingRayIsReady - timePassed) --непосредственно сокращение отката
		local progress = RenovatingRayIsReady / RenovatingRayCooldown
		executeUpdateProgressbar(2, progress)
	end
	if RenovatingRayIsWorking then
		RenovationRayOperate()
		executeUpdateProgressbar(2, 0, true)
	end
	--сегмент усилителя
	if ShieldBoosterIsReady > 0 and ShieldBoosterIsWorking == false then
		ShieldBoosterIsReady = math.max(0, ShieldBoosterIsReady - timePassed) --непосредственно сокращение отката
		local progress = ShieldBoosterIsReady / ShieldBoosterCooldown
		executeUpdateProgressbar(3, progress)
	end
	if ShieldBoosterIsWorking then
		ShieldBoosterOperate()
		executeUpdateProgressbar(3, 0, true)
	end
	--сегмент синхронизатора
	if ShieldSynchronizerIsReady > 0 and ShieldSynchronizerIsWorking == false then
		ShieldSynchronizerIsReady = math.max(0, ShieldSynchronizerIsReady - timePassed) --сокращение отката
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

		--Типа-графика: установка значений и проверка на совпадения, отрисовка сферы
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

		--Отсекание, если не сработала отрисовка сферы
		if _exitResult > 0 or _callResult > 0 then
			DebugMsg('RepairWaveActivate eroro: setSphere failure')
			return
		end

		--Установка кулдауна
		RepairWaveIsReady = RepairWaveCooldown - RepairWaveCooldownRARMP * _rarity

		--Вычисление объема ремонта
		RepairWaveHealAmount = CalculateRepairAmount(0)

		--Вычисление расхода энергии
		RepairWaveEnergyConsumptionCV = EnergySystem().capacity * (RepairWaveEnergyConsumption * 0.01)

		--Установка времени работы
		RepairWaveIsWorking = RepairWaveOperationTime

		--Создание иконки эффекта
		invokeClientFunction(Player(), "updateStatusEffects", 0, true)

		--Выключение луча и усилителя, если они работают
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

		--Звук
		invokeClientFunction(Player(), 'UIplaysound', 0)
	else
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "RepairWaveActivate")

--Выключает графику
-- function RepairWaveDeactivate()

-- end

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

				--Аура
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
		--Выключает обновляющий луч
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
	--Реактивация для выключения работающего луча
	local _shipTGT = Entity().selectedObject
	local _shipSelf = Entity()
	local _range = RenovatingRayRange + RenovatingRayRangeRARMP * _rarity

	if RenovatingRayIsWorking then
		RenovatingRayTurnToFalse()
		return
	end

	--Активация луча
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
	--Проверка неактивности во время перезарядки
	if RenovatingRayIsWorking == false then return end

	--Проверка цели
	if not (valid(RenovatingRayTarget)) or RenovatingRayTarget.isShip == false then
		RenovatingRayTurnToFalse()
		DebugMsg("RenovatingRay: не могу найти цель (отсутствует или погибла)")
		return
	end

	--Проверка допустимой дистанции до цели
	RenovatingRayInRange = isInRangeV3(RenovatingRayTarget.translationf, Entity().translationf,
		RepairWaveRange + RenovatingRayRangeRARMP * _rarity)

	--Контроль состояние цели
	local repairNeeded = (Durability(RenovatingRayTarget.id).filledPercentage < 1)

	--Контроль иконок статуса
	if RenovatingRayInRange then
		invokeClientFunction(Player(), "updateStatusEffects", 1, true)
		invokeClientFunction(Player(), "updateStatusEffects", 2, false)
	else
		invokeClientFunction(Player(), "updateStatusEffects", 1, false)
		invokeClientFunction(Player(), "updateStatusEffects", 2, true)
	end

	--Восстановление корпуса
	if RenovatingRayInRange and repairNeeded then
		if EnergySystem().energy >= RenovatingRayEnergyConsumptionCV then
			SyncEnergyRemove(RenovatingRayEnergyConsumptionCV)
			Durability(RenovatingRayTarget.id):healDamage(RenovatingRayAmount, Entity().id)
			DebugMsg("Ship '" .. RenovatingRayTarget.name .. "' healed for " .. tostring(RenovatingRayAmount))

			--Аура
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
		--Сегмент выключения лазеров
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

	--Реактивация для выключения работающего луча
	if ShieldBoosterIsWorking then
		ShieldBoosterTurnToFalse()
		return
	end
	--Активация луча
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
		--invokeClientFunction(Player(),"ShieldBoosterRayGraphics",ShieldBoosterTarget)
		RenovatingRayTurnToFalse()
		--RenovationRayGraphics(RenovatingRayTarget)
		invokeClientFunction(Player(), 'UIplaysound', 0)
	else
		DebugMsg("ShieldBooster activation failure: on cooldown")
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "ShieldBoosterActivate")

function ShieldBoosterOperate()
	--Проверка неактивности во время перезарядки
	if ShieldBoosterIsWorking == false then return end

	--Проверка цели
	if ShieldBoosterTarget == nil or ShieldBoosterTarget.isShip == false or Shield(ShieldBoosterTarget.id).filledPercentage < 0.1 then
		ShieldBoosterTurnToFalse()
		DebugMsg("ShieldBooster: не могу найти цель (отсутствует или погибла)")
		return
	end

	--Проверка допустимой дистанции до цели
	ShieldBoosterInRange = isInRangeV3(ShieldBoosterTarget.translationf, Entity().translationf,
		ShieldBoosterRange + ShieldBoosterRangeRARMP * _rarity)

	--Контроль состояние цели
	local repairNeeded = (Shield(ShieldBoosterTarget.id).filledPercentage < 1)

	--Контроль иконок статуса
	if ShieldBoosterInRange then
		invokeClientFunction(Player(), "updateStatusEffects", 3, true)
		invokeClientFunction(Player(), "updateStatusEffects", 4, false)
		invokeClientFunction(Player(), "UniSetLaserWidth", 2, 2)
	else
		invokeClientFunction(Player(), "updateStatusEffects", 3, false)
		invokeClientFunction(Player(), "updateStatusEffects", 4, true)
		invokeClientFunction(Player(), "UniSetLaserWidth", 2, 0)
	end

	--Восстановление щита
	if ShieldBoosterInRange and repairNeeded then
		if EnergySystem().energy >= ShieldBoosterEnergyConsumptionCV then
			SyncEnergyRemove(ShieldBoosterEnergyConsumptionCV)
			Shield(ShieldBoosterTarget.id):healDamage(ShieldBoosterHealAmount, Entity().id)
			DebugMsg("Ship '" .. ShieldBoosterTarget.name .. "' healed for " .. tostring(ShieldBoosterHealAmount))
			DebugMsg("Percent is: " .. tostring(Shield(ShieldBoosterTarget.id).filledPercentage))

			--Аура
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
	--Реактивация для выключения работающего луча
	if ShieldSynchronizerIsWorking then
		ShieldSyncTurnToFalse()
		return
	end
	--Активация синхронизатора
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
	--Проверка неактивности во время перезарядки
	if ShieldSynchronizerIsWorking == false then return end
	--Проверка цели
	if not (valid(ShieldSynchronizerTarget)) then
		ShieldSyncTurnToFalse()
		return
	end

	if ShieldSynchronizerTarget == nil or ShieldSynchronizerTarget.isShip == false then
		ShieldSyncTurnToFalse()
		DebugMsg("ShieldSync: не могу найти цель (отсутствует или погибла)")
		return
	end
	--Проверка допустимой дистанции до цели
	ShieldSynchronizerInRange = isInRangeV3(ShieldSynchronizerTarget.translationf, Entity().translationf,
		ShieldBoosterRange + ShieldSynchronizerRange)
	--Контроль иконок статуса
	if ShieldSynchronizerInRange then
		invokeClientFunction(Player(), "updateStatusEffects", 5, true)
		invokeClientFunction(Player(), "updateStatusEffects", 6, false)
		invokeClientFunction(Player(), "UniSetLaserWidth", 2, 1)
	else
		invokeClientFunction(Player(), "updateStatusEffects", 5, false)
		invokeClientFunction(Player(), "updateStatusEffects", 6, true)
		invokeClientFunction(Player(), "UniSetLaserWidth", 2, 0)
	end

	--Восстановление щита
	if ShieldSynchronizerInRange then
		local _amount = CalculateRepairAmount(3)
		local _treshold = (ShieldSynchronizerValueTreshold - ShieldSynchronizerValueTresholdRARMP * _rarity) * 0.01
		local _myPercent = Shield().filledPercentage < _treshold
		local _otherPercent = Shield(ShieldSynchronizerTarget.id).filledPercentage < _treshold

		--Аура на цель
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

		--Аура на себя
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
		--Если возвращаемое значение положительно - щит перемещается от вас к цели, отрицательное - наоборот
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
			--print("Ремонтная сеть завершила активную фазу")
			UIplaysound(1)
		end
		if _type == 2 then
			--print("Усилитель щита завершил активную фазу")
			UIplaysound(1)
		end
		if _type == 3 then
			--print("Экстренный стабилизатор завершил фазу перегрузки")
			UIplaysound(1)
		end
		updateStatusEffects(_type, false)
		--print (Durability().filledPercentage)
		--Durability().invincibility = Durability().invincibility - 0.5
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
		_t, getSubtechName(systemname, 4), ShieldSynchronizerAmount, ShieldSynchronizerRange, ShieldSynchronizerCooldown,
			ShieldSynchronizerValueTreshold - ShieldSynchronizerValueTresholdRARMP * _rarity)
	}

	invokeServerFunction('executeDrawInterface', subSysDesc)
end

function executeDrawInterface(subSysDesc)
	local subsys = {}

	local subsys1 = {
		getSubtechName(systemname, 1), --name
		getSubtechIcon(systemname, 1), --icon
		subSysDesc[1],          --desc
		'RepairWaveActivate',   --command
	}
	local subsys2 = {
		getSubtechName(systemname, 2), --name
		getSubtechIcon(systemname, 2), --icon
		subSysDesc[2],          --desc
		'RenovationRayActivate', --command
	}
	local subsys3 = {
		getSubtechName(systemname, 3), --name
		getSubtechIcon(systemname, 3), --icon
		subSysDesc[3],          --desc
		'ShieldBoosterActivate', --command
	}
	local subsys4 = {
		getSubtechName(systemname, 4), --name
		getSubtechIcon(systemname, 4), --icon
		subSysDesc[4],          --desc
		'ShieldSyncActivate',   --command
	}
	table.insert(subsys, subsys1)
	table.insert(subsys, subsys2)
	table.insert(subsys, subsys3)
	table.insert(subsys, subsys4)

	local _table = {
		scriptname,        --systemScript
		getTechName(systemname), --systemName
		getTechIcon(systemname), --systemIcon
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

	-- end
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
	--Назначает глобальную переменную, используемую для определения качества модуля
	_rarity = rarity.value
	--Добавляет пассивные бонусы при установке
	addBaseMultiplier(StatsBonuses.GeneratedEnergy, _eRegen)
	if _debug then print(_eRegen * 100, "% Бонус регена") end
	addBaseMultiplier(StatsBonuses.EnergyCapacity, _eValue)
	if _debug then print(_eValue * 100, "% Бонус аккума") end

	--Инициализация хуков
	if onServer() then
		Entity():registerCallback("onJump", "onJumpDeactivate")
		--executeDrawInterface()
	end

	--Инициализация элементов интерфейса
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

--Отвечает за различный связанный визуал(иконки на экране, свечение и прочее)
function updateStatusEffects(_type, _status)
	--[[
	0 - иконка работы ремонтной волны
	1 - иконка работы обновляющего луча
	2 - обновляющий луч: вне радиуса
	3 - усилитель щита: работа
	4 - усилитель щита: вне радиуса/низкий заряд щита
	5 - синхронизатор щита: работа
	6 - синхронизатор щита: вне радиуса/низкий заряд щита
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

--Отвечает за прогрессбар, процент и цвет полоски
function updateUIbars(MaxCooldown, CurrentCooldown, index)
	if progressBars[index] == nil then return end
	progressBars[index].progress = 1 - CurrentCooldown / MaxCooldown
	if progressBars[index].progress == 1 then
		progressBars[index].color = _colorG
	else
		progressBars[index].color = _colorR
	end
end

--Отвечает за прогрессбар, процент и цвет полоски, вилка для лучей
function updateUIbarsToYellow(index)
	if progressBars[index] == nil then return end
	progressBars[index].color = _colorY
end

function UIplaysound(_type)
	--0 - activation
	--1 - deactivation
	--2 - error
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

	--Бонусы
	table.insert(texts,
		{ ltext = "Generated Energy" % _t, rtext = string.format("+%i%%", round(_eRegen * 100)), icon =
		"data/textures/icons/electric.png", boosted = permanent })
	table.insert(texts,
		{ ltext = "Energy Capacity" % _t, rtext = string.format("+%i%%", round(_eValue * 100)), icon =
		"data/textures/icons/battery-pack-alt.png", boosted = permanent })

	--Пустая строка
	table.insert(texts, { ltext = "" })

	--Абилки
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
			{ name = "Generated Energy" % _t, key = "generated_energy", value = round(_eRegen * 100), comp =
			UpgradeComparison.MoreIsBetter })
	end

	if charge ~= 0 then
		table.insert(base,
			{ name = "Recharge Rate" % _t, key = "recharge_rate", value = round(_eValue * 100), comp = UpgradeComparison
			.MoreIsBetter })
	end

	return base, bonus
end
