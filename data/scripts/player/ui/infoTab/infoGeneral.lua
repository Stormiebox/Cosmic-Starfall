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
		print('infoGeneral|',_text)
	end
end
local Debug = infoGeneral.DebugMsg
local RR = Neltharaku.ReportRect
local V2R = Neltharaku.ReportVec2
local dF = Neltharaku.debugFrame
local ApplyBorder = Neltharaku.GLapplyBorderFrame
local TSR = Neltharaku.TableSelfReport

local locNames = {}
	locNames['weaponsnew'] = 'Weapons - new'%_t
	locNames['weaponsvanilla'] = 'Weapons - vannila changes'%_t
	locNames['systemsnew'] = 'Systems - new'%_t
	locNames['stationssnew'] = 'Stations - new'%_t
	locNames['uinew'] = 'Interface - new'%_t

local order = {
	--name,ID,IDupdate
	{locNames['weaponsnew'],'weaponclasses',0.1},
	{locNames['weaponsnew'],'weaponnew',0.1},
	{locNames['weaponsvanilla'],'weaponrebalance',0.1},
	{locNames['systemsnew'],'systemnew',0.1},
	{locNames['stationssnew'],'stationnew',0.1},
	{locNames['uinew'],'alertsystem',0.1},
	{locNames['uinew'],'combatgroup',0.1},
	{locNames['uinew'],'asi',0.3},
	{locNames['uinew'],'auracore',0.2},
}

local entities = {}
--1 name
--2 modname
--3 data

local icons = {}
	icons['pulseTractorBeamGenerator'] = 'data/textures/icons/SYSpReactor3.png'

local self = infoGeneral
local listboxLabelSizeK = 0.7 -- Коэффициент размера rUnit для label листбоксов (для листера)
local listboxLabelFontSizeK = 0.32 -- Коэффициент размера rUnit текста для label листбоксов
local stColor = getTypeColorByWeapon()

function infoGeneral.SetEntitiesV2(container,rUnit,gUK)

	Debug('infoGeneral.SetEntitiesV2 gUK is '..tostring(gUK))

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
				local entityRow = entities[entryName]
				local name = entityRow[1]
				
				local color = getTypeColor()
				if entryGUK>=gUK then color = getTypeColor('update') end
				
				Debug('applying '..name..' to '..segment)
				
				boxTable[segment]:addRow()
				boxTable[segment]:setEntry(0,boxTable[segment].rows-1,name,false,false,color)
				boxTable[segment]:setEntryValue(0,boxTable[segment].rows-1,entryName)
			
			end
		end
	end
	
	return boxTable
	
end

--Создает label для списка в LEFT
function infoGeneral.createLabel(y,container,rUnit,name)
	local yMod = y + rUnit * 0.5

	local labelAnchor = vec2(0,y)
	local labelPoint = vec2(container.width*0.98,yMod)
	local labelRect = Rect(labelAnchor,labelPoint)

	local label = container:createLabel(labelRect,name,rUnit * listboxLabelFontSizeK)
	
	return yMod
end

--Создает labelBox для списка в LEFT
function infoGeneral.createBox(y,container,height,rowsize)

	local yMod = y + height

	local boxAnchor = vec2(0,y)
	local boxPoint = vec2(container.width * 0.98,yMod)
	local boxRect = Rect(boxAnchor,boxPoint)

	local label = container:createListBoxEx(boxRect)
	
	return yMod,label
end

--Создает список infobox для RIGHT
function infoGeneral.GetInfoContainers(container,rUnit)
	local _result = {}
	
	for _key,_rows in pairs(entities) do
		local stType = _key
		local infobox = self.SetMain(stType,container,rUnit)
		_result[_key] = infobox
	end
	return _result
end

--Генерирует infobox
function infoGeneral.SetMain(stType,baseContainer,rUnit)

	Debug('SetMain attempt with type '..stType)
	if not(stType) then Debug('Failure: no stType') return end
	if not(baseContainer) then Debug('Failure: no baseContainer') return end
	if not(rUnit) then Debug('Failure: no rUnit') return end

	--Создание контейнера
	local infobox = baseContainer:createScrollFrame(Rect(baseContainer.size))
	
	--Базовые переменные
	local baseSize = infobox.size
	local chosenTable = entities[stType]
	
	--Генерация сегментов
	local data = chosenTable[3]
	local name = chosenTable[1]
	local yMod = 0
	
	for _index,_rows in pairs(data) do
		
		local dataType = _rows[1]
		local dataHeight = _rows[2]
		local dataInfo = _rows[3] --Описание или путь к иконке
		local dataLabel = _rows[4] --Только у iconinfo - содержимое label

		if dataType == 'mainlabel' then
		
			local iconE,nameE
			iconE,nameE,yMod = self.CreateMainLabel(yMod,infobox,rUnit)
			
			iconE.picture = dataInfo
			nameE.caption = name
			nameE.fontSize = rUnit*0.3
			
			yMod = self.CreateLine(yMod,infobox,rUnit)
			
		end
		
		if dataType == 'desc' then
		
			local descE
			descE,yMod = self.CreateDescription(yMod,infobox,dataHeight,rUnit)
			
			descE.text = dataInfo
			
			--yMod = infoStations.CreateLine(yMod,baseContainer,rUnit)
			
		end
		
		if dataType == 'iconinfo' then
		
			local iconE,descE
			iconE,descE,yMod = self.CreateIconLabel(yMod,infobox,rUnit)
			
			iconE.picture = dataInfo
			descE.caption = dataLabel
			descE.fontSize = rUnit*0.25
			
		end
		
	end
	
	infobox:hide()
	return infobox
end

--Создает текстовое поле в табе RIGHT
function infoGeneral.CreateDescription(y,container,height,rUnit)
	local xPadding = rUnit*0.25
	local yPadding = rUnit*0.25
	
	local descAnchor = vec2(xPadding,y+yPadding)
	local descPoint = vec2(container.width - xPadding,descAnchor.y + height * rUnit)
	local descRect = Rect(descAnchor,descPoint)
	local descElement = container:createMultiLineTextBox(descRect)
		descElement.editable = false
		descElement.setFontSize = rUnit*0.3
	local yMod = descPoint.y
	
	return descElement,yMod
end

--Создает картинку в табе RIGHT
function infoGeneral.CreatePicture(y,container,height,rUnit)
	local xPadding = rUnit*0.25
	local yPadding = rUnit*0.25
	
	local baseAnchor = vec2(xPadding,y+yPadding)
	local basePoint = vec2(container.width - xPadding,baseAnchor.y + height * rUnit)
	local baseRect = Rect(baseAnchor,basePoint)
	local baseElement = container:createPicture(baseRect, nil)

	local yMod = basePoint.y
	
	return baseElement,yMod
end

--Создает картинку + название субэлемента в табе RIGHT
function infoGeneral.CreateIconLabel(y,container,rUnit)
	local xPadding = rUnit*0.25
	local yPadding = rUnit*0.25 + y
	local unitMod = rUnit * 0.7
	local textFieldSqueeze = rUnit * 0.25
	
	local iconAnchor = vec2(xPadding,yPadding)
	local iconPoint = vec2(iconAnchor.x + unitMod,iconAnchor.y + unitMod)
	local iconRect = Rect(iconAnchor,iconPoint)
	local iconElement = container:createPicture(iconRect,nil)
		iconElement.isIcon = true
	
	local nameAnchor = vec2(iconPoint.x + xPadding * 2,yPadding + textFieldSqueeze)
	local namePoint = vec2(nameAnchor.x + rUnit * 9,nameAnchor.y + unitMod)
	local nameRect = Rect(nameAnchor,namePoint)
	local nameElement = container:createLabel(nameRect,'',10)
	
	local yMod = iconPoint.y
	
	return iconElement,nameElement,yMod
end

--Создает заголовок в табе RIGHT 
function infoGeneral.CreateMainLabel(y,container,rUnit)
	local xPadding = rUnit*0.25
	local yPadding = rUnit*0.25 + y
	local unitMod = rUnit * 0.9
	local textFieldSqueeze = rUnit * 0.25
	
	local iconAnchor = vec2(xPadding,yPadding)
	local iconPoint = vec2(iconAnchor.x + unitMod,iconAnchor.y + unitMod)
	local iconRect = Rect(iconAnchor,iconPoint)
	local iconElement = container:createPicture(iconRect,nil)
		iconElement.isIcon = true
	
	local nameAnchor = vec2(iconPoint.x + xPadding * 2,yPadding + textFieldSqueeze)
	local namePoint = vec2(nameAnchor.x + rUnit * 9,nameAnchor.y + unitMod)
	local nameRect = Rect(nameAnchor,namePoint)
	local nameElement = container:createLabel(nameRect,'',10)
		nameElement.bold = true
	
	local yMod = iconPoint.y
	
	return iconElement,nameElement,yMod
end

function infoGeneral.CreateLine(y,container,rUnit)
	local yMod = y + rUnit*0.25
	local v1 = vec2(rUnit*0.25,y)
	local v2 = vec2(container.width - rUnit*0.25,y)
	container:createLine(v1,v2)
	return yMod
end

-----------------------------[ДАННЫЕ: МОД]-----------------------------

--Типы: desc,picture,iconinfo,mainlabel

entities['weaponclasses'] = {
	--Имя
	'Weapon class '%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/ASSAULTBLASTER.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.3, -- Высота (nil для iconname/mainlabel)
			"A new characteristic of weapon: 'class' determines the behavior of various types of weapons in some situations. You can see the class of the gun in the information panel of the turret, the corresponding line will be located at the very top"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/weapon/wpnCyclone2.png', -- Содержимое. Текст или путь к картинке.
			'Weapon class - Main caliber'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			2, -- Высота (nil для iconname/mainlabel)
			"Extremely powerful weapons, which have a huge fire power after assebmbly at the stations, surpassing any other types of weapons. Each ship can use a maximum of two 'main caliber' class weapons without consequences, otherwise the ship receives a serious penalty to the rate of fire. These weapons cannot be used in the production of fighters"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/weapon/wpnMagneticmortar.png', -- Содержимое. Текст или путь к картинке.
			'Weapon class - light'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			3, -- Высота (nil для iconname/mainlabel)
			"Usually, light-class weapons have modest characteristics, inferior to other weapons systems in almost all parameters, however, this situation changes during the production of fighters.\nEach gun has its own unique bonus to fighter basic characteristics, depending on the technical level of the turret, a bonus (or penalty) to the firing range, and also, most importantly, when producing a fighter, a different damage coefficient is applied to the turrets from the standard:\nCombat turrets - 105% instead of 40%\nRepair and other turrets - 80% instead of 40%"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/weapon/wpnIonEmitter.png', -- Содержимое. Текст или путь к картинке.
			'Weapon class - heavy'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			0.6, -- Высота (nil для iconname/mainlabel)
			'Weapons of this class cannot be used in the production of fighters'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/weapon/wpnPrd.png', -- Содержимое. Текст или путь к картинке.
			'Weapon class - standart'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			0.6, -- Высота (nil для iconname/mainlabel)
			'Conventional weapons using standard Avorion rules'%_t, -- Содержимое. Текст или путь к картинке.
		},
	},	
}

entities['weaponnew'] = {
	--Имя
	'New weapons'%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/HYPERKINETIC.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.1, -- Высота (nil для iconname/mainlabel)
			"17 new weapons have been added to the game. You can find out more about each one in the tab 'Weapons'"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('pulsegun'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('pulsegun') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. Rapid-fire low- and medium range weapon. does not overheat'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('particleaccelerator'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('particleaccelerator') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. Light accurate medium-range weapon'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('assaultblaster'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('assaultblaster') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. Medium-range rapid-fire weapon that deals increased damage to shields'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('hept'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('hept') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. Universal medium-range plasma cannon'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('mantis'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('mantis') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. Long-range homing weapon designed to deal against mobile targets'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('prd'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('prd') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. Powerful, but not very accurate rail-type plasma weapon'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('plasmaflak'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('plasmaflak') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Defensive. Rapid-fire weapon against fighters'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('pulselaser'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('pulselaser') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: light. A rapid-firing light low-range weapon designed for fighters'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('assaultcannon'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('assaultcannon') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: light. A versatile powerful, but not very accurate medium-range weapon designed for fighters'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('magneticmortar'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('magneticmortar') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: light. A long-range siege weapon designed for fighters'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('nanorepair'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('nanorepair') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: light. Beam weapon for hull repair, designed for fighters'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('chargingbeam'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('chargingbeam') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: light. A beam gun for repairing shields, designed for fighters'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('photoncannon'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('photoncannon') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: heavy. A powerful siege weapon designed for heavy ships'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('ionemitter'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('ionemitter') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: heavy. A powerful siege weapon designed for heavy ships. Deals serious damage to enemy shields'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('hyperkinetic'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('hyperkinetic') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Main caliber. High-powered sniper weapon capable of destroying vulnerable targets with a single shot'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('avalanche'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('avalanche') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Main caliber. A siege weapon capable of inflicting massive damage to slow and stationary targets'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('cyclone'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('cyclone') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Main caliber. A weapon capable of inflicting great damage to any targets at a long distance, but in need of a long recharge'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			getWeaponPath('transphasic'), -- Содержимое. Текст или путь к картинке.
			getWeaponName('transphasic') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.4, -- Высота (nil для iconname/mainlabel)
			'Class: Main caliber. A universal laser heavy weapon that deals good damage at medium range'%_t, -- Содержимое. Текст или путь к картинке.
		},
	},
}

entities['weaponrebalance'] = {
	--Имя
	'Vanilla weapons changes'%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/turret.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.3, -- Высота (nil для iconname/mainlabel)
			"Almost all vanilla weapons have changes that somehow increase their combat potential. This also affects opponents, making them more dangerous. The full list of changes is available in the 'Weapons' tab"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/chaingun.png", -- Содержимое. Текст или путь к картинке.
			'Chaingun'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. Base damage increased. The damage, range and speed of the projectile will increase further with the technical level'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/laser-gun.png", -- Содержимое. Текст или путь к картинке.
			'Laser'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. The base damage is increased and range is slightly reduced. Now it pierces up to two blocks. During assembly, it receives bonus damage on shields'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/plasma-gun.png", -- Содержимое. Текст или путь к картинке.
			'Plasma Gun'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1, -- Высота (nil для iconname/mainlabel)
			"Class: Standard. The base damage is increased and additionally increases with the tech level. The base range also increases slightly with the tech level. Bonus damage to shields increases during assembly"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/rocket-launcher.png", -- Содержимое. Текст или путь к картинке.
			'Rocket Launcher'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1, -- Высота (nil для iconname/mainlabel)
			'Class: heavy. The class has been changed, the damage has been increased, the assembly bonuses have been redesigned. During production, it is possible to increase the flight speed of missiles, but the range has become lower'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/cannon.png", -- Содержимое. Текст или путь к картинке.
			'Cannon'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.2, -- Высота (nil для iconname/mainlabel)
			"Class: heavy. The class has been changed. The base damage has been increased, and the weapon now receives a base bonus to damage on shields and hull. Can no longer receive the Antimatter damage type. Gets big bonuses during assembly"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/rail-gun.png", -- Содержимое. Текст или путь к картинке.
			'Railgun'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.2, -- Высота (nil для iconname/mainlabel)
			'Class: heavy. The class has been changed. The logic of use has been redesigned - now it is a low- and medium-range weapon operating like a slug gun'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/repair-beam.png", -- Содержимое. Текст или путь к картинке.
			'Repair Laser'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.2, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. The basic repair has been greatly increased and will be further increased with tech level. During assembly, the range is greatly increased'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/bolter.png", -- Содержимое. Текст или путь к картинке.
			'Bolter'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.2, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. The base damage is increased, the threshold of the minimum rate of fire is increased, and the base speed of the projectile will increase with the tech level. Gets more bonuses during assembly'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/lightning-gun.png", -- Содержимое. Текст или путь к картинке.
			'Lightning Gun'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.2, -- Высота (nil для iconname/mainlabel)
			'Class: heavy. The class has been changed. The base damage is increased, the rate of fire is significantly reduced (does not affect damage). Receives strong bonuses during assembly'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/tesla-gun.png", -- Содержимое. Текст или путь к картинке.
			'Tesla Gun'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.2, -- Высота (nil для iconname/mainlabel)
			"Class: Standard. Shield damage increased. Can no longer receive the type of damage 'plasma', however, during assembly, the damage to shields increases significantly, as well as normal damage"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			"data/textures/icons/pulsecannon.png", -- Содержимое. Текст или путь к картинке.
			'Pulse Cannon'%_t -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			1.2, -- Высота (nil для iconname/mainlabel)
			'Class: Standard. Base damage is noticeably increased. The range of fire and the speed of the projectile will increase with tech level. Assembly bonuses are increased'%_t, -- Содержимое. Текст или путь к картинке.
		},
	},
}

entities['systemnew'] = {
	--Имя
	'New systems'%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/STArepairPassive.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.3, -- Высота (nil для iconname/mainlabel)
			"The mod contains new ship systems that allow you to more accurately specialize vessels for various tasks. Some of them are active - in addition to providing passive bonuses, they supplement their effect with interactive abilities.\n Learn more in the 'systems' tab"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/SYSrepairDrones.png', -- Содержимое. Текст или путь к картинке.
			getTechName('repairdrones') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			2, -- Высота (nil для iconname/mainlabel)
			"Designed to improve the survival ability of hull-based ships.\nIncreases  durability, applies additional passive repair in case of serious damage. Active abilities are aimed at repairing hull"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/SYShypergenerator.png', -- Содержимое. Текст или путь к картинке.
			getTechName('xperimentalhypergenerator') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			2, -- Высота (nil для iconname/mainlabel)
			'A system for heavy carrier ships and scouts. Increases the chances of leaving the sector after an unlucky warp into an enemy fleet.\nImproves the jump range and cooldown, but increases the energy consumption of the jump.\nActive abilities affect jump range, charging speed, and survival before jumping'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/SYSbastion.png', -- Содержимое. Текст или путь к картинке.
			getTechName('bastionsystem') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			2, -- Высота (nil для iconname/mainlabel)
			'Designed for heavy shield-based ships.\nReduces the volume of the shield, but increases its regeneration and reduces the time before charging.\nActive abilities allow you to strengthen the shield, restore it, make it impenetrable and completely protect yourself from any torpedoes for a while'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/SYSmacrofieldprojector.png', -- Содержимое. Текст или путь к картинке.
			getTechName('macrofieldprojector') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			2, -- Высота (nil для iconname/mainlabel)
			"Designed to specialize ship into repair class. Uses the ship's battery to generate repair beams or a powerful repair field"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/SYSpReactor3.png', -- Содержимое. Текст или путь к картинке.
			getTechName('pulsetractorbeamgenerator') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			2, -- Высота (nil для iconname/mainlabel)
			'Allows you to temporarily accelerate the radius of the tractor beam to large values'%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/SYSsubspacecargo.png', -- Содержимое. Текст или путь к картинке.
			getTechName('subspacecargo') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			2, -- Высота (nil для iconname/mainlabel)
			'Improves the cargo bay, but reduces energy production and slightly reduces the shields. Always a percentage bonus'%_t, -- Содержимое. Текст или путь к картинке.
		},
	},	
}

entities['stationnew'] = {
	--Имя
	'New stations'%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/station.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.3, -- Высота (nil для iconname/mainlabel)
			"New stations added by modification. For more information, see the 'stations' tab"%_t, -- Содержимое. Текст или путь к картинке.
		},
		{
			'iconinfo', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/MCXmegaComplex.png', -- Содержимое. Текст или путь к картинке.
			getStationName('mx') -- Содержимое для icon info 
		},
		{
			'desc', -- Тип элемента
			2, -- Высота (nil для iconname/mainlabel)
			'Megacomplex is a station that allows you to set up automatic and fast logistics of resources between all docked stations'%_t, -- Содержимое. Текст или путь к картинке.
		},
	},	
}

entities['alertsystem'] = {
	--Имя
	'Alert system'%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/alert/AlertDeadTurret.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.3, -- Высота (nil для iconname/mainlabel)
			'A system of visual and audio alerts. The graphical part in the form of an icon appears on the right side of the screen and unfolds when the cursor is hovered over. The current working types of alerts are indicated in the corresponding tab'%_t, -- Содержимое. Текст или путь к картинке.
		},
	},	
}

entities['combatgroup'] = {
	--Имя
	'Combat group'%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/FederationSC.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.3, -- Высота (nil для iconname/mainlabel)
			"Graphical interface for working with a group of players. Allows you to search, invite to a group, kick players and transfer leadership without the need to use chat commands. For more information, see the 'interfaces' tab"%_t, -- Содержимое. Текст или путь к картинке.
		},
	},	
}

entities['asi'] = {
	--Имя
	'Active System Interface'%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/ui/ui_circutry.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.3, -- Высота (nil для iconname/mainlabel)
			"Customizable interface that provides access to the active systems installed on the ship"%_t, -- Содержимое. Текст или путь к картинке.
		},
	},	
}

entities['auracore'] = {
	--Имя
	'Active effects'%_t,
	--принадлежит к:
	nil,
	--Содержимое
	{
		{
			'mainlabel', -- Тип элемента
			nil, -- Высота (nil для iconname/mainlabel)
			'data/textures/icons/ui/ui_invitePending.png', -- Содержимое. Текст или путь к картинке.
		},
		{
			'desc', -- Тип элемента
			1.3, -- Высота (nil для iconname/mainlabel)
			"An interface that displays active effects from the Starfall mod affecting the ship"%_t, -- Содержимое. Текст или путь к картинке.
		},
	},	
}