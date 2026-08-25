include("stringutility")
local techNames = {}


--Active
techNames['bastionsystem'] = {
	"Bastion system",         --Name
	"'Veil' system",          --module name 1
	"Energy recuperation system", --module name 2
	"Multiphase shield",      --module name 3
	"Reflection Protocol",    --module name 4
}
techNames['macrofieldprojector'] = {
	"Macrofield projector", --Name
	"Repair wave",      --module name 1
	"Renovation ray",   --module name 2
	"Shield booster",   --module name 3
	"Shield synchronizer", --module name 4
}
techNames['pulsetractorbeamgenerator'] = {
	"Pulse tractor beam generator", --Name
	"Pulse tractor beam generator", --module name 1
}
techNames['repairdrones'] = {
	"Repair system",       --Name
	"Polarizing nanobots", --module name 1
	"Repair matrix",       --module name 2
	"Emergency stabilization", --module name 3
}
techNames['xperimentalhypergenerator'] = {
	"X-perimental Hypergenerator", --Name
	"Quantum overdrive",       --module name 1
	"Space Destabilizer",      --module name 2
	"Focused Jump",            --module name 3
}

-- Passive
techNames['subspacecargo'] = {
	"Subspace cargo system", --Name
}

local techASIname = { --Used to automatically determine the number of required slots in the aSI system. Requires exact scriptname
	'bastionSystem',
	'macrofieldProjector',
	'pulseTractorBeamGenerator',
	'repairDrones',
	'XperimentalHypergenerator',
}

local techLocInfo = {}
techLocInfo['active'] = 'system active'
techLocInfo['inactive'] = 'system inactive'
techLocInfo['fireratereduced'] = 'rate of fire is reduced'
techLocInfo['shieldsrepairing'] = 'recharging shields'
techLocInfo['outofrange'] = 'out of range'
techLocInfo['outofrangeorshieldslow'] = 'out of range or shields low'
techLocInfo['readystate'] = 'ready state'

local techIcons = {}
--Active
techIcons['bastionsystem'] = {
	'data/textures/icons/SYSbastion.png',              --Main
	'data/textures/icons/SUBSYSimmortalityProtocol.png', --Module1
	'data/textures/icons/SUBSYSRecup.png',             --Module 2
	'data/textures/icons/SUBSYSMultiphase.png',        --Module3
	'data/textures/icons/SUBSYSPulsar.png'             --Module4
}
techIcons['macrofieldprojector'] = {
	'data/textures/icons/SYSmacrofieldprojector.png', --Main
	'data/textures/icons/SUBSYSrepairwave.png',      --Module1
	'data/textures/icons/SUBSYSrenovationray.png',   --Module 2
	'data/textures/icons/SUBSYSshieldbooster.png',   --Module3
	'data/textures/icons/SUBSYSshieldsynchronizer.png' --Module4
}
techIcons['pulsetractorbeamgenerator'] = {
	'data/textures/icons/SYSpReactor3.png', --Main
	'data/textures/icons/SYSpReactor3.png', --Module1
}
techIcons['repairdrones'] = {
	'data/textures/icons/SYSrepairDrones.png',             --Main
	'data/textures/icons/SUBSYSPolarisationNanobots.png',  --Module1
	'data/textures/icons/SUBSYSAdditionalRepairNetwork.png', --Module 2
	'data/textures/icons/SUBSYSEmergencyRepair.png',       --Module3
}
techIcons['xperimentalhypergenerator'] = {
	'data/textures/icons/SYShypergenerator.png', --Main
	'data/textures/icons/SUBSYSJumpCocoon.png', --Module1
	'data/textures/icons/SUBSYSDestibilizer.png', --Module 2
	'data/textures/icons/SUBSYSFocusedJump.png', --Module3
}
--Passive
techIcons['subspacecargo'] = {
	'data/textures/icons/SYSsubspacecargo.png', --Main
}

local techDesc = {}
techDesc['bastionsystem'] =
'Replaces the standard shield generator with a new one with advanced functionality but less power'
techDesc['macrofieldprojector'] =
'A massive system that provides the ability to repair allied ships right on the battlefield'
techDesc['pulsetractorbeamgenerator'] =
'A massive system that provides the ability to repair allied ships right on the battlefield'
techDesc['repairdrones'] = 'A massive system that provides the ability to repair allied ships right on the battlefield' %
_t
techDesc['xperimentalhypergenerator'] = 'A modified jump generator capable of distort space using Xotan technologies' %
_t
--Passive
techDesc['subspacecargo'] = 'Creates a stable pocket subspace dimension based on rift technologies'

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
techEffectAuraDesc['shieldresist'] = 'shield resistance'
techEffectAuraDesc['firerate'] = "weapons fire rate"
techEffectAuraDesc['impenetrableshield'] = "impenetrable shields"
techEffectAuraDesc['timebeforeshieldcharge'] = "shield cooldown after hit"
techEffectAuraDesc['torpedodefence'] = "torpedo defence"
techEffectAuraDesc['hullrepair'] = "hull repairing"
techEffectAuraDesc['hulldamage'] = "hull destruction"
techEffectAuraDesc['shieldrepair'] = "shield recharging"
techEffectAuraDesc['shieldsync'] = "shields are synchronized"
techEffectAuraDesc['tractorrange'] = "tractor beam range increased"
techEffectAuraDesc['emergencystandby'] = "emergency system standby"
techEffectAuraDesc['systemstandby'] = " standby"
techEffectAuraDesc['passiverepairoverclock'] = "auto repair speed"
techEffectAuraDesc['jumprangeincreased'] = "jump range increased"
techEffectAuraDesc['jumpdrivecharging'] = "hyperdrive charge"
--techEffectAuraDesc['passiverepairoverclock'] = "passive repair speed"

local _debug = false

function TechDebug(_text)
	if _debug then
		include("cosmicvaultdebug").info("Cosmic Starfall", 'Tech lib|', _text)
	end
end

function getTechIcon(_name)
	TechDebug('getTechIcon ' .. _name .. '-----------------------------------------------------')
	local icon = techIcons[_name][1]
	if icon then
		TechDebug('getTechIcon - ok')
		return icon
	else
		return nil
	end
end

function getSubtechIcon(_name, _pos)
	--TechDebug('getSubtechIcon '.._name..'-----------------------------------------------------')
	_pos = _pos + 1
	local icon = techIcons[_name][_pos]
	if icon then
		TechDebug('getSubtechIcon - ok')
		return icon
	else
		return nil
	end
end

function getTechName(_name)
	TechDebug('getTechName ' .. _name .. '-----------------------------------------------------')
	local name = techNames[_name][1]
	if name then
		TechDebug('getTechName - ok')
		if onClient() then return name%_t else return name end
	else
		return 'system name failure'
	end
end

function getTechAuraDesc(_name)
	TechDebug('getTechAuraDesc ' .. _name .. '-----------------------------------------------------')
	local name = techEffectAuraDesc[_name]
	if name then
		TechDebug('getTechAuraDesc - ok')
		if onClient() then return name%_t else return name end
	else
		return 'Aura desc failure'
	end
end

function getSubtechName(_name, _pos)
	--TechDebug('getSubtechName '.._name..'-----------------------------------------------------')
	_pos = _pos + 1
	local name = techNames[_name][_pos]
	if name then
		TechDebug('getSubtechName - ok')
		if onClient() then return name%_t else return name end
	else
		return nil
	end
end

function getSubtechSignature(_name, _pos)
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
	TechDebug('getTechDesc ' .. _name .. '-----------------------------------------------------')
	local name = techDesc[_name]
	if name then
		TechDebug('getTechDesc - ok')
		if onClient() then return name%_t else return name end
	else
		return 'system desc failure'
	end
end

function getTechInfo(_name)
	TechDebug('getTechInfo ' .. _name .. '-----------------------------------------------------')
	local name = techLocInfo[_name]
	if name then
		TechDebug('getTechInfo - ok')
		if onClient() then return name%_t else return name end
	else
		return 'system desc failure'
	end
end

function getTechSubsysSize(_name)
	if _name ~= nil then
		return #techNames[_name] - 1
	end
	return 0
end

function getASIinfo()
	return techASIname
end

--=============

function callTechAuraSelf(_aura)
	local owner = Owner(Entity().id)
	if not owner then return end
	local targetPlayer = owner.factionIndex
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'ApplyAura', _aura)
end

function callTechAuraTarget(_aura, _targetEntity)
	local owner = Owner(_targetEntity)
	if not owner then return end
	local targetPlayer = owner.factionIndex
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'ApplyAura', _aura)
end

function callTechAuraInterruptSelf(signature)
	local owner = Owner(Entity().id)
	if not owner then return end
	local targetPlayer = owner.factionIndex
	local source = Entity()
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'InterruptAura', signature, source.name)
end
