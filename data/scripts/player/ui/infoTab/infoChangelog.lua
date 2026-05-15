package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

--namespace infoChangelog
infoChangelog = {}

local _debug = false
function infoChangelog.DebugMsg(_text)
	if _debug then
		print('infoChangelog|', _text)
	end
end

local Debug = infoChangelog.DebugMsg
local RR = Neltharaku.ReportRect
local V2R = Neltharaku.ReportVec2
local dF = Neltharaku.debugFrame
local ApplyBorder = Neltharaku.GLapplyBorderFrame
local TSR = Neltharaku.TableSelfReport

-- local locNames = {}
-- locNames['CG alerts'] = 'Combat group alerts'%_t
-- locNames['WPN alerts'] = 'Weapon alerts'%_t

local order = {
	--name,ID,IDupdate
	--Active
	{ 'Cosmic Starfall Revamp', 'Starfall-Revamp', 1.0 },
}

local entities = {}
--1 name
--2 modname
--3 data

local self = infoChangelog
local listboxLabelSizeK = 0.7      -- rUnit size factor for label listboxes (for lister)
local listboxLabelFontSizeK = 0.32 -- Text size factor rUnit for label listboxes
local stColor = getTypeColorByWeapon()

function infoChangelog.SetEntitiesV2(container, rUnit, gUK)
	Debug('infoChangelog.SetEntitiesV2 gUK is ' .. tostring(gUK))

	--Sorting and output order
	local segments = {}
	local segmentsLen = {}

	--Fills the table of segments (headers) and calculates the length
	for _, _rows in pairs(order) do
		local name = _rows[1]
		if not (segmentsLen[name]) then
			segmentsLen[name] = 1
			table.insert(segments, name)
		else
			segmentsLen[name] = segmentsLen[name] + 1
		end
	end

	--Variables
	local yPos = 0
	local boxTable = {}

	--Creating a UI container
	local listBox = container:createScrollFrame(Rect(container.size))

	--Generating lines in a listBox according to segments
	for i = 1, #segments do
		local segment = segments[i]
		Debug('New segment: ' .. segment)
		Debug('Length is ' .. tostring(segmentsLen[segment]))

		--Generation of the listBox window
		local rowHeight = rUnit * 0.4
		local totalHeight = (segmentsLen[segment] + 1) * rowHeight
		yPos = self.createLabel(yPos, listBox, rUnit, segment)
		yPos, boxTable[segment] = self.createBox(yPos, listBox, totalHeight, rowHeight)

		--TSR(order)
		--String padding
		for _, _rows in pairs(order) do
			if _rows[1] == segment then
				local entryName = _rows[2]
				local entryGUK = _rows[3]
				local entityRow = entities[entryName]
				local name = entityRow[1]

				local color = getTypeColor()
				if entryGUK >= gUK then color = getTypeColor('update') end

				Debug('applying ' .. name .. ' to ' .. segment)

				boxTable[segment]:addRow()
				boxTable[segment]:setEntry(0, boxTable[segment].rows - 1, name, false, false, color)
				boxTable[segment]:setEntryValue(0, boxTable[segment].rows - 1, entryName)
			end
		end
	end

	return boxTable
end

--Creates a label for a list in LEFT
function infoChangelog.createLabel(y, container, rUnit, name)
	local yMod = y + rUnit * 0.5

	local labelAnchor = vec2(0, y)
	local labelPoint = vec2(container.width * 0.98, yMod)
	local labelRect = Rect(labelAnchor, labelPoint)

	local label = container:createLabel(labelRect, name, rUnit * listboxLabelFontSizeK)

	return yMod
end

--Creates a labelBox for a list at LEFT
function infoChangelog.createBox(y, container, height, rowsize)
	local yMod = y + height

	local boxAnchor = vec2(0, y)
	local boxPoint = vec2(container.width * 0.98, yMod)
	local boxRect = Rect(boxAnchor, boxPoint)

	local label = container:createListBoxEx(boxRect)

	return yMod, label
end

--Creates an infobox list for RIGHT
function infoChangelog.GetInfoContainers(container, rUnit)
	local _result = {}

	for _key, _rows in pairs(entities) do
		local stType = _key
		local infobox = self.SetMain(stType, container, rUnit)
		_result[_key] = infobox
	end
	return _result
end

--Generates infobox
function infoChangelog.SetMain(stType, baseContainer, rUnit)
	Debug('SetMain attempt with type ' .. stType)
	if not (stType) then
		Debug('Failure: no stType')
		return
	end
	if not (baseContainer) then
		Debug('Failure: no baseContainer')
		return
	end
	if not (rUnit) then
		Debug('Failure: no rUnit')
		return
	end

	--Creating a container
	local infobox = baseContainer:createScrollFrame(Rect(baseContainer.size))

	--Basic Variables
	local baseSize = infobox.size
	local chosenTable = entities[stType]

	--Generating Segments
	local data = chosenTable[2]
	local name = chosenTable[1]
	local yMod = 0

	for _index, _rows in pairs(data) do
		local dataType = _rows[1]
		local dataHeight = _rows[2]
		local dataInfo = _rows[3] --Description or path to the icon
		local dataLabel = _rows[4] --Only iconinfo has label contents

		if dataType == 'mainlabel' then
			local iconE, nameE
			iconE, nameE, yMod = self.CreateMainLabel(yMod, infobox, rUnit)

			iconE.picture = dataInfo
			nameE.caption = name
			nameE.fontSize = rUnit * 0.3

			yMod = self.CreateLine(yMod, infobox, rUnit)
		end

		if dataType == 'desc' then
			local descE
			descE, yMod = self.CreateDescription(yMod, infobox, dataHeight, rUnit)

			descE.text = dataInfo

			--yMod = infoStations.CreateLine(yMod,baseContainer,rUnit)
		end

		if dataType == 'iconinfo' then
			local iconE, descE
			iconE, descE, yMod = self.CreateIconLabel(yMod, infobox, rUnit)

			iconE.picture = dataInfo
			descE.caption = dataLabel
			descE.fontSize = rUnit * 0.25
		end
	end

	infobox:hide()
	return infobox
end

--Creates a text field in the RIGHT tab
function infoChangelog.CreateDescription(y, container, height, rUnit)
	local xPadding = rUnit * 0.25
	local yPadding = rUnit * 0.25

	local descAnchor = vec2(xPadding, y + yPadding)
	local descPoint = vec2(container.width - xPadding, descAnchor.y + height * rUnit)
	local descRect = Rect(descAnchor, descPoint)
	local descElement = container:createMultiLineTextBox(descRect)
	descElement.editable = false
	descElement.setFontSize = rUnit * 0.3
	local yMod = descPoint.y

	return descElement, yMod
end

--Creates an image in the RIGHT tab
function infoChangelog.CreatePicture(y, container, height, rUnit)
	local xPadding = rUnit * 0.25
	local yPadding = rUnit * 0.25

	local baseAnchor = vec2(xPadding, y + yPadding)
	local basePoint = vec2(container.width - xPadding, baseAnchor.y + height * rUnit)
	local baseRect = Rect(baseAnchor, basePoint)
	local baseElement = container:createPicture(baseRect, nil)

	local yMod = basePoint.y

	return baseElement, yMod
end

--Creates an image + subelement name in the RIGHT tab
function infoChangelog.CreateIconLabel(y, container, rUnit)
	local xPadding = rUnit * 0.25
	local yPadding = rUnit * 0.25 + y
	local unitMod = rUnit * 0.7
	local textFieldSqueeze = rUnit * 0.25

	local iconAnchor = vec2(xPadding, yPadding)
	local iconPoint = vec2(iconAnchor.x + unitMod, iconAnchor.y + unitMod)
	local iconRect = Rect(iconAnchor, iconPoint)
	local iconElement = container:createPicture(iconRect, nil)
	iconElement.isIcon = true

	local nameAnchor = vec2(iconPoint.x + xPadding * 2, yPadding + textFieldSqueeze)
	local namePoint = vec2(nameAnchor.x + rUnit * 9, nameAnchor.y + unitMod)
	local nameRect = Rect(nameAnchor, namePoint)
	local nameElement = container:createLabel(nameRect, '', 10)

	local yMod = iconPoint.y

	return iconElement, nameElement, yMod
end

--Creates a title in the RIGHT tab
function infoChangelog.CreateMainLabel(y, container, rUnit)
	local xPadding = rUnit * 0.25
	local yPadding = rUnit * 0.25 + y
	local unitMod = rUnit * 0.9
	local textFieldSqueeze = rUnit * 0.25

	local iconAnchor = vec2(xPadding, yPadding)
	local iconPoint = vec2(iconAnchor.x + unitMod, iconAnchor.y + unitMod)
	local iconRect = Rect(iconAnchor, iconPoint)
	local iconElement = container:createPicture(iconRect, nil)
	iconElement.isIcon = true

	local nameAnchor = vec2(iconPoint.x + xPadding * 2, yPadding + textFieldSqueeze)
	local namePoint = vec2(nameAnchor.x + rUnit * 9, nameAnchor.y + unitMod)
	local nameRect = Rect(nameAnchor, namePoint)
	local nameElement = container:createLabel(nameRect, '', 10)
	nameElement.bold = true

	local yMod = iconPoint.y

	return iconElement, nameElement, yMod
end

function infoChangelog.CreateLine(y, container, rUnit)
	local yMod = y + rUnit * 0.25
	local v1 = vec2(rUnit * 0.25, y)
	local v2 = vec2(container.width - rUnit * 0.25, y)
	container:createLine(v1, v2)
	return yMod
end

-------------------------------[DATA: LINES]--------------------------------------------
local updateLines = {}
updateLines['Starfall-Revamp'] = {
	"Complete overhaul of the Starfall codebase and related systems for improved performance, stability, and maintainability.",
	"Refactored core mechanics and subsystems to align with modern coding standards and best practices.",
	"Balanced gameplay elements and mechanics based on player feedback and data analysis for a more engaging experience.",
	"Fixed various bugs and issues reported by the community to enhance overall game stability and user experience.",
	"Fixed weapon class names and descriptions to be more accurate and informative.",
	"Added Cosmic Vault as requirement for Cosmic Starfall.",
}

function infoChangelog.transformToSingleLine(_table)
	local _result = ''

	for _, _rows in pairs(_table) do
		_result = _result .. " - " .. _rows .. '\n\n'
	end

	return _result
end

-----------------------------[DATA: GENERATION]----------------------------

--Types: desc,picture,iconinfo,mainlabel

entities['Starfall-Revamp'] = {
	--Name
	'Cosmic Starfall Revamp', --Name of the stType
	--Content
	{
		{
			'mainlabel',                           -- Item type
			nil,                                   -- Height (nil for iconname/mainlabel)
			'data/textures/icons/clipboard-arrow-down.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                            -- Item type
			8,                                                 -- Height (nil for iconname/mainlabel)
			self.transformToSingleLine(updateLines['Starfall-Revamp']), -- Content. Text or path to the image.
		},
	},
}
