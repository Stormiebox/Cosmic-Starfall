package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/neltharaku/?.lua"

include("callable")
include('Neltharaku')

-- namespace aC
aC = {}

--local _opByPlayer = false
local _initSystem = true

local locLines = {}
	locLines['group_invite'] = "Invitation to a group"%_t
	locLines['group_kick'] = "You were kicked from the group"%_t
	locLines['weapon_turretdead'] = "Your turret is destroyed!"%_t

local _alertWindows = {}
--1 window
--2 background
--3 icon
--4 info
--5 lifetime
--6 order
--local _currentOrder = 0

local _debug = false
function aC.DebugMsg(_text)
	if _debug then
		print('alertCore|',_text)
	end
end
local Debug =  aC.DebugMsg

local soundLib = {}
soundLib['failure'] = '/systems/UI_alertFailure'
soundLib['invite'] = '/systems/UI_alertInvite'

function aC.playSound(_type)
	local sound = soundLib[_type]
	if sound then
		playSound(sound, SoundType.UI, 1.5)
	end
end
local play = aC.playSound

----------------------------------[windowManagement]-----------------------------

function aC.getUpdateInterval()
	return 0.2
end

function aC.update(timeStep)
	if onClient() then

		for _index,_rows in pairs(_alertWindows) do
		
			--Переменные для удобства
			local _alertWindow = _rows[1]
			local _alertInfo = _rows[4]
			local _alertLifetime = _rows[5]
				
			--Проверка необходимости разворачивать или сворачивать окно
			if not(aC.alertSelfTest(_rows)) then return end
			
			if _alertWindow.mouseOver then
				if _alertWindow.width <= _alertWindow.height*1.2 then
					Debug('ExpandAlert')
					Neltharaku.ExpandAlert(_rows)
				end
			else
				if _alertWindow.width > _alertWindow.height then
					Debug('ShrinkAlert')
					Debug(tostring(_alertWindow.width)..'|'..tostring(_alertWindow.height))
					Neltharaku.ShrinkAlert(_rows)
				end
			end
			
			--Уменьшение времени жизни
			_rows[5] = _rows[5] - timeStep
			
			--Удаление окна, если требуется
			if _rows[5]<1 then
				Debug('deleteAlert')
				aC.deleteAlert(_index)
			end
			
		end
	end
end

--Отвечает за очередь отображения и время жизни алертов
function aC.orderAlerts()
	local _res = getResolution()
	local _unit = _res.y * 0.07 / 4
	local _padding = _unit * 3.3
	local _startPosition = _res.y * 0.55
	--local _calcPadding = 0
	
	--Расстановка по порядку
	for _index,_row in pairs(_alertWindows) do
		local _alertWindow = _row[1]
		local _order = _row[6]-1
		local _anchorPoint = vec2(_alertWindow.rect.topLeft.x,_startPosition - _padding*_order)
		local _expandedPoint = vec2(_alertWindow.rect.bottomRight.x,_anchorPoint.y+_unit*3)
		local _alertRect = Rect(_anchorPoint,_expandedPoint)
		
		_alertWindow.rect = _alertRect
	end
end

--Обновляет порядок алертов при создании нового. Вызывается ДО создания нового алерта
function aC.recalcOrder()
	for _index,_rows in pairs(_alertWindows) do
		_rows[6] = _rows[6] + 1
	end
end

--Удаляет алерт и обновляет порядок отображения
function aC.deleteAlert(_index)

	--Сохранение порядкового номера
	local _order = _alertWindows[_index][6]
	
	--Скрытие и удаление алерта
	_alertWindows[_index][1]:hide()
	_alertWindows[_index] = nil
	
	--Обработка порядковых номеров
	for _,_row in pairs(_alertWindows) do
		if _row[6]>_order then
			_row[6] = _row[6] - 1
		end
	end
	
	--Обновление
	aC.orderAlerts()
end


----------------------------------[turretDead]----------------------------------

function aC.entityTurretDestroyed()

	--Базовая инфа
	local _alertName = 'entityTurretDestroyed'
	local _alertLifetime = 15
	
	--Проверка на дубликаты
	if _alertWindows[_alertName] then 
		Debug(_alertName..' error: already exists')
		return 
	end
	
	--Генерация окна и информации
	local alertWindow,alertBackground,alertIcon,alertInfo = Neltharaku.CreateAlertV2()
	alertBackground.picture = 'data/textures/icons/alert/AlertRed.png'
	alertIcon.picture = 'data/textures/icons/alert/AlertDeadTurret.png'
	alertInfo.text = locLines['weapon_turretdead']
	
	--Обновление позиции остальных окон с учетом нового
	aC.recalcOrder()
	
	--Запись окна в таблицу
	_alertWindows[_alertName] = {alertWindow,alertBackground,alertIcon,alertInfo,_alertLifetime,1}
	
	--Отображение окна и установка позиции
	alertWindow:show()
	aC.orderAlerts()
	
	--Звук
	play('failure')
end

----------------------------------[MainCaliberWeaponSystemsOverload]----------------------------------

-- function aC.entityMCWSO()

	-- --Базовая инфа
	-- local _alertName = 'MainCaliberWeaponSystemsOverload'
	-- local _alertLifetime = 25
	
	-- --Проверка на дубликаты
	-- if _alertWindows[_alertName] then 
		-- Debug(_alertName..' error: already exists')
		-- return 
	-- end
	
	-- --Генерация окна и информации
	-- local alertWindow,alertBackground,alertIcon,alertInfo = Neltharaku.CreateAlertV2(true)
	-- alertBackground.picture = 'data/textures/icons/alert/AlertRed.png'
	
	-- --Обновление позиции остальных окон с учетом нового
	-- aC.recalcOrder()
	
	-- --Запись окна в таблицу
	-- _alertWindows[_alertName] = {alertWindow,alertBackground,alertIcon,alertInfo,_alertLifetime,1}
	
	-- --Отображение окна и установка позиции
	-- alertWindow:show()
	-- aC.orderAlerts()
	
	-- return alertIcon,alertInfo
-- end

----------------------------------[groupInvite]----------------------------------

function aC.entityGroupInvite()

	--Базовая инфа
	local _alertName = 'playerGroupInvite'
	local _alertLifetime = 15
	
	--Проверка на дубликаты
	if _alertWindows[_alertName] then 
		Debug(_alertName..' error: already exists')
		return 
	end
	
	--Генерация окна и информации
	local alertWindow,alertBackground,alertIcon,alertInfo = Neltharaku.CreateAlertV2(true)
	alertBackground.picture = 'data/textures/icons/alert/AlertGreen.png'
	alertIcon.picture = 'data/textures/icons/alert/AlertFederation.png'
	alertInfo.caption = locLines['group_invite']
	alertInfo.onPressedFunction = 'entityGroupInviteOperate'
	
	--Обновление позиции остальных окон с учетом нового
	aC.recalcOrder()
	
	--Запись окна в таблицу
	_alertWindows[_alertName] = {alertWindow,alertBackground,alertIcon,alertInfo,_alertLifetime,1}
	
	--Отображение окна и установка позиции
	alertWindow:show()
	aC.orderAlerts()
	
	--Звук
	play('invite')
end

function aC.entityGroupInviteOperate()
	Debug('entityGroupInviteOperate')
	local _index = 'playerGroupInvite'
	if onClient() then
		invokeServerFunction('entityGroupInviteOperate')
		aC.deleteAlert(_index)
	else
		Server():addChatCommand(Player(),'/join')
	end
end
callable(aC,'entityGroupInviteOperate')

function aC.entityGroupInviteBroadcast(_name)
	if onServer() then
		broadcastInvokeClientFunction('entityGroupInviteBroadcast')
	else
		if Player().name == _name then
			aC.entityGroupInvite()
		end
	end
	
end

----------------------------------[groupKick]----------------------------------

function aC.playerGroupKick()

	--Базовая инфа
	local _alertName = 'playerGroupKick'
	local _alertLifetime = 15
	
	--Проверка на дубликаты
	if _alertWindows[_alertName] then 
		Debug(_alertName..' error: already exists')
		return 
	end
	
	--Генерация окна и информации
	local alertWindow,alertBackground,alertIcon,alertInfo = Neltharaku.CreateAlertV2()
	alertBackground.picture = 'data/textures/icons/alert/AlertRed.png'
	alertIcon.picture = 'data/textures/icons/alert/AlertFederation.png'
	alertInfo.text = locLines['group_kick']
	
	--Обновление позиции остальных окон с учетом нового
	aC.recalcOrder()
	
	--Запись окна в таблицу
	_alertWindows[_alertName] = {alertWindow,alertBackground,alertIcon,alertInfo,_alertLifetime,1}
	
	--Отображение окна и установка позиции
	alertWindow:show()
	aC.orderAlerts()
	
	--Звук
	play('invite')
end

----------------------------------[tech]----------------------------------
function aC.alertSelfTest(_table)
	local _result = true
	
	if not(_table[1]) then return false end
	if not(_table[2]) then return false end
	if not(_table[3]) then return false end
	if not(_table[4]) then return false end
	if not(_table[5]) then return false end
	if not(_table[6]) then return false end
	
	return true
end