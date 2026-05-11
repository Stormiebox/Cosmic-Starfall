local techNames = {}


--Active
techNames['bastionsystem'] = {
	"Bastion system" % _t,         --Name
	"'Veil' system" % _t,          --module name 1
	"Energy recuperation system" % _t, --module name 2
	"Multiphase shield" % _t,      --module name 3
	"Reflection Protocol" % _t,    --module name 4
}
techNames['macrofieldprojector'] = {
	"Macrofield projector" % _t, --Name
	"Repair wave" % _t,      --module name 1
	"Renovation ray" % _t,   --module name 2
	"Shield booster" % _t,   --module name 3
	"Shield synchronizer" % _t, --module name 4
}
techNames['pulsetractorbeamgenerator'] = {
	"Pulse tractor beam generator" % _t, --Name
	"Pulse tractor beam generator" % _t, --module name 1
}
techNames['repairdrones'] = {
	"Repair system" % _t,       --Name
	"Polarizing nanobots" % _t, --module name 1
	"Repair matrix" % _t,       --module name 2
	"Emergency stabilization" % _t, --module name 3
}
techNames['xperimentalhypergenerator'] = {
	"X-perimental Hypergenerator" % _t, --Name
	"Quantum overdrive" % _t,       --module name 1
	"Space Destabilizer" % _t,      --module name 2
	"Focused Jump" % _t,            --module name 3
}

-- Passive
techNames['subspacecargo'] = {
	"Subspace cargo system" % _t, --Name
}

local techASIname = { --Used to automatically determine the number of required slots in the aSI system. Requires exact scriptname
	'bastionSystem',
	'macrofieldProjector',
	'pulseTractorBeamGenerator',
	'repairDrones',
	'XperimentalHypergenerator',
}

local techLocInfo = {}
techLocInfo['active'] = 'system active' % _t
techLocInfo['inactive'] = 'system inactive' % _t
techLocInfo['fireratereduced'] = 'rate of fire is reduced' % _t
techLocInfo['shieldsrepairing'] = 'recharging shields' % _t
techLocInfo['outofrange'] = 'out of range' % _t
techLocInfo['outofrangeorshieldslow'] = 'out of range or shields low' % _t
techLocInfo['readystate'] = 'ready state' % _t

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
'Replaces the standard shield generator with a new one with advanced functionality but less power' % _t
techDesc['macrofieldprojector'] =
'A massive system that provides the ability to repair allied ships right on the battlefield' % _t
techDesc['pulsetractorbeamgenerator'] =
'A massive system that provides the ability to repair allied ships right on the battlefield' % _t
techDesc['repairdrones'] = 'A massive system that provides the ability to repair allied ships right on the battlefield' %
_t
techDesc['xperimentalhypergenerator'] = 'A modified jump generator capable of distort space using Xotan technologies' %
_t
--Passive
techDesc['subspacecargo'] = 'Creates a stable pocket subspace dimension based on rift technologies' % _t

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
techEffectAuraDesc['shieldresist'] = 'shield resistance' % _t
techEffectAuraDesc['firerate'] = "weapons fire rate" % _t
techEffectAuraDesc['impenetrableshield'] = "impenetrable shields" % _t
techEffectAuraDesc['timebeforeshieldcharge'] = "shield cooldown after hit" % _t
techEffectAuraDesc['torpedodefence'] = "torpedo defence" % _t
techEffectAuraDesc['hullrepair'] = "hull repairing" % _t
techEffectAuraDesc['hulldamage'] = "hull destruction" % _t
techEffectAuraDesc['shieldrepair'] = "shield recharging" % _t
techEffectAuraDesc['shieldsync'] = "shields are synchronized" % _t
techEffectAuraDesc['tractorrange'] = "tractor beam range increased" % _t
techEffectAuraDesc['emergencystandby'] = "emergency system standby" % _t
techEffectAuraDesc['systemstandby'] = " standby" % _t
techEffectAuraDesc['passiverepairoverclock'] = "auto repair speed" % _t
techEffectAuraDesc['jumprangeincreased'] = "jump range increased" % _t
techEffectAuraDesc['jumpdrivecharging'] = "hyperdrive charge" % _t
--techEffectAuraDesc['passiverepairoverclock'] = "passive repair speed"%_t

local _debug = false

function TechDebug(_text)
	if _debug then
		print('Tech lib|', _text)
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
		return name
	else
		return 'system name failure'
	end
end

function getTechAuraDesc(_name)
	TechDebug('getTechAuraDesc ' .. _name .. '-----------------------------------------------------')
	local name = techEffectAuraDesc[_name]
	if name then
		TechDebug('getTechAuraDesc - ok')
		return name
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
		return name
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
		return name
	else
		return 'system desc failure'
	end
end

function getTechInfo(_name)
	TechDebug('getTechInfo ' .. _name .. '-----------------------------------------------------')
	local name = techLocInfo[_name]
	if name then
		TechDebug('getTechInfo - ok')
		return name
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
	local targetPlayer = Owner(Entity().id).factionIndex
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'ApplyAura', _aura)
end

function callTechAuraTarget(_aura, _targetEntity)
	local targetPlayer = Owner(_targetEntity).factionIndex
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'ApplyAura', _aura)
end

function callTechAuraInterruptSelf(signature)
	local targetPlayer = Owner(Entity().id).factionIndex
	local source = Entity()
	invokeFactionFunction(targetPlayer, false, 'auraCore', 'InterruptAura', signature, source.name)
end
