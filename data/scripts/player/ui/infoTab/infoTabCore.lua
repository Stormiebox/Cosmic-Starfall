package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/player/ui/infoTab/?.lua"
include('Neltharaku')

include('infoGeneral')
include('infoWeapons')
include('infoSystems')
include('infoStations')
include('infoInterfaces')
include('infoAlerts')
include('infoChangelog')

--namespace iT
iT = {}

local globalUpdateKey = 0.3

--Units
local rUnit = nil
local rPadding = nil

--Ui
local ITtab = nil
local ITtabbedWindow = nil
local ITtabs = {}
local UIinfoBox = {}
local labelBoxTable = {}
local iconStarfall = 'data/textures/icons/uiStarfall.png'

local infoGeneralTabs = {}
local infoWeaponsTabs = {}
local infoSysTabs = {}
local infoStTabs = {}
local infoInterfaceTabs = {}
local infoAlertsTabs = {}
local infoChangelogTabs = {}

local mainTabsInfo = {}
--iconPath
--desc
--updateKey
--isActive
mainTabsInfo['general'] = { 'data/textures/icons/notAleader.png', 'List of changes' % _t, 1, true }
mainTabsInfo['weapons'] = { 'data/textures/icons/turret.png', 'List of weapons' % _t, 1, true }
mainTabsInfo['systems'] = { 'data/textures/icons/circuitry.png', 'List of systems' % _t, 1, true }
mainTabsInfo['stations'] = { 'data/textures/icons/station.png', 'List of stations' % _t, 1, true }
mainTabsInfo['interceptors'] = { 'data/textures/icons/fighter.png', 'Fighters/drones' % _t, 1, false }
mainTabsInfo['interfaces'] = { 'data/textures/icons/checkbox-tree.png', 'Interfaces' % _t, 1, true }
mainTabsInfo['alertsystem'] = { 'data/textures/icons/hazard-sign.png', 'Alert system' % _t, 1, true }
mainTabsInfo['changelog'] = { 'data/textures/icons/clipboard-arrow-down.png', 'Changelog' % _t, 1, true }

local LVsplitter = nil

local _debug = false
function iT.DebugMsg(_text)
	if _debug then
		print('infoTabCore|', _text)
	end
end

local Debug = iT.DebugMsg
local TSR = Neltharaku.TableSelfReport

--Onclient
if onClient() then
	function iT.initialize()
		--Home tab
		ITtab = PlayerWindow():createTab('Starfall info', iconStarfall, 'Starfall info')

		--Inner container
		local _k = 0.03
		local modSizeRect = Rect(ITtab.width * _k, ITtab.height * _k, ITtab.width * (1 - _k), ITtab.height * (1 - _k))
		ITtabbedWindow = ITtab:createTabbedWindow(modSizeRect)

		--Basic Variables
		rUnit = round(math.min(ITtab.height, ITtab.width) * 0.07, 0)
		Debug('rUnit is ' .. tostring(rUnit))

		--Internal tabs

		-- for _key,_rows in pairs(mainTabsInfo) do
		-- if _rows[4] then iT.createInnerTab(_key) end
		-- end

		--If you run it through a table pass, the tabs will be randomly mixed each time :)
		iT.createInnerTab('general')
		iT.createInnerTab('weapons')
		iT.createInnerTab('systems')
		iT.createInnerTab('stations')
		iT.createInnerTab('interceptors')
		iT.createInnerTab('interfaces')
		iT.createInnerTab('alertsystem')
		iT.createInnerTab('changelog')
	end

	--Creates a tab serving initialize
	function iT.createInnerTab(key)
		local _table = mainTabsInfo[key]
		local _icon = _table[1]
		local _desc = _table[2]
		local _isActive = _table[4]
		if _isActive then
			ITtabs[key] = ITtabbedWindow:createTab(key, _icon, _desc)
		else
			return
		end
		iT.createTabSpace(key)
	end

	--Generates basic tab content
	function iT.createTabSpace(key)
		local tab = ITtabs[key]
		local _splitModY = tab.width * 0.3
		local _splitLrect = Rect(tab.width * 0, tab.height * 0.01, 0, tab.width * 0.3, tab.height * 0.99)
		local _splitPadding = 2
		local _splitMargin = 0
		local _splitRatio = 0.5

		local _splitV = UIVerticalSplitter(Rect(tab.size), 10, 0, 0.3)

		--Left side
		local _labelBox = tab:createContainer(_splitV.left)
		iT.labelPickIni(key, _labelBox)

		--Right side
		UIinfoBox[key] = tab:createContainer(_splitV.right)
		iT.infoPickIni(key)
	end

	--Initializes an entity segment
	function iT.labelPickIni(key, labelbox)
		if key == 'general' then
			labelBoxTable[key] = infoGeneral.SetEntitiesV2(labelbox, rUnit, globalUpdateKey)
			for _name, _rows in pairs(labelBoxTable[key]) do
				_rows.onSelectFunction = 'onClickGeneral'
			end
			return
		end

		if key == 'weapons' then
			labelBoxTable[key] = infoWeapons.SetEntitiesV2(labelbox, rUnit, globalUpdateKey)
			for _name, _rows in pairs(labelBoxTable[key]) do
				_rows.onSelectFunction = 'onClickWeapons'
			end
			return
		end

		if key == 'systems' then
			labelBoxTable[key] = infoSystems.SetEntitiesV2(labelbox, rUnit, globalUpdateKey)
			for _name, _rows in pairs(labelBoxTable[key]) do
				_rows.onSelectFunction = 'onClickSystems'
			end
			return
		end

		if key == 'stations' then
			labelBoxTable[key] = infoStations.SetEntitiesV2(labelbox, rUnit, globalUpdateKey)
			for _name, _rows in pairs(labelBoxTable[key]) do
				_rows.onSelectFunction = 'onClickStations'
			end
			return
		end

		if key == 'interfaces' then
			labelBoxTable[key] = infoInterfaces.SetEntitiesV2(labelbox, rUnit, globalUpdateKey)
			for _name, _rows in pairs(labelBoxTable[key]) do
				_rows.onSelectFunction = 'onClickInterface'
			end
			return
		end
		if key == 'alertsystem' then
			labelBoxTable[key] = infoAlerts.SetEntitiesV2(labelbox, rUnit, globalUpdateKey)
			for _name, _rows in pairs(labelBoxTable[key]) do
				_rows.onSelectFunction = 'onClickAlerts'
			end
			return
		end
		if key == 'changelog' then
			labelBoxTable[key] = infoChangelog.SetEntitiesV2(labelbox, rUnit, globalUpdateKey)
			for _name, _rows in pairs(labelBoxTable[key]) do
				_rows.onSelectFunction = 'onClickChangelog'
			end
			return
		end
	end

	--Initializes the information segment
	function iT.infoPickIni(key)
		if key == 'general' then
			Debug('infoPickIni attempt with key = ' .. key)
			infoGeneralTabs = infoGeneral.GetInfoContainers(UIinfoBox[key], rUnit)
			return
		end

		if key == 'weapons' then
			Debug('infoPickIni attempt with key = ' .. key)
			infoWeaponsTabs = infoWeapons.GetInfoContainers(UIinfoBox[key], rUnit)
			return
		end

		if key == 'systems' then
			Debug('infoPickIni attempt with key = ' .. key)
			infoSysTabs = infoSystems.GetInfoContainers(UIinfoBox[key], rUnit)
			return
		end

		if key == 'stations' then
			Debug('infoPickIni attempt with key = ' .. key)
			infoStTabs = infoStations.GetInfoContainers(UIinfoBox[key], rUnit)
			return
		end
		if key == 'interfaces' then
			Debug('infoPickIni attempt with key = ' .. key)
			infoInterfaceTabs = infoInterfaces.GetInfoContainers(UIinfoBox[key], rUnit)
			return
		end
		if key == 'alertsystem' then
			Debug('infoPickIni attempt with key = ' .. key)
			infoAlertsTabs = infoAlerts.GetInfoContainers(UIinfoBox[key], rUnit)
			return
		end
		if key == 'changelog' then
			Debug('infoPickIni attempt with key = ' .. key)
			infoChangelogTabs = infoChangelog.GetInfoContainers(UIinfoBox[key], rUnit)
			return
		end
	end

	--Displays generated information when clicking on an entity (general)
	function iT.onClickGeneral(index)
		--Debug('onClickWeapons attempt with index '..tostring(index))

		for _name, _rows in pairs(labelBoxTable['general']) do
			if _rows.selectedValue then
				local value = _rows.selectedValue
				_rows:deselect()

				--Checking tabs for matches by name
				for _name, _rows in pairs(infoGeneralTabs) do
					if _name == value then
						_rows:show()
					else
						_rows:hide()
					end
				end
			end
		end
	end

	--Displays generated information when clicking on an entity (weapon)
	function iT.onClickWeapons(index)
		--Debug('onClickWeapons attempt with index '..tostring(index))

		for _name, _rows in pairs(labelBoxTable['weapons']) do
			if _rows.selectedValue then
				local value = _rows.selectedValue
				_rows:deselect()

				--Checking tabs for matches by name
				for _name, _rows in pairs(infoWeaponsTabs) do
					if _name == value then
						_rows:show()
					else
						_rows:hide()
					end
				end
			end
		end
	end

	--Displays generated information when clicking on an entity (system)
	function iT.onClickSystems(index)
		--Debug('onClickWeapons attempt with index '..tostring(index))

		for _name, _rows in pairs(labelBoxTable['systems']) do
			if _rows.selectedValue then
				local value = _rows.selectedValue
				_rows:deselect()

				--Checking tabs for matches by name
				for _name, _rows in pairs(infoSysTabs) do
					if _name == value then
						_rows:show()
					else
						_rows:hide()
					end
				end
			end
		end
	end

	--Displays generated information when clicking on an entity (stations)
	function iT.onClickStations(index)
		--Debug('onClickWeapons attempt with index '..tostring(index))

		for _name, _rows in pairs(labelBoxTable['stations']) do
			if _rows.selectedValue then
				local value = _rows.selectedValue
				_rows:deselect()

				--Checking tabs for matches by name
				for _name, _rows in pairs(infoStTabs) do
					if _name == value then
						_rows:show()
					else
						_rows:hide()
					end
				end
			end
		end
	end

	--Displays generated information when clicking on an entity (interfaces)
	function iT.onClickInterface(index)
		--Debug('onClickWeapons attempt with index '..tostring(index))

		for _name, _rows in pairs(labelBoxTable['interfaces']) do
			if _rows.selectedValue then
				local value = _rows.selectedValue
				_rows:deselect()

				--Checking tabs for matches by name
				for _name, _rows in pairs(infoInterfaceTabs) do
					if _name == value then
						_rows:show()
					else
						_rows:hide()
					end
				end
			end
		end
	end

	--Displays generated information when clicking on an entity (alerts)
	function iT.onClickAlerts(index)
		--Debug('onClickWeapons attempt with index '..tostring(index))

		for _name, _rows in pairs(labelBoxTable['alertsystem']) do
			if _rows.selectedValue then
				local value = _rows.selectedValue
				_rows:deselect()

				--Checking tabs for matches by name
				for _name, _rows in pairs(infoAlertsTabs) do
					if _name == value then
						_rows:show()
					else
						_rows:hide()
					end
				end
			end
		end
	end

	--Displays generated information when clicking on an entity (changelog)
	function iT.onClickChangelog(index)
		--Debug('onClickWeapons attempt with index '..tostring(index))

		for _name, _rows in pairs(labelBoxTable['changelog']) do
			if _rows.selectedValue then
				local value = _rows.selectedValue
				_rows:deselect()

				--Checking tabs for matches by name
				for _name, _rows in pairs(infoChangelogTabs) do
					if _name == value then
						_rows:show()
					else
						_rows:hide()
					end
				end
			end
		end
	end

	--onclient over
end
