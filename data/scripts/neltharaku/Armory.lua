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
--The unit is the value that is obtained by integer division of the technical level of the tourette by 10
--Thus, on Avorion this value will be 5-6 (rounding up)
--UNIT

local weaponNames = {}
weaponNames['pulsegun'] = "Pulse Gun" % _t
weaponNames['particleaccelerator'] = "Particle Accelerator" % _t
weaponNames['assaultblaster'] = "Photon Blaster" % _t
weaponNames['hept'] = "Vortex Cannon" % _t
weaponNames['pulselaser'] = "Pulse Laser" % _t
weaponNames['assaultcannon'] = "Assault Cannon" % _t
weaponNames['magneticmortar'] = "Magnetic Mortar" % _t
weaponNames['chargingbeam'] = "Charging Beam" % _t
weaponNames['nanorepair'] = "Nano Repair Beam" % _t
weaponNames['mantis'] = "'Mantis' launcher" % _t
weaponNames['photoncannon'] = "Photon Cannon" % _t
weaponNames['ionemitter'] = "Ion Emitter" % _t
weaponNames['prd'] = "Plasma Beam Disintegrator" % _t
weaponNames['plasmaflak'] = "Plasma Flak Cannon" % _t
weaponNames['hyperkinetic'] = "Hyperkinetic Artillery" % _t
weaponNames['avalanche'] = "'Avalanche' Gravity Cannon" % _t
weaponNames['cyclone'] = "'Cyclone' Missile Battery" % _t
weaponNames['transphasic'] = "Transphasic Laser" % _t

-- local fighterProdLines = {}
-- fighterProdLines['cant_produce_heavy'] = ""%_t

----------------icons
--Standard
weaponIcons['pulsegun'] = 'data/textures/icons/PULSEGUN.png'                       --pulse gun
weaponIcons['particleaccelerator'] = 'data/textures/icons/PARTICLEACCELERATOR.png' --kinetic weapon
weaponIcons['assaultblaster'] = 'data/textures/icons/ASSAULTBLASTER.png'           --photon blaster
weaponIcons['hept'] = 'data/textures/icons/HEPT.png'                               --vortex gun
weaponIcons['mantis'] = 'data/textures/icons/MANTIS.png'                           --Mantis
weaponIcons['prd'] = 'data/textures/icons/weapon/wpnPrd.png'                       --Plasmonithium disintegrator
weaponIcons['plasmaflak'] = 'data/textures/icons/weapon/wpnPlasmaflak.png'         --Anti-aircraft plasma launcher

--Lungs
weaponIcons['pulselaser'] = 'data/textures/icons/weapon/wpnPulseLaser.png' --pulse laser
weaponFigherBonuses['pulselaser'] = { 1, 0, 0.5, 1 }

weaponIcons['assaultcannon'] = 'data/textures/icons/WPNassaultCannon.png' --assault cannon
weaponFigherBonuses['assaultcannon'] = { 1, 0.25, 1, 0 }

weaponIcons['magneticmortar'] = 'data/textures/icons/weapon/wpnMagneticmortar.png' --magnetic mortar
weaponFigherBonuses['magneticmortar'] = { 0, 0, 0.5, 0.5 }

weaponIcons['nanorepair'] = 'data/textures/icons/weapon/wpnNanorepair.png' --nanorepair unit
weaponFigherBonuses['nanorepair'] = { 1, 0, 0, 0.5 }

weaponIcons['chargingbeam'] = 'data/textures/icons/weapon/wpnRecahrge.png' --charging beam
weaponFigherBonuses['chargingbeam'] = { 1, 0, 0, 0.5 }
--Heavy
weaponIcons['photoncannon'] = 'data/textures/icons/PHOTON.png'             --photon cannon
weaponIcons['ionemitter'] = 'data/textures/icons/weapon/wpnIonEmitter.png' --ion emitter

weaponIcons['vanillarailgun'] = 'data/textures/icons/rail-gun.png'         --Rails
weaponIcons['vanillalauncher'] = 'data/textures/icons/rocket-launcher.png' --Rocket launcher
weaponIcons['vanillacannon'] = 'data/textures/icons/cannon.png'            --Rifle
weaponIcons['vanillalightning'] = 'data/textures/icons/lightning-gun.png'  --Volt

--Main caliber
weaponIcons['hyperkinetic'] = 'data/textures/icons/HYPERKINETIC.png'        --hyperkinetic artillery
weaponIcons['avalanche'] = 'data/textures/icons/weapon/wpnAvalanche.png'    --Gravity cannon "avalanche"
weaponIcons['cyclone'] = 'data/textures/icons/weapon/wpnCyclone2.png'       --Rocket launcher "cyclone"
weaponIcons['transphasic'] = 'data/textures/icons/weapon/wpnHeavyLaser.png' --transphase laser
--weaponIcons['solarlance'] = 'data/textures/icons/weapon/wpnSolarLance.png' --Solar Lance

--Support
----------------

---------------------------------------------------------------------------------------------------------------------

local _debug = false

function Debug(_text)
	if _debug then
		print('Armory lib|', _text)
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

	for _, _rows in pairs(_index) do
		if _path == weaponIcons[_rows] then return true, _rows end
	end

	return false, nil
end

function checkHeavyPath(_path)
	local _index = {
		--Starfall
		'photoncannon',
		'ionemitter',

		--Vanillas
		'vanillarailgun',
		'vanillalauncher',
		'vanillacannon',
		'vanillalightning'
	}

	for _, _rows in pairs(_index) do
		if _path == weaponIcons[_rows] then return true, _rows end
	end

	return false, nil
end

function checkMCPath(_path)
	local _index = {
		'hyperkinetic',
		'avalanche',
		'cyclone',
		'transphasic'
	}

	for _, _rows in pairs(_index) do
		if _path == weaponIcons[_rows] then return true, _rows end
	end

	return false, nil
end

--Returns the path to the icon, auxiliary
function armoryGetPath(_itemturret, _weapon, _Weapons)
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

--=======================[External calls]=======================

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

--Called to check if a cannon is a light type
function isTurretLight(_itemturret, _weapon, _Weapons)
	Debug('isTurretLight attempt')
	--Cutting off
	if not (_itemturret) and not (_weapon) and not (_Weapons) then return false end

	--Variables
	local _result = false
	local _index = nil

	--Search for a string
	local _path = armoryGetPath(_itemturret, _weapon, _Weapons)

	--Cutting off the unsuccessful
	if not (_path) then
		Debug('isTurretLight failure')
		return false, nil
	end

	--Search for information
	_result, _index = checkLightPath(_path)

	--Returning values
	if _result then
		Debug('isTurretLight - true')
	else
		Debug('isTurretLight - false')
	end
	return _result, _index
end

--Called to check if the gun is a heavy type
function isTurretHeavy(_itemturret, _weapon, _Weapons)
	Debug('isTurretHeavy attempt')
	--Cutting off
	if not (_itemturret) and not (_weapon) and not (_Weapons) then return false end

	--Search for a string
	local _path = armoryGetPath(_itemturret, _weapon, _Weapons)

	--Cutting off the unsuccessful
	if not (_path) then
		Debug('isTurretHeavy failure')
		return false
	end

	--Search string icons
	if checkHeavyPath(_path) then return true end

	--Returning the correct value
	Debug('isTurretHeavy false call')
	return false
end

--Called to check whether the gun is of the main caliber type
function isTurretMC(_itemturret, _weapon, _Weapons)
	Debug('isTurretMC attempt')
	--Cutting off
	if not (_itemturret) and not (_weapon) and not (_Weapons) then return false end

	--Search for a string
	local _path = armoryGetPath(_itemturret, _weapon, _Weapons)

	--Cutting off the unsuccessful
	if not (_path) then
		Debug('isTurretMC failure')
		return false
	end

	--Search string icons
	if checkMCPath(_path) then return true end

	--Returning the correct value
	Debug('isTurretMC false call')
	return false
end

--Called to provide the title/type color resp. type of weapon
function getTypeColor(_type)
	if not (_type) then return armoryColors['standart'] end

	Debug('getTypeColor attempt with argument: ' .. _type)
	if armoryColors[_type] then
		Debug('getTypeColor: ok')
		return armoryColors[_type]
	else
		Debug('getTypeColor: failure')
		return armoryColors['standart']
	end
end
