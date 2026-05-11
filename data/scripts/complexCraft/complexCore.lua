package.path = package.path .. ";data/scripts/complexCraft/?.lua"
--package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
--include ("basesystem")
include("utility")
include('callable')
include('goods')
--include("productionsindex")
--include("productions")
--include("stringutility")

local TradingUtility = include("tradingutility")
--local TradingAPI = include ("tradingmanager")

--namespace Megacomplex
Megacomplex = {}
--Interface
local MCXwindow, MCXtab, tabIncome, tabOutcome, tabSettings
local MCXscrollerInc, MCXscrollerOut

local MCXincomeLines = {}
local MCXincomeIcons = {}
local MCXincomeGoodsLabel = {}
local MCXincomeStInfo = {}
local MCXincomeAmount = {}
local MCXincomeSwitcher = {}
local MCXincomeIsAllowed = {}
local MCXincomeBoundedStation = {}

local MCXoutcomeLines = {}
local MCXoutcomeIcons = {}
local MCXoutcomeGoodsLabel = {}
local MCXoutcomeStInfo = {}
local MCXoutcomeAmount = {}
local MCXoutcomeSwitcher = {}
local MCXoutcomeIsAllowed = {}
local MCXoutcomeBoundedStation = {}
local MCXoutcomeExportedRoutes = {} --the number of export destinations for each cargo is stored here

local MCXsettingsMainSwitcher = nil
local MCXsettingsSwitcherLabel = nil
local MCXsettingsRestrLabel = nil
local MCSsettingsRestrTextbox = nil
local MCSsettingsRestrButton = nil


local _pad = 25
local _incomeRows = 0
local _outcomeRows = 0
local _baseRestrCargo = 500 --Responsible for the starting limit of cargo compartment volume for each type of product
local _baseRestrCargoInput = 500
local _baseRestrCargoOutput = 500
local _minRestrCargo = 10       --The value below which the limit will not fall
local _isWorkingMainSW = true
local _transferInfoSwitcher = 0 --Responsible for switching processing resource transfer/interface update
--local _globalIsWorking = true
--local _tableOperationsIncome = {} --Fixes the shutdown of some stations for import
--local _tableOperationsOutcome = {} --Fixes the shutdown of some stations for export

local _debug = false
local _iconGreen = 'data/textures/icons/TRPHon.png'
local _iconRed = 'data/textures/icons/TRPHoff.png'

function Megacomplex.debugMsg(_text)
	if _debug then
		print(_text)
	end
end

function Megacomplex.initialize()
	Entity():addScriptOnce("complexCraft/complexCoreV2.lua")
	terminate()
	--Entity():remove script('complex craft/complex core.lua')
	if onClient() and EntityIcon().icon == "" then
		EntityIcon().icon = "data/textures/icons/pix/PIXmx.png"
	end
end

--key segments
--Entity():registerCallback("onEntityDocked", "onDockedChange")
--end of key segments

function Megacomplex.DoMeow()
	if _debug then print("Meow") end
end

function Megacomplex.getUpdateInterval()
	return 1
end

function Megacomplex.updateServer(timePassed)
	-- _transferInfoSwitcher = _transferInfoSwitcher + 1

	-- if _isWorkingMainSW and _transferInfoSwitcher == 5 then
	-- --invokeClientFunction(Player(),'transferResourses')
	-- end
	-- if _isWorkingMainSW and _transferInfoSwitcher == 6 then
	-- --_transferInfoSwitcher = 0
	-- --invokeClientFunction(Player(),'refreshUIinfo')
	-- end
end

--Called to perform a server-side load transfer to avoid client-server desynchronization
--source -the station from which resources are taken
--destination -station to which resources are sent
--amount -amount of resource
--good -TradingGood type!!! -resource type
function Megacomplex.transferCargo(_source, _destination, _amount, _good)
	if _amount == nil or _amount < 1 then
		print('transferCargo: error, transferred resource is less than one or nil')
		return
	end
	if _source == nil or _destination == nil then
		print('transferCargo: error, no receiving station or destination station')
		return
	end
	if _good == nil then
		print('transferCargo: error, product type nil')
		return
	end

	if CargoBay(_source):getNumCargos(_good) < _amount then
		if _debug then
			print('transferCargo: error, there are not enough product units for transfer, I am trying the minimum value')
		end
		if CargoBay(_source):getNumCargos(_good) == 0 then
			if _debug then
				print('transferCargo: error, not enough product units for transfer, products do not exist')
			end
			return
		else
			_amount = CargoBay(_source):getNumCargos(_good)
		end
	end

	CargoBay(_source):removeCargo(_good, _amount)
	CargoBay(_destination):addCargo(_good, _amount)
	if _debug then
		print("Resource transfer completed", _good.name, "from the station", _source.name, 'to the station',
			_destination.name, 'in quantity', _amount, 'Things')
	end
end

callable(Megacomplex, 'transferCargo')

function Megacomplex.transferResourses()
	if _incomeRows > 0 then
		for i = 0, _incomeRows - 1 do
			if MCXincomeGoodsLabel[i] == nil then
				print(Entity().name, i, 'Ошибка importResourses income')
				return
			end

			local _good = MCXincomeGoodsLabel[i].tooltip
			_good = tableToGood(goods[_good])

			--Import scanning sector
			local _currentCargoRestrict = _baseRestrCargo / _good.size
			--Print( current cargo restrict,' current cargo restrict')
			local _currentCargoAviableSpace = _currentCargoRestrict - CargoBay():getNumCargos(_good)
			if _currentCargoAviableSpace > CargoBay().freeSpace then
				_currentCargoAviableSpace = CargoBay().freeSpace
			end
			--Print( current cargo aviable space,' current cargo aviable space')
			local _currentAviableForImport = CargoBay(MCXincomeBoundedStation[i]):getNumCargos(_good)
			--print(_currentAviableForImport,'_currentAviableForImport')
			--Transfer execution sector
			--if _currentAviableForImport>0 and _currentCargoAviableSpace>0 and MCXincomeIsAllowed[i] then
			if _currentAviableForImport > 0 and _currentCargoAviableSpace > 0 then
				local _transferValue = _currentAviableForImport
				if _transferValue > _currentCargoAviableSpace then _transferValue = _currentCargoAviableSpace end
				if _transferValue > 1 then
					invokeServerFunction('transferCargo', MCXincomeBoundedStation[i], Entity(), _transferValue, _good)
				end
			end
		end
	end
	if _outcomeRows > 0 then
		for i = 0, _outcomeRows - 1 do
			if MCXoutcomeGoodsLabel[i] == nil then
				print(Entity().name, i, 'Error importResourses outcome')
				return
			end

			local _good = MCXoutcomeGoodsLabel[i].tooltip
			_good = tableToGood(goods[_good])
			local _goodSize = _good.size
			--Export scanning sector

			if _goodSize < 0.5 then
				_goodSize = 0.5
			end

			local _currentCargoRestrict = _baseRestrCargo / _goodSize
			--if _currentCargoRestrict > _baseRestrCargo then
			--_currentCargoRestrict = _baseRestrCargo
			--end
			local _currentCargoAviableSpace = _currentCargoRestrict -
				CargoBay(MCXoutcomeBoundedStation[i]):getNumCargos(_good)
			if _currentCargoAviableSpace > CargoBay(MCXoutcomeBoundedStation[i]).freeSpace then
				_currentCargoAviableSpace = CargoBay(MCXoutcomeBoundedStation[i]).freeSpace
			end
			local _currentAvailableForExport = CargoBay():getNumCargos(_good) / MCXoutcomeExportedRoutes[_good.name]
			--Transfer execution sector
			--if _currentAvailableForExport>0 and _currentCargoAviableSpace>0 and MCXoutcomeIsAllowed[i] then
			if _currentAvailableForExport > 0 and _currentCargoAviableSpace > 0 then
				local _transferValue = _currentAvailableForExport
				if _transferValue > _currentCargoAviableSpace then _transferValue = _currentCargoAviableSpace end
				if _transferValue > 1 then
					invokeServerFunction('transferCargo', Entity(), MCXoutcomeBoundedStation[i], _transferValue, _good)
				end
			end
		end
	end

	--local start = os.time()
	--repeat until os.time() > start + 1
	--sleep(1)
end

--Performs the creation of a basic interface, creates a start interface and attaches docking/undocking scripts to the megacomplex
function Megacomplex.initUI()
	local res = getResolution()
	local size = vec2(400, 350)
	local frameV2 = vec2(370, 270) --the second point for the rect scroller of the first two tabs

	MCXwindow = ScriptUI():createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
	ScriptUI():registerWindow(MCXwindow, "Mega complex management" % _t)
	MCXwindow.caption = "Mega complex management"
	MCXwindow.showCloseButton = true
	MCXwindow.moveable = true
	--Find out
	MCXtab = MCXwindow:createTabbedWindow(Rect(vec2(10, 10), size - 10))
	tabIncome = MCXtab:createTab("MCXinput", "data/textures/icons/MCXoutput.png",
		"Configuring the reception of resources from factories")
	tabOutcome = MCXtab:createTab("MCXoutput", "data/textures/icons/MCXinput.png",
		"Setting up sending resources to factories")
	tabSettings = MCXtab:createTab("Settings", "data/textures/icons/MCXmegaComplex.png",
		"Mega complex operation configuration")
	--Creating import-export tabs
	MCXscrollerInc = tabIncome:createScrollFrame(Rect(vec2(10, 10), frameV2))
	MCXscrollerInc.layer = 1
	if _debug then print(MCXscrollerInc.layer, "frame layer") end
	MCXscrollerOut = tabOutcome:createScrollFrame(Rect(vec2(10, 10), frameV2))
	MCXscrollerOut.layer = 1
	--Creating a configuration tab

	--Tab settings:create round button(rect(175,20,225,70),'data/textures/icons/trp hon.png','do meow')
	MCXsettingsMainSwitcher = tabSettings:createRoundButton(Rect(20, 20, 50, 50), 'data/textures/icons/TRPHon.png',
		'globalSwitcherButton')
	MCXsettingsSwitcherLabel = tabSettings:createTextField(Rect(80, 10, 280, 70), 'The complex is operational')
	MCXsettingsSwitcherLabel.fontSize = 12
	if _debug then print(Entity():getValue('globalSW'), '<- globalSW') end
	if Entity():getValue('globalSW') == nil then
		Entity():setValue('globalSW', true)
	elseif Entity():getValue('globalSW') == false then
		if _debug then print('Initially the complex is turned off') end
		MCXsettingsMainSwitcher.icon = _iconRed
		MCXsettingsSwitcherLabel.text = 'The complex is stopped'
		invokeServerFunction('globalSWtoServer', false)
	end

	MCXsettingsRestrLabel = tabSettings:createTextField(Rect(10, 80, 200, 140), 'Volume limit per product:')
	MCXsettingsRestrLabel.fontSize = 12
	MCSsettingsRestrTextbox = tabSettings:createTextBox(Rect(220, 90, 280, 110), '')
	--MCSsettingsRestrTextbox.onTextChangedFunction = invokeServerFunction('cargoRestrOperate',)
	MCSsettingsRestrButton = tabSettings:createButton(Rect(290, 90, 340, 110), 'Rewrite',
		'cargoRestrOperateOnButtonPressed')
	invokeServerFunction('cargoRestrOperate', nil)

	Entity():registerCallback("onEntityDocked", "onDockChange")
	Entity():registerCallback("onEntityUndocked", "onDockChange")

	invokeServerFunction("rebuildUI", Entity(), nil)
end

function Megacomplex.cargoRestrOperateOnButtonPressed()
	local _amount = MCSsettingsRestrTextbox.text
	if _debug then print('cargoRestrOperateOnButtonPressed amount ->', _amount) end

	local num = tonumber(_amount)
	if num == nil or num < _minRestrCargo then
		num = _minRestrCargo
	end

	invokeServerFunction('cargoRestrOperate', num)
end

function Megacomplex.cargoRestrOperate(_amount)
	local _value = Entity():getValue('cargoRestr')

	--If amount is nil -then preloads from memory
	if _amount == nil then
		_amount = _baseRestrCargo
		if _value == nil then
			Entity():setValue('cargoRestr', _amount)
		else
			local _result = Entity():getValue('cargoRestr')
			if _debug then print('cargoRestr', _result) end
			invokeClientFunction(Player(), 'cargoRestrOnClient', _result)
		end
		--Otherwise, changes the cargo bay limit with overwriting
	else
		Entity():setValue('cargoRestr', _amount)
		invokeClientFunction(Player(), 'cargoRestrOnClient', _amount)
		if _debug then print('CargoRestr value successfully set to', _amount) end
	end
end

callable(Megacomplex, 'cargoRestrOperate')

function Megacomplex.cargoRestrOnClient(_amount)
	_baseRestrCargo = _amount
	MCSsettingsRestrTextbox.text = _amount
end

function Megacomplex.refreshUIinfo()
	--sleep(1)
	--print(_incomeRows,'_incomeRows-refreshUIinfo')
	if _incomeRows > 0 then
		print(Entity().name)
		for i = 0, _incomeRows - 1 do
			if MCXincomeGoodsLabel[i] == nil then
				print(Entity().name, i, 'refreshUIinfo income error')
				return
			end

			local _good = MCXincomeGoodsLabel[i].tooltip
			local _currentCargoValue = CargoBay():getNumCargos(_good)
			local _currentCargoRestrict = _baseRestrCargo / getGoodAttribute(_good, 'size')

			MCXincomeAmount[i].text = tostring(_currentCargoValue) .. '/' .. tostring(_currentCargoRestrict)
			--Mc xincome goods label.tooltip
		end
	end

	if _outcomeRows > 0 then
		for i = 0, _outcomeRows - 1 do
			if MCXoutcomeGoodsLabel[i] == nil then
				print(Entity().name, i, 'Error refreshUIinfo outcome')
				return
			end

			local _good = MCXoutcomeGoodsLabel[i].tooltip
			local _currentCargoValue = CargoBay(MCXoutcomeBoundedStation[i]):getNumCargos(_good)
			local _currentCargoRestrict = _baseRestrCargo / getGoodAttribute(_good, 'size')

			MCXoutcomeAmount[i].text = tostring(_currentCargoValue) .. '/' .. tostring(_currentCargoRestrict)
		end
	end

	-- if _incomeRows>0 then
	-- _good = MCXincomeGoodsLabel[0].tooltip
	-- local _currentCargoValue = CargoBay():getNumCargos(_good)
	-- end
end

--Clears the interface for re-creation
function Megacomplex.clearMXUI()
	if _debug then print("Cleaning up the interface") end
	--local frameV2 = vec2(370,270)
	MCXscrollerInc:clear()
	MCXscrollerOut:clear()
	MCXoutcomeExportedRoutes = { nil }
	_incomeRows = 0
	_outcomeRows = 0
end

function Megacomplex.globalSWtoServer(_bool)
	--Entity():set value('global sw', bool)
	_isWorkingMainSW = _bool
	if _debug then print('_isWorkingMainSW switched to', _bool) end
end

callable(Megacomplex, 'globalSWtoServer')

function Megacomplex.globalSwitcherButton()
	if Entity():getValue('globalSW') then
		Entity():setValue('globalSW', false)
		MCXsettingsMainSwitcher.icon = _iconRed
		MCXsettingsSwitcherLabel.text = 'Compex stopped'
		invokeServerFunction('globalSWtoServer', false)
		if _debug then print('The complex is turned off') end
	else
		Entity():setValue('globalSW', true)
		MCXsettingsMainSwitcher.icon = _iconGreen
		MCXsettingsSwitcherLabel.text = 'The complex is operational'
		invokeServerFunction('globalSWtoServer', true)
		if _debug then print('The complex is activated') end
	end
end

--Finds the resource and goods of each docked station, initiating the creation of corresponding elements in the mega-complex interface
function Megacomplex.generateIncomeOutcome(_station)
	local scripts = TradingUtility.getTradeableScripts()
	local station = _station

	for _, script in pairs(scripts) do
		local tradingStation = nil


		local results = { station:invokeFunction(script, "getSoldGoods") }
		--Megacomplex.debug msg(tostring(script).."script")
		local callResult = nil
		if script == "/consumer.lua" then
			--if _debug then print("I cut off consumer script") end
			callResult = 1
		else
			--if _debug then print("Correct script. Switching") end
			callResult = results[1]
		end
		if callResult == 0 then
			--print("Script run successful: trading something!")
			tradingStation = { station = station, script = script, bought = {}, sold = {} }
			tradingStation.sold = {}

			for i = 2, tablelength(results) do
				local _getBool = Megacomplex.getStateFromString(_incomeRows, 'income')
				--print(_incomeRows)
				--print('incomeRows =',_incomeRows)
				_incomeRows = _incomeRows + 1
				if _getBool == -1 or _getBool == nil then
					Megacomplex.writeStateToString(_incomeRows, true, 'income')
					_getBool = true
					if _debug then print('When scanning a station, a new value for the center variable was created') end
				end
				invokeClientFunction(Player(), "generateLine", "income", _station, results[i], Entity(), _getBool)
			end
		end

		local results = { station:invokeFunction(script, "getBoughtGoods") }
		local callResult = nil
		if script == "/consumer.lua" then
			--if _debug then print("I cut off consumer script") end
			callResult = 1
		else
			callResult = results[1]
		end
		if callResult == 0 then -- call was successful, the station buys goods
			if tradingStation == nil then
				tradingStation = { station = station, script = script, bought = {}, sold = {} }
			end

			for i = 2, tablelength(results) do
				local _getBool = Megacomplex.getStateFromString(_outcomeRows, 'outcome')
				_outcomeRows = _outcomeRows + 1
				if _getBool == -1 or _getBool == nil then
					Megacomplex.writeStateToString(_outcomeRows, true, 'outcome')
					_getBool = true
					if _debug then
						print(
							'When scanning a station, a new value for the center variable was created, Outcome sector')
					end
				end
				--table.insert(tradingStation.bought, results[i])
				invokeClientFunction(Player(), "generateLine", "outcome", _station, results[i], Entity(), _getBool)
				--_amountLinesOutcome = _amountLinesOutcome + 1
			end
		end
	end
end

callable(Megacomplex, "generateIncomeOutcome")

--Gets an array of characters and converts it to a string
function Megacomplex.convertToString(_input)
	local _result = ''

	for i = 1, #_input do
		_result = _result .. _input[i]
	end

	return _result
end

--returns a bool from a position in a binary series. Returns -1 if value does not exist
function Megacomplex.getStateFromString(_pos, _type)
	local _string = ''

	if _type == 'income' then
		_string = Entity():getValue('MGXincome')
		if _string == nil then return -1 end
	else
		_string = Entity():getValue('MGXoutcome')
		if _string == nil then return -1 end
	end

	if string.sub(_string, _pos + 1, _pos + 1) == '1' then
		--if _debug then print("getStateFromString Вернул true") end
		return true
	else
		--if _debug then print("getStateFromString Vernul false") end
		return false
	end
end

callable(Megacomplex, 'getStateFromString')
--writes the value of the button (bool) to the corresponding position in the general string as 0 or 1. Creates stored strings in customValue if none exist
--where _pos is the position of the element in the line, _bool is the value, _type is import or export
--IMPORTANT, _pos is offset by +1 due to the fact that the enumeration of UI elements starts from zero, and the enumeration of line elements starts from one
function Megacomplex.writeStateToString(_pos, _bool, _type)
	local _getValue = ''
	if _type == 'income' then
		_getValue = Entity():getValue("MGXincome")
		if _getValue == nil then
			Entity():setValue("MGXincome", 1)
			_getValue = 1
			print('Empty center variable, set to 1')
		end
	else
		_getValue = Entity():getValue("MGXoutcome")
		if _getValue == nil then
			Entity():setValue("MGXoutcome", 1)
			_getValue = 1
		end
	end

	local _result = Megacomplex.convertToArray(_getValue)
	if _bool then
		_result[_pos + 1] = 1
	else
		_result[_pos + 1] = 0
	end
	local toSave = Megacomplex.convertToString(_result)
	if _type == 'income' then
		Entity():setValue("MGXincome", toSave)
	else
		Entity():setValue("MGXoutcome", toSave)
	end
	if _debug then print(toSave, "-the string to be saved from writeStateToString") end
end

callable(Megacomplex, 'writeStateToString')
--Gets a string and splits it into a character array
function Megacomplex.convertToArray(_input)
	local _result = {}
	_input = tostring(_input)
	-- if _debug then
	-- print('|',_input,'| -main line')
	-- print(#_input,"-length of string?")
	-- end
	for i = 1, #_input do
		_result[i] = string.sub(_input, i, i)
		--if _debug then print(_result[i],"_result[i]") end
	end
	return _result
end

--Creates a line in the megacomplex interface containing an icon, the name (in translation) of the product, its quantity, an icon with information about the station and a button
function Megacomplex.generateLine(_tab, _sourceStation, _good, _complex, _boolIcon)
	if _good == nil then
		print('Error: no variable _good (generateLine)')
		return
	end
	_goodT = getTranslatedGoodName(_good)
	_icon = getGoodAttribute(_good, 'icon')
	_cargoAmount = getGoodAttribute(_good, 'size') * CargoBay(_complex):getNumCargos(_good)
	_cargoRestricted = _baseRestrCargo / getGoodAttribute(_good, 'size')
	_cargoResult = tostring(_cargoAmount) .. '/' .. tostring(_cargoRestricted)
	local _iconB = ''
	if _boolIcon then
		_iconB = 'data/textures/icons/TRPHon.png'
	else
		_iconB = 'data/textures/icons/TRPHoff.png'
	end

	if _tab == 'income' then
		--resource acquisition segment
		local i = _incomeRows
		_incomeRows = _incomeRows + 1
		--Product icon
		MCXincomeIcons[i] = MCXscrollerInc:createPicture(Rect(25, _pad * i + 25, 5, _pad * i + 5), _icon)
		--Product name (with translation)
		--MCXincomeIcons[i].layer = 0
		MCXincomeGoodsLabel[i] = MCXscrollerInc:createTextField(Rect(30, _pad * i, 170, _pad * i + 30), _goodT)
		MCXincomeGoodsLabel[i].fontSize = 10
		MCXincomeGoodsLabel[i].tooltip = _good
		--Station information
		MCXincomeStInfo[i] = MCXscrollerInc:createPicture(Rect(175, _pad * i + 5, 195, _pad * i + 25),
			"data/textures/icons/MCXinfo.png")
		MCXincomeStInfo[i].tooltip = _sourceStation.name
		--Information on the amount of space occupied
		MCXincomeAmount[i] = MCXscrollerInc:createTextField(Rect(200, _pad * i, 320, _pad * i + 30), _cargoResult)
		MCXincomeAmount[i].fontSize = 10
		MCXincomeSwitcher[i] = MCXscrollerInc:createRoundButton(Rect(325, _pad * i, 350, _pad * i + 25), _iconB,
			"onButtonChangeStateIncome")
		MCXincomeBoundedStation[i] = _sourceStation
		MCXincomeIsAllowed[i] = _boolIcon
	elseif _tab == 'outcome' then
		--resource sending segment
		local i = _outcomeRows
		_outcomeRows = _outcomeRows + 1
		--Product icon
		MCXoutcomeIcons[i] = MCXscrollerOut:createPicture(Rect(25, _pad * i + 25, 5, _pad * i + 5), _icon)
		--Product name (with translation)
		MCXoutcomeGoodsLabel[i] = MCXscrollerOut:createTextField(Rect(30, _pad * i, 170, _pad * i + 30), _goodT)
		MCXoutcomeGoodsLabel[i].fontSize = 10
		MCXoutcomeGoodsLabel[i].tooltip = _good
		--Station information
		MCXoutcomeStInfo[i] = MCXscrollerOut:createPicture(Rect(175, _pad * i + 5, 195, _pad * i + 25),
			"data/textures/icons/MCXinfo.png")
		MCXoutcomeStInfo[i].tooltip = _sourceStation.name
		--Information on the amount of space occupied
		MCXoutcomeAmount[i] = MCXscrollerOut:createTextField(Rect(200, _pad * i, 320, _pad * i + 30), _cargoResult)
		MCXoutcomeAmount[i].fontSize = 10
		MCXoutcomeSwitcher[i] = MCXscrollerOut:createRoundButton(Rect(325, _pad * i, 350, _pad * i + 25), _iconB,
			"onButtonChangeStateOutcome")
		MCXoutcomeBoundedStation[i] = _sourceStation
		if MCXoutcomeExportedRoutes[_good] == nil then
			if _boolIcon then MCXoutcomeExportedRoutes[_good] = 1 else MCXoutcomeExportedRoutes[_good] = 0 end
		elseif _boolIcon then
			MCXoutcomeExportedRoutes[_good] = MCXoutcomeExportedRoutes[_good] + 1
		end
		MCXoutcomeIsAllowed[i] = _boolIcon
	end
end

function Megacomplex.switchButtonIcon(_pos, _bool, _type)
	if _type == 'income' then
		--Print( bool)
		if _bool then
			MCXincomeSwitcher[_pos].icon = 'data/textures/icons/TRPHoff.png'
			MCXincomeIsAllowed[_pos] = false
		else
			MCXincomeSwitcher[_pos].icon = 'data/textures/icons/TRPHon.png'
			MCXincomeIsAllowed[_pos] = true
		end
	else
		local _goodName = MCXoutcomeGoodsLabel[_pos].tooltip
		if _bool then
			MCXoutcomeSwitcher[_pos].icon = 'data/textures/icons/TRPHoff.png'
			MCXoutcomeExportedRoutes[_goodName] = MCXoutcomeExportedRoutes[_goodName] - 1
			print(MCXoutcomeExportedRoutes[_goodName], 'current routes value after decrement for the product', _goodName)
			MCXoutcomeIsAllowed[_pos] = false
		else
			MCXoutcomeSwitcher[_pos].icon = 'data/textures/icons/TRPHon.png'
			MCXoutcomeExportedRoutes[_goodName] = MCXoutcomeExportedRoutes[_goodName] + 1
			print(MCXoutcomeExportedRoutes[_goodName], 'current routes value after increment for the product', _goodName)
			MCXoutcomeIsAllowed[_pos] = true
		end
	end
end

--Handling a button click in the import panel
function Megacomplex.onButtonChangeStateIncome(_button)
	local _rectPos = _button.localRect.topLeft.y / _pad --converts the Y-coordinate of a button to its index
	invokeServerFunction('onButtonWorkCore', _rectPos, 'income')
end

function Megacomplex.onButtonChangeStateOutcome(_button)
	local _rectPos = _button.localRect.topLeft.y / _pad --converts the Y-coordinate of a button to its index
	invokeServerFunction('onButtonWorkCore', _rectPos, 'outcome')
end

--Further processing of button clicks on import/export, changing the icon and changing the main ship variable storing values
function Megacomplex.onButtonWorkCore(_pos, _type)
	if _type ~= 'income' and _type ~= 'outcome' then
		print('onButtonWorkCore error: invalid type _type')
		return
	end

	local _buttonState = Megacomplex.getStateFromString(_pos, _type)
	if _buttonState and _buttonState ~= -1 then
		Megacomplex.writeStateToString(_pos, false, _type)
		invokeClientFunction(Player(), 'switchButtonIcon', _pos, _buttonState, _type)
	elseif _buttonState ~= -1 then
		Megacomplex.writeStateToString(_pos, true, _type)
		invokeClientFunction(Player(), 'switchButtonIcon', _pos, _buttonState, _type)
	end
end

callable(Megacomplex, 'onButtonWorkCore')

--Recreates (updates) the interface every time a station docks or undocks to the complex. Also called at the beginning to render the initial interface
function Megacomplex.rebuildUI(_complexID, _stationID)
	local _complex = Entity(_complexID)

	if _debug then
		local _testy = _complex:getValue('MGXincome')
		print(_testy, 'perestroika through rebuildUI')
	end

	local _station = Entity(_stationID)
	if _station.isStation then
		if _debug then print("Initialize the interface") end
		--reset values
		if _debug then print("I start resetting the interface, creating a new one") end
		invokeClientFunction(Player(), "clearMXUI")
		_incomeRows = 0
		_outcomeRows = 0
		--request processing
		_doent = { DockingClamps(_complex):getDockedEntities() }
		for i = 1, #_doent do
			if _debug then print("Creating an interface for " .. tostring(i) .. " docked station") end
			Megacomplex.generateIncomeOutcome(Entity(_doent[i]))
		end
	else
		if _debug then print("The check failed, the docked vessel is not a station") end
	end
end

callable(Megacomplex, "rebuildUI")

function Megacomplex.onDockChange(_complexId, _stationId)
	invokeServerFunction("rebuildUI", _complexId, _stationId)
	if _debug then print("The docking or undocking is complete, I transfer control to the rebuildUI script") end
end

function Megacomplex.interactionPossible(playerIndex, option)
	local player = Player()
	if Entity().index == player.craftIndex then
		return true
	end
end

--/run Entity():addScript("data/scripts/complexCraft/complexCore.lua")
