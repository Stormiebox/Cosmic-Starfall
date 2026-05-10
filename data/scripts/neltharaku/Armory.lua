package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('ColorLib')

local weaponIcons = {}

local armoryColors = {}
	armoryColors['standart'] = ColorHSV(240, 0, 100)
	armoryColors['update'] = getColor('infotabs_updated')
	armoryColors['light'] = getColor('weaponclass_light')
	armoryColors['heavy'] = getColor('weaponclass_heavy')
	armoryColors['MC'] = getColor('weaponclass_MC')

local weaponFigherBonuses = {}
--diameter
--durability
--turningSpeed
--maxVelocity
--В качестве единицы используется значение, которое получается путем целочисленногоделения техуровня туретки на 10
--Таким образом на аворионе это значение будет равно 5-6 (округление в большую сторону)
--UNIT

local weaponNames = {}
	weaponNames['pulsegun'] = "Pulse Gun"%_t
	weaponNames['particleaccelerator'] = "Particle Accelerator"%_t
	weaponNames['assaultblaster'] = "Photon Blaster"%_t
	weaponNames['hept'] = "Vortex Cannon"%_t
	weaponNames['pulselaser'] = "Pulse Laser"%_t
	weaponNames['assaultcannon'] = "Assault Cannon"%_t
	weaponNames['magneticmortar'] = "Magnetic Mortar"%_t
	weaponNames['chargingbeam'] = "Charging Beam"%_t
	weaponNames['nanorepair'] = "Nano Repair Beam"%_t
	weaponNames['mantis'] = "'Mantis' launcher"%_t
	weaponNames['photoncannon'] = "Photon Cannon"%_t
	weaponNames['ionemitter'] = "Ion Emitter"%_t
	weaponNames['prd'] = "Plasma Beam Disintegrator"%_t
	weaponNames['plasmaflak'] = "Plasma Flak Cannon"%_t
	weaponNames['hyperkinetic'] = "Hyperkinetic Artillery"%_t
	weaponNames['avalanche'] = "'Avalanche' Gravity Cannon"%_t
	weaponNames['cyclone'] = "'Cyclone' Missile Battery"%_t
	weaponNames['transphasic'] = "Transphasic Laser"%_t
	
-- local fighterProdLines = {}
	-- fighterProdLines['cant_produce_heavy'] = ""%_t

----------------иконки
--Стандартные
weaponIcons['pulsegun'] = 'data/textures/icons/PULSEGUN.png' --импульсная пушка
weaponIcons['particleaccelerator'] = 'data/textures/icons/PARTICLEACCELERATOR.png' --кинетическое орудие
weaponIcons['assaultblaster'] = 'data/textures/icons/ASSAULTBLASTER.png' --фотонный бластер
weaponIcons['hept'] = 'data/textures/icons/HEPT.png' --вихревая пушка
weaponIcons['mantis'] = 'data/textures/icons/MANTIS.png' --богомол
weaponIcons['prd'] = 'data/textures/icons/weapon/wpnPrd.png' --Плазмонитиевый дезинтегратор
weaponIcons['plasmaflak'] = 'data/textures/icons/weapon/wpnPlasmaflak.png' --Зенитный плазмомет

--Легкие
weaponIcons['pulselaser'] = 'data/textures/icons/weapon/wpnPulseLaser.png' --импульсный лазер
	weaponFigherBonuses['pulselaser'] = {1,0,0.5,1}

weaponIcons['assaultcannon'] = 'data/textures/icons/WPNassaultCannon.png' --штурмовая пушка
	weaponFigherBonuses['assaultcannon'] = {1,0.25,1,0}
	
weaponIcons['magneticmortar'] = 'data/textures/icons/weapon/wpnMagneticmortar.png' --магнитный миномет
	weaponFigherBonuses['magneticmortar'] = {0,0,0.5,0.5}
	
weaponIcons['nanorepair'] = 'data/textures/icons/weapon/wpnNanorepair.png' --наноремонтная установка
	weaponFigherBonuses['nanorepair'] = {1,0,0,0.5}
	
weaponIcons['chargingbeam'] = 'data/textures/icons/weapon/wpnRecahrge.png' --заряжающий луч
	weaponFigherBonuses['chargingbeam'] = {1,0,0,0.5}
--Тяжелые
weaponIcons['photoncannon'] = 'data/textures/icons/PHOTON.png' --фотонная пушка
weaponIcons['ionemitter'] = 'data/textures/icons/weapon/wpnIonEmitter.png' --ионный излучатель

weaponIcons['vanillarailgun'] = 'data/textures/icons/rail-gun.png' --рельса
weaponIcons['vanillalauncher'] = 'data/textures/icons/rocket-launcher.png' --ракетомет
weaponIcons['vanillacannon'] = 'data/textures/icons/cannon.png' --пушко
weaponIcons['vanillalightning'] = 'data/textures/icons/lightning-gun.png' --вольт

--Главный калибр
weaponIcons['hyperkinetic'] = 'data/textures/icons/HYPERKINETIC.png' --гиперкинетическая артиллерия
weaponIcons['avalanche'] = 'data/textures/icons/weapon/wpnAvalanche.png' --Гравитационная пушка "лавина"
weaponIcons['cyclone'] = 'data/textures/icons/weapon/wpnCyclone2.png' --Ракетная установка "циклон"
weaponIcons['transphasic'] = 'data/textures/icons/weapon/wpnHeavyLaser.png' --трансфазный лазер
--weaponIcons['solarlance'] = 'data/textures/icons/weapon/wpnSolarLance.png' --Солнечное копье

--Поддержки
----------------

---------------------------------------------------------------------------------------------------------------------

local _debug = false

function Debug(_text)
	if _debug then
		print('Armory lib|',_text)
	end
end

function checkLightPath(_path)
	local _index = {
		'pulselaser',
		'assaultcannon',
		'magneticmortar',
		'nanorepair',
		'chargingbeam'
	}
	
	for _,_rows in pairs(_index) do
		if _path == weaponIcons[_rows] then return true,_rows end
	end

	return false,nil
end

function checkHeavyPath(_path)

	local _index = {
		--Звездопад
		'photoncannon',
		'ionemitter',
		
		--Ванилки
		'vanillarailgun',
		'vanillalauncher',
		'vanillacannon',
		'vanillalightning'
	}
	
	for _,_rows in pairs(_index) do
		if _path == weaponIcons[_rows] then return true,_rows end
	end
	
	return false,nil
	
end

function checkMCPath(_path)

	local _index = {
		'hyperkinetic',
		'avalanche',
		'cyclone',
		'transphasic'
	}
	
	for _,_rows in pairs(_index) do
		if _path == weaponIcons[_rows] then return true,_rows end
	end

	return false,nil
end

--Возвращает путь к иконе, служебная
function armoryGetPath(_itemturret,_weapon,_Weapons)

	if _itemturret then
		local wpn = _itemturret:getWeapons()
		return wpn.icon
	end
	
	if _weapon then
		return _weapon.icon
	end
	
	if _Weapons then
		return _Weapons.weaponIcon
	end
	
end

function getTypeColorByWeapon(path)
	if checkLightPath(path) then return armoryColors['light'] end
	if checkHeavyPath(path) then return armoryColors['heavy'] end
	if checkMCPath(path) then return armoryColors['MC'] end
	return armoryColors['standart']
end

--=======================[Внешние вызовы]=======================

function getWeaponName(_name)
	if weaponNames[_name] then
		return weaponNames[_name]
	else
		return 'nothing'
	end
end

function getWeaponPath(_name)
	if weaponIcons[_name] then
		return weaponIcons[_name]
	else
		return 'data/textures/icons/cancel.png'
	end
end

function getWeaponBonuses(_name)
	if weaponFigherBonuses[_name] then
		return weaponFigherBonuses[_name]
	end
end

--Вызывается для проверки, принадлежит ли пушка к легкому типу
function isTurretLight(_itemturret,_weapon,_Weapons)
	Debug('isTurretLight attempt')
	--Отсекание
	if not(_itemturret) and not(_weapon) and not(_Weapons) then return false end

	--Переменные
	local _result = false
	local _index = nil

	--Поиск строки
	local _path = armoryGetPath(_itemturret,_weapon,_Weapons)
	
	--Отсекание неудачного
	if not(_path) then
		Debug('isTurretLight failure')
		return false,nil
	end
	
	--Поиск информации
	_result,_index = checkLightPath(_path)
	
	--Возвращение значений
	if _result then
		Debug('isTurretLight - true')
	else
		Debug('isTurretLight - false')
	end
	return _result,_index
end

--Вызывается для проверки, принадлежит ли пушка к тяжелому типу
function isTurretHeavy(_itemturret,_weapon,_Weapons)
	Debug('isTurretHeavy attempt')
	--Отсекание
	if not(_itemturret) and not(_weapon) and not(_Weapons) then return false end

	--Поиск строки
	local _path = armoryGetPath(_itemturret,_weapon,_Weapons)
	
	--Отсекание неудачного
	if not(_path) then
		Debug('isTurretHeavy failure')
		return false
	end
	
	--Поиск строки иконки
	if checkHeavyPath(_path) then return true end
	
	--Возвращение корректного значения
	Debug('isTurretHeavy false call')
	return false
end

--Вызывается для проверки, принадлежит ли пушка к типу главного калибра
function isTurretMC(_itemturret,_weapon,_Weapons)
	Debug('isTurretMC attempt')
	--Отсекание
	if not(_itemturret) and not(_weapon) and not(_Weapons) then return false end

	--Поиск строки
	local _path = armoryGetPath(_itemturret,_weapon,_Weapons)
	
	--Отсекание неудачного
	if not(_path) then
		Debug('isTurretMC failure')
		return false
	end
	
	--Поиск строки иконки
	if checkMCPath(_path) then return true end
	
	--Возвращение корректного значения
	Debug('isTurretMC false call')
	return false
end

--Вызывается для предоставления цвета названия/типа соотв. типа вооружения
function getTypeColor(_type)
	if not(_type) then return armoryColors['standart'] end
	
	Debug('getTypeColor attempt with argument: '.._type)
	if armoryColors[_type] then
		Debug('getTypeColor: ok')
		return armoryColors[_type]
	else
		Debug('getTypeColor: failure')
		return armoryColors['standart']
	end
end