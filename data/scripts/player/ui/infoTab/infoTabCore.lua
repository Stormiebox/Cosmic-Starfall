package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/player/ui/infoTab/?.lua"
include('utility')
include('Neltharaku')

include('infoGeneral')
include('infoWeapons')
include('infoSystems')
include('infoStations')
include('infoInterfaces')
include('infoAlerts')
include('infoChangelog')

-- namespace iT
iT = {}

local rUnit = 12

local ITtab = nil
local ITtabbedWindow = nil

local UIlabelBox = nil
local UIinfoBox = {}

local labelBoxTable = {}

local infoGeneralTabs = nil
local infoWeaponsTabs = nil
local infoSysTabs = nil
local infoStTabs = nil
local infoInterfaceTabs = nil
local infoAlertsTabs = nil
local infoChangelogTabs = nil

--Global variable indicating the presence of new functions
local globalUpdateKey = 2.0

if onClient() then

function iT.initialize()
	--Home tab
	ITtab = PlayerWindow():createTab('Cosmic Starfall Info'%_t, 'data/textures/icons/uiStarfall.png', 'Cosmic Starfall Information'%_t)
	
	--Inner container
	local _k = 0.01
	local modSizeRect = Rect(ITtab.size)
	ITtabbedWindow = ITtab:createTabbedWindow(modSizeRect)
	
	--Basic Variables
	rUnit = ITtabbedWindow.height/35
	
	--Internal tabs
	local _general = ITtabbedWindow:createTab('General'%_t, 'data/textures/icons/vortex.png', 'General Mod Info'%_t)
	local _weapons = ITtabbedWindow:createTab('Weapons'%_t, 'data/textures/icons/missile-pod.png', 'Mod Weapons'%_t)
	local _systems = ITtabbedWindow:createTab('Systems'%_t, 'data/textures/icons/circuitry.png', 'Mod Upgrades'%_t)
	local _stations = ITtabbedWindow:createTab('Stations'%_t, 'data/textures/icons/base.png', 'Mod Stations'%_t)
	local _interfaces = ITtabbedWindow:createTab('Interfaces'%_t, 'data/textures/icons/tv.png', 'Mod Interfaces'%_t)
	local _alertsystem = ITtabbedWindow:createTab('Alerts'%_t, 'data/textures/icons/rss.png', 'Alert Types'%_t)
	local _changelog = ITtabbedWindow:createTab('Changelog'%_t, 'data/textures/icons/parchment.png', 'Update Log'%_t)
	
	--Basic functions called at initialize
	iT.splitIni('general',_general)
	iT.splitIni('weapons',_weapons)
	iT.splitIni('systems',_systems)
	iT.splitIni('stations',_stations)
	iT.splitIni('interfaces',_interfaces)
	iT.splitIni('alertsystem',_alertsystem)
	iT.splitIni('changelog',_changelog)
	
	ITtab.onSelectedFunction = 'onSelected'

end

function iT.onSelected()
	--Hiding
	--Hiding old
	--Disabling old
	--Hiding container
	--Disabling field
	--If you run it through a table pass, the tabs will be randomly mixed each time :)
	
end

--Initialization of general elements
function iT.splitIni(key,tab)

	local _splitV = UIVerticalSplitter(Rect(tab.size), 10, 0, 0.3)
	
	--Initialization of labelBox container
	local _labelBox = tab:createContainer(_splitV.left)
	iT.labelPickIni(key,_labelBox)
	
	--Initialization of infoBox container
	UIinfoBox[key] = tab:createContainer(_splitV.right)
	iT.infoPickIni(key)

end

--Generation of fill labelboxes for the left UI frame (menu)
function iT.labelPickIni(key,labelbox)

	if key=='general' then 
		labelBoxTable[key] = infoGeneral.SetEntitiesV2(labelbox,rUnit,globalUpdateKey)
		for _name,_rows in pairs(labelBoxTable[key]) do
			_rows.onSelectFunction = 'onClickGeneral'
		end
		return 
	end

	if key=='weapons' then 
		labelBoxTable[key] = infoWeapons.SetEntitiesV2(labelbox,rUnit,globalUpdateKey)
		for _name,_rows in pairs(labelBoxTable[key]) do
			_rows.onSelectFunction = 'onClickWeapons'
		end
		return 
	end
	
	if key=='systems' then 
		labelBoxTable[key] = infoSystems.SetEntitiesV2(labelbox,rUnit,globalUpdateKey)
		for _name,_rows in pairs(labelBoxTable[key]) do
			_rows.onSelectFunction = 'onClickSystems'
		end
		return 
	end
	
	if key=='stations' then 
		labelBoxTable[key] = infoStations.SetEntitiesV2(labelbox,rUnit,globalUpdateKey)
		for _name,_rows in pairs(labelBoxTable[key]) do
			_rows.onSelectFunction = 'onClickStations'
		end
		return 
	end
	
	if key=='interfaces' then 
		labelBoxTable[key] = infoInterfaces.SetEntitiesV2(labelbox,rUnit,globalUpdateKey)
		for _name,_rows in pairs(labelBoxTable[key]) do
			_rows.onSelectFunction = 'onClickInterface'
		end
		return 
	end
	if key=='alertsystem' then 
		labelBoxTable[key] = infoAlerts.SetEntitiesV2(labelbox,rUnit,globalUpdateKey)
		for _name,_rows in pairs(labelBoxTable[key]) do
			_rows.onSelectFunction = 'onClickAlerts'
		end
		return 
	end
	if key=='changelog' then 
		labelBoxTable[key] = infoChangelog.SetEntitiesV2(labelbox,rUnit,globalUpdateKey)
		for _name,_rows in pairs(labelBoxTable[key]) do
			_rows.onSelectFunction = 'onClickChangelog'
		end
		return 
	end
end

--Generation of fill containers for the right UI frame (data)
function iT.infoPickIni(key)

	if key=='general' then 
		--Debug('infoPickIni attempt with key = '..key)
		infoGeneralTabs = infoGeneral.GetInfoContainers(UIinfoBox[key],rUnit)
		return 
	end

	if key=='weapons' then 
		--Debug('infoPickIni attempt with key = '..key)
		infoWeaponsTabs = infoWeapons.GetInfoContainers(UIinfoBox[key],rUnit)
		return 
	end
	
	if key=='systems' then 
		--Debug('infoPickIni attempt with key = '..key)
		infoSysTabs = infoSystems.GetInfoContainers(UIinfoBox[key],rUnit)
		return 
	end
	
	if key=='stations' then 
		--Debug('infoPickIni attempt with key = '..key)
		infoStTabs = infoStations.GetInfoContainers(UIinfoBox[key],rUnit)
		return 
	end
	if key=='interfaces' then 
		--Debug('infoPickIni attempt with key = '..key)
		infoInterfaceTabs = infoInterfaces.GetInfoContainers(UIinfoBox[key],rUnit)
		return 
	end
	if key=='alertsystem' then 
		--Debug('infoPickIni attempt with key = '..key)
		infoAlertsTabs = infoAlerts.GetInfoContainers(UIinfoBox[key],rUnit)
		return 
	end
	if key=='changelog' then 
		--Debug('infoPickIni attempt with key = '..key)
		infoChangelogTabs = infoChangelog.GetInfoContainers(UIinfoBox[key],rUnit)
		return 
	end
end

--When clicking on a field, disables/enables data/info containers in the right UI table (general)
function iT.onClickGeneral(index)
	--Debug('onClickWeapons attempt with index '..tostring(index))
	
	for _name,_rows in pairs(labelBoxTable['general']) do
		if _rows.selectedValue then
			local value = _rows.selectedValue
			_rows:deselect()
			
			--Loop over tabs to toggle visibility
			for _name,_rows in pairs(infoGeneralTabs) do
				if _name==value then
					_rows:show()
				else
					_rows:hide()
				end
			end
			
		end
	end
end

--When clicking on a field, disables/enables data/info containers in the right UI table (weapons)
function iT.onClickWeapons(index)
	--Debug('onClickWeapons attempt with index '..tostring(index))
	
	for _name,_rows in pairs(labelBoxTable['weapons']) do
		if _rows.selectedValue then
			local value = _rows.selectedValue
			_rows:deselect()
			
			--Loop over tabs to toggle visibility
			for _name,_rows in pairs(infoWeaponsTabs) do
				if _name==value then
					_rows:show()
				else
					_rows:hide()
				end
			end
			
		end
	end
end

--When clicking on a field, disables/enables data/info containers in the right UI table (systems)
function iT.onClickSystems(index)
	--Debug('onClickWeapons attempt with index '..tostring(index))
	
	for _name,_rows in pairs(labelBoxTable['systems']) do
		if _rows.selectedValue then
			local value = _rows.selectedValue
			_rows:deselect()
			
			--Loop over tabs to toggle visibility
			for _name,_rows in pairs(infoSysTabs) do
				if _name==value then
					_rows:show()
				else
					_rows:hide()
				end
			end
			
		end
	end
end

--When clicking on a field, disables/enables data/info containers in the right UI table (stations)
function iT.onClickStations(index)
	--Debug('onClickWeapons attempt with index '..tostring(index))
	
	for _name,_rows in pairs(labelBoxTable['stations']) do
		if _rows.selectedValue then
			local value = _rows.selectedValue
			_rows:deselect()
			
			--Loop over tabs to toggle visibility
			for _name,_rows in pairs(infoStTabs) do
				if _name==value then
					_rows:show()
				else
					_rows:hide()
				end
			end
			
		end
	end
end

--When clicking on a field, disables/enables data/info containers in the right UI table (interfaces)
function iT.onClickInterface(index)
	--Debug('onClickWeapons attempt with index '..tostring(index))
	
	for _name,_rows in pairs(labelBoxTable['interfaces']) do
		if _rows.selectedValue then
			local value = _rows.selectedValue
			_rows:deselect()
			
			--Loop over tabs to toggle visibility
			for _name,_rows in pairs(infoInterfaceTabs) do
				if _name==value then
					_rows:show()
				else
					_rows:hide()
				end
			end
			
		end
	end
end

--When clicking on a field, disables/enables data/info containers in the right UI table (alerts)
function iT.onClickAlerts(index)
	--Debug('onClickWeapons attempt with index '..tostring(index))
	
	for _name,_rows in pairs(labelBoxTable['alertsystem']) do
		if _rows.selectedValue then
			local value = _rows.selectedValue
			_rows:deselect()
			
			--Loop over tabs to toggle visibility
			for _name,_rows in pairs(infoAlertsTabs) do
				if _name==value then
					_rows:show()
				else
					_rows:hide()
				end
			end
			
		end
	end
end

--When clicking on a field, disables/enables data/info containers in the right UI table (changelog)
function iT.onClickChangelog(index)
	--Debug('onClickWeapons attempt with index '..tostring(index))
	
	for _name,_rows in pairs(labelBoxTable['changelog']) do
		if _rows.selectedValue then
			local value = _rows.selectedValue
			_rows:deselect()
			
			--Loop over tabs to toggle visibility
			for _name,_rows in pairs(infoChangelogTabs) do
				if _name==value then
					_rows:show()
				else
					_rows:hide()
				end
			end
			
		end
	end
end

end -- onClient


