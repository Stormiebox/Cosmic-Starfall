package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include("basesystem")
include("utility")
include("randomext")
include("tooltipmaker")
include("Tech")
include("cosmicstarfalllib")

--include('callable')

local _debug = false
local _prototype = true
local RDwindow
local updateSW = false
local systemname = 'repairdrones'
local scriptname = 'repairDrones'
--local isMultiplied = false

--Базовые величины активных фаз систем. Используйте как конфиг, отдельный делать лень :)
ModuleBonusDurability = 6         --проценты, бонус корпуса при установке (автоматически изменяется от -3 до +15 в зависимости от уровня модуля)

NanobotsCooldown = 300            --секунды, время отката (дефолт - 300)
NanobotsOperationTime = 20        -- секунды, время работы (дефолт - 20)
NanobotsHealingTreshhold = 50     --проценты, объем корпуса, выше которого не ремонтирует
NanobotsHealingAmount = 20        --проценты, объем ремонта корпуса за все время действия (дефолт - 20)
NanobotsCooldownPerWarp = 50      --секунды, сокращение перезарядки за варп

RepairnetworkCooldown = 250       --секунды, время отката
RepairnetworkOperationTime = 120  -- секунды, время работы
RepairnetworkHealingAmount = 30   --проценты, объем ремонта за все время действия
RepairnetworkCooldownPerWarp = 50 --секунды, сокращение перезарядки за варп

EmergencyCooldown = 800           --секунды, время отката
EmergencyOperationTime = 20       -- секунды, время работы режима готовности
EmergencyBoosterTime = 20         --секунды, время работы перегрузки ремонта
EmergencyBoosterAmount = 3        --единицы, во столько раз усиливается пассивная регенерация на время работы перегрузки ремонта
EmergencyActivationTreshhold = 5  --проценты, прочность корпуса, ниже которой срабатывает активация
EmergencyHealingAmount = 10       --проценты, объем мгновенного ремонта
EmergencyCooldownPerWarp = 0      --секунды, сокращение перезарядки за варп

--Величины пассивного эффекта систем
local PassiveRepairTreshhold = 10 --проценты. Объем корпуса, выше которого пассивный ремонт не работает (изменяется автоматически на значение от -2 до 10, в зависимости от уровня устанавливаемого модуля)
PassiveRepairAmount = 0.2         --проценты, объем ремонтируемого корпуса за секунду (дефолт - 0.2%)

--Динамические величины активных фаз систем. Изменение вручную повлечет поломки разной степени тяжести активных систем и всего модуля

local NanobotsIsReady = 0            --статус готовности модуля, содержит оставшееся время перезарядки модуля
local NanobotsIsWorking = 0          --статус активной фазы модуля, содержит оставшееся время работы модуля
local NanobotsHealingSpeed = 0       --автоматически вычисляемый объем ремонта за единицу времени

local RepairnetworkIsReady = 0       --статус готовности модуля
local RepairnetworkIsWorking = 0     --статус активной фазы модуля
local RepairnetworkHealingSpeed = 0  --автоматически вычисляемый объем ремонта за единицу времени

local EmergencyIsReady = 0           --статус готовности модуля
local EmergencyOverloadIsWorking = 0 --статус фазы перегрузки модуля
local EmergencyIsWorking = 0         --статус активной фазы модуля
local EmergencyHeal = 0              --автоматически вычисляемый объем ремонта

--Переменные интерфейса
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
	--0 - activation
	--1 - deactivation
	--2 - error
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
	--invokeClientFunction(Player(),'UIplaysound',2)
end

--Заставляет основную функцию-обработчик (ниже) обращаться к серверу раз в секунду для выполнения активных фаз
function getUpdateInterval()
	return 1
end

function update(timeStep)
	if onClient() and updateSW and RDwindow then
		invokeServerFunction("UIsyncPosition", RDwindow.position)
		if Entity().selectedObject then
			--DebugMsg(tostring(Entity().selectedObject.name))
		end
	end
end

--Основная функция-обработчик работы всех модулей, завязанная на API игры
function updateServer(timePassed)
	--сегмент пассивного эффекта
	if Durability().filledPercentage < (PassiveRepairTreshhold / 100) then
		Entity().durability = Entity().durability + (Durability().maximum / 100 * PassiveRepairAmount)
		--Аура на себя
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
	--сегмент наноботов
	if NanobotsIsReady > 0 then
		NanobotsIsReady = math.max(0, NanobotsIsReady - timePassed) --непосредственно сокращение отката
		executeUpdateProgressbar(1, NanobotsIsReady / NanobotsCooldown)
		--invokeClientFunction(Player(),"updateUIbars",NanobotsCooldown,NanobotsIsReady,0)
	end
	if NanobotsIsWorking > 0 then
		NanobotsIsWorking = NanobotsIsWorking - timePassed
		if Durability().filledPercentage < (NanobotsHealingTreshhold / 100) then --Не работает, если прочность корпуса выше капа
			Entity().durability = Entity().durability + NanobotsHealingSpeed
		end
		invokeClientFunction(Player(), "onFinishWork", NanobotsIsWorking, 0) --Ловит момент окончания работы модуля
	end
	--сегмент ремонтной сети
	if RepairnetworkIsReady > 0 then
		RepairnetworkIsReady = math.max(0, RepairnetworkIsReady - timePassed) --непосредственно сокращение отката
		executeUpdateProgressbar(2, RepairnetworkIsReady / RepairnetworkCooldown)
		--invokeClientFunction(Player(),"updateUIbars",RepairnetworkCooldown,RepairnetworkIsReady,1)
	end
	if RepairnetworkIsWorking > 0 then
		RepairnetworkIsWorking = RepairnetworkIsWorking - timePassed
		Entity().durability = Entity().durability + RepairnetworkHealingSpeed
		invokeClientFunction(Player(), "onFinishWork", RepairnetworkIsWorking, 1) --Ловит момент окончания работы модуля
	end
	--сегмент экстренного стабилизатора
	if EmergencyIsReady > 0 then
		EmergencyIsReady = math.max(0, EmergencyIsReady - timePassed) --непосредственно сокращение отката
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
	--подсегмент для перегрузки
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
		NanobotsIsReady = NanobotsCooldown                                                            --запускает откат
		NanobotsHealingSpeed = (Durability().maximum / 100 * NanobotsHealingAmount) /
		NanobotsOperationTime                                                                         --назначает объем ремонта за единицу времени (1 сек)
		NanobotsIsWorking =
		NanobotsOperationTime                                                                         --назначаем время работы, вместе с тем говорим обработчику, что модуль запущен
		invokeClientFunction(Player(), "updateStatusEffects", 0, true)                                --Включает иконку на верхней панели игрока
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Аура на себя
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

		--Аура на себя
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

		--Аура на себя
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

--включается при срабатывании экстренного стабилизатора в его активной фазе
function EmergencyOverloadActivate()
	EmergencyOverloadIsWorking = EmergencyBoosterTime
	PassiveRepairAmount = PassiveRepairAmount * EmergencyBoosterAmount
	invokeClientFunction(Player(), "updateStatusEffects", 3, true)
	invokeClientFunction(Player(), 'UIplaysound', 0)
	--Аура на себя
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
	--Сброс предыдущей ауры
	callTechAuraInterruptSelf(getSubtechSignature(systemname, 3))
end

--Запускает основные функции активных эффектов в режиме "сервер", чтобы переменные корректно работали в updateServer
function NanobotsActivateTransfer()
	invokeServerFunction("NanobotsActivate")
end

function RepairNetworkActivateTransfer()
	invokeServerFunction("RepairNetworkActivate")
end

function EmergencyActivateTransfer()
	invokeServerFunction("EmergencyActivate")
end

--Функция вызывается до onInstalled, поэтому здесь тоже нужно добавлять rarity.value для отображения корректного значения в описании модуля
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

	--изменяет лимит пассивно восстанавливаемого корпуса в зависимости от текущего уровня модуля (от -1 до +5)
	PassiveRepairTreshhold = PassiveRepairTreshhold + rarity.value * 2
	if _debug then print(PassiveRepairTreshhold, "% Лимит ремонта от качества") end

	--Изменяет бонус корпуса в зависимости от текущего уровня модуля (от -1 до +5)
	ModuleBonusDurability = ModuleBonusDurability + rarity.value * 3
	if _debug then print(ModuleBonusDurability, "% Бонус корпуса") end

	--Проверяет существование кастомной переменной на корабле и если ее нет - создает
	if _cv == nil then
		Entity():setValue("isRepairDrones", false)
		if _debug then print("isRepairDrones успешно создана") end
	end

	--Проверяет, нет ли подобного бонуса уже. Необходимо для того, чтобы при старте игры бонус не накладывался повторно (при старте игры функция onInstalled срабатывает автоматически для всех сущностей, где модуль уже установлен)
	if _cv == 0 or _cv == false then
		Entity():setValue("isRepairDrones", true)
		Durability().maxDurabilityFactor = (Durability().maxDurabilityFactor + ModuleBonusDurability / 100)
		if _debug then print("Корпус успешно увеличен при установке модуля") end
	end

	--Инициализация элементов интерфейса
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
		_t, getSubtechName(systemname, 3), EmergencyOperationTime, EmergencyActivationTreshhold, EmergencyHealingAmount,
			EmergencyBoosterTime, _emergencyPercent, EmergencyCooldown),
	}

	invokeServerFunction('executeDrawInterface', subSysDesc)
end

function executeDrawInterface(subSysDesc)
	local subsys = {}

	local subsys1 = {
		getSubtechName(systemname, 1), --name
		getSubtechIcon(systemname, 1), --icon
		subSysDesc[1],          --desc
		'NanobotsActivate',     --command
	}
	local subsys2 = {
		getSubtechName(systemname, 2), --name
		getSubtechIcon(systemname, 2), --icon
		subSysDesc[2],          --desc
		'RepairNetworkActivate', --command
	}
	local subsys3 = {
		getSubtechName(systemname, 3), --name
		getSubtechIcon(systemname, 3), --icon
		subSysDesc[3],          --desc
		'EmergencyActivate',    --command
	}

	table.insert(subsys, subsys1)
	table.insert(subsys, subsys2)
	table.insert(subsys, subsys3)


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
	--local selfIndex = Faction().index

	if not (_isStandby) then _isStandby = false end
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeUpdateProgress', _index,
		scriptname, entity, _progress, _isStandby)
end

function executeDelete()
	local entity = Entity().id
	CosmicStarfallLib.invokeOwnerFunctionIfOnline(Entity(), 'activeSysInterface', 'executeDelete', scriptname, entity)
end

--Отвечает за различный связанный визуал(иконки на экране, свечение и прочее)
function updateStatusEffects(_type, _status)
	--[[
	0 - иконка работы наноботов
	1 - иконка работы ремонтной сети
	2 - иконка активной фазы экстренного стабилизатора
	3 - иконка перегрузки ремонта экстренного стабилизатора
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

--Цепляет ивент конца активной фазы модуля для одноразовых действий для наноботов
-- 0 - наноботы
-- 1 - ремонтная сеть
-- 2 - экстренный ремонт
-- 3 - перегрузка ремонтных систем
function onFinishWork(_time, _type)
	if _time <= 0 then
		if _type == 0 then
			--print("Наноботы завершили активную фазу")
			updateStatusEffects(_type, false)
			UIplaysound(1)
		end
		if _type == 1 then
			--print("Ремонтная сеть завершила активную фазу")
			updateStatusEffects(_type, false)
			UIplaysound(1)
		end
		if _type == 2 then
			--print("Экстренный стабилизатор завершил активную фазу")
			updateStatusEffects(_type, false)
			UIplaysound(1)
		end
		if _type == 3 then
			--print("Экстренный стабилизатор завершил фазу перегрузки")
			updateStatusEffects(_type, false)
		end
		--print (Durability().filledPercentage)
		--Durability().invincibility = Durability().invincibility - 0.5
	else
		return
	end
end

function onHitReact() --Нужна для корректного завершения работы ремонтной сети при получении урона в корпус
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

	--Бонусы
	table.insert(texts,
		{ ltext = "Hull Durability" % _t, rtext = string.format("%+2i%%", round(_h)), icon =
		"data/textures/icons/staDurability.png", boosted = permanent })
	table.insert(texts,
		{ ltext = "Auto-repair treshold" % _t, rtext = string.format("%2i%%", round(_r)), icon =
		"data/textures/icons/staRepair.png", boosted = permanent })
	table.insert(texts,
		{ ltext = "Auto-repair value" % _t, rtext = string.format("%.1f%%", PassiveRepairAmount), icon =
		"data/textures/icons/staRepair.png", boosted = permanent })

	--Пустая строка
	table.insert(texts, { ltext = "" })

	--Абилки
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

function getComparableValues(seed, rarity) --Не понимаю, нафига это нужно
	local _h, _r = getBonuses(seed, rarity, permanent)

	local base = {}
	local bonus = {}
	-- if _h ~= 0 then
	-- table.insert(base, {name = "Дополнительная прочность корпуса"%_t, key = "addhull_relative", value = round(_h * 100), comp = UpgradeComparison.MoreIsBetter})
	-- table.insert(base, {name = "Лимит автоматического ремонта"%_t, key = "autorepairTreshhold_relative", value = round(_r * 100), comp = UpgradeComparison.MoreIsBetter})
	-- table.insert(base, {name = "Скорость автоматического ремонта"%_t, key = "autorepair_relative", value = PassiveRepairAmount, comp = UpgradeComparison.MoreIsBetter})
	-- end

	return base, bonus
end
