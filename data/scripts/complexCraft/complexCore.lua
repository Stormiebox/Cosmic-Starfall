package.path = package.path .. ";data/scripts/complexCraft/?.lua"
--package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
--include ("basesystem")
include ("utility")
include('callable')
include('goods')
--include("productionsindex")
--include("productions")
--include("stringutility")

local TradingUtility = include ("tradingutility")
--local TradingAPI = include ("tradingmanager")

--namespace Megacomplex
Megacomplex = {}
--Интерфейс
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
local MCXoutcomeExportedRoutes = {} --здесь хранится кол-во направлений экспорта для каждого груза

local MCXsettingsMainSwitcher = nil
local MCXsettingsSwitcherLabel = nil
local MCXsettingsRestrLabel = nil
local MCSsettingsRestrTextbox = nil
local MCSsettingsRestrButton = nil


local _pad = 25
local _incomeRows = 0
local _outcomeRows = 0
local _baseRestrCargo = 500 --Отвечает за стартовое ограничение объема грузового отсека для каждого типа товара
local _baseRestrCargoInput = 500
local _baseRestrCargoOutput = 500
local _minRestrCargo = 10 --Значение, ниже которого ограничение не опустится
local _isWorkingMainSW = true
local _transferInfoSwitcher = 0 --Отвечает за переключение обработки передача ресурсов/обновление интерфейса
--local _globalIsWorking = true
--local _tableOperationsIncome = {} --Фиксирует отключение работы некоторых станций на импорт
--local _tableOperationsOutcome = {} --Фиксирует отключение работы некоторых станций на экспорт

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
	--Entity():removeScript('complexCraft/complexCore.lua') 
	if onClient() and EntityIcon().icon == "" then
        EntityIcon().icon = "data/textures/icons/pix/PIXmx.png"
    end
end

--ключевые сегменты
	--Entity():registerCallback("onEntityDocked", "onDockedChange")
--конец ключевых сегментов

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

--Вызывается для выполнения передачи груза со стороны сервера, чтобы избежать рассинхронизации клиент-сервер
--source - станция, с которой берутся ресурсы
--destination - станция, на которую отправляются ресурсы
--amount - количество ресурса
--good - TradingGood тип!!! - тип ресурса
function Megacomplex.transferCargo(_source,_destination,_amount,_good)
	if _amount<1 or _amount == nil then print('transferCargo: ошибка, передаваемый ресурс меньше единицы или nil') return end
	if _source == nil or _destination == nil then print('transferCargo: ошибка, отсутствует станция приема или станция назначения') return end
	if _good == nil then print('transferCargo: ошибка, тип товара nil') return end
	
	if CargoBay(_source):getNumCargos(_good) < _amount then
		if _debug then
			print('transferCargo: ошибка, недостаточно единиц товара для трансфера, пробую минимальное значение')
		end
		if CargoBay(_source):getNumCargos(_good) == 0 then
			if _debug then
				print('transferCargo: ошибка, недостаточно единиц товара для трансфера, товары не существуют')
			end
			return
		else
			_amount = CargoBay(_source):getNumCargos(_good)
		end
	end
	
	CargoBay(_source):removeCargo(_good,_amount)
	CargoBay(_destination):addCargo(_good,_amount)
	if _debug then print("Произведен трансфер ресурса",_good.name,"со станции",_source.name,'на станцию',_destination.name,'в количестве',_amount,'штук') end
end
callable(Megacomplex,'transferCargo')

function Megacomplex.transferResourses()
	if _incomeRows>0 then
		for i=0,_incomeRows-1 do
			if MCXincomeGoodsLabel[i] == nil then print(Entity().name,i,'Ошибка importResourses income') return end
			
			local _good = MCXincomeGoodsLabel[i].tooltip
			_good = tableToGood(goods[_good])
			
			--Сектор сканирования импорта
			local _currentCargoRestrict = _baseRestrCargo / _good.size
				--print(_currentCargoRestrict,'_currentCargoRestrict')
			local _currentCargoAviableSpace = _currentCargoRestrict - CargoBay():getNumCargos(_good)
			if _currentCargoAviableSpace>CargoBay().freeSpace then 
				_currentCargoAviableSpace = CargoBay().freeSpace
			end
				--print(_currentCargoAviableSpace,'_currentCargoAviableSpace')
			local _currentAviableForImport = CargoBay(MCXincomeBoundedStation[i]):getNumCargos(_good)
				--print(_currentAviableForImport,'_currentAviableForImport')
			--Сектор выполнения трансфера
			--if _currentAviableForImport>0 and _currentCargoAviableSpace>0 and MCXincomeIsAllowed[i] then
			if _currentAviableForImport>0 and _currentCargoAviableSpace>0 then
				local _transferValue = _currentAviableForImport
				if _transferValue > _currentCargoAviableSpace then _transferValue = _currentCargoAviableSpace end
				if _transferValue>1 then
					invokeServerFunction('transferCargo',MCXincomeBoundedStation[i],Entity(),_transferValue,_good)
				end
			end
		end
	end
	if _outcomeRows>0 then
		for i=0,_outcomeRows-1 do
			if MCXoutcomeGoodsLabel[i] == nil then print(Entity().name,i,'Ошибка importResourses outcome') return end
			
			local _good = MCXoutcomeGoodsLabel[i].tooltip
			_good = tableToGood(goods[_good])
			local _goodSize = _good.size
			--Сектор сканирования экспорта
			
			if _goodSize <0.5 then
			_goodSize = 0.5
			end
			
			local _currentCargoRestrict = _baseRestrCargo / _goodSize
			--if _currentCargoRestrict > _baseRestrCargo then
			--_currentCargoRestrict = _baseRestrCargo
			--end
			local _currentCargoAviableSpace = _currentCargoRestrict - CargoBay(MCXoutcomeBoundedStation[i]):getNumCargos(_good)
			if _currentCargoAviableSpace>CargoBay(MCXoutcomeBoundedStation[i]).freeSpace then 
				_currentCargoAviableSpace = CargoBay(MCXoutcomeBoundedStation[i]).freeSpace
			end
			local _currentAvailableForExport = CargoBay():getNumCargos(_good) / MCXoutcomeExportedRoutes[_good.name]
			--Сектор выполнения трансфера
			--if _currentAvailableForExport>0 and _currentCargoAviableSpace>0 and MCXoutcomeIsAllowed[i] then
			if _currentAvailableForExport>0 and _currentCargoAviableSpace>0 then
				local _transferValue = _currentAvailableForExport
				if _transferValue > _currentCargoAviableSpace then _transferValue = _currentCargoAviableSpace end
				if _transferValue > 1 then
					invokeServerFunction('transferCargo',Entity(),MCXoutcomeBoundedStation[i],_transferValue,_good)
				end
			end
		end
	end
	
	--local start = os.time()
    --repeat until os.time() > start + 1
	--sleep(1)
end

--Выполняет создание базового интерфейса, создает стартовый интерфейс и прикрепляет скрипты на стыкову/отстыковку к мегакомплексу
function Megacomplex.initUI()
	local res = getResolution()
	local size = vec2(400, 350)
	local frameV2 = vec2(370,270) --вторая точка для ректа скроллера первых двух вкладок
	
	MCXwindow = ScriptUI():createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
	ScriptUI():registerWindow(MCXwindow, "Управление мегакомплексом"%_t)
	MCXwindow.caption = "Управление мегакомплексом"
	MCXwindow.showCloseButton = true
    MCXwindow.moveable = true
	--Табы
	MCXtab = MCXwindow:createTabbedWindow(Rect(vec2(10, 10), size - 10))
		tabIncome = MCXtab:createTab("MCXinput","data/textures/icons/MCXoutput.png","Настройка приема ресурсов с фабрик")
		tabOutcome = MCXtab:createTab("MCXoutput","data/textures/icons/MCXinput.png","Настройка отправки ресурсов на фабрики")
		tabSettings = MCXtab:createTab("Settings","data/textures/icons/MCXmegaComplex.png","Конфигурация работы мегакомплекса")
	--Создание импорт-экспорт табов
	MCXscrollerInc = tabIncome:createScrollFrame(Rect(vec2(10, 10), frameV2))
		MCXscrollerInc.layer = 1
		if _debug then print(MCXscrollerInc.layer,"frame layer") end
	MCXscrollerOut = tabOutcome:createScrollFrame(Rect(vec2(10, 10), frameV2))
		MCXscrollerOut.layer = 1
	--Создание таба конфигурации
	
	--tabSettings:createRoundButton(Rect(175,20,225,70),'data/textures/icons/TRPHon.png','DoMeow')
	MCXsettingsMainSwitcher = tabSettings:createRoundButton(Rect(20,20,50,50),'data/textures/icons/TRPHon.png','globalSwitcherButton')
	MCXsettingsSwitcherLabel = tabSettings:createTextField(Rect(80,10,280,70),'Комплекс функционирует')
		MCXsettingsSwitcherLabel.fontSize = 12
	if _debug then print(Entity():getValue('globalSW'),'<- globalSW') end
	if Entity():getValue('globalSW') == nil then
		Entity():setValue('globalSW',true)
	elseif Entity():getValue('globalSW') == false then
		if _debug then print('Изначально комплекс выключен') end
		MCXsettingsMainSwitcher.icon = _iconRed
		MCXsettingsSwitcherLabel.text = 'Комплекс остановлен'
		invokeServerFunction('globalSWtoServer',false)
	end
	
	MCXsettingsRestrLabel = tabSettings:createTextField(Rect(10,80,200,140),'Ограничение объема на товар:')
		MCXsettingsRestrLabel.fontSize = 12
	MCSsettingsRestrTextbox = tabSettings:createTextBox(Rect(220,90,280,110),'')
		--MCSsettingsRestrTextbox.onTextChangedFunction = invokeServerFunction('cargoRestrOperate',)
	MCSsettingsRestrButton = tabSettings:createButton(Rect(290,90,340,110),'Переписать','cargoRestrOperateOnButtonPressed')
	invokeServerFunction('cargoRestrOperate',nil)

	Entity():registerCallback("onEntityDocked", "onDockChange")
	Entity():registerCallback("onEntityUndocked", "onDockChange")
	
	invokeServerFunction("rebuildUI",Entity(),nil)
end

function Megacomplex.cargoRestrOperateOnButtonPressed()
	_amount = MCSsettingsRestrTextbox.text
	if _debug then print('cargoRestrOperateOnButtonPressed amount ->',_amount) end
	if tonumber(_amount) < _minRestrCargo or _amount == nil then _amount = _minRestrCargo end
	invokeServerFunction('cargoRestrOperate',_amount)
end

function Megacomplex.cargoRestrOperate(_amount)
	local _value = Entity():getValue('cargoRestr')
	
	--Если amount nil - то выполняет предзагрузку из памяти
	if _amount == nil then
		_amount = _baseRestrCargo
		if _value == nil then
			Entity():setValue('cargoRestr',_amount)
		else
			local _result = Entity():getValue('cargoRestr')
			if _debug then print('cargoRestr',_result) end
			invokeClientFunction(Player(),'cargoRestrOnClient',_result)
		end
	--Иначе выполняет изменение ограничения грузотсека с перезаписью
	else
		Entity():setValue('cargoRestr',_amount)
		invokeClientFunction(Player(),'cargoRestrOnClient',_amount)
		if _debug then print('Значение CargoRestr Успешно установлено на',_amount) end
	end
end
callable(Megacomplex,'cargoRestrOperate')

function Megacomplex.cargoRestrOnClient(_amount)
	_baseRestrCargo = _amount
	MCSsettingsRestrTextbox.text = _amount
end

function Megacomplex.refreshUIinfo()
	--sleep(1)
	--print(_incomeRows,'_incomeRows-refreshUIinfo')
	if _incomeRows>0 then
		print(Entity().name)
		for i=0,_incomeRows-1 do
			if MCXincomeGoodsLabel[i] == nil then print(Entity().name,i,'Ошибка refreshUIinfo income') return end
			
			local _good = MCXincomeGoodsLabel[i].tooltip
			local _currentCargoValue = CargoBay():getNumCargos(_good)
			local _currentCargoRestrict = _baseRestrCargo / getGoodAttribute(_good,'size')

			MCXincomeAmount[i].text = tostring(_currentCargoValue)..'/'..tostring(_currentCargoRestrict)
			--MCXincomeGoodsLabel.tooltip
		end
	end
	
	if _outcomeRows>0 then
		
		for i=0,_outcomeRows-1 do
			if MCXoutcomeGoodsLabel[i] == nil then print(Entity().name,i,'Ошибка refreshUIinfo outcome') return end
			
			local _good = MCXoutcomeGoodsLabel[i].tooltip
			local _currentCargoValue = CargoBay(MCXoutcomeBoundedStation[i]):getNumCargos(_good)
			local _currentCargoRestrict = _baseRestrCargo / getGoodAttribute(_good,'size')
			
			MCXoutcomeAmount[i].text = tostring(_currentCargoValue)..'/'..tostring(_currentCargoRestrict)
		end
	end
	
	-- if _incomeRows>0 then
		-- _good = MCXincomeGoodsLabel[0].tooltip
		-- local _currentCargoValue = CargoBay():getNumCargos(_good)
	-- end
end

--Очищает интерфейс для пересоздания
function Megacomplex.clearMXUI()
	if _debug then print("Выполняю очистку интерфейса") end
	--local frameV2 = vec2(370,270)
	 MCXscrollerInc:clear()
	 MCXscrollerOut:clear()
	 MCXoutcomeExportedRoutes = {nil}
	 _incomeRows = 0
	 _outcomeRows = 0
end

function Megacomplex.globalSWtoServer(_bool)
	--Entity():setValue('globalSW',_bool)
	_isWorkingMainSW = _bool
	if _debug then print('_isWorkingMainSW переключен на',_bool) end
end
callable(Megacomplex,'globalSWtoServer')

function Megacomplex.globalSwitcherButton()
	if Entity():getValue('globalSW') then
		Entity():setValue('globalSW',false)
		MCXsettingsMainSwitcher.icon = _iconRed
		MCXsettingsSwitcherLabel.text = 'Комплекс остановлен'
		invokeServerFunction('globalSWtoServer',false)
		if _debug then print('Комплекс выключен') end
	else
		Entity():setValue('globalSW',true)
		MCXsettingsMainSwitcher.icon = _iconGreen
		MCXsettingsSwitcherLabel.text = 'Комплекс функционирует'
		invokeServerFunction('globalSWtoServer',true)
		if _debug then print('Комплекс активирован') end
	end
end

--Находит ресурс и товар каждой пристыкованной станции, инициируя создание соответствующих элементов в интерфейсе мегакомплекса
function Megacomplex.generateIncomeOutcome(_station)
	local scripts = TradingUtility.getTradeableScripts()
	local station = _station
	
	for _, script in pairs(scripts) do

                local tradingStation = nil
				

                    local results = {station:invokeFunction(script, "getSoldGoods")}
					--Megacomplex.debugMsg(tostring(script).."script")
					local callResult = nil
					if script == "/consumer.lua" then
						--if _debug then print("Отсекаю consumer script") end
						callResult = 1
					else
						--if _debug then print("Корректный скрипт. Переключаю") end
						callResult = results[1]
					end
                    if callResult == 0 then
						--print("Прогон скрипта успешен: чем-то торгует!")
                        tradingStation = {station = station, script = script, bought = {}, sold = {}}
                        tradingStation.sold = {}

                        for i = 2, tablelength(results) do
							local _getBool = Megacomplex.getStateFromString(_incomeRows,'income')
							--print(_incomeRows)
							--print('incomeRows =',_incomeRows)
							_incomeRows = _incomeRows + 1
							if _getBool == -1 or _getBool == nil then
								Megacomplex.writeStateToString(_incomeRows,true,'income')
								_getBool = true
								if _debug then print('При сканировании станции создано новое значение центр-переменной') end
							end		
							invokeClientFunction(Player(),"generateLine","income",_station,results[i],Entity(),_getBool)
                        end
                    end
					
					local results = {station:invokeFunction(script, "getBoughtGoods")}
					local callResult = nil
					if script == "/consumer.lua" then
						--if _debug then print("Отсекаю consumer script") end
						callResult = 1
					else
						callResult = results[1]
					end
                    if callResult == 0 then -- call was successful, the station buys goods

                        if tradingStation == nil then
                            tradingStation = {station = station, script = script, bought = {}, sold = {}}
                        end

                        for i = 2, tablelength(results) do
							local _getBool = Megacomplex.getStateFromString(_outcomeRows,'outcome')
							_outcomeRows = _outcomeRows + 1
							if _getBool == -1 or _getBool == nil then
								Megacomplex.writeStateToString(_outcomeRows,true,'outcome')
								_getBool = true
								if _debug then print('При сканировании станции создано новое значение центр-переменной, сектор Outcome') end
							end		
                            --table.insert(tradingStation.bought, results[i])
							invokeClientFunction(Player(),"generateLine","outcome",_station,results[i],Entity(),_getBool)
							--_amountLinesOutcome = _amountLinesOutcome + 1
                        end

                    end
	end
end
callable(Megacomplex,"generateIncomeOutcome")

--Получает массив символов и конвертирует его в строку
function Megacomplex.convertToString(_input)
	local _result = ''
	
	for i=1,#_input do
		_result = _result .. _input[i]
	end

	return _result
end

--возвращает bool из позиции в двоичном ряде. Возвращает -1, если значения не существует
function Megacomplex.getStateFromString(_pos,_type)
	local _string = ''
	
	if _type == 'income' then
		_string = Entity():getValue('MGXincome')
		if _string == nil then return -1 end
	else
		_string = Entity():getValue('MGXoutcome')
		if _string == nil then return -1 end
	end

	if string.sub(_string,_pos+1,_pos+1)=='1' then
		--if _debug then print("getStateFromString Вернул true") end
		return true
	else
		--if _debug then print("getStateFromString Вернул false") end
		return false
	end
end
callable(Megacomplex,'getStateFromString')
--записывает значение кнопки (bool) на соответствующую позицию в общей строке как 0 или 1. Создает сохраняемые строки в customValue, если таковые отсутствуют
--где _pos - позиция элемента в строке, _bool - значение, _type - импорт или экспорт
--ВАЖНО, _pos смещен на +1 из-за того, что перечисление UI элементов идет с нуля, а перечисление элементов строки идет с единицы
function Megacomplex.writeStateToString(_pos,_bool,_type)
	local _getValue = ''
	if _type == 'income' then
		_getValue = Entity():getValue("MGXincome")
		if _getValue == nil then
			Entity():setValue("MGXincome",1)
			_getValue = 1
			print('Пустая центр-переменная, устанавливаю 1')
		end
	else
		_getValue = Entity():getValue("MGXoutcome")
		if _getValue == nil then
			Entity():setValue("MGXoutcome",1)
			_getValue = 1
		end
	end
	
	local _result = Megacomplex.convertToArray(_getValue)
	if _bool then
		_result[_pos+1] = 1
	else
		_result[_pos+1] = 0
	end
	local toSave = Megacomplex.convertToString(_result)
	if _type == 'income' then
		Entity():setValue("MGXincome",toSave)
	else
		Entity():setValue("MGXoutcome",toSave)
	end
	if _debug then print(toSave,"- сохраняемая строка из writeStateToString") end
end
callable(Megacomplex,'writeStateToString')
--Получает строку и разбивает ее на массив символов
function Megacomplex.convertToArray(_input)
	local _result = {}
	_input = tostring(_input)
	-- if _debug then
		-- print('|',_input,'| - основная строка')
		-- print(#_input,"- длина строки?")
	-- end
	for i=1,#_input do
		_result[i] = string.sub(_input,i,i)
		--if _debug then print(_result[i],"_result[i]") end
	end
	return _result
end

--Создает линию в интерфейсе мегакомплекса, содержащую иконку, название (в переводе) товара, его количество, иконку с инфой про станцию и кнопку
function Megacomplex.generateLine(_tab,_sourceStation,_good,_complex,_boolIcon)
	if _good == nil then print('Error: нет переменной _good (generateLine)') return end
	_goodT = getTranslatedGoodName(_good)
	_icon = getGoodAttribute(_good,'icon')
	_cargoAmount = getGoodAttribute(_good,'size')*CargoBay(_complex):getNumCargos(_good)
	_cargoRestricted = _baseRestrCargo/getGoodAttribute(_good,'size')
	_cargoResult = tostring(_cargoAmount)..'/'..tostring(_cargoRestricted)
	local _iconB = ''
	if _boolIcon then
		_iconB = 'data/textures/icons/TRPHon.png'
	else
		_iconB = 'data/textures/icons/TRPHoff.png'
	end
	
	if _tab == 'income' then
	--сегмент получения ресурсов
	local i = _incomeRows
	_incomeRows = _incomeRows + 1
		--Иконка товара
		MCXincomeIcons[i] = MCXscrollerInc:createPicture(Rect(25,_pad*i+25,5,_pad*i+5),_icon)
		--Название товара (с переводом)
			--MCXincomeIcons[i].layer = 0
		MCXincomeGoodsLabel[i] = MCXscrollerInc:createTextField(Rect(30,_pad*i,170,_pad*i+30),_goodT)
			MCXincomeGoodsLabel[i].fontSize = 10
			MCXincomeGoodsLabel[i].tooltip = _good
		--Информация по станции
		MCXincomeStInfo[i] = MCXscrollerInc:createPicture(Rect(175,_pad*i+5,195,_pad*i+25),"data/textures/icons/MCXinfo.png")
			MCXincomeStInfo[i].tooltip = _sourceStation.name
		--Информация по количеству занимаемого места
		MCXincomeAmount[i] = MCXscrollerInc:createTextField(Rect(200,_pad*i,320,_pad*i+30),_cargoResult)
			MCXincomeAmount[i].fontSize = 10		 
		MCXincomeSwitcher[i] = MCXscrollerInc:createRoundButton(Rect(325,_pad*i,350,_pad*i+25),_iconB,"onButtonChangeStateIncome")
		MCXincomeBoundedStation[i] = _sourceStation
		MCXincomeIsAllowed[i] = _boolIcon

	elseif _tab == 'outcome' then
	--сегмент отправки ресурсов
	local i = _outcomeRows
	_outcomeRows = _outcomeRows + 1
		--Иконка товара
		MCXoutcomeIcons[i] = MCXscrollerOut:createPicture(Rect(25,_pad*i+25,5,_pad*i+5),_icon)
		--Название товара (с переводом)
		MCXoutcomeGoodsLabel[i] = MCXscrollerOut:createTextField(Rect(30,_pad*i,170,_pad*i+30),_goodT)
			MCXoutcomeGoodsLabel[i].fontSize = 10
			MCXoutcomeGoodsLabel[i].tooltip = _good
		--Информация по станции
		MCXoutcomeStInfo[i] = MCXscrollerOut:createPicture(Rect(175,_pad*i+5,195,_pad*i+25),"data/textures/icons/MCXinfo.png")
			MCXoutcomeStInfo[i].tooltip = _sourceStation.name
		--Информация по количеству занимаемого места
		MCXoutcomeAmount[i] = MCXscrollerOut:createTextField(Rect(200,_pad*i,320,_pad*i+30),_cargoResult)
			MCXoutcomeAmount[i].fontSize = 10
		MCXoutcomeSwitcher[i] = MCXscrollerOut:createRoundButton(Rect(325,_pad*i,350,_pad*i+25),_iconB,"onButtonChangeStateOutcome")
		MCXoutcomeBoundedStation[i] = _sourceStation
		if MCXoutcomeExportedRoutes[_good] == nil then
			if _boolIcon then MCXoutcomeExportedRoutes[_good] = 1 else MCXoutcomeExportedRoutes[_good] = 0 end
		elseif _boolIcon then
			MCXoutcomeExportedRoutes[_good] = MCXoutcomeExportedRoutes[_good] + 1
		end
		MCXoutcomeIsAllowed[i] = _boolIcon
	end
end

function Megacomplex.switchButtonIcon(_pos,_bool,_type)
	if _type=='income' then
	--print(_bool)
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
			print(MCXoutcomeExportedRoutes[_goodName],'текущее значение routes после декремента для товара',_goodName)
			MCXoutcomeIsAllowed[_pos] = false
		else
			MCXoutcomeSwitcher[_pos].icon = 'data/textures/icons/TRPHon.png'
			MCXoutcomeExportedRoutes[_goodName] = MCXoutcomeExportedRoutes[_goodName] + 1
			print(MCXoutcomeExportedRoutes[_goodName],'текущее значение routes после инкремента для товара',_goodName)
			MCXoutcomeIsAllowed[_pos] = true
		end
	end
end
--Обработка нажатия кнопки на панели импорта
function Megacomplex.onButtonChangeStateIncome(_button)
	local _rectPos = _button.localRect.topLeft.y / _pad --преобразует Y-координату кнопки в ее индекс
	invokeServerFunction('onButtonWorkCore',_rectPos,'income')
end
function Megacomplex.onButtonChangeStateOutcome(_button)
	local _rectPos = _button.localRect.topLeft.y / _pad --преобразует Y-координату кнопки в ее индекс
	invokeServerFunction('onButtonWorkCore',_rectPos,'outcome')
end
--Дальнейшая обработка нажатия кнопок на импорте/экспорте, изменяющая иконку и изменяющая хранящую значения основную переменную корабля
function Megacomplex.onButtonWorkCore(_pos,_type)
	if _type ~= 'income' and _type ~= 'outcome' then print('onButtonWorkCore error: некорректный тип _type') return end
	
	local _buttonState = Megacomplex.getStateFromString(_pos,_type)
	if _buttonState and _buttonState~=-1 then
		Megacomplex.writeStateToString(_pos,false,_type)
		invokeClientFunction(Player(),'switchButtonIcon',_pos,_buttonState,_type)
	elseif _buttonState~=-1 then
		Megacomplex.writeStateToString(_pos,true,_type)
		invokeClientFunction(Player(),'switchButtonIcon',_pos,_buttonState,_type)
	end
end
callable(Megacomplex,'onButtonWorkCore')

--Пересоздает (обновляет) интерфейс каждый раз, когда к комплексу пристыковывается, либо отстыковывается станция. Также вызывается в начале для отрисовки первоначального интерфейса
function Megacomplex.rebuildUI(_complexID,_stationID)
	local _complex = Entity(_complexId)

	if _debug then
		local _testy = _complex:getValue('MGXincome')
		print (_testy,'перестройка через rebuildUI')
	end
	
	local _station = Entity(_stationId)
	if _station.isStation then
		if _debug then print("Инициация интерфейса") end
		--сброс значений
		if _debug then print("Запускаю сброс интерфейса, создаю новый") end
		invokeClientFunction(Player(),"clearMXUI")
		_incomeRows = 0
		_outcomeRows = 0
		--обработка запроса
		_doent = {DockingClamps(_complex):getDockedEntities()}
		for i=1,#_doent do
			if _debug then print("Создаю интерфейс по",i,"пристыкованной станции") end
			Megacomplex.generateIncomeOutcome(Entity(_doent[i]))
		end
	else
		if _debug then print("Проверка не прошла, пристыкованное судно не является станцией") end
	end
	
end
callable(Megacomplex,"rebuildUI")

function Megacomplex.onDockChange(_complexId,_stationId)
		invokeServerFunction("rebuildUI",_complexId,_stationId)
		if _debug then print("Совершена стыковка или отстыковка, передаю управление на скрипт rebuildUI") end
end

function Megacomplex.interactionPossible(playerIndex, option)
    local player = Player()
    if Entity().index == player.craftIndex then
        return true
    end
end
--/run Entity():addScript("data/scripts/complexCraft/complexCore.lua")