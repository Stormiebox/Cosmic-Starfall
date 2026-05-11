package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/neltharaku/?.lua"

include("callable")
include('Neltharaku')

-- namespace aC
aC = {}

--local _opByPlayer = false
local _initSystem = true

local locLines = {}
locLines['group_invite'] = "Invitation to a group" % _t
locLines['group_kick'] = "You were kicked from the group" % _t
locLines['weapon_turretdead'] = "Your turret is destroyed!" % _t

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
		print('alertCore|', _text)
	end
end

local Debug = aC.DebugMsg

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

----[window management]

function aC.getUpdateInterval()
	return 0.2
end

function aC.update(timeStep)
	if onClient() then
		for _index, _rows in pairs(_alertWindows) do
			--Variables for convenience
			local _alertWindow = _rows[1]
			local _alertInfo = _rows[4]
			local _alertLifetime = _rows[5]

			--Checking whether a window should be maximized or minimized
			if not (aC.alertSelfTest(_rows)) then return end

			if _alertWindow.mouseOver then
				if _alertWindow.width <= _alertWindow.height * 1.2 then
					Debug('ExpandAlert')
					Neltharaku.ExpandAlert(_rows)
				end
			else
				if _alertWindow.width > _alertWindow.height then
					Debug('ShrinkAlert')
					Debug(tostring(_alertWindow.width) .. '|' .. tostring(_alertWindow.height))
					Neltharaku.ShrinkAlert(_rows)
				end
			end

			--Reduced lifetime
			_rows[5] = _rows[5] - timeStep

			--Removing a window if required
			if _rows[5] < 1 then
				Debug('deleteAlert')
				aC.deleteAlert(_index)
			end
		end
	end
end

--Responsible for the display queue and alert lifetime
function aC.orderAlerts()
	local _res = getResolution()
	local _unit = _res.y * 0.07 / 4
	local _padding = _unit * 3.3
	local _startPosition = _res.y * 0.55
	--local _calcPadding = 0

	--Arrangement in order
	for _index, _row in pairs(_alertWindows) do
		local _alertWindow = _row[1]
		local _order = _row[6] - 1
		local _anchorPoint = vec2(_alertWindow.rect.topLeft.x, _startPosition - _padding * _order)
		local _expandedPoint = vec2(_alertWindow.rect.bottomRight.x, _anchorPoint.y + _unit * 3)
		local _alertRect = Rect(_anchorPoint, _expandedPoint)

		_alertWindow.rect = _alertRect
	end
end

--Updates the order of alerts when a new one is created. Called BEFORE creating a new alert
function aC.recalcOrder()
	for _index, _rows in pairs(_alertWindows) do
		_rows[6] = _rows[6] + 1
	end
end

--Removes the alert and updates the display order
function aC.deleteAlert(_index)
	--Saving the sequence number
	local _order = _alertWindows[_index][6]

	--Hiding and deleting an alert
	_alertWindows[_index][1]:hide()
	_alertWindows[_index] = nil

	--Processing sequence numbers
	for _, _row in pairs(_alertWindows) do
		if _row[6] > _order then
			_row[6] = _row[6] - 1
		end
	end

	--Update
	aC.orderAlerts()
end

----[turret dead]

function aC.entityTurretDestroyed()
	--Basic info
	local _alertName = 'entityTurretDestroyed'
	local _alertLifetime = 15

	--Check for duplicates
	if _alertWindows[_alertName] then
		Debug(_alertName .. ' error: already exists')
		return
	end

	--Generating Window and Information
	local alertWindow, alertBackground, alertIcon, alertInfo = Neltharaku.CreateAlertV2()
	alertBackground.picture = 'data/textures/icons/alert/AlertRed.png'
	alertIcon.picture = 'data/textures/icons/alert/AlertDeadTurret.png'
	alertInfo.text = locLines['weapon_turretdead']

	--Update the position of the remaining windows to reflect the new one
	aC.recalcOrder()

	--Write a window to a table
	_alertWindows[_alertName] = { alertWindow, alertBackground, alertIcon, alertInfo, _alertLifetime, 1 }

	--Displaying the window and setting the position
	alertWindow:show()
	aC.orderAlerts()

	--Sound
	play('failure')
end

----[main caliber weapon systems overload]

-- function aC.entityMCWSO()

-- --Basic info
-- local _alertName = 'MainCaliberWeaponSystemsOverload'
-- local _alertLifetime = 25

-- --Check for duplicates
-- if _alertWindows[_alertName] then
-- Debug(_alertName..' error: already exists')
-- return
-- end

-- --Window and information generation
-- local alertWindow,alertBackground,alertIcon,alertInfo = Neltharaku.CreateAlertV2(true)
-- alertBackground.picture = 'data/textures/icons/alert/AlertRed.png'

-- --Updating the position of the remaining windows taking into account the new one
-- aC.recalcOrder()

-- --Write a window to a table
-- _alertWindows[_alertName] = {alertWindow,alertBackground,alertIcon,alertInfo,_alertLifetime,1}

-- --Display window and set position
-- alertWindow:show()
-- aC.orderAlerts()

-- return alertIcon,alertInfo
-- end

----[group invite]

function aC.entityGroupInvite()
	--Basic info
	local _alertName = 'playerGroupInvite'
	local _alertLifetime = 15

	--Check for duplicates
	if _alertWindows[_alertName] then
		Debug(_alertName .. ' error: already exists')
		return
	end

	--Generating Window and Information
	local alertWindow, alertBackground, alertIcon, alertInfo = Neltharaku.CreateAlertV2(true)
	alertBackground.picture = 'data/textures/icons/alert/AlertGreen.png'
	alertIcon.picture = 'data/textures/icons/alert/AlertFederation.png'
	alertInfo.caption = locLines['group_invite']
	alertInfo.onPressedFunction = 'entityGroupInviteOperate'

	--Update the position of the remaining windows to reflect the new one
	aC.recalcOrder()

	--Write a window to a table
	_alertWindows[_alertName] = { alertWindow, alertBackground, alertIcon, alertInfo, _alertLifetime, 1 }

	--Displaying the window and setting the position
	alertWindow:show()
	aC.orderAlerts()

	--Sound
	play('invite')
end

function aC.entityGroupInviteOperate()
	Debug('entityGroupInviteOperate')
	local _index = 'playerGroupInvite'
	if onClient() then
		invokeServerFunction('entityGroupInviteOperate')
		aC.deleteAlert(_index)
	else
		Server():addChatCommand(Player(), '/join')
	end
end

callable(aC, 'entityGroupInviteOperate')

function aC.entityGroupInviteBroadcast(_name)
	if onServer() then
		broadcastInvokeClientFunction('entityGroupInviteBroadcast')
	else
		if Player().name == _name then
			aC.entityGroupInvite()
		end
	end
end

----[group kick]

function aC.playerGroupKick()
	--Basic info
	local _alertName = 'playerGroupKick'
	local _alertLifetime = 15

	--Check for duplicates
	if _alertWindows[_alertName] then
		Debug(_alertName .. ' error: already exists')
		return
	end

	--Generating Window and Information
	local alertWindow, alertBackground, alertIcon, alertInfo = Neltharaku.CreateAlertV2()
	alertBackground.picture = 'data/textures/icons/alert/AlertRed.png'
	alertIcon.picture = 'data/textures/icons/alert/AlertFederation.png'
	alertInfo.text = locLines['group_kick']

	--Update the position of the remaining windows to reflect the new one
	aC.recalcOrder()

	--Write a window to a table
	_alertWindows[_alertName] = { alertWindow, alertBackground, alertIcon, alertInfo, _alertLifetime, 1 }

	--Displaying the window and setting the position
	alertWindow:show()
	aC.orderAlerts()

	--Sound
	play('invite')
end

----[tech]
function aC.alertSelfTest(_table)
	local _result = true

	if not (_table[1]) then return false end
	if not (_table[2]) then return false end
	if not (_table[3]) then return false end
	if not (_table[4]) then return false end
	if not (_table[5]) then return false end
	if not (_table[6]) then return false end

	return true
end
