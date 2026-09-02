include("stringutility")
local _debug = false

function StationDebug(_text)
	if _debug then
		include("cosmicvaultdebug").info("Cosmic Starfall", 'Station lib|', _text)
	end
end

local stationNames = {}
local stationIcons = {}
local stationDesc = {}

-- getStationName()/getStationDesc() are called from entity/stationfounder.lua's
-- own top-level factory table (both server and client evaluate that file), so
-- these values are needed on both sides - unlike a pure-UI table, they can't
-- just be skipped with `if onClient() then`. %_t/%_T at unguarded global scope
-- crashes a dedicated server on startup (no UI localization metatable
-- server-side), but is safe inside a function body, so build the table there
-- and call it once immediately - this keeps identical behavior/timing (values
-- ready before anything can call the getters) while moving the %_t evaluation
-- out of the dangerous global scope.
local function _buildStationText()
	stationNames['mx'] = "Megacomplex"%_t --Name

	stationIcons['mx'] = 'data/textures/icons/MCXmegaComplex.png'

	stationDesc['mx'] =
	"A megacomplex is a station that allows you to automatically create a logistics of resources between all stations docked to it. In addition, it contains various display and control functionality" %
	_t
end
_buildStationText()

local stationInnerIcons = {}
stationInnerIcons['mxoutput'] = 'data/textures/icons/MCXoutput.png'
stationInnerIcons['mxexpand'] = 'data/textures/icons/MCXexpand.png'
stationInnerIcons['mxinput'] = 'data/textures/icons/MCXinput.png'
stationInnerIcons['mxstorage'] = 'data/textures/icons/MCXmegaComplex.png'
stationInnerIcons['mxtodelete'] = 'data/textures/icons/MCXtoDelete.png'
stationInnerIcons['mxexport'] = 'data/textures/icons/captain-merchant.png'
stationInnerIcons['mxsettings'] = 'data/textures/icons/staRepair.png'



function getStationName(_name)
	StationDebug('getStationName ' .. _name .. '-----------------------------------------------------')
	local name = stationNames[_name]
	if name then
		StationDebug('getStationName - ok')
		return name
	else
		return 'station name failure'
	end
end

function getStationDesc(_name)
	StationDebug('getStationDesc ' .. _name .. '-----------------------------------------------------')
	local name = stationDesc[_name]
	if name then
		StationDebug('getStationDesc - ok')
		return name
	else
		return 'station name failure'
	end
end

function getStationIcon(_name)
	StationDebug('getStationIcon ' .. _name .. '-----------------------------------------------------')
	local name = stationIcons[_name]
	if name then
		StationDebug('getStationIcon - ok')
		return name
	else
		return 'station icon failure'
	end
end

function getInnerStationIcon(_name)
	StationDebug('getInnerStationIcon ' .. _name .. '-----------------------------------------------------')
	local name = stationInnerIcons[_name]
	if name then
		StationDebug('getInnerStationIcon - ok')
		return name
	else
		return 'station inner icon failure'
	end
end
