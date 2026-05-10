package.path = package.path .. ";data/scripts/complexCraft/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include ("basesystem")
include ("utility")
include ("randomext")
include ("tooltipmaker")


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
local soundPath = '/systems/'

local buttonCooldown = 5

local testTable = {}

--Переменные интерфейса
local progressBars = {}

--Переменные графики
local LaserRR = nil --переменная ремонтного луча
local LaserSB = nil --переменная усилителя щита
local LaserSS = nil --переменная сихнронизатора
local RefrSphere = nil --сферка ремонтной волны

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
Unique = true

function isInRangeV3(v1,v2,range)
	local modRange = (range*100)*(range*100)
	local calcDist2 = distance2(v1,v2) * 0.85
	if calcDist2 <= modRange and calcDist2>0 then
		return true
	else
		return false
	end
	
	--DebugMsg("Range for 'isInRange' = "..tostring(calcDist)..", when range sqrt is "..tostring(calcDist2))
end

function DebugMsg(_text)
	if _debug then
		print('overpoweredCore('..Entity().name..')| ',_text)
	end
end
--------------------------------------------------------------------------------------------

function getUpdateInterval()
	if onClient() then
		return 1
	else
		return 1
	end
end

function update(timeStep)

end

function updateServer(timePassed)

end

function ApplyDebug()
	if onClient() then
		invokeServerFunction('ApplyDebug')
	else
		Entity():addScript("lib/entitydbg.lua")
		DebugMsg('ApplyDebug')
	end
end
callable(nil,'ApplyDebug')

function ApplyOCC()
	if onClient() then
			invokeServerFunction('ApplyOCC')
	else
		Entity():addScript("complexCraft/OCnode.lua")
		DebugMsg('ApplyOCC')
	end
end
callable(nil,'ApplyOCC')
--------------------------------------------------------------------------------------------

function initializeUI()
	if Owner(Entity()).name ~= Player().name then return end
	DebugMsg('UI initialization')
	local resolution = getResolution()
	local windowPoint = vec2(resolution.x * 0.6, resolution.y * 0.7)
	
	local button1 = Rect(5,5,35,35)
	local button2 = Rect(40,5,70,35)
	local button3 = Rect(75,5,105,35)
	--local button4 = Rect(110,5,140,35)
	
	local bar1 = Rect(5,37,35,40)
	--local bar2 = Rect(40,37,70,40)
	--local bar3 = Rect(75,37,105,40)
	--local bar4 = Rect(110,37,140,40)

	if _prototype then
		local rUnit = resolution.x / 10 * 0.7
		local rHeightMain = 0.409 * rUnit
		local uSpacing = 0.045 * rUnit
		local uButton = 0.273 * rUnit
		local uBar = uButton * 0.1
		local uBarSpacing = 0.336 * rUnit
		
		button1 = Rect(uSpacing,uSpacing,uSpacing+uButton,uSpacing+uButton)
		button2 = Rect(uSpacing*2+uButton,uSpacing,uSpacing*2+uButton*2,uSpacing+uButton)
		button3 = Rect(uSpacing*3+uButton*2,uSpacing,uSpacing*3+uButton*3,uSpacing+uButton)
		--button4 = Rect(uSpacing*4+uButton*3,uSpacing,uSpacing*4+uButton*4,uSpacing+uButton)
		
		--bar1 = Rect(uSpacing,uBarSpacing,uSpacing+uButton,uBarSpacing+uBar)
		--bar2 = Rect(uSpacing*2+uButton,uBarSpacing,uSpacing*2+uButton*2,uBarSpacing+uBar)
		--bar3 = Rect(uSpacing*3+uButton*2,uBarSpacing,uSpacing*3+uButton*3,uBarSpacing+uBar)
		--bar4 = Rect(uSpacing*4+uButton*3,uBarSpacing,uSpacing*4+uButton*4,uBarSpacing+uBar)
		
		BSwindow = Hud():createWindow(Rect(windowPoint, windowPoint+vec2(rUnit, rHeightMain)))
	else
		BSwindow = Hud():createWindow(Rect(windowPoint, windowPoint+vec2(145, 45)))
	end

	BSwindow.showCloseButton = false
	BSwindow.moveable = true
	BSwindow.transparency = 100
	
	btnModule01 = BSwindow:createRoundButton(button1, "data/textures/icons/GRAVITON.png", "ApplyDebug")
		btnModule01.tooltip = "Установить скрипт дебага"
	btnModule02 = BSwindow:createRoundButton(button2, "data/textures/icons/GRAVITON.png", "ApplyOCC")
		btnModule02.tooltip = 'Добавить скрипт "OCCore"'
	-- btnModule03 = BSwindow:createRoundButton(button3, "data/textures/icons/GRAVITON.png", "RestoreTable")
		-- btnModule03.tooltip = "Проверить таблицу"
	
	-- progressBars[0] = BSwindow:createProgressBar (bar1,ColorHSV(150, 64, 100))
		-- progressBars[0].progress = 1
	-- progressBars[1] = BSwindow:createProgressBar (bar2,ColorHSV(150, 64, 100))
		-- progressBars[1].progress = 1
	-- progressBars[2] = BSwindow:createProgressBar (bar3,ColorHSV(150, 64, 100))
		-- progressBars[2].progress = 1
	-- progressBars[3] = BSwindow:createProgressBar (bar4,ColorHSV(150, 64, 100))
		-- progressBars[3].progress = 1
		
	invokeServerFunction("UIretrievePosition")
	
	UIshowhide()
end

function UIsyncPosition(_position)
	Entity():setValue("oCsysUIposX",_position.x)
	Entity():setValue("oCsysUIposY",_position.y)
end
callable(nil,"UIsyncPosition")

function UIretrievePosition(_position)
	if onServer() then
		local retrPosition = vec2(Entity():getValue("oCsysUIposX"),Entity():getValue("oCsysUIposY"))
		DebugMsg(tostring(retrPosition).." - retrPos")
		if retrPosition ~= vec2(0,0) then
			invokeClientFunction(Player(),'UIretrievePosition',retrPosition)
		end
	else
		if _position ~= nil then
			if _position.x>(getResolution().x*0.97) then
				_position.x = getResolution().x*0.5
				DebugMsg("Wrong x position for oC: x>"..tostring(getResolution().x*0.97))
			end
			if _position.y>(getResolution().y*0.97) then
				_position.y = getResolution().y*0.7
				DebugMsg("Wrong y position for oC: y>"..tostring(getResolution().y*0.97))
			end
			BSwindow.position = _position
			DebugMsg("position retrieved")
		end
	end
end
callable(nil,'UIretrievePosition')

function UIshowhide()
	if onServer() then return end
	if not(BSwindow) then return end
	
	local player = Player(callingPlayer)
	
	if (Entity().index == player.craftIndex) and (Owner(Entity().id).name == player.name) then
		BSwindow:show()
		updateSW = true
	else
		BSwindow:hide()
		updateSW = false
	end
end

--------------------------------------------------------------------------------------------

function onInstalled(seed, rarity, permanent)
	local _eRegen,_eValue = getBonuses(seed, rarity, permanent)
	--Назначает глобальную переменную, используемую для определения качества модуля
	_rarity = rarity.value
	--Добавляет пассивные бонусы при установке
	addBaseMultiplier(StatsBonuses.GeneratedEnergy, _eRegen)
	--if _debug then print (_eRegen*100,"% Бонус регена") end
	addBaseMultiplier(StatsBonuses.EnergyCapacity, _eValue)
	--if _debug then print (_eValue*100,"% Бонус аккума") end
	
	
	--Инициализация элементов интерфейса
	Player():registerCallback("onStateChanged", "UIshowhide")
    Player():registerCallback("onShipChanged", "UIshowhide")
	Player():registerCallback("onSectorChanged", "UIshowhide")
	if onClient() and not(BSwindow) then
		initializeUI()
	end
end

function onUninstalled(seed, rarity, permanent)
	if onServer() then
		Entity():setValue("oCsysUIposX",getResolution.x * 0.5)
		Entity():setValue("oCsysUIposY",getResolution.y * 0.4)
	end
end
-- function secure()
	-- local savedTable = {}
	-- return {savedTable = testTable}
-- end

-- function restore(values)
	-- if values.savedTable then
		-- DebugMsg('restore attempt')
		-- testTable = values.savedTable
	-- end
-- end

function UIplaysound(_type)
	--0 - activation
	--1 - deactivation
	--2 - error
	if _type == 0 then
		playSound(soundPath.."UI_Activation", SoundType.UI, 1.5)
		return
	end
	if _type == 1 then
		playSound(soundPath.."UI_Deactivation", SoundType.UI, 2)
		return
	end
	if _type == 2 then
		playSound(soundPath.."UI_Incorrect", SoundType.UI, 1.5)
		return
	end
	return
end
---------------------------------------------------------------------
function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)
    local _eRegen = 0.07
    local _eAmount = 0.07
	
    return _eRegen, _eAmount
end

function getName(seed, rarity)
    local _mk = rarity.value + 2
    return "Перегруженное квантовое ядро MP-"..tostring(_mk)
end

function getIcon(seed, rarity)
    return "data/textures/icons/SUBSYSmacroPulsar.png"
end

function getPrice(seed, rarity)
    local _eRegen,_eValue = getBonuses(seed, rarity, permanent)
    local price = 300 * 50 * (_eRegen+rarity.value);
    return (price * 2.0 ^ rarity.value)*10
end

function getEnergy(seed, rarity, permanent)
	local _cost = (rarity.value + 2)^2*(10^8 / 2) * 10
    return _cost
end

function getTooltipLines(seed, rarity, permanent)

    local texts = {}
    local bonuses = {}
    local _eRegen,_eValue = getBonuses(seed, rarity, permanent)

    table.insert(texts, {ltext = "Генерация энергии"%_t, rtext = string.format("%+2i%%", round(_eRegen*100)), icon = "data/textures/icons/electric.png", boosted = permanent})
	table.insert(texts, {ltext = "Объем аккумулятора"%_t, rtext = string.format("%+2i%%", round(_eValue*100)), icon = "data/textures/icons/battery-pack-alt.png", boosted = permanent})
		
	table.insert(texts, {ltext = "Ремонтная волна"%_t, rtext = "Да", rcolor = ColorRGB(0.3, 1.0, 0.3), icon = "data/textures/icons/SUBSYSrepairwave.png", boosted = permanent})
	table.insert(texts, {ltext = "Обновляющий луч"%_t, rtext = "Да", rcolor = ColorRGB(0.3, 1.0, 0.3), icon = "data/textures/icons/SUBSYSrenovationray.png", boosted = permanent})
	table.insert(texts, {ltext = "Усилитель щита"%_t, rtext = "Да", rcolor = ColorRGB(0.3, 1.0, 0.3), icon = "data/textures/icons/SUBSYSshieldbooster.png", boosted = permanent})
	table.insert(texts, {ltext = "Синхронизатор щитов"%_t, rtext = "Да", rcolor = ColorRGB(0.3, 1.0, 0.3), icon = "data/textures/icons/SUBSYSshieldsynchronizer.png", boosted = permanent})
    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        {ltext = "Never ask a wyvern: 'why'"%_t, lcolor = ColorRGB(1, 0.5, 0.5)}
    }
end

function getComparableValues(seed, rarity)
    local _eRegen,_eValue = getBonuses(seed, rarity, permanent)

    local base = {}
    local bonus = {}
    if _eRegen ~= 0 then
        table.insert(base, {name = "Generated Energy"%_t, key = "generated_energy", value = round(_eRegen * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    if charge ~= 0 then
        table.insert(base, {name = "Recharge Rate"%_t, key = "recharge_rate", value = round(_eValue * 100), comp = UpgradeComparison.MoreIsBetter})
    end

    return base, bonus
end