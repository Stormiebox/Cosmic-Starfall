package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Neltharaku')
include('ColorLib')

local colors = {}
colors['buff'] = getColor('auracore_buff')
colors['debuff'] = getColor('auracore_debuff')
colors['neutral'] = getColor('auracore_standby')

-- namespace auraCore
auraCore = {}

local _debug = false
function auraCore.DebugMsg(_text)
	if _debug then
		print('auraCore|', _text)
	end
end

local self = auraCore

local Debug = self.DebugMsg

local sf = string.format



local locLines = {}
locLines['activeauras'] = "Active effects" % _t
--locLines['sec'] = "s"%_t

local activeAuras = {}
--1 signature(str)
--2 effect strength(str)
--3 effect length(int)
--4 effect name(str)
--5 aura type(str)
--6 source name(str)
--7 target name(str)
--8 icon(str)
--9 isAura(bool)
--10 isUniq(bool)

--AuraType
--debuff
--buff
--neutral

local UIanchor = nil
local rUnit = nil
local containerSize = nil

local containerUI = nil
local containerDynamicUI = nil
local containerLabelUI = nil
--local auraLinesUI = {}

function auraCore.initialize()
	Debug('--------initialize--------')
	if onClient() then
		--Variables
		UIanchor = vec2(getResolution().x * 0.25, getResolution().y * 0.15)
		rUnit = math.min(getResolution().x, getResolution().y) * 0.05
		containerSize = rUnit * 4


		--Actions
		self.CreateContainer()
	end
end

function auraCore.getUpdateInterval()
	return 1
end

function auraCore.update(timeStep)
	if onClient() then
		self.TimerOperate(activeAuras)
		self.ShowAuras()
	end
end

--=========================================[Interface functions]=====================================

function auraCore.CreateContainer()
	--Variables
	Debug(string.format("rUnit is %i", rUnit))
	local windowPoint = vec2(UIanchor.x + containerSize, UIanchor.y + rUnit)
	local windowRect = Rect(UIanchor, windowPoint)

	--Creating a container
	containerUI = Hud():createContainer(windowRect)
	--Container ui:create frame(rect(container ui.size))

	--Creation of LABEL
	local labelAnchor = vec2(rUnit * 0.05, rUnit * 0.05)
	local labelTextSize = rUnit * 0.25

	containerLabelUI = containerUI:createLabel(labelAnchor, locLines['activeauras'], labelTextSize)

	--Creating dynamicContainer
	containerDynamicUI = containerUI:createContainer(Rect(containerUI.size))
end

function auraCore.ShowAuras()
	--Cutting off
	if not (containerDynamicUI) or not (containerLabelUI) then return end

	--Creating an overview table
	local tableToShow = {}

	--Cleaning the interface
	containerDynamicUI:clear()

	local yPos = containerLabelUI.height

	--ActiveAuras Data Analysis
	for _, rows in pairs(activeAuras) do
		local okToShow = self.isOkToShow(rows)

		if okToShow then
			--Debug(sf("ok to show: %s",rows[1]))
			table.insert(tableToShow, rows)
		end
	end

	for _, _rows in pairs(tableToShow) do
		yPos = self.DrawAuraLine(_rows, yPos)
	end

	--Switching main label
	if #tableToShow > 0 then
		containerLabelUI:show()
	else
		containerLabelUI:hide()
	end
end

--Checks if it can be shown
function auraCore.isOkToShow(_table)
	if Player().craft ~= nil then
		local currentCraftName = Player().craft.name

		if _table[7] == currentCraftName then
			return true
		end

		return false
	end
end

--Operation of aura timers, elimination of outdated ones
function auraCore.TimerOperate(_table)
	for _index, _rows in pairs(activeAuras) do
		local timer = _rows[3]
		_rows[3] = math.max(_rows[3] - 1, 0)

		--Erase if timer is 0
		if _rows[3] == 0 then
			table.remove(activeAuras, _index)
		end
	end
end

--Draws an aura line
function auraCore.DrawAuraLine(_table, posY)
	local iconPath = _table[8]

	local xPad = rUnit * 0.05
	local yPad = rUnit * 0.05 + posY
	local sizeMod = rUnit * 0.3
	local textSize = rUnit * 0.25

	--Creating a text line
	local effectSTR = _table[2]
	local effectLNG = _table[3]
	local effectNAME = _table[4]
	local auraType = _table[5]
	local sourceName = _table[6]
	local targetName = _table[7]
	local isAura = _table[9]

	--Duration is not displayed for auras
	if isAura then effectLNG = "" end

	--the source is not displayed for itself, or add brackets + space
	if targetName == sourceName then
		sourceName = ""
	else
		sourceName = string.format(" (%s)", sourceName)
	end

	--If the strength is "0" -erase, otherwise space
	if effectSTR == '0' or effectSTR == 0 then
		effectSTR = ''
	else
		effectSTR = string.format("%s ", effectSTR)
	end

	--Purpose of aura colors
	local _color = colors[auraType]

	--Generating a Time String
	if not (isAura) then
		local seconds = effectLNG % 60
		if seconds < 10 then
			seconds = string.format("0%i", seconds)
		else
			seconds = tostring(seconds)
		end
		local minutes = string.format("%i", math.floor(effectLNG / 60))

		effectLNG = string.format(" %s:%s", minutes, seconds)
	end


	--string generation
	local textLine = string.format("%s%s%s%s", effectSTR, effectNAME % _t, sourceName, effectLNG)

	--Icon
	local iconAnchor = vec2(xPad, yPad)
	local iconPoint = vec2(iconAnchor.x + sizeMod, iconAnchor.y + sizeMod)
	local iconRect = Rect(iconAnchor, iconPoint)
	local pic = containerDynamicUI:createPicture(iconRect, iconPath)
	pic.isIcon = true
	pic.color = _color

	--Text
	local textAnchor = vec2(iconPoint.x + xPad, yPad)
	local textPoint = vec2(textAnchor.x + sizeMod * 20, textAnchor.y + sizeMod)
	local textRect = Rect(textAnchor, textPoint)
	local txt = containerDynamicUI:createLabel(textRect, textLine, textSize)
	txt.color = _color

	return textAnchor.y + sizeMod
end

--===========================[Request processing functions]=========================================

--Checks and adds the effect to the general table
function auraCore.ApplyAura(_table)
	if onServer() then
		invokeClientFunction(Player(), 'ApplyAura', _table)
		return
	end

	--Inspection and clipping
	if not (self.isAuraCorrect(_table)) then
		return 1
	end

	--Data Analysis
	local isDuplicate, isPossibleToDuplicate = self.isAuraUniqOrCorrect(_table)
	local okToCreate = (not (isDuplicate) or isPossibleToDuplicate)

	if okToCreate then
		table.insert(activeAuras, _table)
		Debug(string.format('Successful created %s', _table[1]))
	end

	--Processing auras without a timer (auras of constant update)
	self.isAuraToUpdate(_table)
end

--Interrupts the effect of the aura
function auraCore.InterruptAura(signature, sourcename)
	if onServer() then
		invokeClientFunction(Player(), 'InterruptAura', signature, sourcename)
	end

	for _ind, _rows in pairs(activeAuras) do
		local isFound = ((_rows[1] == signature) and (_rows[6] == sourcename))
		if isFound then
			table.remove(activeAuras, _ind)
			Debug('table removed')
		end
	end
end

--Checks the correctness of the received effect
function auraCore.isAuraCorrect(_table)
	if _table[1] == nil then
		Debug('isAuraCorrect: signature is nil')
		return false
	end

	if _table[2] == nil then
		Debug('isAuraCorrect: effectSTR is nil')
		return false
	end

	if _table[3] == nil then
		Debug('isAuraCorrect: effectLNG is nil')
		return false
	end

	if _table[4] == nil then
		Debug('isAuraCorrect: effectNAME is nil')
		return false
	end

	if _table[5] == nil then
		Debug('isAuraCorrect: auraType is nil')
		return false
	end

	if _table[6] == nil then
		Debug('isAuraCorrect: sourceName is nil')
		return false
	end

	if _table[7] == nil then
		Debug('isAuraCorrect: targetName is nil')
		return false
	end

	if _table[8] == nil then
		Debug('isAuraCorrect: icon is nil')
		return false
	end

	if _table[9] == nil then
		Debug('isAuraCorrect: isAura is nil')
		return false
	end

	if _table[10] == nil then
		Debug('isAuraCorrect: isUniq is nil')
		return false
	end

	return true
	--1 signature(str)
	--2 effect strength(int)
	--3 effect length(int)
	--4 effect name(str)
	--5 aura type(str)
	--6 source name(str)
	--7 target name(str)
	--8 icon(str)
	--9 isAura(bool)
	--10 isUniq(bool)
end

--1 signature(str)
--2 effect strength(str)
--3 effect length(int)
--4 effect name(str)
--5 aura type(str)
--6 source name(str)
--7 target name(str)
--8 icon(str)
--9 isAura(bool)
--10 isUniq(bool)

--Checks for duplicates and the ability to create duplicates
function auraCore.isAuraUniqOrCorrect(_table)
	local signature = _table[1]
	local sourceName = _table[6]
	local targetName = _table[7]
	local isUniq = _table[10]
	local effectSTR = _table[2]

	local isUniqDuplicateCheck = false --if true -the aura is already affecting the ship
	local isOkToDuplicate = false   --if true -the aura is already operating from another source, you can add
	--local isOkToEnhance = false --if true -there is a duplicate, but the aura can be enhanced by replacing it with a stronger one
	--local enhanceID = nil --ID of the function to replace

	--If there is a "unique" flag and there is a similar aura on the same ship -a uniqueness error
	if isUniq then
		for _, _rows in pairs(activeAuras) do
			local isSameTargetName = (targetName == _rows[7])
			local isSameSignature = (signature == _rows[1])

			if isSameTargetName and isSameSignature then
				isUniqDuplicateCheck = true
			end
		end
	end

	--Checking the possibility of correct duplication
	if not (isUniq) then
		isOkToDuplicate = true

		for _, _rows in pairs(activeAuras) do
			local isSameTargetName = (targetName == _rows[7])
			local isSameSignature = (signature == _rows[1])
			local isSameSource = (sourceName == _rows[6])

			if isSameTargetName and isSameSignature and isSameSource then
				Debug('same target, signature, source')
				isOkToDuplicate = false
			end
		end
	end

	return isUniqDuplicateCheck, isOkToDuplicate
end

--Checks if this aura is “without a timer” -updates it
function auraCore.isAuraToUpdate(_table)
	--Cutting off unnecessary iterations is not for auras
	local isAura = _table[9]
	if not (isAura) then return false end

	--Variables
	local signature = _table[1]
	local sourceName = _table[6]
	local targetName = _table[7]
	local effectSTR = _table[2]

	--Processing
	for _ind, _rows in pairs(activeAuras) do
		local isEverythingSame = ((signature == _rows[1]) and (sourceName == _rows[6]) and (targetName == _rows[7]))
		if isEverythingSame then
			Debug(sf("UpdateAura %s", signature))
			_rows[2] = effectSTR
			_rows[3] = 1.5
		end
	end
end
