package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')
include('Tech')

--namespace infoSystems
infoSystems = {}

local _debug = false
function infoSystems.DebugMsg(_text)
	if _debug then
		print('infoSystems|', _text)
	end
end

local Debug = infoSystems.DebugMsg
local RR = Neltharaku.ReportRect
local V2R = Neltharaku.ReportVec2
local dF = Neltharaku.debugFrame
local ApplyBorder = Neltharaku.GLapplyBorderFrame
local TSR = Neltharaku.TableSelfReport

local locNames = {}
locNames['interactive'] = 'Starfall - interactive' % _t
locNames['noninteractive'] = 'Starfall - passive' % _t

local order = {
	--name,ID,IDupdate
	--Active
	{ locNames['interactive'],    'bastionSystem',             0.1 },
	{ locNames['interactive'],    'macrofieldProjector',       0.1 },
	{ locNames['interactive'],    'repairDrones',              0.1 },
	{ locNames['interactive'],    'XperimentalHypergenerator', 0.1 },
	{ locNames['interactive'],    'pulseTractorBeamGenerator', 0.1 },
	--Passive
	{ locNames['noninteractive'], 'subspaceCargo',             0.1 },
}

local entities = {}
--1 icon
--2 name
--3 desc
--4 bonuses
--5 spells
--6 modname

local self = infoSystems
local listboxLabelSizeK = 0.7      -- rUnit size factor for label listboxes (for lister)
local listboxLabelFontSizeK = 0.32 -- Text size factor rUnit for label listboxes
local stColor = getTypeColorByWeapon()

--Creates and fills listboxes for LEFT
function infoSystems.SetEntitiesV2(container, rUnit, gUK)
	Debug('infoSystems.SetEntitiesV2 gUK is ' .. tostring(gUK))

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
				local name = entityRow[2]

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

--Creates an infobox list for RIGHT
function infoSystems.GetInfoContainers(container, rUnit)
	local _result = {}

	for _key, _rows in pairs(entities) do
		local sysType = _key
		local infobox = self.SetMain(sysType, container, rUnit)
		_result[_key] = infobox
	end
	return _result
end

--Generates infobox
function infoSystems.SetMain(sysType, baseContainer, rUnit)
	Debug('SetMain attempt with type ' .. sysType)
	if not (sysType) then
		Debug('Failure: no sysType')
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

	--Basic container
	local infobox = baseContainer:createContainer(Rect(baseContainer.size))

	--Basic Variables
	local baseSize = infobox.size
	local chosenTable = entities[sysType]

	local paddingY = rUnit * 0.5
	local unitIcon = rUnit * 4

	--Creating containers

	--Main splitter info | scroll descriptions
	local hSplitter = UIHorizontalSplitter(Rect(infobox.size), 10, 0, 0.45)

	--Container info
	local infoContainer = infobox:createContainer(hSplitter.top)
	local infoContainerVec = vec2(infoContainer.size.x, infoContainer.size.y)
	infoContainer:createFrame(Rect(infoContainerVec))

	--Description/Change Scroller
	local otherContainer = infobox:createScrollFrame(hSplitter.bottom)

	--Splitter for separating description and changes
	local descChangesSplitter = UIHorizontalSplitter(Rect(otherContainer.size), 10, 0, 0.45)

	--The scroller is described
	local descContainer = otherContainer:createScrollFrame(descChangesSplitter.top)

	--Links to information
	local sysIcon = chosenTable[1]
	local sysName = chosenTable[2]
	local sysDesc = chosenTable[3][1]
	local sysDescMod = chosenTable[3][2]
	local sysBonusesTable = chosenTable[4]
	local sysSpellsTable = chosenTable[5]

	--Creating an icon
	local iconTRanchor = vec2(baseSize.x - unitIcon - paddingY, paddingY)
	local iconSecondPoint = vec2(iconTRanchor.x + unitIcon, iconTRanchor.y + unitIcon)
	local iconRect = Rect(iconTRanchor, iconSecondPoint)
	local icon = infoContainer:createPicture(iconRect, sysIcon)
	icon.isIcon = true

	--Name
	local nameAnchor = vec2(rUnit * 1, paddingY)
	local namePoint = vec2(nameAnchor.x + rUnit * 7, nameAnchor.y + rUnit)
	local nameRect = Rect(nameAnchor, namePoint)
	local name = infoContainer:createTextField(nameRect, sysName)
	name.fontSize = rUnit * 0.4

	--Characteristics
	for i = 1, #sysBonusesTable do
		local selfTable = sysBonusesTable[i]
		local _icon, _label, _value = self.InfoLineCreator(i - 1, rUnit, infoContainer)
		_icon.picture = selfTable[1]
		_label.text = selfTable[2]
		_value.text = selfTable[3]
		_value.fontColor = stColor
	end

	--Info
	local descVec = vec2(descContainer.size.x, descContainer.size.y * sysDescMod)
	--local descRect = Neltharaku.ShrinkRect(Rect(descContainer.size),rUnit*0.2)
	local descRect = Neltharaku.ShrinkRect(Rect(descVec), rUnit * 0.2)

	local descTextBox = otherContainer:createMultiLineTextBox(descRect)
	descTextBox.editable = false
	descTextBox.text = sysDesc
	descTextBox.setFontSize = rUnit * 0.3

	local yPoint = descRect.bottomRight.y + rUnit * 0.1

	--Active Effects
	if sysSpellsTable then
		--dF(otherContainer,descChangesSplitter.bottom)
		--local changesLister = UIVerticalLister(activeContainer.rect, 5, 5)

		for _, _rows in pairs(sysSpellsTable) do
			--Variables
			local icon = _rows[1]
			local name = _rows[2]
			local desc = _rows[3]
			local descM = _rows[4]
			local yStart = yPoint

			local hModifier = 1 --for icon and title

			--Icon
			local iconAnchor = vec2(rUnit * 0.25, yPoint + rUnit * 0.25)
			local iconPoint = vec2(iconAnchor.x + rUnit * hModifier, iconAnchor.y + rUnit * hModifier)
			local iconRect = Rect(iconAnchor, iconPoint)
			local thisIcon = otherContainer:createPicture(iconRect, icon)
			thisIcon.isIcon = true

			--Name
			local nameAnchor = vec2(iconPoint.x, iconAnchor.y)
			local namePoint = vec2(nameAnchor.x + rUnit * 7, nameAnchor.y + rUnit * hModifier)
			local nameRect = Rect(nameAnchor, namePoint)
			local thisName = otherContainer:createTextField(nameRect, name)
			thisName.fontSize = rUnit * 0.3

			--Description
			local descAnchor = vec2(rUnit * 0.25, iconPoint.y + rUnit * 0.1)
			local descPoint = vec2(otherContainer.width - rUnit * 0.25, descAnchor.y + rUnit * 1.5 * descM)
			local descRect = Rect(descAnchor, descPoint)
			local thisDesc = otherContainer:createMultiLineTextBox(descRect)
			thisDesc.editable = false
			thisDesc.text = desc
			thisDesc.setFontSize = rUnit * 0.3

			yPoint = descPoint.y + rUnit * 0.2
		end
	end

	infobox:hide()
	return infobox
end

--Creates a title for the list
function infoSystems.createLabel(y, container, rUnit, name)
	local yMod = y + rUnit * 0.5

	local labelAnchor = vec2(0, y)
	local labelPoint = vec2(container.width * 0.98, yMod)
	local labelRect = Rect(labelAnchor, labelPoint)

	local label = container:createLabel(labelRect, name, rUnit * listboxLabelFontSizeK)

	return yMod
end

--Creates a labelBox for a list of guns
function infoSystems.createBox(y, container, height, rowsize)
	local yMod = y + height

	local boxAnchor = vec2(0, y)
	local boxPoint = vec2(container.width * 0.98, yMod)
	local boxRect = Rect(boxAnchor, boxPoint)

	local label = container:createListBoxEx(boxRect)

	return yMod, label
end

--Creates a line of text for the infotab
function infoSystems.InfoLineCreator(index, rUnit, infobox)
	--Variables
	local staticPadding = rUnit * 1.5
	local modUnit = rUnit * 0.7
	local paddingY = staticPadding + (modUnit * index)
	local paddingX = rUnit * 0.5
	local textFieldSqueeze = rUnit * 0.05
	local divX = rUnit * 0.10

	--Icon
	local iconAnchor = vec2(paddingX, paddingY)
	local iconPoint = vec2(iconAnchor.x + modUnit, iconAnchor.y + modUnit)
	local iconRect = Neltharaku.ShrinkRect(Rect(iconAnchor, iconPoint), rUnit * 0.1)
	local icon = infobox:createPicture(iconRect, nil)
	icon.isIcon = true

	--Text -title
	local labelAnchor = vec2(iconPoint.x + divX, paddingY + textFieldSqueeze)
	local labelPoint = vec2(labelAnchor.x + modUnit * 4, labelAnchor.y + modUnit - textFieldSqueeze)
	local labelRect = Rect(labelAnchor, labelPoint)
	local label = infobox:createTextField(labelRect, '')
	label.fontSize = rUnit * 0.2

	--Text -meaning
	local valueAnchor = vec2(labelPoint.x, paddingY + textFieldSqueeze)
	local valuePoint = vec2(valueAnchor.x + modUnit * 5.5, valueAnchor.y + modUnit - textFieldSqueeze)
	local valueRect = Rect(valueAnchor, valuePoint)
	local value = infobox:createTextField(valueRect, '')
	value.fontSize = rUnit * 0.2

	return icon, label, value, valuePoint.y
end

-----------------------------[DATA: ACTIVE]------------------------------------------
entities['bastionSystem'] = {
	--Icon
	getTechIcon('bastionsystem'),
	--Name
	getTechName('bastionsystem'),
	--Description
	{
		"A unique system designed to be installed on ships based on a shield. Modifies the ship's shields, reducing their volume, but in return increases their charging speed and reduces the time before it starts.\nActive Bastion systems allow you to reduce damage to the shield at the cost of reducing weapons fire rate (while repairing the hull), accumulate a charge from the damage received to replenish the shield, make it temporarily impenetrable, and also instantly destroy hostile torpedoes for a short time" %
		_t,
		1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ "data/textures/icons/health-normal.png", "Shield Durability" % _t,  '- (rand(27,31) - R * 2)%' },
		{ "data/textures/icons/shield-charge.png", "Shield Recharge Rate" % _t, '+ (rand(14,19) + R * 3)%' },
		{ "data/textures/icons/recharge-time.png", "Time Until Recharge" % _t, '- (rand(19,21) + R * 2)%' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('bastionsystem', 1),

			getSubtechName('bastionsystem', 1),
			"Activating the module increases the shield's resistance to all damage, and also slowly restores the ship's hull. During the operation of the module, the rate of fire of all weapons drops" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('bastionsystem', 2),

			getSubtechName('bastionsystem', 2),
			"Plasma, energy and electrical damage received by the shield accumulates a charge that can be used to restore shields" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('bastionsystem', 3),

			getSubtechName('bastionsystem', 3),
			"Activation makes the shields impenetrable for the duration of the module. Also, for a short time after activation, the delay before regeneration after receiving damage is significantly reduced" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('bastionsystem', 4),

			getSubtechName('bastionsystem', 4),
			"During operation, your ship will automatically and instantly shoot down all torpedoes that are aimed at it, as well as all hostile torpedoes within the range of the module. Anti-aircraft weapons are not required for operation" %
			_t,

			1 -- description window height modifier from standard
		},
	},
}

entities['macrofieldProjector'] = {
	--Icon
	getTechIcon('macrofieldprojector'),
	--Name
	getTechName('macrofieldprojector'),
	--Description
	{
		"A special system designed to fully specialize ship to repair-class at the cost of a significant reduction in defensive and offensive capabilities. To achieve an acceptable amount of repairs per second, it is necessary to turn the ship into a flying battery, since three of the four active systems directly depend on its volume (and on the rate of energy replenishment).\nActive systems allow you to send a beam to an ally restoring the hull or shield, absorbing battery energy for operation, or, in critical situations, at the cost of huge energy costs, activate mass repairs of the hull in a large radius.\nIn addition, it allows you to link the shields of your and any other player's ship, gradually equalizing their percentage of volume" %
		_t,
		1.4, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ 'data/textures/icons/electric.png',         "Generated Energy" % _t, '+ 20 + R * 4 %' },
		{ "data/textures/icons/battery-pack-alt.png", "Energy Capacity" % _t, '+ 130 + R * 15 %' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('macrofieldprojector', 1),

			getSubtechName('macrofieldprojector', 1),

			string.format(
			"Activating the module burns the ship's energy very quickly, restoring the hull to all allied ships of the players. This effect also works on the ship itself, restoring the increased volume of the hull to it. Wave activation disables %s and %s" %
			_t, getSubtechName('macrofieldprojector', 2), getSubtechName('macrofieldprojector', 3)),

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('macrofieldprojector', 2),

			getSubtechName('macrofieldprojector', 2),
			"Gradually burns the battery's energy reserve, repairing the hull of the selected allied ship. The amount of repair directly depends on the amount of energy burned. The beam does not work if the target has flown out of range or if its hull is 100%. Activation turns off the operation of the 'Shield Amplifier'.\nWorks only on ships owned by players!" %
			_t,

			1.1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('macrofieldprojector', 3),

			getSubtechName('macrofieldprojector', 3),
			"Works as a 'Renovation ray', but restores the shields of an allied target. The amount of repair directly depends on the amount of energy burned. The booster does not work if the target has flown out of range, if its shields have dropped below the minimum threshold, or if they have reached 100%. Activation disables the operation of the 'Renovation ray'.\nWorks only on ships owned by players!" %
			_t,

			1.2 -- description window height modifier from standard
		},

		{
			getSubtechIcon('macrofieldprojector', 4),

			getSubtechName('macrofieldprojector', 4),
			'Forms a link between your ship and the target. The module will gradually syphon the shields in both directions, trying to equalize their percentage. It does not consume energy and can work independently of the other three modules./nWorks only on ships owned by players!' %
			_t,

			1 -- description window height modifier from standard
		},
	},
}

entities['repairDrones'] = {
	--Icon
	getTechIcon('repairdrones'),
	--Name
	getTechName('repairdrones'),
	--Description
	{
		"Designed for combat vessels based on the hull. When installed, it slightly increases its volume and provides a unique bonus in the form of accelerated repairs when the hull is at a critical level. Active systems allow you to accelerate repairs in combat, increase the chances of surviving in a dangerous situation and restore hull faster out of combat" %
		_t,
		1.1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ 'data/textures/icons/staDurability.png', "Hull Durability" % _t,    '+ (6 + R * 3)%' },
		{ "data/textures/icons/staRepair.png",     "Auto-repair treshold" % _t, '+ (10 + R * 2)%' },
		{ "data/textures/icons/staRepair.png",     "Auto-repair value" % _t,  '0.2% / s.' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('repairdrones', 1),

			getSubtechName('repairdrones', 1),
			"Activation of this system restores hull for a limited time. However, this system will not restore hull if its volume exceeds 50%" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('repairdrones', 2),

			getSubtechName('repairdrones', 2),
			"Gradually restores the hull for a long time, works even in the negative environment of rifts. Receiving any damage or repairs with the help of repair lasers interrupts the operation of the module and reduces the remaining recharge time by 60%" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('repairdrones', 3),

			getSubtechName('repairdrones', 3),
			"Activation puts the module in standby mode for 20 seconds. If during this time hull durability falls below a certain value, the module turns on, simultaneously restoring a certain percentage of hull and accelerates passive repair three times" %
			_t,

			1 -- description window height modifier from standard
		},

	},
}

entities['XperimentalHypergenerator'] = {
	--Icon
	getTechIcon('xperimentalhypergenerator'),
	--Name
	getTechName('xperimentalhypergenerator'),
	--Description
	{
		"An excellent module for risky travel and exploration. Slightly increases the jump range and reduces its cooldown at the cost of a decent increase in energy consumption.\nThe active systems of this module allow you to significantly increase the jump range at the cost of increasing the recharge time after its execution, accelerate the charging of the hyperdrive in critical situations and sacrifice the combat capability of the ship to get additional survival during the calculation of the jump route" %
		_t,
		1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ "data/textures/icons/hourglass.png",  "Hyperspace Cooldown" % _t,    '+ (rand(8,12) + R * 3)%' },
		{ "data/textures/icons/electric.png",   "Hyperspace Charge Energy" % _t, '+ (rand(37,43) - R * 2)%' },
		{ "data/textures/icons/star-cycle.png", "Jump Range" % _t,             '- (rand(1,3) + R)%' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('xperimentalhypergenerator', 1),

			getSubtechName('xperimentalhypergenerator', 1),
			"Activation puts the module into standby mode. As soon as the ship begins to calculate the jump route, the module is activated and begins to quickly restore shields, while the rate of fire of the weapons will be seriously reduced before the jump" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('xperimentalhypergenerator', 2),

			getSubtechName('xperimentalhypergenerator', 2),
			"The activation of the module greatly accelerates the recharge of the hyperdrive, causing damage to the ship's hull during operation. For the module to work, it is necessary that the volume of the ship's shields fall below a certain threshold" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('xperimentalhypergenerator', 3),

			getSubtechName('xperimentalhypergenerator', 3),
			"Activation requires additional hyperdrive charging (cannot be performed if the hyperdrive is still charging) and increases the allowable jump range by more than twice. Adds extra time to recharge after performing a jump, depending on the range bonus provided." %
			_t,

			1 -- description window height modifier from standard
		},
	},
}

entities['pulseTractorBeamGenerator'] = {
	--Icon
	getTechIcon('pulsetractorbeamgenerator'),
	--Name
	getTechName('pulsetractorbeamgenerator'),
	--Description
	{
		"Does not provide any passive bonuses. It is equipped with only one active system, which gradually expands the radius of the attracting beam to large values, allowing you to collect loot in a huge radius during the action" %
		_t,
		1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ "data/textures/icons/SYSpReactor3.png", "Number of pulses" % _t, '+ ((R+2) * 4)' },
		{ "data/textures/icons/SYSpReactor3.png", "Range" % _t,          '+ 200' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('pulsetractorbeamgenerator', 1),

			getSubtechName('pulsetractorbeamgenerator', 1),
			"During operation, every two seconds it makes an impulse that increases the range of the attracting beam by a fixed value. The number of pulses depends on the rarity level of the system. At the end of the work, the beam range returns to the initial value" %
			_t,

			1 -- description window height modifier from standard
		},
	},
}
-----------------------------[DATA: PASSIVE]----------------------------

entities['subspaceCargo'] = {
	--Icon
	getTechIcon('subspacecargo'),
	--Name
	getTechName('subspacecargo'),
	--Description
	{
		"Using rift technology creates a stable subspace storage" % _t,
		1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ 'data/textures/icons/crate.png',         "Cargo Hold (relative)" % _t, '+ (rand(31,35) + R * 4)%' },
		{ "data/textures/icons/electric.png",      "Generated Energy" % _t,    '- (rand(14,18) - R)%' },
		{ "data/textures/icons/health-normal.png", "Shield Durability" % _t,   '- (rand(11,15) - R)%' },
	},
	--Active Effects
	nil,
}
