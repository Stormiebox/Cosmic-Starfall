package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

--namespace infoInterfaces
infoInterfaces = {}

local _debug = false
function infoInterfaces.DebugMsg(_text)
	if _debug then
		print('infoInterfaces|', _text)
	end
end

local Debug = infoInterfaces.DebugMsg
local RR = Neltharaku.ReportRect
local V2R = Neltharaku.ReportVec2
local dF = Neltharaku.debugFrame
local ApplyBorder = Neltharaku.GLapplyBorderFrame
local TSR = Neltharaku.TableSelfReport

local locNames = {}
locNames['combatgroup'] = 'Combat group' % _t
locNames['auracore'] = 'Active effects' % _t
locNames['asi'] = 'Active System Interface' % _t

local locIcons = {}
locIcons['player'] = 'data/textures/icons/ui/ui_playerOnline.png'
locIcons['cancel'] = 'data/textures/icons/ui/ui_cancelWOring.png'

local order = {
	--Name,id,i dupdate
	{ locNames['combatgroup'], 'combatgroupgeneral', 0.3 },
	{ locNames['combatgroup'], 'combatgroupmanage',  0.3 },
	{ locNames['combatgroup'], 'combatgroupinvite',  0.3 },
	{ locNames['auracore'],    'auracoreinfo',       0.2 },
	{ locNames['asi'],         'asiinfo',            0.3 },
}

local entities = {}
--1 name
--2 modname
--3 data

local icons = {}
icons['pulseTractorBeamGenerator'] = 'data/textures/icons/SYSpReactor3.png'

local self = infoInterfaces
local listboxLabelSizeK = 0.7      -- rUnit size factor for label listboxes (for lister)
local listboxLabelFontSizeK = 0.32 -- Text size factor rUnit for label listboxes
local stColor = getTypeColorByWeapon()

function infoInterfaces.SetEntitiesV2(container, rUnit, gUK)
	Debug('infoInterfaces.SetEntitiesV2 gUK is ' .. tostring(gUK))

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
function infoInterfaces.createLabel(y, container, rUnit, name)
	local yMod = y + rUnit * 0.5

	local labelAnchor = vec2(0, y)
	local labelPoint = vec2(container.width * 0.98, yMod)
	local labelRect = Rect(labelAnchor, labelPoint)

	local label = container:createLabel(labelRect, name, rUnit * listboxLabelFontSizeK)

	return yMod
end

--Creates a labelBox for a list at LEFT
function infoInterfaces.createBox(y, container, height, rowsize)
	local yMod = y + height

	local boxAnchor = vec2(0, y)
	local boxPoint = vec2(container.width * 0.98, yMod)
	local boxRect = Rect(boxAnchor, boxPoint)

	local label = container:createListBoxEx(boxRect)

	return yMod, label
end

--Creates an infobox list for RIGHT
function infoInterfaces.GetInfoContainers(container, rUnit)
	local _result = {}

	for _key, _rows in pairs(entities) do
		local stType = _key
		local infobox = self.SetMain(stType, container, rUnit)
		_result[_key] = infobox
	end
	return _result
end

--Generates infobox
function infoInterfaces.SetMain(stType, baseContainer, rUnit)
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
function infoInterfaces.CreateDescription(y, container, height, rUnit)
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
function infoInterfaces.CreatePicture(y, container, height, rUnit)
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
function infoInterfaces.CreateIconLabel(y, container, rUnit)
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
function infoInterfaces.CreateMainLabel(y, container, rUnit)
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

function infoInterfaces.CreateLine(y, container, rUnit)
	local yMod = y + rUnit * 0.25
	local v1 = vec2(rUnit * 0.25, y)
	local v2 = vec2(container.width - rUnit * 0.25, y)
	container:createLine(v1, v2)
	return yMod
end

-----------------------------[DATA: MOD]----------------------------

--Types: desc,picture,iconinfo,mainlabel

entities['combatgroupgeneral'] = {
	--Name
	'General info' % _t,
	--Content
	{
		{
			'mainlabel',                   -- Item type
			nil,                           -- Height (nil for iconname/mainlabel)
			'data/textures/icons/FederationSC.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                                                                                                                -- Item type
			1.8,                                                                                                                                                                                   -- Height (nil for iconname/mainlabel)
			"A special interface called by the corresponding button on the screen allows you to perform group management (player invitation, player kick, leader transfer) without using chat commands" %
			_t,                                                                                                                                                                                    -- Content. Text or path to the image.
		},
		{
			'iconinfo',                  -- Item type
			nil,                         -- Height (nil for iconname/mainlabel)
			'data/textures/icons/uiCollapse.png', -- Content. Text or path to the image.
			"'Collapse' button" % _t     -- Content for icon info
		},
		{
			'desc',                                                                                      -- Item type
			1,                                                                                           -- Height (nil for iconname/mainlabel)
			"Minimizes the window, leaving the 'expand' button on its place, allowing you to expand it later" % _t, -- Content. Text or path to the image.
		},
		-- {
		-- 'iconinfo', --Element type
		-- nil, --Height (nil for iconname/mainlabel)
		-- 'data/textures/icons/uiUpdate.png', --Content. Text or path to the image.
		-- "'Update' button"%_t --Content for icon info
		-- },
		-- {
		-- 'desc', --Element type
		-- 1, --Height (nil for iconname/mainlabel)
		-- "Updates information in the active window"%_t, --Content. Text or path to the image.
		-- },
		{
			'iconinfo',              -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			'data/textures/icons/uiPlus.png', -- Content. Text or path to the image.
			"'Switch to adding' button" % _t -- Content for icon info
		},
		{
			'desc',                                                             -- Item type
			1,                                                                  -- Height (nil for iconname/mainlabel)
			"Opens a window with a list of online players who are not in your group" % _t, -- Content. Text or path to the image.
		},
		-- {
		-- 'iconinfo', --Element type
		-- nil, --Height (nil for iconname/mainlabel)
		-- 'data/textures/icons/uiPlayer.png', --Content. Text or path to the image.
		-- "'Switch to Group Management' button"%_t --Content for icon info
		-- },
		-- {
		-- 'desc', --Element type
		-- 1, --Height (nil for iconname/mainlabel)
		-- "Switches the main window to group management mode. Unavailable if you are not a group leader"%_t, --Content. Text or path to the image.
		-- },

	},
}
entities['combatgroupmanage'] = {
	--Name
	'Group Control Panel' % _t,
	--Content
	{
		{
			'mainlabel',               -- Item type
			nil,                       -- Height (nil for iconname/mainlabel)
			'data/textures/icons/uiPlayer.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                                                                                                              -- Item type
			1,                                                                                                                                                                                   -- Height (nil for iconname/mainlabel)
			"This window contains a list of all the players in the group, and also allows you to transfer leadership and kick players (including yourself). Unavailable functions will not be active" %
			_t,                                                                                                                                                                                  -- Content. Text or path to the image.
		},
		{
			'iconinfo', -- Item type
			nil,       -- Height (nil for iconname/mainlabel)
			locIcons['player'], -- Content. Text or path to the image.
			'Player status' % _t -- Content for icon info
		},
		{
			'desc',                                                                                         -- Item type
			1.2,                                                                                            -- Height (nil for iconname/mainlabel)
			"Indicates the status of the player (offline, online, leader) and allows you to transfer the leader" % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',            -- Item type
			nil,                   -- Height (nil for iconname/mainlabel)
			'data/textures/icons/kick.png', -- Content. Text or path to the image.
			"'Kick' button" % _t   -- Content for icon info
		},
		{
			'desc',                                                                                   -- Item type
			1.2,                                                                                      -- Height (nil for iconname/mainlabel)
			"Allows you to kick the player (available only to the leader). You can't kick players offline" % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo', -- Item type
			nil,       -- Height (nil for iconname/mainlabel)
			locIcons['cancel'], -- Content. Text or path to the image.
			"'Leave' button" % _t -- Content for icon info
		},
		{
			'desc',                    -- Item type
			1.2,                       -- Height (nil for iconname/mainlabel)
			"Allows you to leave the group" % _t, -- Content. Text or path to the image.
		},
	},
}
entities['combatgroupinvite'] = {
	--Name
	'Player Invitation Panel' % _t,
	--Content
	{
		{
			'mainlabel',             -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			'data/textures/icons/uiPlus.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                                                                                                                                                                                                                                                                                                                                                            -- Item type
			1.6,                                                                                                                                                                                                                                                                                                                                                                                                                               -- Height (nil for iconname/mainlabel)
			"This window displays online players who are not in the same group as the current player. Being the leader of the group (or not being in the group), you can invite the specified player, in which case the button will change to a confirmation one and become inactive. The specified player will receive an alert with that allows him to instantly accept/decline the invitation.\n The button is inactive if you are not a leader" %
			_t,                                                                                                                                                                                                                                                                                                                                                                                                                                -- Content. Text or path to the image.
		},
	},
}
entities['auracoreinfo'] = {
	--Name
	'Active effects' % _t,
	--Content
	{
		{
			'mainlabel',               -- Item type
			nil,                       -- Height (nil for iconname/mainlabel)
			'data/textures/icons/acid-fog.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                                                                                                                                             -- Item type
			1.3,                                                                                                                                                                                                                -- Height (nil for iconname/mainlabel)
			"An interface element that is initially hidden. As soon as the effects of modules / environment from the Starfall mod begin to act on the ship, information about this effect will appear near the vanilla status icons" %
			_t,                                                                                                                                                                                                                 -- Content. Text or path to the image.
		},
	},
}

entities['asiinfo'] = {
	--Name
	'Active System Interface' % _t,
	--Content
	{
		{
			'mainlabel',                     -- Item type
			nil,                             -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_circutry.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                              -- Item type
			1.3,                                                                                 -- Height (nil for iconname/mainlabel)
			"Customizable interface that provides access to the active systems installed on the ship" % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                        -- Item type
			nil,                               -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_framesfull.png', -- Content. Text or path to the image.
			"Frame switcher" % _t              -- Content for icon info
		},
		{
			'desc',                                                                                                               -- Item type
			1.4,                                                                                                                  -- Height (nil for iconname/mainlabel)
			"Allows you to include a frame on each system panel to improve visibility. The frame color is similar to the system color" %
			_t,                                                                                                                   -- Content. Text or path to the image.
		},
		{
			'iconinfo',                           -- Item type
			nil,                                  -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_moveinterface.png', -- Content. Text or path to the image.
			"Movement switcher" % _t              -- Content for icon info
		},
		{
			'desc',                                                                                                                                                                                                 -- Item type
			1.5,                                                                                                                                                                                                    -- Height (nil for iconname/mainlabel)
			"Allows you to unlock elements with which you can move panels around the screen. To do this, click on them and, holding the left mouse button pressed (the element will turn green), specify a new location" %
			_t,                                                                                                                                                                                                     -- Content. Text or path to the image.
		},
		{
			'iconinfo',                          -- Item type
			nil,                                 -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_hideMainIcon.png', -- Content. Text or path to the image.
			"Main icon switcher" % _t            -- Content for icon info
		},
		{
			'desc',                                                                   -- Item type
			1.2,                                                                      -- Height (nil for iconname/mainlabel)
			"Allows you to enable and disable the display of the module icon on its panel" % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                    -- Item type
			nil,                           -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_colors.png', -- Content. Text or path to the image.
			"Color switcher" % _t          -- Content for icon info
		},
		{
			'desc',                                                                                                                          -- Item type
			1.4,                                                                                                                             -- Height (nil for iconname/mainlabel)
			"Opens the color selection panel for the progress bars. Clicking on the button next to each bar resets the color to the original one" %
			_t,                                                                                                                              -- Content. Text or path to the image.
		},
		{
			'iconinfo',                     -- Item type
			nil,                            -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_default.png', -- Content. Text or path to the image.
			"Reset to Default" % _t         -- Content for icon info
		},
		{
			'desc',                                                                                                     -- Item type
			1.3,                                                                                                        -- Height (nil for iconname/mainlabel)
			"Resets all panel settings to the original ones. After activation, you need to click on the confirmation button" %
			_t,                                                                                                         -- Content. Text or path to the image.
		},
	},
}
