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
	--checkIfTorpedo
	if target.type == EntityType.Torpedo then
		local SC = Entity(Torpedo(target.index).shootingCraft)
		local torpedoTarget = Entity(TorpedoAI(target.index).target)
		if Owner(me):getRelationValue(Owner(SC).factionIndex) < -95000 or torpedoTarget.index == Entity().index then
			return true
		else
			return false
		end
	end

	--checkOthers
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

--Базовые величины активных фаз систем.
local VeilResistance = 25  --проценты, резист щита
local VeilRepair = 0.1     --проценты, максимальный объем щита, который переводится в ремонт корпуса в секунду
local VeilFireRate = 25    --проценты, падение скорострельности
local VeilCooldown = 60    --секунды, кд
local VeilCooldownR = 2    --секунды, снижение кд за уровень редкости

local RecupMaxValue = 25   --проценты, макс накопление в зависимости от щита
local RecupMaxValueR = 1   --проценты, бонус за уровень редкости
local RecupMultiplier = 40 --проценты, конверсия полученного урона в заряд
local RecupLength = 20     --секунды, время работы модуля
local RecupCooldown = 35   --секунды, откат


local MultiphaseLength = 30       --секунды, время действия
local MultiphaseLengthR = 1       --секунды, дополнительная длительность за уровень редкости
local MultiphaseCooldown = 60     --секунды, откат
local MultiphaseCooldownR = 1     -- секунды, снижение отката за уровень редкости
local MultiphaseChargeLength = 25 --секунды, время непрерывной зарядки после активации

local PulsarRange = 30            --километры, радиус работы модуля
local PulsarRangeR = 2            --километры, доп дальность за уровень редкости
local PulsarLength = 10           --секунды, длительность работы
local PulsarLengthR = 1           --секунды, дополнительная длительность за единицу редкости
local PulsarCooldown = 100        --секунды, откат
local PulsarTreshold = 10         --проценты, ограничение минимального объема щита для работы

--Автоматические переменные
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
	--print("Перманент выключен")
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
	--Сегмент "Завесы"
	local _player = Player(callingPlayer)
	if not (_player) then return end
	if VeilIsReady > 0 and not (VeilIsWorking) then
		VeilIsReady = math.max(0, VeilIsReady - timePassed) --непосредственно сокращение отката
		executeUpdateProgressbar(1, VeilIsReady / (VeilCooldown - VeilCooldownR * _rarity))
	end
	if VeilIsWorking then
		VeilOperate()
		executeUpdateProgressbar(1, 0, true)
	end
	--Сегмент рекуперации
	if RecupIsReady > 0 then
		RecupIsReady = math.max(0, RecupIsReady - timePassed) --непосредственно сокращение отката
		executeUpdateProgressbar(2, RecupIsReady / RecupCooldown)
	end
	if RecupIsWorking > 0 then
		RecupIsWorking = math.max(0, RecupIsWorking - timePassed)
		RecupOperate()
		invokeClientFunction(_player, "onFinishWork", RecupIsWorking, 1) --Ловит момент окончания работы модуля
	else
		--DebugMsg("Attempt to call updateUIrecup")
		local _value = Entity():getValue("RecupStoredAmount")
		if _value ~= nil then
			executeUpdateSecondary(2, _value / RecupMaximumAmount)
		end
	end
	--Сегмент мультифазника
	if MultiphaseIsReady > 0 then
		MultiphaseIsReady = math.max(0, MultiphaseIsReady - timePassed) --непосредственно сокращение отката
		executeUpdateProgressbar(3, MultiphaseIsReady / (MultiphaseCooldown - MultiphaseCooldownR * _rarity))
	end
	if MultiphaseIsWorking > 0 then
		MultiphaseIsWorking = math.max(0, MultiphaseIsWorking - timePassed)
		invokeClientFunction(_player, "onFinishWork", MultiphaseIsWorking, 2) --Ловит момент окончания работы модуля
		--Сбрасывает бонусы при окончании работы
		if MultiphaseIsWorking == 0 then
			MultiphaseOperateSetup()
			DebugMsg("Multiphase: trying to 'MultiphaseOperateSetup'")
		end
		--Обрабатывает отключение щита
		if Shield().durability == 0 then
			DebugMsg("serverUpdate_Multiphase: shields down, deactivating")
			MultiphaseIsWorking = 0
			MultiphaseOperateSetup()
		end
		--Обрабатывает отключение потоковой зарядки
		if MultiphaseIsWorking < ((MultiphaseLength + MultiphaseLengthR * _rarity) - MultiphaseChargeLength) then
			MultiphaseStreamingChargeSwitchOff()
		end
	end
	--Сегмент "Протокола"
	if PulsarIsReady > 0 then
		PulsarIsReady = math.max(0, PulsarIsReady - timePassed) --непосредственно сокращение отката
		executeUpdateProgressbar(4, PulsarIsReady / PulsarCooldown)
	end
	if PulsarIsWorking > 0 then
		PulsarIsWorking = math.max(0, PulsarIsWorking - timePassed)
		PulsarOperate()
		invokeClientFunction(_player, "onFinishWork", PulsarIsWorking, 3) --Ловит момент окончания работы модуля
	end
end

function updateStatusEffects(_type, _status)
	--0 - иконка работы завесы
	--1 - иконка работы рекуперации
	--2 - иконка работы многофазника
	--3 - иконка работы протокола
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
		--Создание сферки
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

		--Отсекание, если не сработала отрисовка сферы
		if _exitResult > 0 or _callResult > 0 then
			DebugMsg('VeilActivate eroro: setSphere failure')
			return
		end

		--Установка кулдауна
		VeilIsReady = VeilCooldown - VeilCooldownR * _rarity
		--Вычисление объема ремонта
		VeilRepairAmount = getVeilRepairAmount()
		--Установка флага работы
		VeilIsWorking = true
		--Создание иконки эффекта
		invokeClientFunction(Player(), "updateStatusEffects", 0, true)
		--Включение бонусов
		VeilOperateSetup()
		--Проигрывание звука
		invokeClientFunction(Player(), 'UIplaysound', 0)
		return
	else
		--Отсечка лишнего срабатывания во время кд
		if VeilIsReady == 0 then return end
		DebugMsg("Veil: deactivate")
		--Выключение модуля
		VeilTurnToFalse()
		--Откат бонусов
		VeilOperateSetup()
		return
	end
end

callable(nil, "VeilActivate")

function VeilOperateSetup()
	--Установка бонусов при активации
	if VeilIsWorking then
		--Установка показателя сопротивления
		if Shield().damageFactor ~= 1 then
			DebugMsg("Veil - damage factor is not 1 somehow")
		end
		Shield().damageFactor = 1 - VeilResistance * 0.01
		DebugMsg("Veil: current damage factor is " .. tostring(Shield().damageFactor))
		--Установка скорострельности
		Entity():addBaseMultiplier(StatsBonuses.FireRate, -VeilFireRate * 0.01)
		return
	end
	--Отмена бонусов при деактивации
	if not (VeilIsWorking) then
		--Резист щита
		Shield().damageFactor = Shield().damageFactor + VeilResistance * 0.01
		DebugMsg("Veil: current damage factor after cancel is " .. tostring(Shield().damageFactor))
		--Скорострельность
		Entity():addBaseMultiplier(StatsBonuses.FireRate, VeilFireRate * 0.01)
		return
	end
	return
end

function VeilOperate()
	--Отсечка багов
	if Entity() == nil or VeilRepairAmount <= 0 then return end
	--Отсключение при падении щита
	if not (Shield().isActive) or Shield().durability == 0 then
		VeilTurnToFalse()
		VeilOperateSetup()
		DebugMsg("Veil: shield offline, deactivating")
		return
	end
	--Ремонт корпуса при активном модуле
	if VeilIsWorking then
		Durability():healDamage(VeilRepairAmount, Entity().id)
		DebugMsg("Veil: ship repaired for " .. tostring(VeilRepairAmount))

		--Генерация ауры
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

		--Генерация ауры на дебафф
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
		--invokeClientFunction(Player(),"VeilGraphics")
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

		--Установка кулдауна
		RecupIsReady = RecupCooldown

		--Вычисление объема ремонта
		RecupHealAmount = Entity():getValue("RecupStoredAmount") / RecupLength
		DebugMsg("RecupHealAmount is " .. tostring(RecupHealAmount))

		--Установка флага работы
		RecupIsWorking = RecupLength

		--Создание иконки эффекта
		invokeClientFunction(Player(), "updateStatusEffects", 1, true)

		--Сброс накопленного заряда
		Entity():setValue("RecupStoredAmount", 0)
		executeUpdateSecondary(2, 0)

		--Обнуление прогрессбара состояния заряда
		invokeClientFunction(Player(), "updateUIrecup", 0, RecupMaximumAmount)
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Генерация ауры
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
	--Отсечка багов
	if Entity() == nil or RecupHealAmount <= 0 then return end
	--Отсключение при падении щита
	if not (Shield().isActive) or Shield().durability == 0 then
		DebugMsg("Recup: shield offline, cant work")
		RecupIsWorking = 0
		invokeClientFunction(Player(), "onFinishWork", RecupIsWorking, 1)
		return
	end
	--Ремонт щита
	if RecupIsWorking then
		Shield():healDamage(RecupHealAmount, Entity().id)
		DebugMsg("Recup: shield repaired for " .. tostring(RecupHealAmount))
	end
end

function RecupInitiation()
	if onClient() then return end
	DebugMsg("RecupInitiation!")
	Entity():registerCallback("onShieldDamaged", "RecupStoreCharge")
	--Проверка максимального объема
	if RecupMaximumAmount == 0 then
		RecupMaximumAmount = Shield().maximum * (RecupMaxValue + RecupMaxValueR * _rarity) * 0.01
		DebugMsg("Current capacitor amount is: " .. tostring(RecupMaximumAmount))
	end
	--Проверка наличия кастомки
	if Entity():getValue("RecupStoredAmount") == nil then
		Entity():setValue("RecupStoredAmount", 0)
	end
	--Установка заряда
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
		--Проверка наличия кастомки
		if Entity():getValue("RecupStoredAmount") == nil then
			Entity():setValue("RecupStoredAmount", 0)
		end
		--Проверка максимального объема
		if RecupMaximumAmount == 0 then
			RecupMaximumAmount = Shield().maximum * (RecupMaxValue + RecupMaxValueR * _rarity) * 0.01
			DebugMsg("Current capacitor amount is: " .. tostring(RecupMaximumAmount))
		end
		--Обновление значения запаса энергии
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

		--Создание сферки
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

		--Отсекание, если не сработала отрисовка сферы
		if _exitResult > 0 or _callResult > 0 then
			DebugMsg('VeilActivate eroro: setSphere failure')
			return
		end

		--Установка кулдауна
		MultiphaseIsReady = MultiphaseCooldown - MultiphaseCooldownR * _rarity
		--Установка флага работы
		MultiphaseIsWorking = MultiphaseLength + MultiphaseLengthR * _rarity
		--Создание иконки эффекта
		invokeClientFunction(Player(), "updateStatusEffects", 2, true)
		--Запуск бонусов
		MultiphaseOperateSetup()
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Генерация ауры (непробиваемость)
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

		--Генерация ауры (сокращение отката)
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
	--Установка бонусов при активации
	if MultiphaseIsWorking > 0 then
		DebugMsg("Multiphase: activate")
		--Установка непробиваемого щита
		MultiphaseAlreadyImp = Shield().impenetrable
		if MultiphaseAlreadyImp and _debug then
			DebugMsg("Multiphase - already impenetrable")
		end
		if not (MultiphaseAlreadyImp) then
			DebugMsg("Multiphase: set up imp status")
			Shield().impenetrable = true
		end
		--Установка времени перед откатом
		DebugMsg("MultiphaseOperateSetup| timeUntilRechargeAfterHit: " .. tostring(Shield().timeUntilRechargeAfterHit))

		Entity():setValue("BastionMultiphaseRestoreTimer", Shield().timeUntilRechargeAfterHit)

		local _reValue = (Shield().timeUntilRechargeAfterHit) * -1
		DebugMsg("MultiphaseOperateSetup| _reValue is " .. tostring(_reValue))
		Entity():addMultiplyableBias(StatsBonuses.ShieldTimeUntilRechargeAfterHit, _reValue)
		--Entity():addMultiplyableBias(StatsBonuses.ShieldTimeUntilRechargeAfterHit,2)
		DebugMsg("MultiphaseOperateSetup| afterTimeUntilRechargeAfterHit: " ..
		tostring(Shield().timeUntilRechargeAfterHit))

		return
	end
	--Отмена бонусов при деактивации
	if MultiphaseIsWorking == 0 then
		DebugMsg("Multiphase: deactivate")
		--Откат непробиваемого щита
		if not (MultiphaseAlreadyImp) and Shield().impenetrable then
			DebugMsg("Multiphase: set up imp status to false")
			Shield().impenetrable = false
		end
		--Сброс графики
		MultiphaseTurnToFalse()
		--invokeClientFunction(Player(),'UIplaysound',1)
		return
	end
	return
end

function MultiphaseTurnToFalse()
	if MultiphaseIsWorking > 0 then
		MultiphaseIsWorking = 0
	end
	--invokeClientFunction(Player(),"MultiphaseGraphics")
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

	--Отсечка активации, если щит ниже ограничения
	if Shield().durability < PulsarTreshold * 0.01 then
		invokeClientFunction(Player(), 'UIplaysound', 2)
		return
	end
	if PulsarIsReady == 0 then
		DebugMsg("PDS: activate")
		invokeClientFunction(Player(), 'UIplaysound', 0)
		--Установка кулдауна
		PulsarIsReady = PulsarCooldown
		--Установка флага работы
		PulsarIsWorking = PulsarLength + PulsarLengthR * _rarity
		--Создание иконки эффекта
		invokeClientFunction(Player(), "updateStatusEffects", 3, true)

		--Генерация ауры
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
		--Отсечка лишнего срабатывания во время кд
		invokeClientFunction(Player(), 'UIplaysound', 2)
		if PulsarIsReady == 0 then return end
	end
end

callable(nil, "PulsarActivate")

function PulsarOperate()
	--Выключение при низком заряде щита
	if Shield().durability < PulsarTreshold * 0.01 then
		DebugMsg('PulsarOperate: shields too low, deactivating!')
		PulsarIsWorking = 1
		invokeClientFunction(Player(), 'UIplaysound', 1)
		return
	end

	local PlayerCache = { Sector():getPlayers() }
	if #PlayerCache < 1 then return end -- Потенциально невозможно, но пусть будет.
	DebugMsg('PulsarOperate: #PlayerCache = ' .. tostring(#PlayerCache))
	--Выборка потенциальных целей
	local potentialTargets = { Sector():getEntitiesByType(EntityType.Torpedo) }
	if #potentialTargets < 1 then return end
	DebugMsg('PulsarOperate: #potentialTargets = ' .. tostring(#potentialTargets))

	local targets = {}
	--Определение позиций целей для передачи и ликвидация торпед
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
					DebugMsg('PulsarOperate: torpedo is too far away') end
			end
		end
	end
	--Отправка информации для отрисовки эффектов и инициализация отрисовки
	if #targets > 0 then
		for _, _player in pairs(PlayerCache) do
			--DebugMsg('PulsarClearLasersInit: remote call for player "'.._player.name..'": create laser')
			invokeClientFunction(_player, 'PulsarGraphics', Entity(), targets)
		end
	end
end

callable(nil, 'PulsarOperate')

--Отрисовка лазера
function PulsarGraphics(_entity, _targets)
	--Отсекание
	if _entity == nil or Entity() == nil or #_targets < 1 then
		DebugMsg('PulsarKillTorpedo: target or entity is nil or no targets')
		return
	end
	--Создание лазера
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
	--0 - рекуперация
	--1 - мультифазник
	--3 - протокол/пульсар
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
		_t, getSubtechName(systemname, 4), PulsarLength + PulsarLengthR * _rarity, PulsarRange + PulsarRangeR * _rarity,
			PulsarTreshold, PulsarCooldown)
	}

	invokeServerFunction('executeDrawInterface', subSysDesc)
end

function executeDrawInterface(subSysDesc)
	local subsys = {}

	local subsys1 = {
		getSubtechName(systemname, 1), --name
		getSubtechIcon(systemname, 1), --icon
		subSysDesc[1],          --desc
		'VeilActivate',         --command
	}
	local subsys2 = {
		getSubtechName(systemname, 2), --name
		getSubtechIcon(systemname, 2), --icon
		subSysDesc[2],          --desc
		'RecupActivate',        --command
	}
	local subsys3 = {
		getSubtechName(systemname, 3), --name
		getSubtechIcon(systemname, 3), --icon
		subSysDesc[3],          --desc
		'MultiphaseActivate',   --command
	}
	local subsys4 = {
		getSubtechName(systemname, 4), --name
		getSubtechIcon(systemname, 4), --icon
		subSysDesc[4],          --desc
		'PulsarActivate',       --command
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
	--Назначает глобальную переменную, используемую для определения качества модуля
	_rarity = rarity.value
	--Добавляет пассивные бонусы при установке
	addBaseMultiplier(StatsBonuses.ShieldRecharge, _regen / 100)
	addMultiplier(StatsBonuses.ShieldDurability, 1 - (_shield / 100))
	addBaseMultiplier(StatsBonuses.ShieldTimeUntilRechargeAfterHit, -(_timeFactor / 100))

	--Инициализация элементов интерфейса
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
	--Отсекание
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

	--Бонусы
	table.insert(texts,
		{ ltext = "Shield Durability" % _t, rtext = string.format('-%i%%', _shield), icon =
		"data/textures/icons/health-normal.png", boosted = permanent })
	table.insert(texts,
		{ ltext = "Shield Recharge Rate" % _t, rtext = string.format("+%i%%", _regen), icon =
		"data/textures/icons/shield-charge.png", boosted = permanent })
	table.insert(texts,
		{ ltext = "Time Until Recharge" % _t, rtext = string.format("-%i%%", _timeFactor), icon =
		"data/textures/icons/recharge-time.png", boosted = permanent })

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
	local base = {}
	local bonus = {}

	return base, bonus
end
