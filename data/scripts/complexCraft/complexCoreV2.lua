package.path = package.path .. ";data/scripts/complexCraft/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include("utility")
include('callable')
include('goods')
include('Stations')
local TradingUtility = include("tradingutility")

--namespace MX
MX = {}

local _debug = false
local _debugUpdate = 2     --Update cycle interval if debug is enabled
local _secureSwitch = true --Despite the weird name, it just disables (false) the script's ability to load tables from the server's memory :)

local restoredValue = nil

local locLines = {}
locLines['window_label'] = "Megacomplex interface" % _t
locLines['tabprod_label'] = "Configuring import" % _t
locLines['tabcons_label'] = "Configuring export" % _t
locLines['tabstorage_label'] = "Configuring storage and utilization" % _t
locLines['tabexport_label'] = "Configuring external export" % _t
locLines['tabsettings_label'] = "Megacomplex Settings" % _t

locLines['settings_button_analysis'] = "Starting the analysis procedure (updating the list of stations)" % _t
locLines['settings_button_forcerefresh'] = "Forced update" % _t
locLines['settings_button_reset'] = "Resetting megacomplex data and settings" % _t

locLines['production_tooltip_namestation'] = "Name of the associated station" % _t
locLines['production_tooltip_streams'] = "Active production streams / Maximum number of streams of the current station" %
_t
locLines['production_tooltip_expand'] = "Switch to Detailed mode" % _t
locLines['production_tooltip_switch'] = "Shutdown/activation of all production streams" % _t
locLines['production_tooltip_switchbut_off'] = "All production streams are turned off" % _t
locLines['production_tooltip_switchbut_partial'] = "Production streams are partially functioning" % _t
locLines['production_tooltip_switchbut_on'] = "Production streams are functioning" % _t
locLines['production_label_cons'] = "Provided: " % _t


locLines['consumption_tooltip_name'] = "Export streams" % _t
locLines['consumption_tooltip_switchbut_off'] = "All export streams are turned off" % _t
locLines['consumption_tooltip_switchbut_partial'] = "Export streams are partially functioning" % _t
locLines['consumption_tooltip_switchbut_on'] = "Export streams are functioning" % _t

locLines['storage_label_instock'] = "In cargo: " % _t
locLines['storage_label_production'] = "Productions: " % _t
locLines['storage_label_consumption'] = "Export: " % _t
locLines['storage_label_limit'] = "Limit " % _t
locLines['storage_tooltip_goodname'] = "\nGoods name" % _t
locLines['storage_tooltip_goodamount'] = "The number of resources in the megacomplex cargo at the moment" % _t
locLines['storage_tooltip_todelete'] =
"On/off utilization mode.\n In this mode, the complex will try to accumulate this product from the stations indefinitely, while all goods over the storage limit will be deleted from stations" %
_t
locLines['storage_tooltip_goodlimit'] = "Limitation on the amount of this product in the cargo of the megacomplex" % _t
locLines['storage_tooltip_production'] = "Number of stations producing this product" % _t
locLines['storage_tooltip_consumption'] = "Number of stations consuming this product" % _t
locLines['storage_tooltip_inputlimit'] = "Enter here a new value for the storage limit of this product" % _t

locLines['linegenerator_label_stationscargo'] = "Station cargo: " % _t
locLines['linegenerator_tooltip_goodname'] = "Product name" % _t
locLines['linegenerator_tooltip_goodamount'] = "Stock of goods in the station cargo" % _t
locLines['linegenerator_tooltip_switcher'] = "Disable/enable this stream" % _t

local _colorG = ColorHSV(150, 64, 100)
local _colorY = ColorHSV(60, 94, 78)
local _colorR = ColorHSV(16, 97, 84)
local _colorB = ColorHSV(240, 40, 100)
local _colorC = ColorHSV(264, 60, 100)

function MX.DebugMsg(_text)
	if _debug then
		print('MX(' .. Entity().name .. ')|', _text)
	end
end

local Debug = MX.DebugMsg

function MX.TableSelfReport(_table, _name)
	if _debug then
		local _headline = 'TableSelfReport: called]------------------------------------'
		if _name then
			_headline = 'TableSelfReport(' .. _name .. '): called]------------------------------------'
		end
		MX.DebugMsg(_headline)
		MX.TSRbase(_table)
		MX.DebugMsg('TableSelfReport: EndOfBaseLevel]----------------------------')
		MX.TSRre(_table)
		MX.DebugMsg('TableSelfReport: finish]------------------------------------')
	end
end

function MX.TSRre(_value, _level)
	if _level == nil then _level = 0 end
	local _lines = '---(' .. tostring(_level) .. ')---'
	for i = 0, _level do
		_lines = _lines .. '------'
	end
	if type(_value) == 'table' then
		MX.DebugMsg('TSRre: ' .. _lines)
		for _index, _row in pairs(_value) do
			MX.TSRre(_row, _level + 1)
		end
		MX.DebugMsg('TSRre: ' .. _lines)
	else
		if _value ~= nil then
			print(type(_value), '|', _value)
		else
			print('Empty')
		end
	end
end

function MX.TSRbase(_value)
	if type(_value) == 'table' then
		for _index, _row in pairs(_value) do
			local _text = 'TSRre:position ' .. tostring(_index) .. ' - '
			if type(_row) == 'table' then
				_text = _text .. 'table(' .. tostring(#_row) .. ')'
				print(_text)
			else
				text = _text .. 'non-table|'
				print(_text, _row)
			end
		end
	else
		MX.DebugMsg('TSRre: this isnt a table')
	end
end

function MX.compareID(_id1, _id2)
	if Entity(_id1).index == Entity(_id2).index then
		return true
	end

	return false
end

function MX.DoMeow()
	MX.DebugMsg('Meow')
end

--Interface
local MXwindow, MXtab

local MXtemp = {}
local _tempWindow
local _tempStateIsProd = true

local tabProduction, tabConsume, tabStorage, tabExport, tabSettings
local tabProductionScroller, tabConsumeScroller, tabStorageScroller, tabExportScroller

local rUnit = 30
local rPaddingX = 15
local rPaddingY = 10

--Basic tables
local tableProduction = {}
--Entity().id
--Goods(table)
--isActive(table)
local interfaceProduction = {}

local tableConsumption = {}
--Entity().id
--GoodType
--TransferAmount
--isActive
local interfaceConsumption = {}

local tableStorage = {}
--GoodType
--Entries
--StorageAmount
--ToDelete
local interfaceStorage = {}

local tableExport = {}
--Entity().id
--GoodType
--TransferRate
--Priority (true -priority over the station consumption algorithm)
--isActive
local tableSettings = {}
table.insert(tableSettings, true) --Is complex active
table.insert(tableSettings, 500)  --Base transfer rate

function MX.interactionPossible(playerIndex, option)
	local player = Player()
	if Entity().index == player.craftIndex then
		return true
	end
end

---------------------------------------------------------------------------------

function MX.getIcon()
	return "data/textures/icons/MCXmegaComplex.png"
end

function MX.getUpdateInterval()
	if _debug then
		return _debugUpdate
	else
		return 2
	end
end

function MX.operate()
	if onServer() then return end

	if #tableProduction <= 0 and #tableConsumption <= 0 and #tableStorage <= 0 then
		Debug('Force analysis')
		MX.analyse()
	end

	if MXwindow then
		MX.buildRequestPacket()
	end

	invokeServerFunction('SyncMainTables', tableProduction, tableConsumption, tableStorage)
	MX.refreshInterface()
	MX.generatedWindowsUpdate()
end

function MX.updateServer(timePassed)
	if #tableProduction <= 0 and #tableConsumption <= 0 and #tableStorage <= 0 then
		--Debug('updateServer: force to restore')
		--MX.restore(values)
	end
	--Mx.restore(values)
	invokeClientFunction(Player(callingPlayer), 'operate')
end

---------------------------------------------------------------------------------
function MX.initialize()
	--Entity():remove script('complex craft/complex core.lua')
	if onClient() and EntityIcon().icon == "" then
		EntityIcon().icon = "data/textures/icons/pix/PIXmx.png"
	end
	if onClient() then
		MX.DebugMsg('====================[CLIENT INITIALIZATION]====================')
	else
		MX.DebugMsg('====================[SERVER INITIALIZATION]====================')
	end
end

function MX.initUI()
	local res = getResolution()
	local frameV2 = vec2(rUnit * 16, rUnit * 15)
	local size = vec2(frameV2.x + rUnit, frameV2.y + rUnit * 3)

	MXwindow = ScriptUI():createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
	ScriptUI():registerWindow(MXwindow, locLines['window_label'])
	MXwindow.caption = locLines['window_label']
	MXwindow.showCloseButton = true
	MXwindow.moveable = true
	--Find out
	MXtab = MXwindow:createTabbedWindow(Rect(vec2(10, 10), size - 10))
	tabProduction = MXtab:createTab("MXproduction", getInnerStationIcon('mxoutput'), locLines['tabprod_label'])
	tabConsume = MXtab:createTab("MXconsumption", getInnerStationIcon('mxinput'), locLines['tabcons_label'])
	tabStorage = MXtab:createTab("MXstorage", getInnerStationIcon('mxstorage'), locLines['tabstorage_label'])
	tabExport = MXtab:createTab("MXexport", getInnerStationIcon('mxexport'), locLines['tabexport_label'])
	tabSettings = MXtab:createTab("MXsettings", getInnerStationIcon('mxsettings'), locLines['tabsettings_label'])

	--Creating import-export tabs
	tabProductionScroller = tabProduction:createScrollFrame(Rect(vec2(10, 10), frameV2))
	tabProductionScroller.layer = 1
	tabConsumeScroller = tabConsume:createScrollFrame(Rect(vec2(10, 10), frameV2))
	tabConsumeScroller.layer = 1
	tabStorageScroller = tabStorage:createScrollFrame(Rect(vec2(10, 10), frameV2))
	tabStorageScroller.layer = 1
	tabExportScroller = tabExport:createScrollFrame(Rect(vec2(10, 10), frameV2))
	tabExportScroller.layer = 1

	if _debug then
		local rectButtons = {}
		-- local rUnit = 30
		-- local rPaddingX = 15
		-- local rPaddingY = 10
		for i = 0, 5 do
			local X1 = (rPaddingX * (i + 1) + rUnit * i)
			local X2 = X1 + rUnit
			local _rectResult = Rect(X1, rPaddingY, X2, rPaddingY + rUnit)
			table.insert(rectButtons, _rectResult)
		end
		local testButton1 = tabSettings:createRoundButton(rectButtons[1],
			"data/textures/icons/SUBSYSPolarisationNanobots.png", "analyse")
		testButton1.tooltip = "Пуск процедуры анализа"
		local testButton2 = tabSettings:createRoundButton(rectButtons[2],
			"data/textures/icons/SUBSYSPolarisationNanobots.png", "buildRequestPacket")
		testButton2.tooltip = "Инициация пакета обновления"
		local testButton3 = tabSettings:createRoundButton(rectButtons[3],
			"data/textures/icons/SUBSYSPolarisationNanobots.png", "DebugPurge")
		testButton3.tooltip = "Удалить батареи с комплекса и всех пристыкованных станций"
		local testButton4 = tabSettings:createRoundButton(rectButtons[4],
			"data/textures/icons/SUBSYSPolarisationNanobots.png", "DebugClearMain")
		testButton4.tooltip = "Сброс основных таблиц"
		local testButton5 = tabSettings:createRoundButton(rectButtons[5], "data/textures/icons/SUBSYSEmergencyRepair.png",
			"restoreOperate")
		testButton5.tooltip = "Принудительная загрузка из памяти"
	else
		local rectButtons = {}
		-- local rUnit = 30
		-- local rPaddingX = 15
		-- local rPaddingY = 10
		for i = 0, 3 do
			local X1 = (rPaddingX * (i + 1) + rUnit * i)
			local X2 = X1 + rUnit
			local _rectResult = Rect(X1, rPaddingY, X2, rPaddingY + rUnit)
			table.insert(rectButtons, _rectResult)
		end
		local testButton1 = tabSettings:createRoundButton(rectButtons[1], "data/textures/icons/MCXinput.png", "analyse")
		testButton1.tooltip = locLines['settings_button_analysis']

		local testButton2 = tabSettings:createRoundButton(rectButtons[2], "data/textures/icons/MCXupdateLimit.png",
			"buildRequestPacket")
		testButton2.tooltip = locLines['settings_button_forcerefresh']

		local testButton3 = tabSettings:createRoundButton(rectButtons[3],
			"data/textures/icons/SUBSYSPolarisationNanobots.png", "DebugClearMain")
		testButton3.tooltip = locLines['settings_button_reset']
	end
	if _secureSwitch then
		invokeServerFunction('adaptiveSync')
	end

	Entity():registerCallback("onEntityDocked", "analyse")
	Entity():registerCallback("onEntityUndocked", "analyse")
end

-----------------------------------------------------------------------------------[Interface functions and its generation]
--Scans stations and causes updates to main tables
function MX.analyse()
	MX.DebugMsg('analyse launch')
	local dockedEntities = { DockingClamps():getDockedEntities() }

	if not (dockedEntities) then
		Debug('analyse failure: docked entities is nil')
	end

	local collectedStations = {} --capturing all stations that meet the conditions (there is at least one resource or product)

	--------------------------[Production/Consumption Segment]-----------
	--The algorithm checks all docked objects and fills a temporary table of results, filtering out duplicates
	for _, _scanned in pairs(dockedEntities) do
		--MX.DebugMsg('analyse: '..Entity(_scanned).name)
		if MX.isStationUniq(_scanned) then
			MX.DebugMsg('analyse uniq: ' .. Entity(_scanned).name .. ' - success')
			local _scannedProduction = MX.getProduction(_scanned)
			local _scannedResourses = MX.getConsumption(_scanned)

			if #_scannedProduction > 0 or #_scannedResourses > 0 then
				table.insert(collectedStations, { _scanned, _scannedProduction, _scannedResourses })
			end
		else
			MX.DebugMsg('analyse uniq: ' .. Entity(_scanned).name .. ' - failed')
		end
	end

	MX.DebugMsg('Analysis finish| uniq stations found: ' .. tostring(#collectedStations))
	MX.refreshMainTables(collectedStations)
end

function MX.refreshMainTables(_analysisResult)
	--preliminary run to detect inactive (missing) segments and remove them from the table
	for _index, _prod in pairs(tableProduction) do
		local _entity = Entity(_prod[1])
		if valid(_entity) then
			if not (_entity.dockingParent == Entity().id) then
				MX.DebugMsg('refreshProductionTable(' .. _entity.name .. '): deleted (undock)')
				SWrewriteConfirmed = true
				table.remove(tableProduction, _index)
			end
		else
			MX.DebugMsg('refreshProductionTable: deleted from update (station is not valid)')
			table.remove(tableProduction, _index)
		end
	end
	--MX.DebugMsg('refreshProductionTable: refreshed')

	for _index, _prod in pairs(tableConsumption) do
		local _entity = Entity(_prod[1])
		if valid(_entity) then
			if not (_entity.dockingParent == Entity().id) then
				MX.DebugMsg('refreshConsumptionTable(' .. _entity.name .. '): deleted (undock)')
				SWrewriteConfirmed = true
				table.remove(tableProduction, _index)
			end
		else
			MX.DebugMsg('refreshConsumptionTable: deleted from update (station is not valid)')
			table.remove(tableConsumption, _index)
		end
	end
	--MX.DebugMsg('refreshConsumptionTable: refreshed')

	--Writing new elements
	if _analysisResult ~= nil then
		for _index, _rows in pairs(_analysisResult) do
			--Entry into the production table
			if #_rows[2] > 0 then
				local _stId = _rows[1]
				local _goodTypes = _rows[2]
				local _isActive = {}

				for i = 1, #_rows[2] do
					table.insert(_isActive, true)
				end
				local _insert = { _stId, _goodTypes, _isActive }
				table.insert(tableProduction, _insert)
			end
			--Entry into the consumption table
			if #_rows[3] > 0 then
				local _stId = _rows[1]
				local _goodTypes = _rows[3]
				local _isActive = {}

				for i = 1, #_rows[3] do
					table.insert(_isActive, true)
				end
				local _insert = { _stId, _goodTypes, _isActive }
				table.insert(tableConsumption, _insert)
			end
		end
	end

	--interface generation
	MX.renderProductionLine()
	MX.renderConsumptionLine()
	MX.renderStorageLine()
end

--creates an interactive line in the production interface
function MX.renderProductionLine()
	--Cutting off
	if tableProduction == nil or #tableProduction < 1 then
		MX.DebugMsg('generateProductionLine: основная таблица отсутствует или пуста')
		return
	end

	if not (tabProductionScroller) then return end


	--full interface reset
	tabProductionScroller:clear()
	interfaceProduction = {}

	--interface variables
	local iconHead = 'data/textures/icons/MCXicon.png'
	local iconArrow = 'data/textures/icons/MCXexpand.png'
	local iconOnline = 'data/textures/icons/MCXon.png'

	--A generation
	for _index, _station in pairs(tableProduction) do
		local i = _index - 1
		local UnivY = rPaddingY * (i + 1) + rUnit * i
		local UnivY2 = UnivY + rUnit


		local HeadIconX = rPaddingX
		local HeadIconX2 = rPaddingX + rUnit
		local NameX = HeadIconX2 + rPaddingX
		local NameX2 = NameX + rUnit * 5
		local ProdsX = NameX2 + rPaddingX
		local ProdsX2 = ProdsX + rUnit * 4
		local ExpandX = ProdsX2 + rPaddingX
		local ExpandX2 = ExpandX + rUnit
		local SwitchX = ExpandX2 + rPaddingX
		local SwitchX2 = SwitchX + rUnit


		local HeadIconRect = Rect(HeadIconX, UnivY, HeadIconX2, UnivY2)
		local NameRect = Rect(NameX, UnivY, NameX2, UnivY2)
		local ProdsRect = Rect(ProdsX, UnivY, ProdsX2, UnivY2)
		local ExpandRect = Rect(ExpandX, UnivY, ExpandX2, UnivY2)
		local SwitchRect = Rect(SwitchX, UnivY, SwitchX2, UnivY2)

		--------------------------[Production Interface]-------------------------
		--Aqua icon
		local STheadIcon = tabProductionScroller:createPicture(HeadIconRect, iconHead)

		--Station name
		local STname = tabProductionScroller:createTextField(NameRect, 'default')
		STname.fontSize = 10
		STname.tooltip = locLines['production_tooltip_namestation']
		-- STlocalNameFrame = tabProductionScroller:createFrame(STname.localRect)
		-- STlocalNameFrame.backgroundColor = _colorC
		--Number of productions
		local STprods = tabProductionScroller:createTextField(ProdsRect, 'default')
		STprods.fontSize = 10
		STprods.tooltip = locLines['production_tooltip_streams']
		-- STlocalProdsFrame = tabProductionScroller:createFrame(STprods.localRect)
		-- STlocalProdsFrame.backgroundColor = _colorC
		--"More details" button
		local STexpand = tabProductionScroller:createRoundButton(ExpandRect, iconArrow, 'onProductionClick')
		STexpand.tooltip = locLines['production_tooltip_expand']
		--Shutdown button
		local STswitch = tabProductionScroller:createRoundButton(SwitchRect, iconOnline, 'onClickSwitchProdGlobal')
		STswitch.tooltip = locLines['production_tooltip_switch']

		local _result = { STheadIcon, STname, STprods, STexpand, STswitch }
		table.insert(interfaceProduction, _result)
	end
end

--creates an interactive line in the production interface
function MX.renderConsumptionLine()
	--Cutting off
	if tableConsumption == nil or #tableConsumption < 1 then
		MX.DebugMsg('renderConsumptionLine: main table is empty or nil')
		return
	end

	if not (tabProductionScroller) then return end

	--full interface reset
	tabConsumeScroller:clear()
	interfaceConsumption = {}

	--interface variables
	local iconHead = 'data/textures/icons/MCXicon.png'
	local iconArrow = 'data/textures/icons/MCXexpand.png'
	local iconOnline = 'data/textures/icons/MCXon.png'

	--A generation
	for _index, _station in pairs(tableConsumption) do
		local i = _index - 1
		local UnivY = rPaddingY * (i + 1) + rUnit * i
		local UnivY2 = UnivY + rUnit


		local HeadIconX = rPaddingX
		local HeadIconX2 = rPaddingX + rUnit
		local NameX = HeadIconX2 + rPaddingX
		local NameX2 = NameX + rUnit * 5
		local ConsX = NameX2 + rPaddingX
		local ConsX2 = ConsX + rUnit * 4
		local ExpandX = ConsX2 + rPaddingX
		local ExpandX2 = ExpandX + rUnit
		local SwitchX = ExpandX2 + rPaddingX
		local SwitchX2 = SwitchX + rUnit


		local HeadIconRect = Rect(HeadIconX, UnivY, HeadIconX2, UnivY2)
		local NameRect = Rect(NameX, UnivY, NameX2, UnivY2)
		local ConsRect = Rect(ConsX, UnivY, ConsX2, UnivY2)
		local ExpandRect = Rect(ExpandX, UnivY, ExpandX2, UnivY2)
		local SwitchRect = Rect(SwitchX, UnivY, SwitchX2, UnivY2)

		--------------------------[Consumption Interface]-------------------------
		--Aqua icon
		local STheadIcon = tabConsumeScroller:createPicture(HeadIconRect, iconHead)
		--Station name
		local STname = tabConsumeScroller:createTextField(NameRect, 'default')
		STname.fontSize = 10
		--Number of productions
		local STcons = tabConsumeScroller:createTextField(ConsRect, 'default')
		STcons.fontSize = 10
		--"More details" button
		local STexpand = tabConsumeScroller:createRoundButton(ExpandRect, iconArrow, 'onConsumptionClick')
		--Shutdown button
		local STswitch = tabConsumeScroller:createRoundButton(SwitchRect, iconOnline, 'onClickSwitchConsGlobal')

		local _result = { STheadIcon, STname, STcons, STexpand, STswitch }
		table.insert(interfaceConsumption, _result)
	end
end

--Performs full processing (updating, deleting, searching for new elements) of the warehouse table and rendering the elements
function MX.renderStorageLine()
	--------------------------[Warehouse table processing segment]-----------
	local _goodsTable = {}

	--Cutting off
	if not (tabStorageScroller) then return end

	--Collects a list of possible unique products from production
	for _, _row in pairs(tableProduction) do
		for i = 1, #_row[2] do
			local _good = _row[2][i]
			if MX.isGoodUniq(_goodsTable, _good) then
				table.insert(_goodsTable, _good)
			end
		end
	end

	--Collects a list of possible unique goods from consumption
	for _, _row in pairs(tableConsumption) do
		for i = 1, #_row[2] do
			local _good = _row[2][i]
			if MX.isGoodUniq(_goodsTable, _good) then
				table.insert(_goodsTable, _good)
			end
		end
	end

	--Mx.table self report( goods table,'uniq resourses to storage')

	--Removes an irrelevant product from the current table
	for _index, _rows in pairs(tableStorage) do
		if MX.isGoodUniq(_goodsTable, _rows[1]) then
			table.remove(tableStorage, _index)
			MX.DebugMsg('Good removed from table (wasnt presented in prod/cons tables): ' ..
			getGoodAttribute(_rows[1], 'name'))
		end
	end

	--Detects an unaccounted item and adds it to the table
	for _, _rows in pairs(_goodsTable) do
		if MX.isGoodUniq(tableStorage, _rows) then
			local _goodType = _rows
			local _EntriesProd = MX.getEntries(_GoodType, tableProduction)
			local _EntriesCons = MX.getEntries(_GoodType, tableConsumption)
			local _StorageAmount = tableSettings[2]
			local _ToDelete = false
			--MX.DebugMsg('Good inserted into storage table: '..getGoodAttribute(_goodType,'name'))
			table.insert(tableStorage, { _goodType, _EntriesProd, _EntriesCons, _StorageAmount, _ToDelete })
		end
	end
	--------------------------[Warehouse table rendering segment]-----------
	--cutting off
	if not (tableStorage) then return end
	--Reset
	tabStorageScroller:clear()
	interfaceStorage = {}
	for _index, _row in pairs(tableStorage) do
		--Variables
		local _good = _row[1]
		local i = _index - 1
		local _icon = getGoodAttribute(_good, 'icon')
		local _name = getTranslatedGoodName(_good)
		local _currentStorage = locLines['storage_label_instock'] .. tostring(CargoBay():getNumCargos(_good))
		local _production = locLines['storage_label_production']
		if #_row[2] > 0 then
			_production = _production .. tostring(#_row[2])
		else
			_production = _production .. '0'
		end
		local _consumption = locLines['storage_label_consumption']
		if #_row[3] > 0 then
			_consumption = _consumption .. tostring(#_row[3])
		else
			_consumption = _consumption .. '0'
		end
		local _storageLimit = locLines['storage_label_limit'] .. _row[4]
		local _toDelete = _row[5]


		local _iconToDelete = 'data/textures/icons/MCXtoDelete.png'
		if _toDelete then
			_iconToDelete = 'data/textures/icons/MCXtoDeleteR.png'
		end
		local _iconRefreshLimit = 'data/textures/icons/MCXupdateLimit.png'

		local UnivY = rPaddingY + rPaddingY * 2 * (i) + rUnit * 2 * i
		local Line1Y = UnivY
		local Line1Y2 = Line1Y + rUnit
		local Line2Y = Line1Y2 + rPaddingY
		local Line2Y2 = Line2Y + rUnit

		local MainIconX = rPaddingX
		local MainIconX2 = MainIconX + rUnit * 1.5
		local MainIconY2 = Line1Y + rUnit * 1.5
		local MainIconRect = Rect(MainIconX2, MainIconY2, MainIconX, Line1Y)
		--Line 1
		local NameX = MainIconX2 + rPaddingX
		local NameX2 = NameX + rUnit * 3.5
		local StorageX = NameX2 + rPaddingX
		local StorageX2 = StorageX + rUnit * 3.5
		local LimitX = StorageX2 + rPaddingX
		local LimitX2 = LimitX + rUnit * 3
		local ToDeleteX = LimitX2 + rPaddingX
		local ToDeleteX2 = ToDeleteX + rUnit

		local NameRect = Rect(NameX, Line1Y, NameX2, Line1Y2)
		local StorageRect = Rect(StorageX, Line1Y, StorageX2, Line1Y2)
		local ToDeleteRect = Rect(ToDeleteX, Line1Y, ToDeleteX2, Line1Y2)
		local LimitRect = Rect(LimitX, Line1Y, LimitX2, Line1Y2)

		--Line 2
		local ProdX = MainIconX2 + rPaddingX
		local ProdX2 = ProdX + rUnit * 3.5
		local ConsX = ProdX2 + rPaddingX
		local ConsX2 = ConsX + rUnit * 3.5
		local LimitInsertX = ConsX2 + rPaddingX
		local LimitInsertX2 = LimitInsertX + rUnit * 3

		local ProdRect = Rect(ProdX, Line2Y, ProdX2, Line2Y2)
		local ConsRect = Rect(ConsX, Line2Y, ConsX2, Line2Y2)
		local LimitInsertRect = Rect(LimitInsertX, Line2Y, LimitInsertX2, Line2Y2)
		--------------------------[Storage Interface]-------------------------
		--Product icon
		local STMainIcon = tabStorageScroller:createPicture(MainIconRect, _icon)

		--Line 1
		--Product name
		local STname = tabStorageScroller:createTextField(NameRect, _name)
		STname.fontSize = 10
		STname.tooltip = _name .. locLines['storage_tooltip_goodname']
		STname.scrollable = true
		--Current volume
		local STstorage = tabStorageScroller:createTextField(StorageRect, _currentStorage)
		STstorage.fontSize = 10
		STstorage.tooltip = locLines['storage_tooltip_goodamount']
		--Delete button
		local STtoDelete = tabStorageScroller:createRoundButton(ToDeleteRect, _iconToDelete, 'onClickToDelete')
		STtoDelete.tooltip = locLines['storage_tooltip_todelete']
		--Limit
		local STlimit = tabStorageScroller:createTextField(LimitRect, _storageLimit)
		STlimit.fontSize = 10
		STlimit.tooltip = locLines['storage_tooltip_goodlimit']

		--Line 2
		--Productions
		local STprod = tabStorageScroller:createTextField(ProdRect, _production)
		STprod.fontSize = 10
		STprod.tooltip = locLines['storage_tooltip_production']
		--Consumption
		local STcons = tabStorageScroller:createTextField(ConsRect, _consumption)
		STcons.fontSize = 10
		STcons.tooltip = locLines['storage_tooltip_consumption']
		--Limit filling window
		local STlimitInsert = tabStorageScroller:createTextBox(LimitInsertRect, 'adjustStorageValue', '1')
		STlimitInsert.tooltip = locLines['storage_tooltip_inputlimit']
		STlimitInsert.maxCharacters = 5
		--STlimitInsert.fontSize = 10
		--function TextBox createTextBox(Rect rect, string onTextChangedFunction)


		local _result = { STMainIcon, STname, STstorage, STtoDelete, STlimit, STprod, STcons, STlimitInsert }
		table.insert(interfaceStorage, _result)
	end
end

function MX.refreshInterface()
	--General Variables
	local _iconOn = 'data/textures/icons/MCXon.png'
	local _iconOff = 'data/textures/icons/MCXoff.png'
	--------------------------------[Product Segment]--------------------------------
	--MX.TableSelfReport(interfaceProduction,'interfaceProduction(refresh)')
	local _refreshAvialable = false
	if (interfaceProduction and tableProduction) and (#interfaceProduction == #tableProduction) and #interfaceProduction > 0 then
		_refreshAvialable = true
	end

	if _refreshAvialable then
		for _index, _rows in pairs(interfaceProduction) do
			if _rows[1] == nil then
				MX.DebugMsg('refreshInterface(1): не могу найти нихрена :С')
				return
			end

			_rows[1].tooltip = tostring(_index)
			--Name
			_rows[2].text = Entity(tableProduction[_index][1]).name

			--Status
			local _thisProduction = tableProduction[_index][3]
			local _active = 0
			local _inactive = 0
			local _color = nil
			--Counts the number of turned on and off productions
			for _, _activity in pairs(_thisProduction) do
				if _activity then
					_active = _active + 1
				else
					_inactive = _inactive + 1
				end
			end

			--Compiling a list of production facilities and filling out a tooltip
			local _prodTable = tableProduction[_index][2]
			local _prodTextAdd = ''
			for i = 1, #_prodTable do
				_prodTextAdd = _prodTextAdd .. '\n - ' .. getTranslatedGoodName(_prodTable[i])
			end
			_rows[3].tooltip = locLines['production_tooltip_streams'] .. _prodTextAdd
			--Mx.table self report( prod table,' prod table')

			--installation of production
			--uses data from past segments
			local _prodText = string.format("%s%i/%i", locLines['storage_label_production'], _active, #_thisProduction)
			_rows[3].text = _prodText

			--Primary icon color and row[5] button icon
			local _headIconText = ''

			if _active == 0 then
				_color = _colorR
				_rows[5].icon = _iconOff
				_headIconText = locLines['production_tooltip_switchbut_off']
			elseif _inactive == 0 then
				_color = _colorG
				_rows[5].icon = _iconOn
				_headIconText = locLines['production_tooltip_switchbut_on']
			else
				_color = _colorY
				_rows[5].icon = _iconOn
				_headIconText = locLines['production_tooltip_switchbut_partial']
			end
			_rows[1].color = _color
			_rows[1].tooltip = _headIconText
		end
	end

	--------------------------------[Consumption segment]--------------------------------
	_refreshAvialable = false
	if (interfaceConsumption and tableConsumption) and (#interfaceConsumption == #tableConsumption) and #interfaceProduction > 0 then
		_refreshAvialable = true
	end

	if _refreshAvialable then
		for _index, _rows in pairs(interfaceConsumption) do
			if _rows[1] == nil then
				MX.DebugMsg('refreshInterface(2): не могу найти нихрена :С')
				return
			end

			--Name
			_rows[2].text = Entity(tableConsumption[_index][1]).name

			--Status
			local _thisConsumption = tableConsumption[_index][3]
			_active = 0
			_inactive = 0
			--Counts the number of enabled and disabled consumption streams
			for _, _activity in pairs(_thisConsumption) do
				if _activity then
					_active = _active + 1
				else
					_inactive = _inactive + 1
				end
			end

			--setting the display of available consumption streams
			local _needs = tableConsumption[_index]
			local _availableRoutes = 0

			local _row3tooltip = locLines['consumption_tooltip_name']

			--Checks production for appropriate flows
			for i = 1, #_needs[2] do
				local isRoutes = MX.getAvialableProductionRoutes(_needs[2][i])
				local isRouteActive = _needs[3][i]

				if isRoutes > 0 and isRouteActive then
					_availableRoutes = _availableRoutes + 1
					_row3tooltip = _row3tooltip .. '\n+' .. getTranslatedGoodName(_needs[2][i])
				else
					_row3tooltip = _row3tooltip .. '\n' .. getTranslatedGoodName(_needs[2][i])
				end
			end

			--Indicates the ratio of available production to consumption.
			--local _consText = 'Provided by: '..tostring(_availableRoutes)..'/'..tostring(_active)
			local _consText = string.format("%s%i/%i", locLines['production_label_cons'], _availableRoutes, _active)
			_rows[3].text = _consText

			--Primary icon color
			if _active == 0 then
				_color = _colorR
				_rows[5].icon = _iconOff
				_headIconText = locLines['consumption_tooltip_switchbut_off']
			elseif _inactive == 0 then
				_color = _colorG
				_rows[5].icon = _iconOn
				_headIconText = locLines['consumption_tooltip_switchbut_on']
			else
				_color = _colorY
				_rows[5].icon = _iconOn
				_headIconText = locLines['consumption_tooltip_switchbut_partial']
			end
			_rows[1].color = _color
			_rows[1].tooltip = _headIconText

			_rows[3].tooltip = _row3tooltip
		end
	end
	--------------------------------[Storage segment]--------------------------------
	MX.refreshProdCons()
	if interfaceStorage and (#interfaceStorage > 0) then
		for _index, _rows in pairs(interfaceStorage) do
			local _STtable = tableStorage[_index]
			local _good = _STtable[1]
			local _iconToDelete = 'data/textures/icons/MCXtoDelete.png'
			local _iconToDeleteR = 'data/textures/icons/MCXtoDeleteR.png'
			--The icon does not change!
			--The product name does not change!

			--Composition
			local _currentStorage = CargoBay():getNumCargos(_good)
			local _currentStorageText = locLines['storage_label_instock'] .. tostring(_currentStorage)

			--Production flows


			local _entryProd = locLines['storage_label_production']
			if #_STtable[2] > 0 then
				_entryProd = _entryProd .. tostring(#_STtable[2])
			else
				_entryProd = _entryProd .. '0'
			end

			--Consumption flows
			local _entryCons = locLines['storage_label_consumption']
			if #_STtable[3] > 0 then
				_entryCons = _entryCons .. tostring(#_STtable[3])
			else
				_entryCons = _entryCons .. '0'
			end

			--Storage limit
			local _storageLimit = locLines['storage_label_limit'] .. _STtable[4]

			--Removal
			local _toDelete = _STtable[5]

			--Processing received values
			--Warehouse
			_rows[3].text = _currentStorageText
			if _currentStorage > 9999 then
				_rows[3].fontSize = 9
				_rows[3].scrollable = true
			else
				_rows[3].fontSize = 10
				_rows[3].scrollable = false
			end
			--Delete icon
			if _toDelete then
				_rows[4].icon = _iconToDeleteR
			else
				_rows[4].icon = _iconToDelete
			end
			--Resource limit
			_rows[5].text = _storageLimit
			--Production
			_rows[6].text = _entryProd
			--Consumption
			_rows[7].text = _entryCons
			--Limit window is not updated
		end
	end
end

function MX.onProductionClick(_button)
	--Determining the button index. This is such nonsense, fucked up :/
	local _thisIndex = nil
	for _index, _rows in pairs(interfaceProduction) do
		if _rows[4].index == _button.index then
			_thisIndex = _index
		end
	end
	--Calling a window
	MX.generateProdWindow(_thisIndex)
end

function MX.onConsumptionClick(_button)
	--Determining the button index. This is such nonsense, fucked up :/
	local _thisIndex = nil
	for _index, _rows in pairs(interfaceConsumption) do
		if _rows[4].index == _button.index then
			_thisIndex = _index
		end
	end
	--Calling a window
	MX.generateConsWindow(_thisIndex)
end

function MX.generateProdWindow(_stindex)
	-- if MXtemp[1] then
	-- _tempWindow:hide()
	-- _tempWindow = nil
	-- end
	if _tempWindow then
		_tempWindow:hide()
		_tempWindow = nil
	end

	_tempStateIsProd = true

	local res = getResolution()
	local frameV2 = vec2(rUnit * 13, rUnit * 8)
	local size = vec2(frameV2.x + rUnit, frameV2.y + rUnit * 3)

	local _table = tableProduction[_stindex]
	local _station = Entity(_table[1])
	local _stname = _station.name

	local _caption = _stname
	_tempWindow = ScriptUI():createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
	_tempWindow.caption = _caption
	_tempWindow.showCloseButton = true
	_tempWindow.moveable = true
	local _winSize = _tempWindow.size
	local _frameRect = Rect(vec2(rPaddingX / 2, rPaddingX / 2), _winSize - rPaddingX * 1.5)

	local _frame = _tempWindow:createScrollFrame(_frameRect)
	_frame:createFrame(_frameRect)
	MXtemp = {}
	------------------------------[line generation]------------------------------
	for _index, _rows in pairs(_table[2]) do
		local _result = {}
		local _good = _rows
		local _icon = getGoodAttribute(_good, 'icon')
		local _name = getTranslatedGoodName(_good)
		local _iconButton = 'data/textures/icons/MCXon.png'
		local _iconButtonR = 'data/textures/icons/MCXoff.png'

		local _goodsOnStation = locLines['linegenerator_label_stationscargo'] ..
		tostring(CargoBay(_station.id):getNumCargos(_good))
		local _isActive = _table[3][_index]

		--Coordinates
		local i = _index - 1
		local UnivY = rPaddingY * _index + rUnit * i
		local UnivY2 = UnivY + rUnit


		local GoodIconX = rPaddingX
		local GoodIconX2 = GoodIconX + rUnit
		local NameX = GoodIconX2 + rPaddingX
		local NameX2 = NameX + rUnit * 4
		local AmountX = NameX2 + rPaddingX
		local AmountX2 = AmountX + rUnit * 4.5
		local ButtonX = AmountX2 + rPaddingX
		local ButtonX2 = ButtonX + rUnit

		local GoodIconRect = Rect(GoodIconX2, UnivY2, GoodIconX, UnivY)
		local NameRect = Rect(NameX, UnivY, NameX2, UnivY2)
		local AmountRect = Rect(AmountX, UnivY, AmountX2, UnivY2)
		local ButtonRect = Rect(ButtonX, UnivY, ButtonX2, UnivY2)

		--Product icon
		local STgoodIcon = _frame:createPicture(GoodIconRect, _icon)
		--Naimenovanie tovar
		local STname = _frame:createTextField(NameRect, _name)
		STname.tooltip = locLines['linegenerator_tooltip_goodname']
		STname.fontSize = 10
		--Stock cargo at stations
		local STamount = _frame:createTextField(AmountRect, _goodsOnStation)
		STamount.fontSize = 10
		STamount.tooltip = locLines['linegenerator_tooltip_goodamount']
		--Shutdown button
		local STswitch = _frame:createRoundButton(ButtonRect, _iconButton, 'onClickSwitchProd')
		STswitch.tooltip = locLines['linegenerator_tooltip_switcher']

		_result = { STamount, STswitch, _good, _table[1], _stindex, _index }
		--Mx.table self report( result,' result')
		table.insert(MXtemp, _result)
	end
	_tempWindow:show()
	MX.generatedWindowsUpdate()
end

function MX.generateConsWindow(_stindex)
	if _tempWindow then
		_tempWindow:hide()
		_tempWindow = nil
	end
	MXtemp = {}
	_tempStateIsProd = false

	local res = getResolution()
	local frameV2 = vec2(rUnit * 13, rUnit * 8)
	local size = vec2(frameV2.x + rUnit, frameV2.y + rUnit * 3)

	local _table = tableConsumption[_stindex]
	local _station = Entity(_table[1])
	local _stname = _station.name

	local _caption = _stname
	_tempWindow = ScriptUI():createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
	_tempWindow.caption = _caption
	_tempWindow.showCloseButton = true
	_tempWindow.moveable = true
	local _winSize = _tempWindow.size
	local _frameRect = Rect(vec2(rPaddingX / 2, rPaddingX / 2), _winSize - rPaddingX * 1.5)

	local _frame = _tempWindow:createScrollFrame(_frameRect)
	_frame:createFrame(_frameRect)

	------------------------------[line generation]------------------------------
	for _index, _rows in pairs(_table[2]) do
		local _result = {}
		local _good = _rows
		local _icon = getGoodAttribute(_good, 'icon')
		local _name = getTranslatedGoodName(_good)
		local _iconButton = 'data/textures/icons/MCXon.png'
		local _iconButtonR = 'data/textures/icons/MCXoff.png'

		local _goodsOnStation = locLines['linegenerator_label_stationscargo'] ..
		tostring(CargoBay(_station.id):getNumCargos(_good))
		local _isActive = _table[3][_index]

		--Coordinates
		local i = _index - 1
		local UnivY = rPaddingY * _index + rUnit * i
		local UnivY2 = UnivY + rUnit


		local GoodIconX = rPaddingX
		local GoodIconX2 = GoodIconX + rUnit
		local NameX = GoodIconX2 + rPaddingX
		local NameX2 = NameX + rUnit * 4
		local AmountX = NameX2 + rPaddingX
		local AmountX2 = AmountX + rUnit * 4.5
		local ButtonX = AmountX2 + rPaddingX
		local ButtonX2 = ButtonX + rUnit

		local GoodIconRect = Rect(GoodIconX2, UnivY2, GoodIconX, UnivY)
		local NameRect = Rect(NameX, UnivY, NameX2, UnivY2)
		local AmountRect = Rect(AmountX, UnivY, AmountX2, UnivY2)
		local ButtonRect = Rect(ButtonX, UnivY, ButtonX2, UnivY2)

		--Product icon
		local STgoodIcon = _frame:createPicture(GoodIconRect, _icon)
		--Naimenovanie tovar
		local STname = _frame:createTextField(NameRect, _name)
		STname.tooltip = locLines['linegenerator_tooltip_goodname']
		STname.fontSize = 10
		--Stock cargo at stations
		local STamount = _frame:createTextField(AmountRect, _goodsOnStation)
		STamount.fontSize = 10
		STamount.tooltip = locLines['linegenerator_tooltip_goodamount']
		--Shutdown button
		local STswitch = _frame:createRoundButton(ButtonRect, _iconButton, 'onClickSwitchCons')
		STswitch.tooltip = locLines['linegenerator_tooltip_switcher']

		_result = { STamount, STswitch, _good, _table[1], _stindex, _index }
		--Mx.table self report( result,' result')
		table.insert(MXtemp, _result)
	end
	_tempWindow:show()
	MX.generatedWindowsUpdate()
end

--Updates data in an open production detail table
function MX.generatedWindowsUpdate()
	------------------------------[Product Window Segment]------------------------------
	if #MXtemp > 0 then
		for _index, _row in pairs(MXtemp) do
			local _good = _row[3]
			local _stindex = _row[5]
			--volume of goods
			local _goodsOnStation = locLines['linegenerator_label_stationscargo'] ..
			tostring(CargoBay(_row[4]):getNumCargos(_good))
			--icon status
			local _status = nil
			if _tempStateIsProd then
				_status = tableProduction[_stindex][3][_index]
			else
				_status = tableConsumption[_stindex][3][_index]
			end
			--volume setting
			_row[1].text = _goodsOnStation
			--setting icon
			if _status then
				_row[2].icon = 'data/textures/icons/MCXon.png'
			else
				_row[2].icon = 'data/textures/icons/MCXoff.png'
			end
		end
	end
end

function MX.onClickSwitchProd(_button)
	local _thisIndex = MX.getElementIndex(_button, MXtemp, 2)
	if not (_thisIndex) then return end

	local _tempTable = MXtemp[_thisIndex]
	local _stIndex = _tempTable[5]
	local _prodTable = tableProduction[_stIndex][3]
	local _status = _prodTable[_thisIndex]

	if _status then
		_prodTable[_thisIndex] = false
	else
		_prodTable[_thisIndex] = true
	end
	MX.generatedWindowsUpdate()
end

function MX.onClickSwitchCons(_button)
	local _thisIndex = MX.getElementIndex(_button, MXtemp, 2)

	if not (_thisIndex) then return end

	local _tempTable = MXtemp[_thisIndex]
	local _stIndex = _tempTable[5]
	local _prodTable = tableConsumption[_stIndex][3]
	local _status = _prodTable[_thisIndex]

	if _status then
		_prodTable[_thisIndex] = false
	else
		_prodTable[_thisIndex] = true
	end
	MX.generatedWindowsUpdate()
end

function MX.onClickSwitchProdGlobal(_button)
	local _thisIndex = MX.getElementIndex(_button, interfaceProduction, 5)

	if not (_thisIndex) then return end

	local _table = tableProduction[_thisIndex][3]

	local _calcCorrect = 0

	for i = 1, #_table do
		if _table[i] then
			_calcCorrect = _calcCorrect + 1
		end
	end

	if _calcCorrect == 0 then
		for i = 1, #_table do
			_table[i] = true
		end
	else
		for i = 1, #_table do
			_table[i] = false
		end
	end
	MX.refreshInterface()
end

function MX.onClickSwitchConsGlobal(_button)
	local _thisIndex = MX.getElementIndex(_button, interfaceConsumption, 5)

	if not (_thisIndex) then return end

	local _table = tableConsumption[_thisIndex][3]

	local _calcCorrect = 0

	for i = 1, #_table do
		if _table[i] then
			_calcCorrect = _calcCorrect + 1
		end
	end

	if _calcCorrect == 0 then
		for i = 1, #_table do
			_table[i] = true
		end
	else
		for i = 1, #_table do
			_table[i] = false
		end
	end
	MX.refreshInterface()
end

function MX.onClickToDelete(_button)
	--local _thisIndex = MX.getButtonIndex(_button,interfaceStorage,4)
	local _thisIndex = MX.getElementIndex(_button, interfaceStorage, 4)

	local _toDelete = tableStorage[_thisIndex][5]

	if _toDelete then
		tableStorage[_thisIndex][5] = false
	else
		tableStorage[_thisIndex][5] = true
	end

	MX.refreshInterface()
end

function MX.adjustStorageValue(_textBox)
	local _thisIndex = MX.getElementIndex(_textBox, interfaceStorage, 8)
	local _value = tonumber(_textBox.text)
	local _baseValue = tableSettings[2]
	if not (_value) then return end
	if _value > _baseValue then
		tableStorage[_thisIndex][4] = _value
	end
end

--------------------------------------------------------------------------[Functions for sending/receiving/deleting resources]

--Generates a request for resources based on the requirements of consuming stations and the capabilities of producing ones
function MX.buildRequestPacket()
	local requestProduction = {}
	--station.id
	--good
	--amount
	--toDelete
	local requestConsumption = {}
	--station.id
	--good
	--amount
	----------------------[Request generation segment]---------------------
	--Request Path Scanning
	for _index, _row in pairs(tableStorage) do
		local _good = _row[1]
		local _entriesProdT = _row[2]
		local _amount = _row[4] - CargoBay():getNumCargos(_good)
		local _toDelete = _row[5]

		--Search for a resource on related stations
		for _index2, _st in pairs(_entriesProdT) do
			if _amount > 0 or _toDelete then
				local _localAmount = CargoBay(_st):getNumCargos(_good)
				local _resultRequest = {}
				if _localAmount > 0 then --Checking resource availability
					if _amount < 0 then _amount = 0 end

					if _localAmount >= _amount then --Checking stock availability for simultaneous transmission
						_resultRequest = { _st, _good, _amount, _toDelete }
						_amount = 0
					else --Partial transfer
						_resultRequest = { _st, _good, _localAmount, _toDelete }
						_amount = _amount - _localAmount
					end

					if _resultRequest then
						--A request for 0 units is not sent if there is no toDelete position
						if (_resultRequest[3] > 0) or _toDelete then
							table.insert(requestProduction, _resultRequest)
						end
					end
				end
			end
		end
	end

	--MX.TableSelfReport(requestProduction,'requestProduction')
	----------------------[Issue generation segment]-----------------------
	for _index, _row in pairs(tableStorage) do
		local _good = _row[1]
		local _goodSize = getGoodAttribute(_good, 'size')
		local _routes = _row[3]
		local _BV = tableSettings[2]

		if #_routes > 0 then
			--We find out the current available supply of these resources on the complex
			local _requestTotal = CargoBay():getNumCargos(_good)
			--We find out a potential request taking into account all flows
			local _consumers = #_routes
			local _requestedByCons = _BV * _consumers
			--We equalize the request and the available amount of resources if necessary
			if _requestedByCons > _requestTotal then
				_requestedByCons = _requestTotal
			end
			--We distribute resources
			for _ind, _row2 in pairs(_routes) do
				--We calculate the packet volume from the common pool for one station
				local _PV = _requestedByCons / _consumers
				--We carry out clarification according to the volume of goods that is already available at the station
				local amountNeeded = _BV - CargoBay(_row2):getNumCargos(_good)
				if _PV > amountNeeded then
					_PV = amountNeeded
				end

				--Conditional calculation of free space. There must be enough space to distribute the resource
				local _freeSpace = CargoBay(_row2).freeSpace
				if _PV * _goodSize > _freeSpace then
					_PV = _freeSpace / _goodSize - 1 --Little crutch :)
				end
				if _PV > 1 then
					--Writing the result to the active table
					local _result = { _row2, _good, _PV }
					--A request for 0 units is not sent
					if _result[3] > 0 then
						table.insert(requestConsumption, _result)
					end
					--Dynamic pool and consumer reduction
					_requestedByCons = _requestedByCons - _PV
					_consumers = _consumers - 1
				else
					--MX.DebugMsg('_PV < 1, error')
				end
			end
		end
	end

	if #requestProduction > 0 then
		MX.applyRequestProduction(requestProduction)
	end
	if #requestConsumption > 0 then
		MX.applyRequestConsumption(requestConsumption)
	end
end

--Performs a request to obtain a resource from a station
function MX.applyRequestProduction(_productionTable)
	if _productionTable and (#_productionTable > 0) then
		for _, _rows in pairs(_productionTable) do
			local _from = _rows[1]
			local _to = Entity().id
			local _good = _rows[2]
			local _amount = _rows[3]
			local _delete = _rows[4]
			if _delete == nil then _delete = false end
			local _result = { _from, _to, _good, _amount, _delete }

			invokeServerFunction('ServerSendResourses', _result)
		end
	else
		--MX.DebugMsg('applyRequestProduction error: table is nil')
	end
end

--Performs a request to transfer a resource TO a station
function MX.applyRequestConsumption(_consumptionTable)
	for _, _rows in pairs(_consumptionTable) do
		local _from = Entity().id
		local _to = _rows[1]
		local _good = _rows[2]
		local _amount = _rows[3]
		local _result = { _from, _to, _good, _amount, false }

		if _amount == 0 then return end

		invokeServerFunction('ServerSendResourses', _result)
	end
end

function MX.ServerSendResourses(_table)
	--Running Variables
	local _from = _table[1]
	local _to = _table[2]
	local _good = _table[3]
	local _amount = _table[4]
	local _delete = _table[5]
	local _isRequestCorrect = true

	--Validation of values
	if _amount <= 0 and not (_delete) then
		MX.DebugMsg('ServerSendResourses error: incorrect _amount(' .. tostring(_amount) .. ')')
		_isRequestCorrect = false
	end
	--Checking the existence of goals
	if not (_from) or not (_to) then
		MX.DebugMsg('ServerSendResourses error: from or to is NIL')
		_isRequestCorrect = false
	end
	--Checking available resource
	local _resourseAvailable = CargoBay(_from):getNumCargos(_good)
	if _resourseAvailable < _amount then
		MX.DebugMsg('ServerSendResourses error: not enough goods(' ..
		getGoodAttribute(_good, 'name') .. ', station: ' .. Entity(_from).name .. ') for transfer')
		_isRequestCorrect = false
	end
	--Checking available space
	local _spaceAvailable = CargoBay(_to).freeSpace
	local _spaceNeeded = getGoodAttribute(_good, 'size') * _amount
	if _spaceAvailable < _spaceNeeded then
		MX.DebugMsg('ServerSendResourses error: not enough space(' .. Entity(_to).name .. ') for transfer')
		_isRequestCorrect = false
	end
	--Reaction to an incorrect request
	if not (_isRequestCorrect) then
		MX.TableSelfReport(ServerSendResourses, 'ServerSendResourses')
		return
	end

	--Task processing
	if _amount > 0 then
		CargoBay(_from):removeCargo(tableToGood(goods[_good]), _amount)
		CargoBay(_to):addCargo(tableToGood(goods[_good]), _amount)
		--MX.DebugMsg('ServerResourseTransfer: transfered '..tostring(_amount)..' '..getGoodAttribute(_good,'name')..' from '..Entity(_from).name..' to '..Entity(_to).name)
	end
	--Delete mode
	if _delete then
		local _toRemoveValue = CargoBay(_from):getNumCargos(_good)
		if _toRemoveValue > _amount then
			CargoBay(_from):removeCargo(_good, _toRemoveValue)
			--MX.DebugMsg('ServerResourseTransfer: deleted '..tostring(_toRemoveValue)..' of '..getGoodAttribute(_good,'name')..' from '..Entity(_from).name)
		end
	end
end

callable(MX, 'ServerSendResourses')

-----------------------------------------------------------------------------------[utility functions]

--Checking for the uniqueness of a station simultaneously for the production and consumption tables
function MX.isStationUniq(_id)
	if not (tableProduction) and not (tableConsumption) then return true end
	for _, _row in pairs(tableProduction) do
		if MX.compareID(_id, _row[1]) then
			return false
		end
	end
	if not (tableConsumption) then return true end
	for _, _row in pairs(tableConsumption) do
		if MX.compareID(_id, _row[1]) then
			return false
		end
	end
	return true
end

--It's just a mess of the council
function MX.ServerDebugPurge()
	MX.DebugMsg('PurgeAttempt')
	local _good = tableToGood(goods['Energy Cell'])

	local _amount = CargoBay():getNumCargos(_good)
	CargoBay():removeCargo(_good, _amount)

	local dockedEntities = { DockingClamps():getDockedEntities() }
	for _, _scanned in pairs(dockedEntities) do
		local _amount = CargoBay(_scanned):getNumCargos(_good)
		CargoBay(_scanned):removeCargo(_good, _amount)
	end
end

callable(MX, 'ServerDebugPurge')

function MX.DebugClearMain()
	MX.DebugMsg('===========================|DebugClearMain called|===========================')
	tableProduction = {}
	tableConsumption = {}
	tableStorage = {}

	interfaceProduction = {}
	interfaceConsumption = {}
	interfaceStorage = {}

	MX.analyse()
end

function MX.DebugPurge()
	if _debug then
		invokeServerFunction('ServerDebugPurge')
	end
end

--Synchronizes information from main tables in a client/server system
function MX.SyncMainTables(_prod, _cons, _stor)
	--MX.DebugMsg('SyncMainTables called')
	tableProduction = _prod
	tableConsumption = _cons
	tableStorage = _stor
end

callable(MX, 'SyncMainTables')

function MX.onRestore(_prod, _cons, _stor)
	MX.DebugMsg('onRestore called')
	tableProduction = _prod
	tableConsumption = _cons
	tableStorage = _stor
	--MX.TableSelfReport(tableStorage,'Restored Storage')
	MX.analyse()
end

--Performs an update of ACTIVE providers/consumers in the storage table
function MX.refreshProdCons()
	for _index, _rows in pairs(tableStorage) do
		local _good = _rows[1]
		--List of manufacturers
		_rows[2] = MX.getEntries(_good, tableProduction)
		--List of consumers
		_rows[3] = MX.getEntries(_good, tableConsumption)
	end
end

--Returns the index of the element calling the function (button, TB)
function MX.getElementIndex(_element, _table, _pos)
	local _result = nil
	for _index, _rows in pairs(_table) do
		if _rows[_pos].index == _element.index then
			_result = _index
		end
	end
	return _result
end

--Scans the production table and returns the number of productions of the specified product, or 0 if the production data is missing (outdated?)
function MX.getAvialableProductionRoutes(_good)
	local _result = 0
	--Table Pass
	for _, _production in pairs(tableProduction) do
		for i = 1, #_production[2] do
			if (_production[2][i] == _good) and _production[3][i] then
				_result = _result + 1
			end
		end
	end
	return _result
end

--Checks the script for correctness to receive goods
function MX.checkTradingScript(_script)
	local _noice = {
		'/basefactory.lua',
		'/factory.lua',
		'/highfactory.lua',
		'/lowfactory.lua',
		'/midfactory.lua'
	}
	for _, _rows in pairs(_noice) do
		if _script == _rows then return true end
	end
	return false
end

--Returns a table of: station output ONLY (does not return the station itself)
function MX.getProduction(_id)
	local _station = Entity(_id)
	local _result = {}
	local scripts = TradingUtility.getTradeableScripts()
	for _, script in pairs(scripts) do
		local results = { _station:invokeFunction(script, "getSoldGoods") }
		local callResult = nil
		if not (MX.checkTradingScript(script)) then
			callResult = 1
		else
			callResult = results[1]
		end
		if callResult == 0 then
			for i = 2, #results do
				table.insert(_result, results[i])
			end
		end
	end
	return _result
end

--Returns a table: required resources for the station
function MX.getConsumption(_id)
	local _station = Entity(_id)
	local _result = {}
	local scripts = TradingUtility.getTradeableScripts()
	for _, script in pairs(scripts) do
		local results = { _station:invokeFunction(script, "getBoughtGoods") }
		local callResult = nil
		--if script == "/consumer.lua" then
		if not (MX.checkTradingScript(script)) then
			callResult = 1
		else
			callResult = results[1]
		end
		if callResult == 0 then
			for i = 2, #results do
				table.insert(_result, results[i])
			end
		end
	end
	return _result
end

--Checks the table for the presence (false) or absence (true) of the specified product in it
function MX.isGoodUniq(_table, _good)
	if #_table < 1 then return true end

	for _, _row in pairs(_table) do
		if type(_row) == 'table' then
			if _row[1] == _good then return false end
		else
			if _row == _good then return false end
		end
	end
	return true
end

--Checks the table for the presence of a given product type and returns a table of related stations
function MX.getEntries(_good, _route)
	local _result = {}
	for _, _rows in pairs(_route) do
		local _entity = _rows[1]
		for i = 1, #_rows[2] do
			if (_rows[2][i] == _good) and (_rows[3][i]) then
				table.insert(_result, _entity)
			end
		end
	end
	return _result
end

function MX.secure()
	MX.DebugMsg('secure attempt')

	--Cutting off an empty save
	if #tableProduction < 1 and #tableConsumption < 1 and #tableStorage < 1 then
		Debug('Secure failed: empty tables')
		return
	end

	local secureTable = {}
	table.insert(secureTable, tableProduction)
	table.insert(secureTable, tableConsumption)
	table.insert(secureTable, tableStorage)
	Debug('secure success')
	return { secureTable = secureTable }
end

function MX.restore(values)
	MX.DebugMsg('restore attempt')

	local restoredValue = secureTable
	MX.restoreOperate()
end

function MX.restoreOperate()
	--Translation of stream
	if onClient() then
		invokeServerFunction('restoreOperate')
		return
	end

	Debug('restoreOperate attempt')

	--Loading Saved Values
	if restoredValue then
		local isProd = restored[1]
		local isCons = restored[2]
		local isStor = restored[3]

		if #isProd < 1 and isCons < 1 and isStor < 1 then
			Debug('Restore failed: empty tables')
			return
		end

		if isProd and isCons and isStor then
			tableProduction = restored[1]
			tableConsumption = restored[2]
			tableStorage = restored[3]
			MX.DebugMsg('restore tables: online')
		end
	else
		Debug('restoredValue failure (nil)')
		--Mx.analyse()
	end
end

callable(MX, 'restoreOperate')

function MX.adaptiveSync()
	local _summLength = #tableProduction + #tableConsumption + #tableStorage
	MX.DebugMsg('adaptiveSync attempt with summLength = ' .. tostring(_summLength))
	if _summLength > 0 then
		invokeClientFunction(Player(callingPlayer), 'onRestore', tableProduction, tableConsumption, tableStorage)
	end
end

callable(MX, 'adaptiveSync')
