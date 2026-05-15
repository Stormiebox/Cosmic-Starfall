package.path = package.path .. ";data/scripts/lib/?.lua"

--namespace Neltharaku
Neltharaku = {}

local _debug = false
local _defaultBackground = 'data/textures/icons/alert/AlertGreen.png'
local _defaultIcon = 'data/textures/icons/alert/AlertFederation.png'

_colorG = ColorHSV(150, 64, 100)
_colorY = ColorHSV(60, 94, 78)
_colorR = ColorHSV(16, 97, 84)
_colorB = ColorHSV(240, 40, 100)
_colorC = ColorHSV(264, 60, 100)

--------------------------------------------------------------------------------------------

function Neltharaku.DebugMsg(_text)
	if _debug then
		print('Neltharaku lib|', _text)
	end
end

local Debug = Neltharaku.DebugMsg
local _iconSubmit = 'data/textures/icons/submit.png'
local _iconCancel = 'data/textures/icons/cancel.png'

function Neltharaku.TableSelfReport(_table, _name)
	--if _debug then
	local _headline = 'TableSelfReport: called]------------------------------------'
	if _name then
		_headline = 'TableSelfReport(' .. _name .. '): called]------------------------------------'
	end
	print(_headline)
	Neltharaku.TSRbase(_table)
	print('TableSelfReport: EndOfBaseLevel]----------------------------')
	Neltharaku.TSRre(_table)
	print('TableSelfReport: finish]------------------------------------')
	--End
end

function Neltharaku.TSRre(_value, _level)
	if _level == nil then _level = 0 end
	local _lines = '---(' .. tostring(_level) .. ')---'
	for i = 0, _level do
		_lines = _lines .. '------'
	end
	if type(_value) == 'table' then
		print('TSRre: ' .. _lines)
		for _index, _row in pairs(_value) do
			Neltharaku.TSRre(_row, _level + 1)
		end
		print('TSRre: ' .. _lines)
	else
		if _value ~= nil then
			print(type(_value), '|', _value)
		else
			print('Empty')
		end
	end
end

function Neltharaku.TSRbase(_value)
	if type(_value) == 'table' then
		for _index, _row in pairs(_value) do
			local _text = 'TSRre:position ' .. tostring(_index) .. ' - '
			if type(_row) == 'table' then
				_text = _text .. 'table(' .. tostring(#_row) .. ')'
				print(_text)
			else
				text = _text .. 'non-table|'
				print(_text, _row)
			end
		end
	else
		print('TSRre: this isnt a table')
	end
end

function Neltharaku.ReportRect(rect, text)
	local str = '----[Rect report]----'
	if text then str = '----[Rect report(' .. text .. ')]----' end
	print(str)

	if rect then
		local TL = rect.topLeft
		local BR = rect.bottomRight
		local TLX = tostring(round(TL.x, 3))
		local TLY = tostring(round(TL.y, 3))
		local BRX = tostring(round(BR.x, 3))
		local BRY = tostring(round(BR.y, 3))
		print('TL: ' .. TLX .. '|' .. TLY)
		print('BR: ' .. BRX .. '|' .. BRY)
	else
		print('FAILURE: rect is nil')
	end

	print('----[Finished]----')
end

function Neltharaku.ReportVec2(vec)
	print('----[Vec2 report]----')

	if vec then
		print('Result: ' .. tostring(vec.x) .. '|' .. tostring(vec.y))
	else
		print('FAILURE: vec2 is nil')
	end

	print('----[Finished]----')
end

local Debug = Neltharaku.DebugMsg
local TSR = Neltharaku.TableSelfReport

function Neltharaku.convertToIconPath(_name)
	return 'data/textures/icons/' .. _name .. '.png'
end

------------------------------------------[Windows]----------------------------------------------------------------
--Creates a standard window
function Neltharaku.CreateStandardWindow(_name, _unit, _widthMult, _heightMult)
	local res = getResolution()
	local frameV2 = vec2(_unit * _widthMult, _unit * _heightMult)
	local size = vec2(frameV2.x + _unit, frameV2.y + _unit * 3)
	local _window = ScriptUI():createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
	_window.caption = _name
	_window.showCloseButton = true
	_window.moveable = true

	local _frameRect = Rect(vec2(_unit / 2, _unit / 2), _window.size - _unit * 0.5)
	local _frame = _window:createScrollFrame(_frameRect)

	return _window, _frame
end

--Creates a standard window on the Hud layer
function Neltharaku.CreateHudWindow(_name, _unit, _widthMult, _heightMult)
	local res = getResolution()
	local frameV2 = vec2(_unit * _widthMult, _unit * _heightMult)
	local size = vec2(frameV2.x + _unit, frameV2.y + _unit * 3)
	local _window = Hud():createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
	_window.caption = _name
	_window.showCloseButton = true
	_window.moveable = true

	local _frameRect = Rect(vec2(_unit / 2, _unit / 2), _window.size - _unit * 0.5)
	local _frame = _window:createScrollFrame(_frameRect)

	return _window, _frame
end

--Creates an updated alert window in the LEFT corner of the screen
function Neltharaku.CreateAlertV2(_isActive)
	--Basic Variables
	local res = getResolution()
	local _unit = res.y * 0.07 / 4
	local _shrinkMod = 0.3 --Squeezing the main button square

	--Alert Position Calculation
	local _size = _unit * 3
	local _alertAnchor = vec2(res.x - _size * 1.2, res.y * 0.5 - _size)
	--Debug('==========[ANCHOR X IS '..tostring(res.x -_size*1.2)..']==========')

	local _alertRect = Neltharaku.GetAchoredRect(_size, _alertAnchor)

	-- if _debug then
	-- local TL = _alertRect.topLeft
	-- local BR = _alertRect.bottomRight

	-- Debug('==========================================')
	-- Debug('unit is '..tostring(_unit))
	-- Debug('_size is '..tostring(_size))
	-- Debug('TL is '..tostring(TL.x)..'|'..tostring(TL.y))
	-- Debug('BR is '..tostring(BR.x)..'|'..tostring(BR.y))
	-- Debug('==========================================')
	-- end


	--Creating a Window
	local _window = Hud():createContainer(_alertRect)

	--Creating a background
	local _backgroundRect = Neltharaku.GetLocalRectOfWindow(_window)
	local _background = _window:createPicture(_backgroundRect, _defaultBackground)
	_background.flippedX = true

	--Creating an icon
	local _alertIcon = _window:createPicture(_backgroundRect, _defaultIcon)
	_alertIcon.flipped = true

	--Creating a Button/Text Field
	local _alertInfo = nil
	if _isActive then
		_alertInfo = _window:createButton(_backgroundRect, 'default', nil)
	else
		_alertInfo = _window:createTextField(_backgroundRect, nil)
	end
	_alertInfo:hide()

	return _window, _background, _alertIcon, _alertInfo
end

--Responsible for turning the window
function Neltharaku.ExpandAlert(_elements)
	--Passed Variables
	local _alertWindow = _elements[1]
	local _alertInfo = _elements[4]

	--Calculated Variables
	local _nativeWidth = round(_alertWindow.width)
	local _expandedBonusWidth = round(_nativeWidth * 5)

	--Setting the container size
	local _expandedAnchor = vec2(_alertWindow.rect.topLeft.x - _expandedBonusWidth, _alertWindow.rect.topLeft.y)
	local _expandedRect = Rect(_expandedAnchor, _alertWindow.rect.bottomRight)
	_alertWindow.rect = _expandedRect

	--Setting the info size and highlighting it
	local _infoAnchor = vec2(_alertWindow.localRect.topLeft.x + _nativeWidth, _alertWindow.localRect.topLeft.y)
	local _infoRect = Rect(_infoAnchor, _alertWindow.localRect.bottomRight)

	if _alertInfo.caption ~= nil then
		_infoRect = Neltharaku.ShrinkRect(_infoRect, _nativeWidth * 0.2)
	end

	_alertInfo.rect = _infoRect
	_alertInfo:show()
end

--Responsible for minimizing the window
function Neltharaku.ShrinkAlert(_elements)
	--Passed Variables
	local _alertWindow = _elements[1]
	local _alertInfo = _elements[4]

	--Calculated Variables
	local _nativeSize = round(_alertWindow.height)
	local _expandedWidth = round(_nativeSize * 5)

	--Collapsing a container
	local _shrinkAnchor = vec2(_alertWindow.rect.topLeft.x + _expandedWidth, _alertWindow.rect.topLeft.y)
	local _shrinkRect = Rect(_shrinkAnchor, _alertWindow.rect.bottomRight)
	_alertWindow.rect = _shrinkRect

	--Button dimming
	_alertInfo:hide()
end

------------------------------------------[Actions with the interface]--------------------------------
--Returns a table with Rects for elements in a line according to the received information
function Neltharaku.UIrowAutoplace(_table, _unit, _xPad, _yPad)
	if not (_table) then return end
	local _result = {}
	local _accumulatedXpad = 0
	for _index, _rows in pairs(_table) do
		_accumulatedXpad = _accumulatedXpad + _xPad
		local pos1 = vec2(_accumulatedXpad, _yPad)
		_accumulatedXpad = _accumulatedXpad + _rows * _unit
		local pos2 = vec2(_accumulatedXpad, _yPad + _unit)
		table.insert(_result, Rect(pos1, pos2))
	end
	--Tsr( result,' result')
	return _result
end

--Simulates a close button
function Neltharaku.UIcreateCloseButton(_window, _size, _position)
	--positions are: 3,2,1
	if not (_window) then return end
	local _sizePadding = _size * 0.3

	--Search location
	local _negativeSize = (getResolution().y / 20)
	local _negativePadding = (_negativeSize / 2 + _size / 2) * (-0.95)

	local _positionPadding = 0
	if _position then
		_positionPadding = (_size + _sizePadding) * (_position - 1)
	end

	local _anchorPoint = vec2(_window.width - _sizePadding - _size - _positionPadding, _negativePadding)
	local _secondPoint = vec2(_anchorPoint.x + _size, _anchorPoint.y + _size)

	local _rect = Rect(_anchorPoint, _secondPoint)

	--Creating a Button
	local _icon = 'data/textures/icons/cancel.png'
	local _resultButton = _window:createRoundButton(_rect, _icon, nil)

	return _resultButton
end

--Moves the close button to fit the window size
function Neltharaku.UIplaceCloseButton(_button, _window, _position)
	--Setting dimensions
	local _size = _button.width
	local _sizePadding = _size * 0.3

	--Offset search
	local _negativeSize = (getResolution().y / 20)
	local _negativePadding = (_negativeSize / 2 + _size / 2) * (-0.95)

	local _positionPadding = 0
	if _position then
		_positionPadding = (_size + _sizePadding) * (_position - 1) -- 3,2,1
	end

	--Calculating the square
	local _windowTopRight = _window.rect.topRight
	local _anchorPoint = vec2(_windowTopRight.x - _sizePadding - _size - _positionPadding,
		_windowTopRight.y + _negativePadding)
	local _secondPoint = vec2(_anchorPoint.x + _size, _anchorPoint.y + _size)

	local _rect = Rect(_anchorPoint, _secondPoint)

	--Setting up a new location
	_button.rect = _rect
end

------------------------------------------[Transformations and calculations]--------------------------------

function Neltharaku.ShrinkRect(_rect, _value)
	local _pos1 = _rect.topLeft
	local _pos2 = _rect.bottomRight
	local _newPos1 = vec2(_pos1.x + _value, _pos1.y + _value)
	local _newPos2 = vec2(_pos2.x - _value, _pos2.y - _value)
	--print(_pos1.x,_pos1.y,'|',_pos2.x,_pos2.y)
	--print(_newPos1.x,_newPos1.y,'|',_newPos2.x,_newPos2.y)
	return Rect(_newPos1, _newPos2)
end

------------------------------------------[Graphics library]------------------------------------------------
--Draws a frame inside window from frames. If you send color, it will color it
function Neltharaku.GLapplyBorderFrame(_element, _size, _color)
	--Cutting off
	if not (_element) or not (_size) then
		Debug('GLapplyBorderFrame error: element or size is nil!')
		return
	end

	local _localP1 = vec2(0, 0)
	local _localP2 = vec2(_element.width, _element.height)
	local _localFrame = Rect(_localP1, _localP2)
	local _rects = {}
	local _createdFrames = {}

	--First pair of frames
	local _F1pointTop = vec2(_localP2.x, _localP1.y + _size)
	local _F2pointTop = vec2(_localP1.x + _size, _localP2.y)
	table.insert(_rects, Rect(_localP1, _F1pointTop))
	table.insert(_rects, Rect(_localP1, _F2pointTop))

	--Second pair of frames
	local _F3pointTop = vec2(_localP2.x - _size, _localP1.y)
	local _F4pointTop = vec2(_localP1.x, _localP2.y - _size)
	table.insert(_rects, Rect(_localP2, _F3pointTop))
	table.insert(_rects, Rect(_localP2, _F4pointTop))

	--Drawing and coloring
	for _, _rows in pairs(_rects) do
		local _createdFrame = _element:createFrame(_rows)
		if _color then
			_createdFrame.backgroundColor = _color
		end
		table.insert(_createdFrames, _createdFrame)
	end
	return _createdFrames
end

function Neltharaku.SetBackgroundImageToWindow(_window, _imagePath)
	local _rect = Neltharaku.GetLocalRectOfWindow(_window)
	local _picture = _window:createPicture(_rect, _imagePath)
	return _picture
end

function Neltharaku.GetLocalRectOfWindow(_window)
	local _pointL = vec2(0, 0)
	local _pointR = vec2(_window.width, _window.height)
	return Rect(_pointL, _pointR)
end

function Neltharaku.GetUnachoredRect(_size)
	local _pointL = vec2(0, 0)
	local _pointR = vec2(_size, _size)
	return Rect(_pointL, _pointR)
end

function Neltharaku.GetAchoredRect(_size, _point)
	local _pointR = vec2(_point.x + _size, _point.y + _size)
	return Rect(_point, _pointR)
end

function Neltharaku.isOutOfBorder(_element)
	--Cutting off
	if not (_element.rect) then
		Debug('isOutOfBorder failure: no rect detected')
	end

	--Variables
	local res = getResolution()
	local TL = _element.rect.topLeft
	local BR = _element.rect.bottomRight

	--Checking
	if TL.x < 0 or TL.y < 0 then return true end

	if BR.x > res.x or BR.y > res.y then return true end

	return false
end

-- function Neltharaku.getRectByAnchor(_anchoredPoint,_size)
-- local
-- end

function Neltharaku.GetListerAnchor(width)
	local listerRect = Rect(0, 0, width, 0)
	return listerRect
end

--Generates a frame that matches the element's square
function Neltharaku.debugFrame(baseElement, element, a)
	local notSame = true
	if not (element) then
		element = baseElement
		notSame = false
	end

	if baseElement and element then
		local anchor = vec2(0, 0)
		if notSame then anchor = element.localPosition end

		local pos = {
			anchor.x, anchor.y,
			element.size.x,
			element.size.y
		}

		local debugRect = baseElement:createFrame(Neltharaku.createRect(pos))

		if a then
			local color = _colorG
			color.a = a
			debugRect.backgroundColor = color
		else
			debugRect.backgroundColor = _colorG
		end
	else
		print('Neltharaku.debugFrame failure')
	end
end

--A simple way to create a square using the anchor-dot principle
function Neltharaku.createRect(_table)
	local Anchor = vec2(_table[1], _table[2])
	local Point = vec2(Anchor.x + _table[3], Anchor.y + _table[4])
	local resultRect = Rect(Anchor, Point)
	return resultRect
end

function Neltharaku.getLines(_table)
	local line1points = { vec2(_table[1], _table[2]), vec2(_table[1] + _table[3], _table[2] + _table[4]) }
	return line1points[1], line1points[2]
end

function Neltharaku.drawLine(cont, y, pad, width)
	local line1 = vec2(pad, y)
	local line2 = vec2(width - pad, y)

	local line = cont:createLine(line1, line2)

	return line
end

function Neltharaku.applyCursor(_entry)
	if _entry[1] == nil then
		Hud():setCursor()
		return 'Cursor reset'
	end

	Hud():setCursor(_entry[1], _entry[2], _entry[3])
	return 'Cursor set'
end

--Creates a container within a container
function Neltharaku.innerContainer(element)
	return element:createContainer(Rect(element.size))
end
