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
local TBGwindow
local updateSW = false
local systemname = 'pulsetractorbeamgenerator'
local scriptname = 'pulseTractorBeamGenerator'
local onlineFlag = true
--local isMultiplied = false

--Базовые величины активных фаз систем. Используйте как конфиг, отдельный делать лень :)
GeneratorMaxPulsesBase = 0   --единицы, базовое значение количества импульсов во время работы (изменяется в зависимости от качества модуля, если GeneratorPulsesPerRarity дефолт, то от +4 до +28)
GeneratorPulsesPerRarity = 4 --единицы, количество импульсов, добавляемых качеством модуля (для дефолт=4 самый плохой дает 4, белый - 8, зеленый - 12 и т.д.)
GeneratorRangePerPulse = 300 --единицы, расстояние, на которое увеличивается радиус притягивания за импульс, одна единица равна 10 метрам (дефолт - 200, т.е. 2км за импульс)
GeneratorCooldown = 240      --секунды, время перезарядки (дефолт - 240)

--Автоматические переменные
GeneratorIsWorking = 0     --Статус работы модуля, остаток времени работы
GeneratorIsReady = 0       --Статус перезарядки модуля, остаток времени перезарядки
GeneratorAllowedPulses = 0 --Общее высчитываемое максимальное количество импульсов
_rarity = 0                --Уровень модуля

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

local Debug = DebugMsg

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
end

--Заставляет основную функцию-обработчик (ниже) обращаться к серверу раз в две секунды для выполнения активных фаз
function getUpdateInterval()
	return 2
end

function update(timeStep)
	-- if onClient() and updateSW and TBGwindow then
	-- invokeServerFunction("UIsyncPosition",TBGwindow.position)
	-- end
end

--Основная функция-обработчик работы всех модулей, завязанная на API игры
function updateServer(timePassed)
	-- if not(onlineFlag) then
	-- Debug('onlineFlag: false for player '..Player(callingPlayer).name)
	-- onlineFlag = true
	-- executeDrawInterface()
	-- end

	local _ship = Entity()
	if GeneratorIsReady > 0 then
		GeneratorIsReady = math.max(0, GeneratorIsReady - timePassed)
		--invokeClientFunction(Player(),"updateUIbars",GeneratorCooldown,GeneratorIsReady,0)
		executeUpdateProgressbar(1, GeneratorIsReady / GeneratorCooldown)
	end
	if GeneratorIsWorking > 0 then
		local _cv = Entity():getValue("isPulseGenerator")

		GeneratorIsWorking = math.max(0, GeneratorIsWorking - timePassed)

		if _debug then print(GeneratorIsWorking, "- оставшееся время") end

		if GeneratorIsWorking > 0 then
			if _debug then
				print(_cv, "- значение, которое имеет _cv перед импульсом")
				print("Активная фаза updateServer")
			end
			_ship:setValue("isPulseGenerator", _cv + GeneratorRangePerPulse)
			_ship:addAbsoluteBias(StatsBonuses.LootCollectionRange, GeneratorRangePerPulse)
			if _debug then
				print(Entity():getValue("isPulseGenerator"), "_cv после импульса")
				print(Entity():getBoostedValue(StatsBonuses.LootCollectionRange, 0), "_ab")
				print("__________")
			end
		else
			Entity():removeScriptBonuses()
			--_cv = ReverseBonusRange(_cv)

			invokeClientFunction(Player(), "onFinishWork", GeneratorIsWorking, 0)
		end
	end
end

function pGeneratorActivate()
	local _cv = Entity():getValue("isPulseGenerator")
	local _ab = Entity():getBoostedValue(StatsBonuses.LootCollectionRange, 0)

	if GeneratorIsReady == 0 then
		if _debug then
			print(_ab, "- lootCollectionRange в начале вызова pGeneratorActivate")
			print(_cv, "_cv в начале работы pGeneratorActivate")
		end

		if _cv == nil then
			if _debug then print("_cv не обнаружен, принудительно установлен как 0") end
			Entity():setValue("isPulseGenerator", 0)
		end
		GeneratorIsReady = GeneratorCooldown                     --запускает откат
		GeneratorAllowedPulses = GeneratorMaxPulsesBase + GeneratorPulsesPerRarity * (_rarity + 2) +
			1                                                    --считает максимальное кол-во импульсов
		if _debug then print(GeneratorAllowedPulses, "- количество импульсов") end
		GeneratorIsWorking = GeneratorAllowedPulses *
		2                                                        --длительность зависит от количества импульсов

		invokeClientFunction(Player(), "updateStatusEffects", 0, true) --Включает иконку на верхней панели игрока
		invokeClientFunction(Player(), 'UIplaysound', 0)

		--Аура на себя
		local _aura = {
			getSubtechSignature(systemname, 1),
			0,
			GeneratorIsWorking,
			getTechAuraDesc('tractorrange'),
			'buff',
			Entity().name,
			Entity().name,
			getSubtechIcon(systemname, 1),
			false,
			true
		}
		callTechAuraSelf(_aura)
	else
		if _debug then print("Перезарядка не закончена! Осталось", GeneratorIsReady, "секунд") end
		invokeClientFunction(Player(), 'UIplaysound', 2)
	end
end

callable(nil, "pGeneratorActivate")

--Запускает основные функции активных эффектов в режиме "сервер", чтобы переменные корректно работали в updateServer
function pGeneratorActivateTransfer()
	invokeServerFunction("pGeneratorActivate", _rarity)
end

--Функция вызывается до onInstalled, поэтому здесь тоже нужно добавлять rarity.value для отображения корректного значения в описании модуля
function getBonuses(seed, rarity, permanent)
	math.randomseed(seed)

	local _bonus1 = 10 -- Влияют только на цену
	local _bonus2 = 10 -- Same

	return _bonus1, _bonus2
end

-- function onInstallCheck()

-- end

callable(nil, "onInstallCheck")

function onInstalled(seed, rarity, permanent)
	local _cv = Entity():getValue("isPulseGenerator")

	_rarity = rarity.value

	--Инициализация элементов интерфейса

	if onClient() and not (TBGwindow) then
		initializeUI()
		Player():registerCallback("onStateChanged", "UIshowhide")
		Player():registerCallback("onShipChanged", "UIshowhide")
		Player():registerCallback("onSectorChanged", "UIshowhide")
	else
		--executeDrawInterface()
	end
end

function onUninstalled(seed, rarity, permanent)
	if onServer() then
		Entity():removeScriptBonuses()
		executeDelete()
	end
end

function initializeUI()
	local subSysDesc = {
		string.format(
			"%s\nActivates a pulse generator that increases the range of the tractor beam by %i km every two seconds for the duration of its operation.\nRecharge %i seconds" %
			_t, getSubtechName(systemname, 1), GeneratorRangePerPulse * 0.01, GeneratorCooldown)
	}

	invokeServerFunction('executeDrawInterface', subSysDesc)
end

function executeDrawInterface(subSysDesc)
	-- local subSysDesc = {
	-- string.format("%s\nActivates a pulse generator that increases the range of the tractor beam by %i km every two seconds for the duration of its operation.\nRecharge %i seconds"%_t,getSubtechName(systemname,1),GeneratorRangePerPulse*0.01,GeneratorCooldown)
	-- }

	local subsys = {}

	local subsys1 = {
		getSubtechName(systemname, 1), --name
		getSubtechIcon(systemname, 1), --icon
		subSysDesc[1],           --desc
		'pGeneratorActivate',    --command
	}

	table.insert(subsys, subsys1)

	local _table = {
		scriptname,        --systemScript
		getTechName(systemname), --systemName
		getTechIcon(systemname), --systemIcon
		Entity().id,       --entityID
		subsys             --subsys
	}

	CosmicStarfallLib.invokeOwnerFunction(Entity(), 'activeSysInterface', 'executeDraw', _table)
	-- if Server():isOnline(Faction().index) then
	-- if invokeFactionFunction(Faction().index,false,'activeSysInterface','executeDraw',_table)==1 then
	-- onlineFlag = false
	-- end
	-- else
	-- onlineFlag = false
	-- end
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

--Отвечает за различный связанный визуал(иконки на экране, свечение и прочее)
function updateStatusEffects(_type, _status)
	--[[
	0 - иконка работы генератора
]]
	if _type == 0 then
		if _status then
			local _line = getSubtechName(systemname, 1) .. ' - ' .. getTechInfo('active')
			addShipProblem("pReactor", Entity().id, _line, getSubtechIcon(systemname, 1), ColorHSV(150, 64, 100), false)
		else
			removeShipProblem("pReactor", Entity().id)
		end
	end
end

--Цепляет ивент конца активной фазы модуля для одноразовых действий
-- 0 - импульсный генератор
function onFinishWork(_time, _type)
	if _time == 0 then
		if _type == 0 then
			updateStatusEffects(_type, false)
			UIplaysound(1)
		end
	else
		return
	end
end

function getName(seed, rarity)
	local _h, _r = getBonuses(seed, rarity, true)

	return getTechName(systemname) .. " Mk-" .. tostring(_rarity)
end

function getIcon(seed, rarity)
	return getTechIcon(systemname)
end

function getEnergy(seed, rarity, permanent)
	local _cost = (rarity.value + 2) ^ 2 * (10 ^ 8 / 4)
	return _cost
end

function getPrice(seed, rarity)
	local _h, _r = getBonuses(seed, rarity)
	local price = 120 * 500 * (_h + rarity.value);
	return price * 2 ^ rarity.value / 10
end

function getTooltipLines(seed, rarity, permanent)
	local _pulses = GeneratorMaxPulsesBase + GeneratorPulsesPerRarity * (rarity.value + 2)
	local _rangeMin = GeneratorRangePerPulse
	local _rangeMax = GeneratorRangePerPulse * _pulses

	if _debug then
		print(_pulses, "pulses")
		print(_rangeMin, "rangeMin")
		print(_rangeMax, "rangeMax")
	end

	local texts = {}
	local bonuses = {}

	table.insert(texts,
		{
			ltext = "Number of pulses" % _t,
			rtext = tostring(_pulses),
			icon = getSubtechIcon(systemname, 1),
			boosted =
				permanent
		})
	table.insert(texts,
		{
			ltext = "Range" % _t,
			rtext = (tostring(_rangeMin * 10) .. "-" .. tostring(_rangeMax * 10)),
			icon =
				getSubtechIcon(systemname, 1),
			boosted = permanent
		})

	--Пустая строка
	table.insert(texts, { ltext = "" })

	table.insert(texts, {
		ltext = getSubtechName(systemname, 1),
		icon = getSubtechIcon(systemname, 1),
		boosted =
			permanent
	})


	return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
	return
	{
		{ ltext = "An experimental reactor operating on the principle of a temporary increase of the effect" % _t, lcolor = ColorRGB(1, 0.5, 0.5) }
	}
end

function getComparableValues(seed, rarity) --Не понимаю, нафига это нужно
	local _h, _r = getBonuses(seed, rarity, permanent)

	local base = {}
	local bonus = {}

	return base, bonus
end
