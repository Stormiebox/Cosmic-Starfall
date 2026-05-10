local _debug = false
add("data/scripts/systems/subspaceCargo.lua", 1)
add("data/scripts/systems/repairDrones.lua", 1)
add("data/scripts/systems/pulseTractorBeamGenerator.lua", 1)
add("data/scripts/systems/XperimentalHypergenerator.lua", 1)
add("data/scripts/systems/bastionSystem.lua", 1)
add("data/scripts/systems/macrofieldProjector.lua", 1)
if _debug then
	print('OVERPOWERED CORE ONLINE')
	add("data/scripts/systems/overpoweredCore.lua", 1)
end