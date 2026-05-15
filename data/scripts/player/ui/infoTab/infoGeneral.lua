package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')
include('Tech')
include('Stations')

--namespace infoGeneral
infoGeneral = {}

local _debug = false
function infoGeneral.DebugMsg(_text)
	if _debug then
		print('infoGeneral|', _text)
	end
end

local Debug = infoGeneral.DebugMsg
local RR = Neltharaku.ReportRect
local V2R = Neltharaku.ReportVec2
local dF = Neltharaku.debugFrame
local ApplyBorder = Neltharaku.GLapplyBorderFrame
local TSR = Neltharaku.TableSelfReport

local locNames = {}
locNames['weaponsnew'] = 'Weapons - New' % _t
locNames['weaponsvanilla'] = 'Weapons - Vanilla Changes' % _t
locNames['systemsnew'] = 'Systems - New' % _t
locNames['stationssnew'] = 'Stations - New' % _t
locNames['uinew'] = 'Interfaces - New' % _t

local order = {
	--Name,id,i dupdate
	{ locNames['weaponsnew'],     'weaponclasses',   0.1 },
	{ locNames['weaponsnew'],     'weaponnew',       0.1 },
	{ locNames['weaponsvanilla'], 'weaponrebalance', 0.1 },
	{ locNames['systemsnew'],     'systemnew',       0.1 },
	{ locNames['stationssnew'],   'stationnew',      0.1 },
	{ locNames['uinew'],          'alertsystem',     0.1 },
	{ locNames['uinew'],          'combatgroup',     0.1 },
	{ locNames['uinew'],          'asi',             0.3 },
	{ locNames['uinew'],          'auracore',        0.2 },
}

local entities = {}
--1 name
--2 modname
--3 data

local icons = {}
icons['pulseTractorBeamGenerator'] = 'data/textures/icons/SYSpReactor3.png'

local self = infoGeneral
local listboxLabelSizeK = 0.7      -- rUnit size factor for label listboxes (for lister)
local listboxLabelFontSizeK = 0.32 -- Text size factor rUnit for label listboxes
local stColor = getTypeColorByWeapon()

function infoGeneral.SetEntitiesV2(container, rUnit, gUK)
	Debug('infoGeneral.SetEntitiesV2 gUK is ' .. tostring(gUK))

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
function infoGeneral.createLabel(y, container, rUnit, name)
	local yMod = y + rUnit * 0.5

	local labelAnchor = vec2(0, y)
	local labelPoint = vec2(container.width * 0.98, yMod)
	local labelRect = Rect(labelAnchor, labelPoint)

	local label = container:createLabel(labelRect, name, rUnit * listboxLabelFontSizeK)

	return yMod
end

--Creates a labelBox for a list at LEFT
function infoGeneral.createBox(y, container, height, rowsize)
	local yMod = y + height

	local boxAnchor = vec2(0, y)
	local boxPoint = vec2(container.width * 0.98, yMod)
	local boxRect = Rect(boxAnchor, boxPoint)

	local label = container:createListBoxEx(boxRect)

	return yMod, label
end

--Creates an infobox list for RIGHT
function infoGeneral.GetInfoContainers(container, rUnit)
	local _result = {}

	for _key, _rows in pairs(entities) do
		local stType = _key
		local infobox = self.SetMain(stType, container, rUnit)
		_result[_key] = infobox
	end
	return _result
end

--Generates infobox
function infoGeneral.SetMain(stType, baseContainer, rUnit)
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
	local data = chosenTable[3]
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
function infoGeneral.CreateDescription(y, container, height, rUnit)
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
function infoGeneral.CreatePicture(y, container, height, rUnit)
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
function infoGeneral.CreateIconLabel(y, container, rUnit)
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
function infoGeneral.CreateMainLabel(y, container, rUnit)
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

function infoGeneral.CreateLine(y, container, rUnit)
	local yMod = y + rUnit * 0.25
	local v1 = vec2(rUnit * 0.25, y)
	local v2 = vec2(container.width - rUnit * 0.25, y)
	container:createLine(v1, v2)
	return yMod
end

-----------------------------[DATA: MOD]----------------------------

--Types: desc,picture,iconinfo,mainlabel

entities['weaponclasses'] = {
	--Name
	'Weapon class ' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                     -- Item type
			nil,                             -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ASSAULTBLASTER.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"A new characteristic of weapon: 'class' determines the behavior of various types of weapons in some situations. You can see the class of the gun in the information panel of the turret, the corresponding line will be located at the very top" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                          -- Item type
			nil,                                 -- Height (nil for iconname/mainlabel)
			'data/textures/icons/weapon/wpnCyclone2.png', -- Content. Text or path to the image.
			'Weapon class - Main Caliber' % _t   -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			"Extremely powerful weapons, which have a huge fire power after assebmbly at the stations, surpassing any other types of weapons. Each ship can use a maximum of two 'main caliber' class weapons without consequences, otherwise the ship receives a serious penalty to the rate of fire. These weapons cannot be used in the production of fighters" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                                -- Item type
			nil,                                       -- Height (nil for iconname/mainlabel)
			'data/textures/icons/weapon/wpnMagneticmortar.png', -- Content. Text or path to the image.
			'Weapon class - Light' % _t                -- Content for icon info
		},
		{
			'desc', -- Item type
			3, -- Height (nil for iconname/mainlabel)
			"Usually, light-class weapons have modest characteristics, inferior to other weapons systems in almost all parameters, however, this situation changes during the production of fighters.\nEach gun has its own unique bonus to fighter basic characteristics, depending on the technical level of the turret, a bonus (or penalty) to the firing range, and also, most importantly, when producing a fighter, a different damage coefficient is applied to the turrets from the standard:\nCombat turrets - 105% instead of 40%\nRepair and other turrets - 80% instead of 40%" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                            -- Item type
			nil,                                   -- Height (nil for iconname/mainlabel)
			'data/textures/icons/weapon/wpnIonEmitter.png', -- Content. Text or path to the image.
			'Weapon class - Heavy' % _t            -- Content for icon info
		},
		{
			'desc',                                                           -- Item type
			0.6,                                                              -- Height (nil for iconname/mainlabel)
			'Weapons of this class cannot be used in the production of fighters' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                     -- Item type
			nil,                            -- Height (nil for iconname/mainlabel)
			'data/textures/icons/weapon/wpnPrd.png', -- Content. Text or path to the image.
			'Weapon class - Standard' % _t  -- Content for icon info
		},
		{
			'desc',                                          -- Item type
			0.6,                                             -- Height (nil for iconname/mainlabel)
			'Conventional weapons using standard Avorion rules' % _t, -- Content. Text or path to the image.
		},
	},
}

entities['weaponnew'] = {
	--Name
	'New weapons' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                   -- Item type
			nil,                           -- Height (nil for iconname/mainlabel)
			'data/textures/icons/HYPERKINETIC.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                              -- Item type
			1.1,                                                                                                 -- Height (nil for iconname/mainlabel)
			"17 new weapons have been added to the game. You can find out more about each one in the tab 'Weapons'" % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',       -- Item type
			nil,              -- Height (nil for iconname/mainlabel)
			getWeaponPath('pulsegun'), -- Content. Text or path to the image.
			getWeaponName('pulsegun') -- Content for icon info
		},
		{
			'desc',                                                                    -- Item type
			1,                                                                         -- Height (nil for iconname/mainlabel)
			'Class: Standard. Rapid-fire low- and medium range weapon. does not overheat' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                  -- Item type
			nil,                         -- Height (nil for iconname/mainlabel)
			getWeaponPath('particleaccelerator'), -- Content. Text or path to the image.
			getWeaponName('particleaccelerator') -- Content for icon info
		},
		{
			'desc',                                            -- Item type
			1,                                                 -- Height (nil for iconname/mainlabel)
			'Class: Standard. Light accurate medium-range weapon' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',             -- Item type
			nil,                    -- Height (nil for iconname/mainlabel)
			getWeaponPath('assaultblaster'), -- Content. Text or path to the image.
			getWeaponName('assaultblaster') -- Content for icon info
		},
		{
			'desc',                                                                               -- Item type
			1.4,                                                                                  -- Height (nil for iconname/mainlabel)
			'Class: Standard. Medium-range rapid-fire weapon that deals increased damage to shields' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',   -- Item type
			nil,          -- Height (nil for iconname/mainlabel)
			getWeaponPath('hept'), -- Content. Text or path to the image.
			getWeaponName('hept') -- Content for icon info
		},
		{
			'desc',                                              -- Item type
			1.4,                                                 -- Height (nil for iconname/mainlabel)
			'Class: Standard. Universal medium-range plasma cannon' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',     -- Item type
			nil,            -- Height (nil for iconname/mainlabel)
			getWeaponPath('mantis'), -- Content. Text or path to the image.
			getWeaponName('mantis') -- Content for icon info
		},
		{
			'desc',                                                                          -- Item type
			1.4,                                                                             -- Height (nil for iconname/mainlabel)
			'Class: Standard. Long-range homing weapon designed to deal against mobile targets' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',  -- Item type
			nil,         -- Height (nil for iconname/mainlabel)
			getWeaponPath('prd'), -- Content. Text or path to the image.
			getWeaponName('prd') -- Content for icon info
		},
		{
			'desc',                                                                 -- Item type
			1.4,                                                                    -- Height (nil for iconname/mainlabel)
			'Class: Standard. Powerful, but not very accurate rail-type plasma weapon' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',         -- Item type
			nil,                -- Height (nil for iconname/mainlabel)
			getWeaponPath('plasmaflak'), -- Content. Text or path to the image.
			getWeaponName('plasmaflak') -- Content for icon info
		},
		{
			'desc',                                             -- Item type
			1.4,                                                -- Height (nil for iconname/mainlabel)
			'Class: Defensive. Rapid-fire weapon against fighters' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',         -- Item type
			nil,                -- Height (nil for iconname/mainlabel)
			getWeaponPath('pulselaser'), -- Content. Text or path to the image.
			getWeaponName('pulselaser') -- Content for icon info
		},
		{
			'desc',                                                                  -- Item type
			1.4,                                                                     -- Height (nil for iconname/mainlabel)
			'Class: Light. A rapid-firing light low-range weapon designed for fighters' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',            -- Item type
			nil,                   -- Height (nil for iconname/mainlabel)
			getWeaponPath('assaultcannon'), -- Content. Text or path to the image.
			getWeaponName('assaultcannon') -- Content for icon info
		},
		{
			'desc',                                                                                            -- Item type
			1.4,                                                                                               -- Height (nil for iconname/mainlabel)
			'Class: Light. A versatile powerful, but not very accurate medium-range weapon designed for fighters' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',             -- Item type
			nil,                    -- Height (nil for iconname/mainlabel)
			getWeaponPath('magneticmortar'), -- Content. Text or path to the image.
			getWeaponName('magneticmortar') -- Content for icon info
		},
		{
			'desc',                                                      -- Item type
			1.4,                                                         -- Height (nil for iconname/mainlabel)
			'Class: Light. A long-range siege weapon designed for fighters' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',         -- Item type
			nil,                -- Height (nil for iconname/mainlabel)
			getWeaponPath('nanorepair'), -- Content. Text or path to the image.
			getWeaponName('nanorepair') -- Content for icon info
		},
		{
			'desc',                                                         -- Item type
			1.4,                                                            -- Height (nil for iconname/mainlabel)
			'Class: Light. Beam weapon for hull repair, designed for fighters' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',           -- Item type
			nil,                  -- Height (nil for iconname/mainlabel)
			getWeaponPath('chargingbeam'), -- Content. Text or path to the image.
			getWeaponName('chargingbeam') -- Content for icon info
		},
		{
			'desc',                                                              -- Item type
			1.4,                                                                 -- Height (nil for iconname/mainlabel)
			'Class: Light. A beam gun for repairing shields, designed for fighters' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',           -- Item type
			nil,                  -- Height (nil for iconname/mainlabel)
			getWeaponPath('photoncannon'), -- Content. Text or path to the image.
			getWeaponName('photoncannon') -- Content for icon info
		},
		{
			'desc',                                                       -- Item type
			1.4,                                                          -- Height (nil for iconname/mainlabel)
			'Class: Heavy. A powerful siege weapon designed for heavy ships' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',         -- Item type
			nil,                -- Height (nil for iconname/mainlabel)
			getWeaponPath('ionemitter'), -- Content. Text or path to the image.
			getWeaponName('ionemitter') -- Content for icon info
		},
		{
			'desc',                                                                                              -- Item type
			1.4,                                                                                                 -- Height (nil for iconname/mainlabel)
			'Class: Heavy. A powerful siege weapon designed for heavy ships. Deals serious damage to enemy shields' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',           -- Item type
			nil,                  -- Height (nil for iconname/mainlabel)
			getWeaponPath('hyperkinetic'), -- Content. Text or path to the image.
			getWeaponName('hyperkinetic') -- Content for icon info
		},
		{
			'desc', -- Item type
			1.4, -- Height (nil for iconname/mainlabel)
			'Class: Main Caliber. High-powered sniper weapon capable of destroying vulnerable targets with a single shot' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',        -- Item type
			nil,               -- Height (nil for iconname/mainlabel)
			getWeaponPath('avalanche'), -- Content. Text or path to the image.
			getWeaponName('avalanche') -- Content for icon info
		},
		{
			'desc', -- Item type
			1.4, -- Height (nil for iconname/mainlabel)
			'Class: Main Caliber. A siege weapon capable of inflicting massive damage to slow and stationary targets' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',      -- Item type
			nil,             -- Height (nil for iconname/mainlabel)
			getWeaponPath('cyclone'), -- Content. Text or path to the image.
			getWeaponName('cyclone') -- Content for icon info
		},
		{
			'desc', -- Item type
			1.4, -- Height (nil for iconname/mainlabel)
			'Class: Main Caliber. A weapon capable of inflicting great damage to any targets at a long distance, but in need of a long recharge' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',          -- Item type
			nil,                 -- Height (nil for iconname/mainlabel)
			getWeaponPath('transphasic'), -- Content. Text or path to the image.
			getWeaponName('transphasic') -- Content for icon info
		},
		{
			'desc',                                                                                   -- Item type
			1.4,                                                                                      -- Height (nil for iconname/mainlabel)
			'Class: Main Caliber. A universal laser heavy weapon that deals good damage at medium range' % _t, -- Content. Text or path to the image.
		},
	},
}

entities['weaponrebalance'] = {
	--Name
	'Vanilla weapons changes' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',             -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			'data/textures/icons/turret.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"Almost all vanilla weapons have changes that somehow increase their combat potential. This also affects opponents, making them more dangerous. The full list of changes is available in the 'Weapons' tab" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                -- Item type
			nil,                       -- Height (nil for iconname/mainlabel)
			"data/textures/icons/chaingun.png", -- Content. Text or path to the image.
			'Chaingun' % _t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			'Class: Standard. Base damage increased. The damage, range and speed of the projectile will increase further with the technical level' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                 -- Item type
			nil,                        -- Height (nil for iconname/mainlabel)
			"data/textures/icons/laser-gun.png", -- Content. Text or path to the image.
			'Laser' % _t                -- Content for icon info
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			'Class: Standard. The base damage is increased and range is slightly reduced. Now it pierces up to two blocks. During assembly, it receives bonus damage on shields' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                  -- Item type
			nil,                         -- Height (nil for iconname/mainlabel)
			"data/textures/icons/plasma-gun.png", -- Content. Text or path to the image.
			'Plasma Gun' % _t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			"Class: Standard. The base damage is increased and additionally increases with the tech level. The base range also increases slightly with the tech level. Bonus damage to shields increases during assembly" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                       -- Item type
			nil,                              -- Height (nil for iconname/mainlabel)
			"data/textures/icons/rocket-launcher.png", -- Content. Text or path to the image.
			'Rocket Launcher' % _t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			'Class: Heavy. The class has been changed, the damage has been increased, the assembly bonuses have been redesigned. During production, it is possible to increase the flight speed of missiles, but the range has become lower' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',              -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			"data/textures/icons/cannon.png", -- Content. Text or path to the image.
			'Cannon' % _t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			"Class: Heavy. The class has been changed. The base damage has been increased, and the weapon now receives a base bonus to damage on shields and hull. Can no longer receive the Antimatter damage type. Gets big bonuses during assembly" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                -- Item type
			nil,                       -- Height (nil for iconname/mainlabel)
			"data/textures/icons/rail-gun.png", -- Content. Text or path to the image.
			'Railgun' % _t             -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Heavy. The class has been changed. The logic of use has been redesigned - now it is a low- and medium-range weapon operating like a slug gun' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                   -- Item type
			nil,                          -- Height (nil for iconname/mainlabel)
			"data/textures/icons/repair-beam.png", -- Content. Text or path to the image.
			'Repair Laser' % _t           -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Standard. The basic repair has been greatly increased and will be further increased with tech level. During assembly, the range is greatly increased' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',              -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			"data/textures/icons/bolter.png", -- Content. Text or path to the image.
			'Bolter' % _t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Standard. The base damage is increased, the threshold of the minimum rate of fire is increased, and the base speed of the projectile will increase with the tech level. Gets more bonuses during assembly' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                     -- Item type
			nil,                            -- Height (nil for iconname/mainlabel)
			"data/textures/icons/lightning-gun.png", -- Content. Text or path to the image.
			'Lightning Gun' % _t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Heavy. The class has been changed. The base damage is increased, the rate of fire is significantly reduced (does not affect damage). Receives strong bonuses during assembly' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                 -- Item type
			nil,                        -- Height (nil for iconname/mainlabel)
			"data/textures/icons/tesla-gun.png", -- Content. Text or path to the image.
			'Tesla Gun' % _t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			"Class: Standard. Shield damage increased. Can no longer receive the type of damage 'plasma', however, during assembly, the damage to shields increases significantly, as well as normal damage" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                   -- Item type
			nil,                          -- Height (nil for iconname/mainlabel)
			"data/textures/icons/pulsecannon.png", -- Content. Text or path to the image.
			'Pulse Cannon' % _t           -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Standard. Base damage is noticeably increased. The range of fire and the speed of the projectile will increase with tech level. Assembly bonuses are increased' %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['systemnew'] = {
	--Name
	'New systems' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                       -- Item type
			nil,                               -- Height (nil for iconname/mainlabel)
			'data/textures/icons/STArepairPassive.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"The mod contains new ship systems that allow you to more accurately specialize vessels for various tasks. Some of them are active - in addition to providing passive bonuses, they supplement their effect with interactive abilities.\n Learn more in the 'systems' tab" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                       -- Item type
			nil,                              -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSrepairDrones.png', -- Content. Text or path to the image.
			getTechName('repairdrones')       -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			"Designed to improve the survival ability of hull-based ships.\nIncreases  durability, applies additional passive repair in case of serious damage. Active abilities are aimed at repairing hull" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                         -- Item type
			nil,                                -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYShypergenerator.png', -- Content. Text or path to the image.
			getTechName('xperimentalhypergenerator') -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			'A system for heavy carrier ships and scouts. Increases the chances of leaving the sector after an unlucky warp into an enemy fleet.\nImproves the jump range and cooldown, but increases the energy consumption of the jump.\nActive abilities affect jump range, charging speed, and survival before jumping' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                  -- Item type
			nil,                         -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSbastion.png', -- Content. Text or path to the image.
			getTechName('bastionsystem') -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			'Designed for heavy shield-based ships.\nReduces the volume of the shield, but increases its regeneration and reduces the time before charging.\nActive abilities allow you to strengthen the shield, restore it, make it impenetrable and completely protect yourself from any torpedoes for a while' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                              -- Item type
			nil,                                     -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSmacrofieldprojector.png', -- Content. Text or path to the image.
			getTechName('macrofieldprojector')       -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			"Designed to specialize ship into repair class. Uses the ship's battery to generate repair beams or a powerful repair field" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                     -- Item type
			nil,                            -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSpReactor3.png', -- Content. Text or path to the image.
			getTechName('pulsetractorbeamgenerator') -- Content for icon info
		},
		{
			'desc',                                                                            -- Item type
			2,                                                                                 -- Height (nil for iconname/mainlabel)
			'Allows you to temporarily accelerate the radius of the tractor beam to large values' % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                        -- Item type
			nil,                               -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSsubspacecargo.png', -- Content. Text or path to the image.
			getTechName('subspacecargo')       -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			'Improves the cargo bay, but reduces energy production and slightly reduces the shields. Always a percentage bonus' %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['stationnew'] = {
	--Name
	'New stations' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',              -- Item type
			nil,                      -- Height (nil for iconname/mainlabel)
			'data/textures/icons/station.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                         -- Item type
			1.3,                                                                            -- Height (nil for iconname/mainlabel)
			"New stations added by modification. For more information, see the 'stations' tab" % _t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                      -- Item type
			nil,                             -- Height (nil for iconname/mainlabel)
			'data/textures/icons/MCXmegaComplex.png', -- Content. Text or path to the image.
			getStationName('mx')             -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			'Megacomplex is a station that allows you to set up automatic and fast logistics of resources between all docked stations' %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['alertsystem'] = {
	--Name
	'Alert system' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                            -- Item type
			nil,                                    -- Height (nil for iconname/mainlabel)
			'data/textures/icons/alert/AlertDeadTurret.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			'A system of visual and audio alerts. The graphical part in the form of an icon appears on the right side of the screen and unfolds when the cursor is hovered over. The current working types of alerts are indicated in the corresponding tab' %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['combatgroup'] = {
	--Name
	'Combat group' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                   -- Item type
			nil,                           -- Height (nil for iconname/mainlabel)
			'data/textures/icons/FederationSC.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"Graphical interface for working with a group of players. Allows you to search, invite to a group, kick players and transfer leadership without the need to use chat commands. For more information, see the 'interfaces' tab" %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['asi'] = {
	--Name
	'Active System Interface' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                     -- Item type
			nil,                             -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_circutry.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                -- Item type
			1.3,                                                                                   -- Height (nil for iconname/mainlabel)
			"Customizable interface that provides access to the active systems installed on the ship" % _t, -- Content. Text or path to the image.
		},
	},
}

entities['auracore'] = {
	--Name
	'Active effects' % _t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                          -- Item type
			nil,                                  -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_invitePending.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                  -- Item type
			1.3,                                                                                     -- Height (nil for iconname/mainlabel)
			"An interface that displays active effects from the Cosmic Starfall mod affecting the ship" % _t, -- Content. Text or path to the image.
		},
	},
}
