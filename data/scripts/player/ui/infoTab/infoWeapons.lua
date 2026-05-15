package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

--namespace infoWeapons
infoWeapons = {}

local _debug = false
function infoWeapons.DebugMsg(_text)
	if _debug then
		print('infoWeapons|', _text)
	end
end

local Debug = infoWeapons.DebugMsg
local RR = Neltharaku.ReportRect
local V2R = Neltharaku.ReportVec2
local dF = Neltharaku.debugFrame
local ApplyBorder = Neltharaku.GLapplyBorderFrame
local TSR = Neltharaku.TableSelfReport

local classST = 'Cosmic Starfall - Standard Weapons' % _t
local classLI = 'Cosmic Starfall - Light Weapons' % _t
local classHE = 'Cosmic Starfall - Heavy Weapons' % _t
local classMC = 'Cosmic Starfall - Main Caliber Weapons' % _t
local classVST = 'Vanilla - Standard' % _t
local classVHE = 'Vanilla - Heavy' % _t

local order = {
	--name,ID,IDupdate
	--Standard
	{ classST,  'pulsegun',            0.1 },
	{ classST,  'particleaccelerator', 0.1 },
	{ classST,  'assaultblaster',      0.1 },
	{ classST,  'hept',                0.1 },
	{ classST,  'mantis',              0.1 },
	{ classST,  'prd',                 0.1 },
	{ classST,  'plasmaflak',          0.1 },
	--Lungs
	{ classLI,  'pulselaser',          0.1 },
	{ classLI,  'assaultcannon',       0.1 },
	{ classLI,  'magneticmortar',      0.1 },
	{ classLI,  'nanorepair',          0.1 },
	{ classLI,  'chargingbeam',        0.1 },
	--Heavy
	{ classHE,  'photoncannon',        0.1 },
	{ classHE,  'ionemitter',          0.1 },
	--Caliber
	{ classMC,  'hyperkinetic',        0.1 },
	{ classMC,  'avalanche',           0.1 },
	{ classMC,  'cyclone',             0.1 },
	{ classMC,  'transphasic',         0.1 },
	--Vanilla -standard
	{ classVST, 'chaingun',            0.1 },
	{ classVST, 'laser',               0.1 },
	{ classVST, 'plasmagun',           0.1 },
	{ classVST, 'repairbeam',          0.1 },
	{ classVST, 'bolter',              0.1 },
	{ classVST, 'tesla',               0.1 },
	{ classVST, 'pulsecannon',         0.1 },
	--Vanilla -heavy
	{ classVHE, 'launcher',            0.1 },
	{ classVHE, 'cannon',              0.1 },
	{ classVHE, 'railgun',             0.1 },
	{ classVHE, 'lightinggun',         0.1 },
}

local entities = {}
--1 icon
--2 name
--3 distance
--4 accuracy
--5 fireSpeed
--6 damageType
--7 desc/info
--8 changes(table)
--9 mod

local icons = {}
icons['class'] = 'data/textures/icons/ASSAULTBLASTER.png'
icons['dtype'] = 'data/textures/icons/ammo-box.png'
icons['accuracy'] = 'data/textures/icons/weaponInfo/uiAim.png'
icons['projSpeed'] = 'data/textures/icons/PARTICLEACCELERATOR.png'
icons['distance'] = 'data/textures/icons/adopt.png'
icons['firerate'] = 'data/textures/icons/bullets.png'

local rangeType = {}
rangeType['s'] = 'small' % _t
rangeType['s-m'] = 'small to medium' % _t
rangeType['m'] = 'medium' % _t
rangeType['m-h'] = 'medium to high' % _t
rangeType['h'] = 'high' % _t
rangeType['h+'] = 'very high' % _t
rangeType['h++'] = 'extremely high' % _t

local accuracyType = {}
accuracyType['l'] = 'poor' % _t
accuracyType['m'] = 'medium' % _t
accuracyType['h'] = 'good' % _t
accuracyType['ho'] = 'homing' % _t
accuracyType['m-ho'] = 'medium to homing' % _t
accuracyType['va'] = 'very accurate' % _t

local fireRateType = {}
fireRateType['ul'] = 'ultra low' % _t
fireRateType['l'] = 'low' % _t
fireRateType['m'] = 'medium' % _t
fireRateType['m-h'] = 'medium to high' % _t
fireRateType['h'] = 'high' % _t
fireRateType['h+'] = 'very high' % _t

local damageType = {}
damageType['phys'] = 'physical' % _t
damageType['am'] = 'anti-matter' % _t
damageType['elec'] = 'electric' % _t
damageType['plasma'] = 'plasma' % _t
damageType['ener'] = 'energy' % _t
damageType['part'] = 'particles' % _t
damageType['no'] = 'no' % _t

local descDetails = {}
descDetails['inc'] = 'increased' % _t
descDetails['dec'] = 'decreased' % _t

descDetails['bonusdamageincrease'] = 'Base damage increased by ' % _t
descDetails['bonusrangeincrease'] = 'Base range increased by ' % _t
descDetails['bonusrangedecrease'] = 'Base range decreased by ' % _t
descDetails['bonusToHull'] = 'Base damage to hull increased by ' % _t
descDetails['bonusToShields'] = 'Base damage to shields increased by ' % _t
descDetails['bonusRepair'] = 'Base repair amount increased by ' % _t

descDetails['accemblyDamageByParts'] = 'When assembling, damage bonus from parts ' % _t
descDetails['accemblyFirerateByParts'] = 'When assembling, rate of fire bonus from parts ' % _t
descDetails['accemblyRangeByParts'] = 'When assembling, range bonus from parts ' % _t

descDetails['newpartDamageToHull'] = 'When assembling, a new part that adds a bonus damage to the hull' % _t
descDetails['newpartDamageToShield'] = 'When assembling, a new part that adds a bonus damage to the shields' % _t
descDetails['newpartProjSpeed'] = 'When assembling, a new part that adds a bonus speed to the projectile' % _t
descDetails['newpartBattery'] = 'When assembling, a new part that adds a bonus to battery/overheating' % _t

descDetails['techleveltoprojspeed'] = 'Base projectile speed will increase with the tech level' % _t
descDetails['techleveltorange'] = 'Base firing range will increase with the tech level' % _t
descDetails['techleveltodamage'] = 'Base damage will increase with the tech level' % _t
descDetails['techleveltorepair'] = 'Base repair rate will increase with the tech level' % _t

descDetails['morepartsDamage'] = 'More parts to damage bonus' % _t
descDetails['morepartsRange'] = 'More parts to range bonus' % _t
descDetails['morepartsBattery'] = 'More parts to battery/overheat bonus' % _t

descDetails['lesspartsRange'] = 'Less parts to range bonus' % _t

descDetails['classToHeavy'] = "Weapon class changed to 'Heavy'" % _t
descDetails['cannotRecieveDamageTypeOf'] = 'Cannot take the following type of damage: ' % _t
descDetails['costDecreased'] = 'Cost decreased' % _t

local self = infoWeapons
local stIcon = 'data/textures/icons/ASSAULTBLASTER.png'
local listboxLabelSizeK = 0.5      -- rUnit size factor for label listboxes (for lister)
local listboxLabelFontSizeK = 0.32 -- Text size factor rUnit for label listboxes

--Fills the entities tab without using a complete Vlister
function infoWeapons.SetEntitiesV2(container, rUnit, gUK)
	Debug('infoWeapons.SetEntitiesV2 gUK is ' .. tostring(gUK))

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
				--Debug('entryName is '..entryName)
				local entityRow = entities[entryName]
				local name = entityRow[2]

				local color = getTypeColor()
				if entryGUK >= gUK then color = getTypeColor('update') end

				--Debug('applying '..name..' to '..segment)

				boxTable[segment]:addRow()
				boxTable[segment]:setEntry(0, boxTable[segment].rows - 1, name, false, false, color)
				boxTable[segment]:setEntryValue(0, boxTable[segment].rows - 1, entryName)
			end
		end
	end

	return boxTable
end

--Creates a set of entity dashboards and returns a table with them
function infoWeapons.GetInfoContainers(container, rUnit)
	local _result = {}

	for _key, _rows in pairs(entities) do
		local wpnType = _key
		local infobox = self.SetMain(wpnType, container, rUnit)
		_result[_key] = infobox
	end
	return _result
end

--Fills the information window
function infoWeapons.SetMain(wpnType, baseContainer, rUnit)
	--Debug('SetMain attempt with type '..wpnType)
	if not (wpnType) then
		Debug('Failure: no wpnType')
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
	local weaponTable = entities[wpnType]

	local paddingY = rUnit * 0.5
	local unitIcon = rUnit * 4

	--Creating containers

	--Main splitter info | scroll descriptions
	local hSplitter = UIHorizontalSplitter(Rect(infobox.size), 10, 0, 0.45)

	--Container info
	local infoContainer = infobox:createContainer(hSplitter.top)
	infoContainer:createFrame(Rect(infoContainer.size))

	--Description/Change Scroller
	local otherContainer = infobox:createScrollFrame(hSplitter.bottom)

	--Splitter for separating description and changes
	local descChangesSplitter = UIHorizontalSplitter(Rect(otherContainer.size), 10, 0, 0.45)

	--The scroller is described
	local descContainer = otherContainer:createScrollFrame(descChangesSplitter.top)
	--Info container:create frame(rect(desc container.size))

	--Square for change list
	local changesRect = descChangesSplitter.bottom


	--Links to information
	local wpnIcon = weaponTable[1]
	local wpnName = weaponTable[2]
	local wpnDistance = weaponTable[3]
	local wpnAccuracy = weaponTable[4]
	local wpnFirerate = weaponTable[5]
	local wpnDamagetype = weaponTable[6]
	local wpnDesc = weaponTable[7]
	local wpnChangesTable = weaponTable[8]

	--Creating an icon
	local iconTRanchor = vec2(baseSize.x - unitIcon - paddingY, paddingY)
	local iconSecondPoint = vec2(iconTRanchor.x + unitIcon, iconTRanchor.y + unitIcon)
	local iconRect = Rect(iconTRanchor, iconSecondPoint)
	local icon = infoContainer:createPicture(iconRect, wpnIcon)
	icon.isIcon = true

	--Name
	local nameAnchor = vec2(rUnit * 1, paddingY)
	local namePoint = vec2(nameAnchor.x + rUnit * 7, nameAnchor.y + rUnit)
	local nameRect = Rect(nameAnchor, namePoint)
	local name = infoContainer:createTextField(nameRect, wpnName)
	name.fontSize = rUnit * 0.4

	--Weapon class
	local wpnClass = 'Standard' % _t
	local classColor = getTypeColor('Standard')
	if checkLightPath(wpnIcon) then
		wpnClass = 'Light' % _t
		classColor = getTypeColor('Light')
	end
	if checkHeavyPath(wpnIcon) then
		wpnClass = 'Heavy' % _t
		classColor = getTypeColor('Heavy')
	end
	if checkMCPath(wpnIcon) then
		wpnClass = 'Main Caliber' % _t
		classColor = getTypeColor('MC')
	end

	local _icon, _label, _value = self.InfoLineCreator(0, rUnit, infoContainer)
	_icon.picture = icons['class']
	_label.text = 'Weapon class' % _t
	_value.text = wpnClass
	_value.fontColor = classColor

	--Damage type
	_icon, _label, _value = self.InfoLineCreator(1, rUnit, infoContainer)
	_icon.picture = icons['dtype']
	_label.text = 'Damage type' % _t
	_value.text = wpnDamagetype

	--Range
	_icon, _label, _value = self.InfoLineCreator(2, rUnit, infoContainer)
	_icon.picture = icons['distance']
	_label.text = 'Fire range' % _t
	_value.text = wpnDistance

	--Accuracy
	_icon, _label, _value = self.InfoLineCreator(3, rUnit, infoContainer)
	_icon.picture = icons['accuracy']
	_label.text = 'Accuracy' % _t
	_value.text = wpnAccuracy

	--Rate of fire + Y coordinate
	_icon, _label, _value, _yPos = self.InfoLineCreator(4, rUnit, infoContainer)
	_icon.picture = icons['firerate']
	_label.text = 'Fire rate' % _t
	_value.text = wpnFirerate

	--Description
	local descRect = Neltharaku.ShrinkRect(Rect(descContainer.size), rUnit * 0.2)

	local descTextBox = otherContainer:createMultiLineTextBox(descRect)
	descTextBox.editable = false
	descTextBox.text = wpnDesc
	descTextBox.setFontSize = rUnit * 0.3

	--Peculiarities
	local changesLister = UIVerticalLister(changesRect, 5, 5)

	for _, _rows in pairs(wpnChangesTable) do
		local resultRow = ' - ' .. _rows
		local textRect = changesLister:nextRect(rUnit * 0.7)
		local textBox = otherContainer:createMultiLineTextBox(textRect)
		textBox.editable = false
		textBox.text = resultRow
		textBox.setFontSize = rUnit * 0.3
	end

	infobox:hide()
	return infobox
end

--Creates a line of text for the infotab (weapon statistics)
function infoWeapons.InfoLineCreator(index, rUnit, infobox)
	--Variables
	local staticPadding = rUnit * 1.5
	local modUnit = rUnit * 0.7
	local paddingY = staticPadding + (modUnit * index)
	local paddingX = rUnit * 0.5
	local textFieldSqueeze = rUnit * 0.05
	local divX = rUnit * 0.30

	--Icon
	local iconAnchor = vec2(paddingX, paddingY)
	local iconPoint = vec2(iconAnchor.x + modUnit, iconAnchor.y + modUnit)
	local iconRect = Rect(iconAnchor, iconPoint)
	local icon = infobox:createPicture(iconRect, stIcon)
	icon.isIcon = true

	--Text -title
	local labelAnchor = vec2(iconPoint.x + divX, paddingY + textFieldSqueeze)
	local labelPoint = vec2(labelAnchor.x + modUnit * 4.5, labelAnchor.y + modUnit - textFieldSqueeze)
	local labelRect = Rect(labelAnchor, labelPoint)
	local label = infobox:createTextField(labelRect, '')
	label.fontSize = rUnit * 0.2
	--Infobox:create frame(label rect)

	--Text -meaning
	local valueAnchor = vec2(labelPoint.x, paddingY + textFieldSqueeze)
	local valuePoint = vec2(valueAnchor.x + modUnit * 4.5, valueAnchor.y + modUnit - textFieldSqueeze)
	local valueRect = Rect(valueAnchor, valuePoint)
	local value = infobox:createTextField(valueRect, '')
	value.fontSize = rUnit * 0.2
	--Infobox:create frame(value rect)

	return icon, label, value, valuePoint.y
end

--Creates a title for the list of guns
function infoWeapons.createLabel(y, container, rUnit, name)
	local yMod = y + rUnit * 0.5

	local labelAnchor = vec2(0, y)
	local labelPoint = vec2(container.width * 0.98, yMod)
	local labelRect = Rect(labelAnchor, labelPoint)

	local label = container:createLabel(labelRect, name, rUnit * listboxLabelFontSizeK)

	return yMod
end

--Creates a labelBox for a list of guns
function infoWeapons.createBox(y, container, height, rowsize)
	local yMod = y + height

	local boxAnchor = vec2(0, y)
	local boxPoint = vec2(container.width * 0.98, yMod)
	local boxRect = Rect(boxAnchor, boxPoint)

	local label = container:createListBoxEx(boxRect)

	return yMod, label
end

-----------------------------[VANILEK DATA]------------------------------------------
entities['chaingun'] = {
	--Icon
	"data/textures/icons/chaingun.png",
	--Name
	'Chaingun' % _t,
	--Range
	rangeType['s-m'],
	--Accuracy
	accuracyType['m'],
	--Rate of fire
	fireRateType['h'],
	--Damage type
	damageType['phys'],
	--Description
	'The simplest low and medium range combat weapon' % _t,
	--Changes
	{
		descDetails['bonusdamageincrease'] .. '25%',
		descDetails['techleveltorange'],
		descDetails['techleveltoprojspeed'],
		descDetails['accemblyDamageByParts'] .. descDetails['inc'],
		descDetails['accemblyFirerateByParts'] .. descDetails['inc'],
		descDetails['newpartDamageToHull'],
	},
}

entities['laser'] = {
	--Icon
	"data/textures/icons/laser-gun.png",
	--Name
	'Laser' % _t,
	--Range
	rangeType['m'],
	--Accuracy
	accuracyType['va'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['ener'],
	--Description
	'Medium-range weapon. It has high accuracy and a good hit rate, which, coupled with the energy type of damage, allows you to inflict stable damage to the enemy' %
	_t,
	--Changes
	{
		descDetails['bonusdamageincrease'] .. '40%',
		descDetails['bonusrangedecrease'] .. '10-30%',
		'Pierce up to two blocks (railgun mechanics)' % _t,
		descDetails['accemblyDamageByParts'] .. descDetails['inc'],
		descDetails['accemblyRangeByParts'] .. descDetails['inc'],
		descDetails['newpartDamageToShield'],
	},
}

entities['plasmagun'] = {
	--Icon
	"data/textures/icons/plasma-gun.png",
	--Name
	'Plasma cannon' % _t,
	--Range
	rangeType['s-m'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['h'],
	--Damage type
	damageType['plasma'],
	--Description
	'A powerful and rapid-fire low-range weapon that causes huge damage to enemy shields' % _t,
	--Changes
	{
		descDetails['bonusdamageincrease'] .. '30%',
		descDetails['techleveltodamage'],
		descDetails['techleveltorange'],
		descDetails['accemblyDamageByParts'] .. descDetails['inc'],
		descDetails['morepartsDamage'],
		descDetails['lesspartsRange'],
		descDetails['morepartsBattery'],
		descDetails['newpartDamageToShield'],
	},
}

entities['launcher'] = {
	--Icon
	"data/textures/icons/rocket-launcher.png",
	--Name
	'Rocket launcher' % _t,
	--Range
	rangeType['h'],
	--Accuracy
	accuracyType['m-ho'],
	--Rate of fire
	fireRateType['m-h'],
	--Damage type
	damageType['phys'],
	--Description
	'A long-range siege weapon. During assembly at the station, the projectiles can be homing' % _t,
	--Changes
	{
		descDetails['classToHeavy'],
		descDetails['bonusdamageincrease'] .. '15%',
		'When assembling: Fuel now adds damage, not range' % _t,
		descDetails['newpartProjSpeed'],
		descDetails['newpartDamageToHull'],
	},
}

entities['cannon'] = {
	--Icon
	"data/textures/icons/cannon.png",
	--Name
	'Cannon' % _t,
	--Range
	rangeType['h'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['l'],
	--Damage type
	damageType['phys'],
	--Description
	'A gun with a huge alpha damage, capable of destroying smaller ships with a couple of volleys, but it overheats very quickly and cools down for a long time' %
	_t,
	--Changes
	{
		descDetails['classToHeavy'],
		descDetails['bonusdamageincrease'] .. '10%',
		descDetails['bonusToHull'] .. '45%',
		descDetails['bonusToShields'] .. '25%',
		descDetails['cannotRecieveDamageTypeOf'] .. damageType['am'],
		descDetails['morepartsDamage'],
		descDetails['newpartDamageToHull'],
		descDetails['newpartProjSpeed'],
		descDetails['newpartBattery'],
		descDetails['costDecreased'],
	},
}

entities['railgun'] = {
	--Icon
	"data/textures/icons/rail-gun.png",
	--Name
	'Railgun' % _t,
	--Range
	rangeType['s-m'],
	--Accuracy
	accuracyType['l'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['phys'],
	--Description
	'A redesigned version of the railgun. Most of the characteristics have been reduced, but instead the railgun now launches three projectiles at once, allowing you to tear opponents apart in close combat' %
	_t,
	--Changes
	{
		descDetails['classToHeavy'],
		'The minimum penetration is reduced by 1, the maximum by 40%' % _t,
		'Base damage reduced by 15%' % _t,
		'Significantly reduced accuracy' % _t,
		descDetails['bonusrangedecrease'] .. '25%',
		'When assembling, the electromagnet now adds damage to shields, not range' % _t,
		'Weapon specializations for range and accuracy are disabled' % _t,
		'Now the gun makes three simultaneous shots, thereby increasing the potential damage three times' % _t,
		descDetails['costDecreased'],
	},
}

entities['repairbeam'] = {
	--Icon
	"data/textures/icons/repair-beam.png",
	--Name
	'Repair laser' % _t,
	--Range
	rangeType['m'],
	--Accuracy
	accuracyType['va'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['no'],
	--Description
	'Repair emitter designed for installation on ships. Allows you to repair the hull or shields of allies at medium range' %
	_t,
	--Changes
	{
		descDetails['bonusRepair'] .. '60%',
		descDetails['techleveltorepair'],
		'During assembly: you can invest more parts to hull repair value, their effect is enhanced' % _t,
		'During assembly: you can invest more parts to shield repair value, their effect is enhanced (higher than for the hull)' %
		_t,
		descDetails['newpartBattery'],
		descDetails['costDecreased'],
	},
}

entities['bolter'] = {
	--Icon
	"data/textures/icons/bolter.png",
	--Name
	'Bolter' % _t,
	--Range
	rangeType['s-m'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['m-h'],
	--Damage type
	damageType['am'],
	--Description
	"Low- and medium-range weapon that allow you to quickly destroy the enemy's hull" % _t,
	--Changes
	{
		descDetails['bonusdamageincrease'] .. '15%',
		descDetails['techleveltoprojspeed'],
		'The threshold of the minimum rate of fire (in case of random assignment) has been increased' % _t,
		descDetails['accemblyFirerateByParts'],
		descDetails['morepartsDamage'],
		descDetails['newpartProjSpeed'],
		descDetails['morepartsRange'],
	},
}

entities['lightinggun'] = {
	--Icon
	"data/textures/icons/lightning-gun.png",
	--Name
	'Lightning Gun' % _t,
	--Range
	rangeType['h'],
	--Accuracy
	accuracyType['va'],
	--Rate of fire
	fireRateType['l'],
	--Damage type
	damageType['elec'] .. '/' .. damageType['plasma'],
	--Description
	'A long-range weapon capable of effectively destroying enemy shields' % _t,
	--Changes
	{
		descDetails['classToHeavy'],
		descDetails['bonusdamageincrease'] .. '25%',
		'Rate of fire significantly reduced (damage remains unchanged)' % _t,
		descDetails['accemblyDamageByParts'] .. descDetails['inc'],
		descDetails['morepartsDamage'],
		'In production: one of the parts now gives a rate of fire' % _t,
		descDetails['newpartBattery'],
	},
}

entities['tesla'] = {
	--Icon
	"data/textures/icons/tesla-gun.png",
	--Name
	'Tesla Gun' % _t,
	--Range
	rangeType['s'],
	--Accuracy
	accuracyType['va'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['elec'],
	--Description
	'A high-precision low-range weapon that destroys enemy shields and technical blocks' % _t,
	--Changes
	{
		descDetails['bonusToShields'] .. '30%',
		descDetails['morepartsDamage'],
		descDetails['lesspartsRange'],
		'During production: one of the parts now provides additional shield damage' % _t,
		descDetails['cannotRecieveDamageTypeOf'] .. damageType['plasma'],
	},
}

entities['pulsecannon'] = {
	--Icon
	"data/textures/icons/pulsecannon.png",
	--Name
	'Pulse Cannon' % _t,
	--Range
	rangeType['s'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['h'],
	--Damage type
	damageType['phys'] .. '/' .. damageType['am'],
	--Description
	'A rapid-fire low-range weapon that partially ignores enemy shields' % _t,
	--Changes
	{
		'Removed vanilla damage penalty (25%), added 5% damage bonus' % _t,
		descDetails['techleveltorange'],
		descDetails['techleveltoprojspeed'],
		descDetails['accemblyFirerateByParts'],
		descDetails['accemblyDamageByParts'],
	},
}


-----------------------------[MOD DATA]----------------------------

entities['pulsegun'] = {
	--Icon
	getWeaponPath('pulsegun'),
	--Name
	getWeaponName('pulsegun'),
	--Range
	rangeType['s-m'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['ener'],
	--Description
	'A light energy weapon created on the basis of machine-gun samples. It has an increased range, but the rate of fire is lower. Very cheap in production' %
	_t,
	--Changes
	{
		'Inherits the mechanics of firing a machine gun, deals a little less damage, but shoots further' % _t,
		descDetails['techleveltorange'],
		descDetails['techleveltoprojspeed'],
		descDetails['techleveltodamage'],
	},
}

entities['particleaccelerator'] = {
	--Icon
	getWeaponPath('particleaccelerator'),
	--Name
	getWeaponName('particleaccelerator'),
	--Range
	rangeType['m'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['ul'],
	--Damage type
	damageType['am'],
	--Description
	"A light sniper gun based on a bolter. It allows you to inflict good damage to the enemy's hull at an average distance and shows itself perfectly on automatic batteries of heavy combat vessels" %
	_t,
	--Changes
	{
		'Inherits the mechanics of bolter, shoots much less often and does a little less damage, but the range is higher' %
		_t,
	},
}

entities['assaultblaster'] = {
	--Icon
	getWeaponPath('assaultblaster'),
	--Name
	getWeaponName('assaultblaster'),
	--Range
	rangeType['m'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['elec'],
	--Description
	'A modified version of the pulse gun. Deals more damage at the cost of reducing the range, and also has a basic bonus damage to the shield' %
	_t,
	--Changes
	{
		'Inherits the mechanics of firing a pulse cannon, deals more damage, the type of damage is changed' % _t,
		'It has a basic additional damage to the shield, this bonus is increased by parts on the assembly' % _t,
	},
}

entities['hept'] = {
	--Icon
	getWeaponPath('hept'),
	--Name
	getWeaponName('hept'),
	--Range
	rangeType['m'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['plasma'],
	--Description
	'A modified version of the plasma cannon. The damage inflicted on the shield and body is balanced, shoots further and deals a little more damage' %
	_t,
	--Changes
	{
		'The gun is well suited for installation on automatic batteries of heavy vessels' % _t,
		'Basic damage bonuses on the shield and body are increased by parts during assembly' % _t,
	},
}

entities['pulselaser'] = {
	--Icon
	getWeaponPath('pulselaser'),
	--Name
	getWeaponName('pulselaser'),
	--Range
	rangeType['s'],
	--Accuracy
	accuracyType['l'],
	--Rate of fire
	fireRateType['h'],
	--Damage type
	damageType['ener'],
	--Description
	'A powerful rapid-fire emitter that does a lot of damage in a short period of time. Designed for installation on fighter jets' %
	_t,
	--Changes
	{
		"Reduces the fighter's firing radius by 25%" % _t,
		'Provides a large bonus to the compactness of the fighter, speed and a small one to maneuverability' % _t,
	},
}

entities['assaultcannon'] = {
	--Icon
	getWeaponPath('assaultcannon'),
	--Name
	getWeaponName('assaultcannon'),
	--Range
	rangeType['s'],
	--Accuracy
	accuracyType['l'],
	--Rate of fire
	fireRateType['l'],
	--Damage type
	damageType['phys'],
	--Description
	'A powerful all-purpose gun designed for installation on fighter jets. Very high projectile speed' % _t,
	--Changes
	{
		"Increases the fighter's firing radius by 25%" % _t,
		'Provides a major bonus to the compactness of the fighter and maneuverability, as well as a small one to its strength' %
		_t,
	},
}

entities['magneticmortar'] = {
	--Icon
	getWeaponPath('magneticmortar'),
	--Name
	getWeaponName('magneticmortar'),
	--Range
	rangeType['m'],
	--Accuracy
	accuracyType['h'],
	--Rate of fire
	fireRateType['l'],
	--Damage type
	damageType['am'],
	--Description
	'An artillery weapon for fighters. Deals good alpha damage, but the projectiles are quite slow. Has basic damage bonuses against shield and hull' %
	_t,
	--Changes
	{
		"Increases the fighter's firing radius by 175%" % _t,
		'Provides an average bonus to the maneuverability and speed of the fighter' % _t,
	},
}

entities['chargingbeam'] = {
	--Icon
	getWeaponPath('chargingbeam'),
	--Name
	getWeaponName('chargingbeam'),
	--Range
	rangeType['s'],
	--Accuracy
	accuracyType['va'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['no'],
	--Description
	'Shield-restoring emitter designed for installation on fighter jets' % _t,
	--Changes
	{
		'Repairs shields only' % _t,
		"Increases the fighter's firing radius by 15%" % _t,
		'Provides a large bonus to the compactness of the fighter, and a small one to the speed' % _t,
	},
}

entities['nanorepair'] = {
	--Icon
	getWeaponPath('nanorepair'),
	--Name
	getWeaponName('nanorepair'),
	--Range
	rangeType['s'],
	--Accuracy
	accuracyType['va'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['no'],
	--Description
	'Repair gun designed for installation on fighter jets. Repairs hull only' % _t,
	--Changes
	{
		'Available from the very beginning of the game' % _t,
		"Increases the fighter's firing radius by 15%" % _t,
		'Provides a large bonus to the compactness of the fighter, and a small one to the speed' % _t,
	},
}

entities['mantis'] = {
	--Icon
	getWeaponPath('mantis'),
	--Name
	getWeaponName('mantis'),
	--Range
	rangeType['h++'],
	--Accuracy
	accuracyType['ho'],
	--Rate of fire
	fireRateType['ul'],
	--Damage type
	damageType['elec'],
	--Description
	'Created on the basis of a rocket launcher, this gun launches four high-speed homing projectiles at the target, capable of quickly covering a long distance. Despite the fact that the Mantis loses to most weapons systems in terms of damage per second, it is excellent for eliminating small and medium-sized remote targets' %
	_t,
	--Changes
	{
		'The gun has a large alpha damage, but its rate of fire is significantly reduced' % _t,
		'Projectiles always homing' % _t,
	},
}

entities['photoncannon'] = {
	--Icon
	getWeaponPath('photoncannon'),
	--Name
	getWeaponName('photoncannon'),
	--Range
	rangeType['h'],
	--Accuracy
	accuracyType['m'],
	--Rate of fire
	fireRateType['l'],
	--Damage type
	damageType['ener'],
	--Description
	'Powerful armament for the main batteries of heavy and artillery vessels. Shoots large slow projectiles that cause a lot of damage. The energy type of damage makes the weapon universal against any resists' %
	_t,
	--Changes
	{
		'Created on the basis of a cannon. Damage, explosion and firing radius are lower, projectile velocity and rate of fire are higher' %
		_t,
		'Receives significant bonuses when assembling at the station' % _t,
	},
}

entities['ionemitter'] = {
	--Icon
	getWeaponPath('ionemitter'),
	--Name
	getWeaponName('ionemitter'),
	--Range
	rangeType['m-h'],
	--Accuracy
	accuracyType['m'],
	--Rate of fire
	fireRateType['l'],
	--Damage type
	damageType['elec'],
	--Description
	'A modified version of a photon cannon designed to destroy enemy shields. The electric type of damage allows you to inflict decent damage even to the hull when hitting tech blocks' %
	_t,
	--Changes
	{
		'Created on the basis of a photon cannon. The damage inflicted is significantly reduced, the projectile flies slower and the radius is smaller' %
		_t,
		'It has a large base bonus damage to shields, during production this bonus increases noticeably' % _t,
	},
}

entities['prd'] = {
	--Icon
	getWeaponPath('prd'),
	--Name
	getWeaponName('prd'),
	--Range
	rangeType['m'],
	--Accuracy
	accuracyType['m'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['plasma'],
	--Description
	'Rail-type weapon. Average firing radius, plasma damage, inaccurate. It is capable of piercing up to two blocks, thus causing good damage to both shields and hull of targets without armor. Great for using on automatic batteries of heavy vessels' %
	_t,
	--Changes
	{
		'It has a basic bonus to shield damage, inheriting the features of the plasma damage type' % _t,
	},
}

entities['plasmaflak'] = {
	--Icon
	getWeaponPath('plasmaflak'),
	--Name
	getWeaponName('plasmaflak'),
	--Range
	rangeType['s'],
	--Accuracy
	accuracyType['m'],
	--Rate of fire
	fireRateType['m-h'],
	--Damage type
	damageType['part'],
	--Description
	'Anti-fighter plasma weapon. Shoots two projectiles at once with a reduced explosion radius and range compared to a vanilla anti-aircraft gun' %
	_t,
	--Changes
	{
		'High rate of fire and firing two projectiles allow you to create an effective barrage' % _t,
		'Unlike other anti-aircraft guns, it has a battery and consumes it when firing' % _t,
	},
}


entities['hyperkinetic'] = {
	--Icon
	getWeaponPath('hyperkinetic'),
	--Name
	getWeaponName('hyperkinetic'),
	--Range
	rangeType['h++'],
	--Accuracy
	accuracyType['va'],
	--Rate of fire
	fireRateType['ul'],
	--Damage type
	damageType['am'],
	--Description
	'Heavy sniper weapon. Deals huge damage to targets without shields and armor blocks, allowing you to destroy enemy ships in one shot. Extremely low rate of fire' %
	_t,
	--Changes
	{
		'It has very low damage to shields and to targets with armor' % _t,
		'Weapon reveals the maximum potential during assembly at the station' % _t,
		"Weapons of the 'main caliber' class impose a permanent penalty to the rate of fire if more than two units are installed" %
		_t,
	},
}

entities['avalanche'] = {
	--Icon
	getWeaponPath('avalanche'),
	--Name
	getWeaponName('avalanche'),
	--Range
	rangeType['s'],
	--Accuracy
	accuracyType['ho'],
	--Rate of fire
	fireRateType['ul'],
	--Damage type
	damageType['phys'],
	--Description
	'Heavy bomber gun. Shoots at a short distance in volleys of two slow projectiles. Deals crushing damage to the target if it hits' %
	_t,
	--Changes
	{
		'Weapon reveals the maximum potential during assembly at the station' % _t,
		'Very bad versus mobile targets' % _t,
		'Does massive damage' % _t,
		"Weapons of the 'main caliber' class impose a permanent penalty to the rate of fire if more than two units are installed" %
		_t,
		'No overheat' % _t,
	},
}

entities['cyclone'] = {
	--Icon
	getWeaponPath('cyclone'),
	--Name
	getWeaponName('cyclone'),
	--Range
	rangeType['h++'],
	--Accuracy
	accuracyType['ho'],
	--Rate of fire
	fireRateType['l'],
	--Damage type
	damageType['elec'],
	--Description
	"Enhanced version of the 'Mantis'. Launches a swarm of missiles in several volleys before overheating. The missiles fly fast, far away and are aimed at the target. It cools down for a very long time (40 seconds) after firing" %
	_t,
	--Changes
	{
		'Weapon reveals the maximum potential during assembly at the station' % _t,
		'An excellent weapon for the targeted destruction of important targets' % _t,
		'Does a lot of damage, but cools down for a very long time' % _t,
		"Weapons of the 'main caliber' class impose a permanent penalty to the rate of fire if more than two units are installed" %
		_t,
	},
}

entities['transphasic'] = {
	--Icon
	getWeaponPath('transphasic'),
	--Name
	getWeaponName('transphasic'),
	--Range
	rangeType['m'],
	--Accuracy
	accuracyType['va'],
	--Rate of fire
	fireRateType['m'],
	--Damage type
	damageType['ener'],
	--Description
	'Heavy version of the laser gun. It pierces up to two blocks and has a basic bonus damage on shields. It has an increased range and discharges its battery more slowly' %
	_t,
	--Changes
	{
		'Weapon reveals the maximum potential during assembly at the station' % _t,
		'A universal tool in its class' % _t,
		"Weapons of the 'main caliber' class impose a permanent penalty to the rate of fire if more than two units are installed" %
		_t,
	},
}
