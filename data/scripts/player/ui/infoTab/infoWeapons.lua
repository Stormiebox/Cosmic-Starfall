package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

--namespace infoWeapons
infoWeapons = {}

local _debug = false
function infoWeapons.DebugMsg(_text)
	if _debug then
		print('infoWeapons|',_text)
	end
end
local Debug = infoWeapons.DebugMsg
local RR = Neltharaku.ReportRect
local V2R = Neltharaku.ReportVec2
local dF = Neltharaku.debugFrame
local ApplyBorder = Neltharaku.GLapplyBorderFrame
local TSR = Neltharaku.TableSelfReport

local classST = 'Starfall - standart weapons'%_t
local classLI = 'Starfall - light weapons'%_t
local classHE = 'Starfall - heavy weapons'%_t
local classMC = 'Starfall - main caliber weapons'%_t
local classVST = 'Vanilla - standart'%_t
local classVHE = 'Vanilla - heavy'%_t

local order = {
	--name,ID,IDupdate
	--Стандартные
	{classST,'pulsegun',0.1},
	{classST,'particleaccelerator',0.1},
	{classST,'assaultblaster',0.1},
	{classST,'hept',0.1},
	{classST,'mantis',0.1},
	{classST,'prd',0.1},
	{classST,'plasmaflak',0.1},
	--Легкие
	{classLI,'pulselaser',0.1},
	{classLI,'assaultcannon',0.1},
	{classLI,'magneticmortar',0.1},
	{classLI,'nanorepair',0.1},
	{classLI,'chargingbeam',0.1},
	--Тяжелые
	{classHE,'photoncannon',0.1},
	{classHE,'ionemitter',0.1},
	--Калибр
	{classMC,'hyperkinetic',0.1},
	{classMC,'avalanche',0.1},
	{classMC,'cyclone',0.1},
	{classMC,'transphasic',0.1},
	--Ванилла - стандартные
	{classVST,'chaingun',0.1},
	{classVST,'laser',0.1},
	{classVST,'plasmagun',0.1},
	{classVST,'repairbeam',0.1},
	{classVST,'bolter',0.1},
	{classVST,'tesla',0.1},
	{classVST,'pulsecannon',0.1},
	--Ванилла - тяжелые
	{classVHE,'launcher',0.1},
	{classVHE,'cannon',0.1},
	{classVHE,'railgun',0.1},
	{classVHE,'lightinggun',0.1},
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
	rangeType['s'] = 'small'%_t
	rangeType['s-m'] = 'small to medium'%_t
	rangeType['m'] = 'medium'%_t
	rangeType['m-h'] = 'medium to high'%_t
	rangeType['h'] = 'high'%_t
	rangeType['h+'] = 'very high'%_t
	rangeType['h++'] = 'extremely high'%_t
	
local accuracyType = {}
	accuracyType['l'] = 'poor'%_t
	accuracyType['m'] = 'medium'%_t
	accuracyType['h'] = 'good'%_t
	accuracyType['ho'] = 'homing'%_t
	accuracyType['m-ho'] = 'medium to homing'%_t
	accuracyType['va'] = 'very accurate'%_t
	
local fireRateType = {}
	fireRateType['ul'] = 'ultra low'%_t
	fireRateType['l'] = 'low'%_t
	fireRateType['m'] = 'medium'%_t
	fireRateType['m-h'] = 'medium to high'%_t
	fireRateType['h'] = 'high'%_t
	fireRateType['h+'] = 'very high'%_t
	
local damageType = {}
	damageType['phys'] = 'physical'%_t
	damageType['am'] = 'anti-matter'%_t
	damageType['elec'] = 'electric'%_t
	damageType['plasma'] = 'plasma'%_t
	damageType['ener'] = 'energy'%_t
	damageType['part'] = 'particles'%_t
	damageType['no'] = 'no'%_t
	
local descDetails = {}
	descDetails['inc'] = 'increased'%_t
	descDetails['dec'] = 'decreased'%_t
	
	descDetails['bonusdamageincrease'] = 'Base damage increased by '%_t
	descDetails['bonusrangeincrease'] = 'Base range increased by '%_t
	descDetails['bonusrangedecrease'] = 'Base range decreased by '%_t
	descDetails['bonusToHull'] = 'Base damage to hull increased by '%_t
	descDetails['bonusToShields'] = 'Base damage to shields increased by '%_t
	descDetails['bonusRepair'] = 'Base repair amount increased by '%_t
	
	descDetails['accemblyDamageByParts'] = 'When assembling, damage bonus from parts '%_t
	descDetails['accemblyFirerateByParts'] = 'When assembling, rate of fire bonus from parts '%_t
	descDetails['accemblyRangeByParts'] = 'When assembling, range bonus from parts '%_t
	
	descDetails['newpartDamageToHull'] = 'When assembling, a new part that adds a bonus damage to the hull'%_t
	descDetails['newpartDamageToShield'] = 'When assembling, a new part that adds a bonus damage to the shields'%_t
	descDetails['newpartProjSpeed'] = 'When assembling, a new part that adds a bonus speed to the projectile'%_t
	descDetails['newpartBattery'] = 'When assembling, a new part that adds a bonus to battery/overheating'%_t
	
	descDetails['techleveltoprojspeed'] = 'Base projectile speed will increase with the tech level'%_t
	descDetails['techleveltorange'] = 'Base firing range will increase with the tech level'%_t
	descDetails['techleveltodamage'] = 'Base damage will increase with the tech level'%_t
	descDetails['techleveltorepair'] = 'Base repair rate will increase with the tech level'%_t
	
	descDetails['morepartsDamage'] = 'More parts to damage bonus'%_t
	descDetails['morepartsRange'] = 'More parts to range bonus'%_t
	descDetails['morepartsBattery'] = 'More parts to battery/overheat bonus'%_t
	
	descDetails['lesspartsRange'] = 'Less parts to range bonus'%_t
	
	descDetails['classToHeavy'] = "Weapon class changed to 'Heavy'"%_t
	descDetails['cannotRecieveDamageTypeOf'] = 'Cannot take the following type of damage: '%_t
	descDetails['costDecreased'] = 'Cost decreased'%_t
	
local self = infoWeapons
local stIcon = 'data/textures/icons/ASSAULTBLASTER.png'
local listboxLabelSizeK = 0.5 -- Коэффициент размера rUnit для label листбоксов (для листера)
local listboxLabelFontSizeK = 0.32 -- Коэффициент размера rUnit текста для label листбоксов

--Заполняет вкладку сущностей без использования конченного Vlister
function infoWeapons.SetEntitiesV2(container,rUnit,gUK)

	Debug('infoWeapons.SetEntitiesV2 gUK is '..tostring(gUK))

	--Сортировка и порядок вывода
	local segments = {}
	local segmentsLen = {}
	
	--Заполняет таблицу сегментов (заголовков) и вычисляет длину
	for _,_rows in pairs(order) do
		local name = _rows[1]
		if not(segmentsLen[name]) then
			segmentsLen[name] = 1
			table.insert(segments,name)
		else
			segmentsLen[name] = segmentsLen[name] + 1
		end
	end
	
	--Переменные
	local yPos = 0
	local boxTable = {}
	
	--Создание UI контейнера
	local listBox = container:createScrollFrame(Rect(container.size))
	
	--Генерация линий в listBox согласно сегментам
	for i=1,#segments do
		
		local segment = segments[i]
		Debug('New segment: '..segment)
		Debug('Length is '..tostring(segmentsLen[segment]))
		
		--Генерация окна listBox
		local rowHeight = rUnit * 0.4
		local totalHeight = (segmentsLen[segment]+1) * rowHeight
		yPos = self.createLabel(yPos,listBox,rUnit,segment)
		yPos,boxTable[segment] = self.createBox(yPos,listBox,totalHeight,rowHeight)
		
		--Заполнение строками
		for _,_rows in pairs(order) do
			if _rows[1] == segment then
		
				local entryName = _rows[2]
				local entryGUK = _rows[3]
				--Debug('entryName is '..entryName)
				local entityRow = entities[entryName]
				local name = entityRow[2]
				
				local color = getTypeColor()
				if entryGUK>=gUK then color = getTypeColor('update') end
				
				--Debug('applying '..name..' to '..segment)
				
				boxTable[segment]:addRow()
				boxTable[segment]:setEntry(0,boxTable[segment].rows-1,name,false,false,color)
				boxTable[segment]:setEntryValue(0,boxTable[segment].rows-1,entryName)
			
			end
		end
	end
	
	return boxTable
	
end

--Создает набор инфопанелей сущностей и возвращает таблицу с ними
function infoWeapons.GetInfoContainers(container,rUnit)
	local _result = {}
	
	for _key,_rows in pairs(entities) do
		local wpnType = _key
		local infobox = self.SetMain(wpnType,container,rUnit)
		_result[_key] = infobox
	end
	return _result
end

--Заполняет окно информации
function infoWeapons.SetMain(wpnType,baseContainer,rUnit)

	--Debug('SetMain attempt with type '..wpnType)
	if not(wpnType) then Debug('Failure: no wpnType') return end
	if not(baseContainer) then Debug('Failure: no baseContainer') return end
	if not(rUnit) then Debug('Failure: no rUnit') return end
	
	--Базовый контейнер
	local infobox = baseContainer:createContainer(Rect(baseContainer.size))
	
	--Базовые переменные
	local baseSize = infobox.size
	local weaponTable = entities[wpnType]
	
	local paddingY = rUnit * 0.5
	local unitIcon = rUnit * 4
	
	--Создание контейнеров

	--Основной сплиттер инфо | скролл описаний
	local hSplitter = UIHorizontalSplitter(Rect(infobox.size),10,0,0.45)
	
	--Контейнер инфо
	local infoContainer = infobox:createContainer(hSplitter.top)
		infoContainer:createFrame(Rect(infoContainer.size))
	
	--Скроллер описания/изменений
	local otherContainer = infobox:createScrollFrame(hSplitter.bottom)
	
	--Сплиттер для разделения описания и изменений
	local descChangesSplitter = UIHorizontalSplitter(Rect(otherContainer.size),10,0,0.45)
	
	--Скроллер описаний
	local descContainer = otherContainer:createScrollFrame(descChangesSplitter.top)
		--infoContainer:createFrame(Rect(descContainer.size))
	
	--Квадрат для листера изменений
	local changesRect = descChangesSplitter.bottom

	
	--Ссылки на инфу
	local wpnIcon = weaponTable[1]
	local wpnName = weaponTable[2]
	local wpnDistance = weaponTable[3]
	local wpnAccuracy = weaponTable[4]
	local wpnFirerate = weaponTable[5]
	local wpnDamagetype = weaponTable[6]
	local wpnDesc = weaponTable[7]
	local wpnChangesTable = weaponTable[8]

	--Создание иконки
	local iconTRanchor = vec2(baseSize.x - unitIcon - paddingY, paddingY)
	local iconSecondPoint = vec2(iconTRanchor.x + unitIcon,iconTRanchor.y + unitIcon)
	local iconRect = Rect(iconTRanchor,iconSecondPoint)
	local icon = infoContainer:createPicture(iconRect,wpnIcon)
		icon.isIcon = true
		
	--Название
	local nameAnchor = vec2(rUnit * 1,paddingY)
	local namePoint = vec2(nameAnchor.x + rUnit * 7,nameAnchor.y + rUnit)
	local nameRect = Rect(nameAnchor,namePoint)
	local name = infoContainer:createTextField(nameRect,wpnName)
		name.fontSize = rUnit * 0.4
		
	--Класс орудия
	local wpnClass = 'standart'%_t
	local classColor = getTypeColor('standart')
	if checkLightPath(wpnIcon) then
		wpnClass = 'light'%_t
		classColor = getTypeColor('light')
	end
	if checkHeavyPath(wpnIcon) then
		wpnClass = 'heavy'%_t
		classColor = getTypeColor('heavy')
	end
	if checkMCPath(wpnIcon) then
		wpnClass = 'main caliber'%_t
		classColor = getTypeColor('MC')
	end
	
	local _icon,_label,_value = self.InfoLineCreator(0,rUnit,infoContainer)
		_icon.picture = icons['class']
		_label.text = 'Weapon class'%_t
		_value.text = wpnClass
		_value.fontColor = classColor
		
	--Тип урона
	_icon,_label,_value = self.InfoLineCreator(1,rUnit,infoContainer)
		_icon.picture = icons['dtype']
		_label.text = 'Damage type'%_t
		_value.text = wpnDamagetype
		
	--Дальность
	_icon,_label,_value = self.InfoLineCreator(2,rUnit,infoContainer)
		_icon.picture = icons['distance']
		_label.text = 'Fire range'%_t
		_value.text = wpnDistance
		
	--Точность
	_icon,_label,_value = self.InfoLineCreator(3,rUnit,infoContainer)
		_icon.picture = icons['accuracy']
		_label.text = 'Accuracy'%_t
		_value.text = wpnAccuracy
		
	--Скорострельность + Y координата
	_icon,_label,_value,_yPos = self.InfoLineCreator(4,rUnit,infoContainer)
		_icon.picture = icons['firerate']
		_label.text = 'Fire rate'%_t
		_value.text = wpnFirerate
		
	--Описание
	local descRect = Neltharaku.ShrinkRect(Rect(descContainer.size),rUnit*0.2)

	local descTextBox = otherContainer:createMultiLineTextBox(descRect)
		descTextBox.editable = false
		descTextBox.text = wpnDesc
		descTextBox.setFontSize = rUnit*0.3
		
	--Особенности
	local changesLister = UIVerticalLister(changesRect, 5, 5)
	
	for _,_rows in pairs(wpnChangesTable) do
		local resultRow = ' - '.._rows
		local textRect = changesLister:nextRect(rUnit*0.7)
		local textBox = otherContainer:createMultiLineTextBox(textRect)
			textBox.editable = false
			textBox.text = resultRow
			textBox.setFontSize = rUnit*0.3
	end
	
	infobox:hide()
	return infobox
end

--Создает линию текста для инфотаба (статистика оружия)
function infoWeapons.InfoLineCreator(index,rUnit,infobox)
	
	--Переменные
	local staticPadding = rUnit * 1.5
	local modUnit = rUnit * 0.7
	local paddingY = staticPadding + (modUnit * index)
	local paddingX = rUnit * 0.5
	local textFieldSqueeze = rUnit*0.05
	local divX = rUnit * 0.30
	
	--Иконка
	local iconAnchor = vec2(paddingX,paddingY)
	local iconPoint = vec2(iconAnchor.x+modUnit,iconAnchor.y+modUnit)
	local iconRect = Rect(iconAnchor,iconPoint)
	local icon = infobox:createPicture(iconRect,stIcon)
		icon.isIcon = true
		
	--Текст - название
	local labelAnchor = vec2(iconPoint.x + divX,paddingY + textFieldSqueeze)
	local labelPoint = vec2(labelAnchor.x + modUnit * 4.5,labelAnchor.y + modUnit - textFieldSqueeze)
	local labelRect = Rect(labelAnchor,labelPoint)
	local label = infobox:createTextField(labelRect,'')
		label.fontSize = rUnit * 0.2
	--infobox:createFrame(labelRect)
		
	--Текст - значение
	local valueAnchor = vec2(labelPoint.x ,paddingY + textFieldSqueeze)
	local valuePoint = vec2(valueAnchor.x + modUnit * 4.5,valueAnchor.y + modUnit - textFieldSqueeze)
	local valueRect = Rect(valueAnchor,valuePoint)
	local value = infobox:createTextField(valueRect,'')
		value.fontSize = rUnit * 0.2
	--infobox:createFrame(valueRect)
	
	return icon,label,value,valuePoint.y
	
end

--Создает название для списка пушек
function infoWeapons.createLabel(y,container,rUnit,name)
	local yMod = y + rUnit * 0.5

	local labelAnchor = vec2(0,y)
	local labelPoint = vec2(container.width*0.98,yMod)
	local labelRect = Rect(labelAnchor,labelPoint)

	local label = container:createLabel(labelRect,name,rUnit * listboxLabelFontSizeK)
	
	return yMod
end

--Создает labelBox для списка пушек
function infoWeapons.createBox(y,container,height,rowsize)

	local yMod = y + height

	local boxAnchor = vec2(0,y)
	local boxPoint = vec2(container.width * 0.98,yMod)
	local boxRect = Rect(boxAnchor,boxPoint)

	local label = container:createListBoxEx(boxRect)
	
	return yMod,label
end

-----------------------------[ДАННЫЕ ВАНИЛЕК]-----------------------------
entities['chaingun'] = {
	--Иконка
	"data/textures/icons/chaingun.png",
	--Название
	'Chaingun'%_t,
	--Дальность
	rangeType['s-m'],
	--Точность
	accuracyType['m'],
	--Скорострельность
	fireRateType['h'],
	--Тип урона
	damageType['phys'],
	--Описание
	'The simplest low and medium range combat weapon'%_t,
	--Изменения
	{
		descDetails['bonusdamageincrease']..'25%',
		descDetails['techleveltorange'],
		descDetails['techleveltoprojspeed'],
		descDetails['accemblyDamageByParts']..descDetails['inc'],
		descDetails['accemblyFirerateByParts']..descDetails['inc'],
		descDetails['newpartDamageToHull'],
	},
}

entities['laser'] = {
	--Иконка
	"data/textures/icons/laser-gun.png",
	--Название
	'Laser'%_t,
	--Дальность
	rangeType['m'],
	--Точность
	accuracyType['va'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['ener'],
	--Описание
	'Medium-range weapon. It has high accuracy and a good hit rate, which, coupled with the energy type of damage, allows you to inflict stable damage to the enemy'%_t,
	--Изменения
	{
		descDetails['bonusdamageincrease']..'40%',
		descDetails['bonusrangedecrease']..'10-30%',
		'Pierce up to two blocks (railgun mechanics)'%_t,
		descDetails['accemblyDamageByParts']..descDetails['inc'],
		descDetails['accemblyRangeByParts']..descDetails['inc'],
		descDetails['newpartDamageToShield'],
	},
}

entities['plasmagun'] = {
	--Иконка
	"data/textures/icons/plasma-gun.png",
	--Название
	'Plasma cannon'%_t,
	--Дальность
	rangeType['s-m'],
	--Точность
	accuracyType['h'],
	--Скорострельность
	fireRateType['h'],
	--Тип урона
	damageType['plasma'],
	--Описание
	'A powerful and rapid-fire low-range weapon that causes huge damage to enemy shields'%_t,
	--Изменения
	{
		descDetails['bonusdamageincrease']..'30%',
		descDetails['techleveltodamage'],
		descDetails['techleveltorange'],
		descDetails['accemblyDamageByParts']..descDetails['inc'],
		descDetails['morepartsDamage'],
		descDetails['lesspartsRange'],
		descDetails['morepartsBattery'],
		descDetails['newpartDamageToShield'],
	},
}

entities['launcher'] = {
	--Иконка
	"data/textures/icons/rocket-launcher.png",
	--Название
	'Rocket launcher'%_t,
	--Дальность
	rangeType['h'],
	--Точность
	accuracyType['m-ho'],
	--Скорострельность
	fireRateType['m-h'],
	--Тип урона
	damageType['phys'],
	--Описание
	'A long-range siege weapon. During assembly at the station, the projectiles can be homing'%_t,
	--Изменения
	{
		descDetails['classToHeavy'],
		descDetails['bonusdamageincrease']..'15%',
		'When assembling: Fuel now adds damage, not range'%_t,
		descDetails['newpartProjSpeed'],
		descDetails['newpartDamageToHull'],
	},
}

entities['cannon'] = {
	--Иконка
	"data/textures/icons/cannon.png",
	--Название
	'Cannon'%_t,
	--Дальность
	'Большая',
	--Точность
	'Хорошая',
	--Скорострельность
	'Низкая',
	--Тип урона
	'Физический',
	--Описание
	'A gun with a huge alpha damage, capable of destroying smaller ships with a couple of volleys, but it overheats very quickly and cools down for a long time'%_t,
	--Изменения
	{
		descDetails['classToHeavy'],
		descDetails['bonusdamageincrease']..'10%',
		descDetails['bonusToHull']..'45%',
		descDetails['bonusToShields']..'25%',
		descDetails['cannotRecieveDamageTypeOf']..damageType['am'],
		descDetails['morepartsDamage'],
		descDetails['newpartDamageToHull'],
		descDetails['newpartProjSpeed'],
		descDetails['newpartBattery'],
		descDetails['costDecreased'],
	},
}

entities['railgun'] = {
	--Иконка
	"data/textures/icons/rail-gun.png",
	--Название
	'Railgun'%_t,
	--Дальность
	rangeType['s-m'],
	--Точность
	accuracyType['l'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['phys'],
	--Описание
	'A redesigned version of the railgun. Most of the characteristics have been reduced, but instead the railgun now launches three projectiles at once, allowing you to tear opponents apart in close combat'%_t,
	--Изменения
	{
		descDetails['classToHeavy'],
		'The minimum penetration is reduced by 1, the maximum by 40%'%_t,
		'Base damage reduced by 15%'%_t,
		'Significantly reduced accuracy'%_t,
		descDetails['bonusrangedecrease']..'25%',
		'When assembling, the electromagnet now adds damage to shields, not range'%_t,
		'Weapon specializations for range and accuracy are disabled'%_t,
		'Now the gun makes three simultaneous shots, thereby increasing the potential damage three times'%_t,
		descDetails['costDecreased'],
	},
}

entities['repairbeam'] = {
	--Иконка
	"data/textures/icons/repair-beam.png",
	--Название
	'Repair laser'%_t,
	--Дальность
	rangeType['m'],
	--Точность
	accuracyType['va'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['no'],
	--Описание
	'Repair emitter designed for installation on ships. Allows you to repair the hull or shields of allies at medium range'%_t,
	--Изменения
	{
		descDetails['bonusRepair']..'60%',
		descDetails['techleveltorepair'],
		'During assembly: you can invest more parts to hull repair value, their effect is enhanced'%_t,
		'During assembly: you can invest more parts to shield repair value, their effect is enhanced (higher than for the hull)'%_t,
		descDetails['newpartBattery'],
		descDetails['costDecreased'],
	},
}

entities['bolter'] = {
	--Иконка
	"data/textures/icons/bolter.png",
	--Название
	'Bolter'%_t,
	--Дальность
	rangeType['s-m'],
	--Точность
	accuracyType['h'],
	--Скорострельность
	fireRateType['m-h'],
	--Тип урона
	damageType['am'],
	--Описание
	"Low- and medium-range weapon that allow you to quickly destroy the enemy's hull"%_t,
	--Изменения
	{
		descDetails['bonusdamageincrease']..'15%',
		descDetails['techleveltoprojspeed'],
		'The threshold of the minimum rate of fire (in case of random assignment) has been increased'%_t,
		descDetails['accemblyFirerateByParts'],
		descDetails['morepartsDamage'],
		descDetails['newpartProjSpeed'],
		descDetails['morepartsRange'],
	},
}

entities['lightinggun'] = {
	--Иконка
	"data/textures/icons/lightning-gun.png",
	--Название
	'Lightning Gun'%_t,
	--Дальность
	rangeType['h'],
	--Точность
	accuracyType['va'],
	--Скорострельность
	fireRateType['l'],
	--Тип урона
	damageType['elec']..'/'..damageType['plasma'],
	--Описание
	'A long-range weapon capable of effectively destroying enemy shields'%_t,
	--Изменения
	{
		descDetails['classToHeavy'],
		descDetails['bonusdamageincrease']..'25%',
		'Скорострельность значительно снижена (урон остается прежним)'%_t,
		descDetails['accemblyDamageByParts']..descDetails['inc'],
		descDetails['morepartsDamage'],
		'In production: one of the parts now gives a rate of fire'%_t,
		descDetails['newpartBattery'],
	},
}

entities['tesla'] = {
	--Иконка
	"data/textures/icons/tesla-gun.png",
	--Название
	'Tesla Gun'%_t,
	--Дальность
	rangeType['s'],
	--Точность
	accuracyType['va'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['elec'],
	--Описание
	'A high-precision low-range weapon that destroys enemy shields and technical blocks'%_t,
	--Изменения
	{
		descDetails['bonusToShields']..'30%',
		descDetails['morepartsDamage'],
		descDetails['lesspartsRange'],
		'При производстве: одна из деталей теперь дает дополнительный урон по щитам'%_t,
		descDetails['cannotRecieveDamageTypeOf']..damageType['plasma'],
	},
}

entities['pulsecannon'] = {
	--Иконка
	"data/textures/icons/pulsecannon.png",
	--Название
	'Pulse Cannon'%_t,
	--Дальность
	rangeType['s'],
	--Точность
	accuracyType['h'],
	--Скорострельность
	fireRateType['h'],
	--Тип урона
	damageType['phys']..'/'..damageType['am'],
	--Описание
	'A rapid-fire low-range weapon that partially ignores enemy shields'%_t,
	--Изменения
	{
		'Removed vanilla damage penalty (25%), added 5% damage bonus'%_t,
		descDetails['techleveltorange'],
		descDetails['techleveltoprojspeed'],
		descDetails['accemblyFirerateByParts'],
		descDetails['accemblyDamageByParts'],
	},
}


-----------------------------[ДАННЫЕ МОДА]-----------------------------

entities['pulsegun'] = {
	--Иконка
	getWeaponPath('pulsegun'),
	--Название
	getWeaponName('pulsegun'),
	--Дальность
	rangeType['s-m'],
	--Точность
	accuracyType['h'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['ener'],
	--Описание
	'A light energy weapon created on the basis of machine-gun samples. It has an increased range, but the rate of fire is lower. Very cheap in production'%_t,
	--Изменения
	{
		'Inherits the mechanics of firing a machine gun, deals a little less damage, but shoots further'%_t,
		descDetails['techleveltorange'],
		descDetails['techleveltoprojspeed'],
		descDetails['techleveltodamage'],
	},
}

entities['particleaccelerator'] = {
	--Иконка
	getWeaponPath('particleaccelerator'),
	--Название
	getWeaponName('particleaccelerator'),
	--Дальность
	rangeType['m'],
	--Точность
	accuracyType['h'],
	--Скорострельность
	fireRateType['ul'],
	--Тип урона
	damageType['am'],
	--Описание
	"A light sniper gun based on a bolter. It allows you to inflict good damage to the enemy's hull at an average distance and shows itself perfectly on automatic batteries of heavy combat vessels"%_t,
	--Изменения
	{
		'Inherits the mechanics of bolter, shoots much less often and does a little less damage, but the range is higher'%_t,
	},
}

entities['assaultblaster'] = {
	--Иконка
	getWeaponPath('assaultblaster'),
	--Название
	getWeaponName('assaultblaster'),
	--Дальность
	rangeType['m'],
	--Точность
	accuracyType['h'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['elec'],
	--Описание
	'A modified version of the pulse gun. Deals more damage at the cost of reducing the range, and also has a basic bonus damage to the shield'%_t,
	--Изменения
	{
		'Inherits the mechanics of firing a pulse cannon, deals more damage, the type of damage is changed'%_t,
		'It has a basic additional damage to the shield, this bonus is increased by parts on the assembly'%_t,
	},
}

entities['hept'] = {
	--Иконка
	getWeaponPath('hept'),
	--Название
	getWeaponName('hept'),
	--Дальность
	rangeType['m'],
	--Точность
	accuracyType['h'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['plasma'],
	--Описание
	'A modified version of the plasma cannon. The damage inflicted on the shield and body is balanced, shoots further and deals a little more damage'%_t,
	--Изменения
	{
		'The gun is well suited for installation on automatic batteries of heavy vessels'%_t,
		'Basic damage bonuses on the shield and body are increased by parts during assembly'%_t,
	},
}

entities['pulselaser'] = {
	--Иконка
	getWeaponPath('pulselaser'),
	--Название
	getWeaponName('pulselaser'),
	--Дальность
	rangeType['s'],
	--Точность
	accuracyType['l'],
	--Скорострельность
	fireRateType['h'],
	--Тип урона
	damageType['ener'],
	--Описание
	'A powerful rapid-fire emitter that does a lot of damage in a short period of time. Designed for installation on fighter jets'%_t,
	--Изменения
	{
		"Reduces the fighter's firing radius by 25%"%_t,
		'Provides a large bonus to the compactness of the fighter, speed and a small one to maneuverability'%_t,
	},
}

entities['assaultcannon'] = {
	--Иконка
	getWeaponPath('assaultcannon'),
	--Название
	getWeaponName('assaultcannon'),
	--Дальность
	rangeType['s'],
	--Точность
	accuracyType['l'],
	--Скорострельность
	fireRateType['l'],
	--Тип урона
	damageType['phys'],
	--Описание
	'A powerful all-purpose gun designed for installation on fighter jets. Very high projectile speed'%_t,
	--Изменения
	{
		"Increases the fighter's firing radius by 25%"%_t,
		'Provides a major bonus to the compactness of the fighter and maneuverability, as well as a small one to its strength'%_t,
	},
}

entities['magneticmortar'] = {
	--Иконка
	getWeaponPath('magneticmortar'),
	--Название
	getWeaponName('magneticmortar'),
	--Дальность
	rangeType['m'],
	--Точность
	accuracyType['h'],
	--Скорострельность
	fireRateType['l'],
	--Тип урона
	damageType['am'],
	--Описание
	'An artillery weapon for fighters. Deals good alpha damage, but the projectiles are quite slow. Has basic damage bonuses against shield and hull'%_t,
	--Изменения
	{
		"Increases the fighter's firing radius by 175%"%_t,
		'Provides an average bonus to the maneuverability and speed of the fighter'%_t,
	},
}

entities['chargingbeam'] = {
	--Иконка
	getWeaponPath('chargingbeam'),
	--Название
	getWeaponName('chargingbeam'),
	--Дальность
	rangeType['s'],
	--Точность
	accuracyType['va'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['no'],
	--Описание
	'Shield-restoring emitter designed for installation on fighter jets'%_t,
	--Изменения
	{
		'Repairs shields only'%_t,
		"Increases the fighter's firing radius by 15%"%_t,
		'Provides a large bonus to the compactness of the fighter, and a small one to the speed'%_t,
	},
}

entities['nanorepair'] = {
	--Иконка
	getWeaponPath('nanorepair'),
	--Название
	getWeaponName('nanorepair'),
	--Дальность
	rangeType['s'],
	--Точность
	accuracyType['va'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['no'],
	--Описание
	'Repair gun designed for installation on fighter jets. Repairs hull only'%_t,
	--Изменения
	{
		'Available from the very beginning of the game'%_t,
		"Increases the fighter's firing radius by 15%"%_t,
		'Provides a large bonus to the compactness of the fighter, and a small one to the speed'%_t,
	},
}

entities['mantis'] = {
	--Иконка
	getWeaponPath('mantis'),
	--Название
	getWeaponName('mantis'),
	--Дальность
	rangeType['h++'],
	--Точность
	accuracyType['ho'],
	--Скорострельность
	fireRateType['ul'],
	--Тип урона
	damageType['elec'],
	--Описание
	'Created on the basis of a rocket launcher, this gun launches four high-speed homing projectiles at the target, capable of quickly covering a long distance. Despite the fact that the Mantis loses to most weapons systems in terms of damage per second, it is excellent for eliminating small and medium-sized remote targets'%_t,
	--Изменения
	{
		'The gun has a large alpha damage, but its rate of fire is significantly reduced'%_t,
		'Projectiles always homing'%_t,
	},
}

entities['photoncannon'] = {
	--Иконка
	getWeaponPath('photoncannon'),
	--Название
	getWeaponName('photoncannon'),
	--Дальность
	rangeType['h'],
	--Точность
	accuracyType['m'],
	--Скорострельность
	fireRateType['l'],
	--Тип урона
	damageType['ener'],
	--Описание
	'Powerful armament for the main batteries of heavy and artillery vessels. Shoots large slow projectiles that cause a lot of damage. The energy type of damage makes the weapon universal against any resists'%_t,
	--Изменения
	{
		'Created on the basis of a cannon. Damage, explosion and firing radius are lower, projectile velocity and rate of fire are higher'%_t,
		'Receives significant bonuses when assembling at the station'%_t,
	},
}

entities['ionemitter'] = {
	--Иконка
	getWeaponPath('ionemitter'),
	--Название
	getWeaponName('ionemitter'),
	--Дальность
	rangeType['m-h'],
	--Точность
	accuracyType['m'],
	--Скорострельность
	'Ниже среднего',
	--Тип урона
	fireRateType['l'],
	--Описание
	'A modified version of a photon cannon designed to destroy enemy shields. The electric type of damage allows you to inflict decent damage even to the hull when hitting tech blocks'%_t,
	--Изменения
	{
		'Created on the basis of a photon cannon. The damage inflicted is significantly reduced, the projectile flies slower and the radius is smaller'%_t,
		'It has a large base bonus damage to shields, during production this bonus increases noticeably'%_t,
	},
}

entities['prd'] = {
	--Иконка
	getWeaponPath('prd'),
	--Название
	getWeaponName('prd'),
	--Дальность
	rangeType['m'],
	--Точность
	accuracyType['m'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['plasma'],
	--Описание
	'Rail-type weapon. Average firing radius, plasma damage, inaccurate. It is capable of piercing up to two blocks, thus causing good damage to both shields and hull of targets without armor. Great for using on automatic batteries of heavy vessels'%_t,
	--Изменения
	{
		'It has a basic bonus to shield damage, inheriting the features of the plasma damage type'%_t,
	},
}

entities['plasmaflak'] = {
	--Иконка
	getWeaponPath('plasmaflak'),
	--Название
	getWeaponName('plasmaflak'),
	--Дальность
	rangeType['s'],
	--Точность
	accuracyType['m'],
	--Скорострельность
	fireRateType['m-h'],
	--Тип урона
	damageType['part'],
	--Описание
	'Anti-fighter plasma weapon. Shoots two projectiles at once with a reduced explosion radius and range compared to a vanilla anti-aircraft gun'%_t,
	--Изменения
	{
		'High rate of fire and firing two projectiles allow you to create an effective barrage'%_t,
		'Unlike other anti-aircraft guns, it has a battery and consumes it when firing'%_t,
	},
}


entities['hyperkinetic'] = {
	--Иконка
	getWeaponPath('hyperkinetic'),
	--Название
	getWeaponName('hyperkinetic'),
	--Дальность
	rangeType['h++'],
	--Точность
	accuracyType['va'],
	--Скорострельность
	fireRateType['ul'],
	--Тип урона
	damageType['am'],
	--Описание
	'Heavy sniper weapon. Deals huge damage to targets without shields and armor blocks, allowing you to destroy enemy ships in one shot. Extremely low rate of fire'%_t,
	--Изменения
	{
		'It has very low damage to shields and to targets with armor'%_t,
		'Weapon reveals the maximum potential during assembly at the station'%_t,
		"Weapons of the 'main caliber' class impose a permanent penalty to the rate of fire if more than two units are installed"%_t,
	},
}

entities['avalanche'] = {
	--Иконка
	getWeaponPath('avalanche'),
	--Название
	getWeaponName('avalanche'),
	--Дальность
	rangeType['s'],
	--Точность
	accuracyType['ho'],
	--Скорострельность
	fireRateType['ul'],
	--Тип урона
	damageType['phys'],
	--Описание
	'Heavy bomber gun. Shoots at a short distance in volleys of two slow projectiles. Deals crushing damage to the target if it hits'%_t,
	--Изменения
	{
		'Weapon reveals the maximum potential during assembly at the station'%_t,
		'Very bad versus mobile targets'%_t,
		'Does massive damage'%_t,
		"Weapons of the 'main caliber' class impose a permanent penalty to the rate of fire if more than two units are installed"%_t,
		'No overheat'%_t,
	},
}

entities['cyclone'] = {
	--Иконка
	getWeaponPath('cyclone'),
	--Название
	getWeaponName('cyclone'),
	--Дальность
	rangeType['h++'],
	--Точность
	accuracyType['ho'],
	--Скорострельность
	fireRateType['l'],
	--Тип урона
	damageType['elec'],
	--Описание
	"Enhanced version of the 'Mantis'. Launches a swarm of missiles in several volleys before overheating. The missiles fly fast, far away and are aimed at the target. It cools down for a very long time (40 seconds) after firing"%_t,
	--Изменения
	{
		'Weapon reveals the maximum potential during assembly at the station'%_t,
		'An excellent weapon for the targeted destruction of important targets'%_t,
		'Does a lot of damage, but cools down for a very long time'%_t,
		"Weapons of the 'main caliber' class impose a permanent penalty to the rate of fire if more than two units are installed"%_t,
	},
}

entities['transphasic'] = {
	--Иконка
	getWeaponPath('transphasic'),
	--Название
	getWeaponName('transphasic'),
	--Дальность
	rangeType['m'],
	--Точность
	accuracyType['va'],
	--Скорострельность
	fireRateType['m'],
	--Тип урона
	damageType['ener'],
	--Описание
	'Heavy version of the laser gun. It pierces up to two blocks and has a basic bonus damage on shields. It has an increased range and discharges its battery more slowly'%_t,
	--Изменения
	{
		'Weapon reveals the maximum potential during assembly at the station'%_t,
		'A universal tool in its class'%_t,
		"Weapons of the 'main caliber' class impose a permanent penalty to the rate of fire if more than two units are installed"%_t,
	},
}