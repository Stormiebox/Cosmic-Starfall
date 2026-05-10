local techNames = {}

	
	--Активные
	techNames['bastionsystem'] = {
		"Bastion system"%_t, --название
		"'Veil' system"%_t, --название модуля 1
		"Energy recuperation system"%_t, --название модуля 2
		"Multiphase shield"%_t, --название модуля 3
		"Reflection Protocol"%_t, --название модуля 4
	}
	techNames['macrofieldprojector'] = {
		"Macrofield projector"%_t, --название
		"Repair wave"%_t, --название модуля 1
		"Renovation ray"%_t, --название модуля 2
		"Shield booster"%_t, --название модуля 3
		"Shield synchronizer"%_t, --название модуля 4
	}
	techNames['pulsetractorbeamgenerator'] = {
		"Pulse tractor beam generator"%_t, --название
		"Pulse tractor beam generator"%_t, --название модуля 1
	}
	techNames['repairdrones'] = {
		"Repair system"%_t, --название
		"Polarizing nanobots"%_t, --название модуля 1
		"Repair matrix"%_t, --название модуля 2
		"Emergency stabilization"%_t, --название модуля 3
	}
	techNames['xperimentalhypergenerator'] = {
		"X-perimental Hypergenerator"%_t, --название
		"Quantum overdrive"%_t, --название модуля 1
		"Space Destabilizer"%_t, --название модуля 2
		"Focused Jump"%_t, --название модуля 3
	}

	-- --Пассивные
		techNames['subspacecargo'] = {
		"Subspace cargo system"%_t, --название
	}

local techASIname = { --Используется для автоопределения количества необходимых слотов в системе aSI. Требует точный scriptname
	'bastionSystem',
	'macrofieldProjector',
	'pulseTractorBeamGenerator',
	'repairDrones',
	'XperimentalHypergenerator',
}
	
local techLocInfo = {}
	techLocInfo['active'] = 'system active'%_t
	techLocInfo['inactive'] = 'system inactive'%_t
	techLocInfo['fireratereduced'] = 'rate of fire is reduced'%_t
	techLocInfo['shieldsrepairing'] = 'recharging shields'%_t
	techLocInfo['outofrange'] = 'out of range'%_t
	techLocInfo['outofrangeorshieldslow'] = 'out of range or shields low'%_t
	techLocInfo['readystate'] = 'ready state'%_t
	
local techIcons = {}
	--Активные
	techIcons['bastionsystem'] = {
		'data/textures/icons/SYSbastion.png', --main
		'data/textures/icons/SUBSYSimmortalityProtocol.png', --module1
		'data/textures/icons/SUBSYSRecup.png', --module2
		'data/textures/icons/SUBSYSMultiphase.png', --module3
		'data/textures/icons/SUBSYSPulsar.png' --module4
	}
	techIcons['macrofieldprojector'] = {
		'data/textures/icons/SYSmacrofieldprojector.png', --main
		'data/textures/icons/SUBSYSrepairwave.png', --module1
		'data/textures/icons/SUBSYSrenovationray.png', --module2
		'data/textures/icons/SUBSYSshieldbooster.png', --module3
		'data/textures/icons/SUBSYSshieldsynchronizer.png' --module4
	}
	techIcons['pulsetractorbeamgenerator'] = {
		'data/textures/icons/SYSpReactor3.png', --main
		'data/textures/icons/SYSpReactor3.png', --module1
	}
	techIcons['repairdrones'] = {
		'data/textures/icons/SYSrepairDrones.png', --main
		'data/textures/icons/SUBSYSPolarisationNanobots.png', --module1
		'data/textures/icons/SUBSYSAdditionalRepairNetwork.png', --module2
		'data/textures/icons/SUBSYSEmergencyRepair.png', --module3
	}
	techIcons['xperimentalhypergenerator'] = {
		'data/textures/icons/SYShypergenerator.png', --main
		'data/textures/icons/SUBSYSJumpCocoon.png', --module1
		'data/textures/icons/SUBSYSDestibilizer.png', --module2
		'data/textures/icons/SUBSYSFocusedJump.png', --module3
	}
	--Пассивные
	techIcons['subspacecargo'] = {
		'data/textures/icons/SYSsubspacecargo.png', --main
	}
	
local techDesc = {}
	techDesc['bastionsystem'] = 'Replaces the standard shield generator with a new one with advanced functionality but less power'%_t
	techDesc['macrofieldprojector'] = 'A massive system that provides the ability to repair allied ships right on the battlefield'%_t
	techDesc['pulsetractorbeamgenerator'] = 'A massive system that provides the ability to repair allied ships right on the battlefield'%_t
	techDesc['repairdrones'] = 'A massive system that provides the ability to repair allied ships right on the battlefield'%_t
	techDesc['xperimentalhypergenerator'] = 'A modified jump generator capable of distort space using Xotan technologies'%_t
	--Пассивные
	techDesc['subspacecargo'] = 'Creates a stable pocket subspace dimension based on rift technologies'%_t
	
local techSignatures = {}
	techSignatures['bastionsystem'] = {
		'subsysveil',
		'subsysrecup',
		'subsysmulti',
		'subsyspulsar',
	}
	techSignatures['macrofieldprojector'] = {
		'subsysrepairwave',
		'subsysrenovationray',
		'subsyschargingbeam',
		'subsysshieldsync',
	}
	techSignatures['pulsetractorbeamgenerator'] = {
		'subsyspulsetractorbeam',
	}
	techSignatures['repairdrones'] = {
		'subsysnanobots',
		'subsysrepairmatrix',
		'subsysemergensystabilizer',
	}
	techSignatures['xperimentalhypergenerator'] = {
		'subsysquantumoverdrive',
		'subsysmatterdestibilizer',
		'subsysfocusedjump',
	}
	
local techEffectAuraDesc = {}
	techEffectAuraDesc['shieldresist'] = 'shield resistance'%_t
	techEffectAuraDesc['firerate'] = "weapons fire rate"%_t
	techEffectAuraDesc['impenetrableshield'] = "impenetrable shields"%_t
	techEffectAuraDesc['timebeforeshieldcharge'] = "shield cooldown after hit"%_t
	techEffectAuraDesc['torpedodefence'] = "torpedo defence"%_t
	techEffectAuraDesc['hullrepair'] = "hull repairing"%_t
	techEffectAuraDesc['hulldamage'] = "hull destruction"%_t
	techEffectAuraDesc['shieldrepair'] = "shield recharging"%_t
	techEffectAuraDesc['shieldsync'] = "shields are synchronized"%_t
	techEffectAuraDesc['tractorrange'] = "tractor beam range increased"%_t
	techEffectAuraDesc['emergencystandby'] = "emergency system standby"%_t
	techEffectAuraDesc['systemstandby'] = " standby"%_t
	techEffectAuraDesc['passiverepairoverclock'] = "auto repair speed"%_t
	techEffectAuraDesc['jumprangeincreased'] = "jump range increased"%_t
	techEffectAuraDesc['jumpdrivecharging'] = "hyperdrive charge"%_t
	--techEffectAuraDesc['passiverepairoverclock'] = "passive repair speed"%_t

local _debug = false

function TechDebug(_text)
	if _debug then
		print('Tech lib|',_text)
	end
end
	
function getTechIcon(_name)
	TechDebug('getTechIcon '.._name..'-----------------------------------------------------')
	local icon = techIcons[_name][1]
	if icon then
		TechDebug('getTechIcon - ok')
		return icon
	else
		return nil
	end
end

function getSubtechIcon(_name,_pos)
	--TechDebug('getSubtechIcon '.._name..'-----------------------------------------------------')
	_pos = _pos+1
	local icon = techIcons[_name][_pos]
	if icon then
		TechDebug('getSubtechIcon - ok')
		return icon
	else
		return nil
	end
end

function getTechName(_name)
	TechDebug('getTechName '.._name..'-----------------------------------------------------')
	local name = techNames[_name][1]
	if name then
		TechDebug('getTechName - ok')
		return name
	else
		return 'system name failure'
	end
end

function getTechAuraDesc(_name)
	TechDebug('getTechAuraDesc '.._name..'-----------------------------------------------------')
	local name = techEffectAuraDesc[_name]
	if name then
		TechDebug('getTechAuraDesc - ok')
		return name
	else
		return 'Aura desc failure'
	end
end

function getSubtechName(_name,_pos)
	--TechDebug('getSubtechName '.._name..'-----------------------------------------------------')
	_pos = _pos+1
	local name = techNames[_name][_pos]
	if name then
		TechDebug('getSubtechName - ok')
		return name
	else
		return nil
	end
end

function getSubtechSignature(_name,_pos)
	--TechDebug('getSubtechSignature '.._name..'-----------------------------------------------------')
	local name = techSignatures[_name][_pos]
	if name then
		TechDebug('getSubtechSignature - ok')
		return name
	else
		return nil
	end
end

function getTechDesc(_name)
	TechDebug('getTechDesc '.._name..'-----------------------------------------------------')
	local name = techDesc[_name]
	if name then
		TechDebug('getTechDesc - ok')
		return name
	else
		return 'system desc failure'
	end
end

function getTechInfo(_name)
	TechDebug('getTechInfo '.._name..'-----------------------------------------------------')
	local name = techLocInfo[_name]
	if name then
		TechDebug('getTechInfo - ok')
		return name
	else
		return 'system desc failure'
	end
end

function getTechSubsysSize(_name)
	if _name~= nil then
		return #techNames[_name] - 1
	end
	return 0
end

function getASIinfo()
	return techASIname
end

--=============

function callTechAuraSelf(_aura)
	local targetPlayer = Owner(Entity().id).factionIndex
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'ApplyAura',_aura)
end

function callTechAuraTarget(_aura,_targetEntity)
	local targetPlayer = Owner(_targetEntity).factionIndex
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'ApplyAura',_aura)
end

function callTechAuraInterruptSelf(signature)
	local targetPlayer = Owner(Entity().id).factionIndex
	local source = Entity()
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'InterruptAura',signature,source.name)
end