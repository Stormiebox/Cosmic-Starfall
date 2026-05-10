package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/entity/?.lua"
package.path = package.path .. ";data/scripts/player/ui/?.lua"

include('utility')
include('callable')
include('Neltharaku')

--namespace cG
cG = {}

_colorG = ColorHSV(150, 64, 100)
_colorY = ColorHSV(60, 94, 78)
_colorR = ColorHSV(16, 97, 84)
_colorB = ColorHSV(240, 40, 100)
_colorC = ColorHSV(264, 60, 100)

local rUnit = 40
local rPaddingX = 15
local rPaddingY = 10

local windowSize = {10,6}

local addNativeIcon = 'data/textures/icons/uiPlus.png'
local addSwitchedIcon = 'data/textures/icons/uiPlayer.png'

local cGwindow = nil
local cGframe = nil

local locLines = {}
	locLines['button_tooltip_expand'] = "Expand combat group window"%_t
	locLines['button_tooltip_collapse'] = "Collapse window"%_t
	locLines['button_tooltip_refresh'] = "Refresh window"%_t
	locLines['button_tooltip_settoinvite'] = "Switch to the mode of adding players"%_t
	locLines['button_tooltip_settogroup'] = "Switch to the current group display mode"%_t
	locLines['button_label_online'] = "Online"%_t
	
	locLines['window_name'] = "Combat group"%_t

local windowName = locLines['window_name']
local mainWindow = {}
--window
--frame
--iconCollapse
--iconRefresh
--buttonInit

local groupUIelements = {}
--icon
--name
--status
--kick

local groupUIadd = {}
--inviteButton
--name

local playersOnline = {}
--name

local _debug = false
function cG.DebugMsg(_text)
	if _debug then
		print('combatGroup|',_text)
	end
end
local Debug = cG.DebugMsg
local TSR = Neltharaku.TableSelfReport

function cG.DoMeow()
	Debug('Meow')
end

--Выполняет поиск индекса элемента в указанной таблице
function cG.getElementByIndex(_element, _table, _pos)
--Сам элемент в _element
--Таблица, в которой искать в _table
--Позиция кнопки в строке в _pos
	local _result = nil
	for _index,_rows in pairs(_table) do
		if _rows[_pos].index == _element.index then
			_result =_index
		end
	end
	return _result
end

function cG.initialize()
	terminate()
	if onServer() then
		--Вызовы для обновления данных
		Server():registerCallback("onPlayerLogIn", "callbackIssuePoint")
		Server():registerCallback("onPlayerLogOff", "callbackIssuePoint")
		Player():registerCallback("onGroupChanged", "callbackIssuePoint")
		Player():registerCallback("onGroupLeaderChanged", "callbackIssuePoint")
		Player():registerCallback("onPlayerEnteredGroup", "callbackIssuePoint")
		Player():registerCallback("onPlayerLeftGroup", "callbackIssuePoint")
	end
	
	if onClient() then
		cG.createWindow()
	end
end

----------------------------------[Служебные]-------------------------------------



----------------------------------[Отрисовка базового интерфейса]-------------------------------------
--Создает основное окно
function cG.createWindow()
	if _debug then
		rUnit = 40
		Debug('createWindow local unit corrected')
	end
	
	--Создание основного окна
	mainWindow['window'],mainWindow['frame'] = Neltharaku.CreateHudWindow(windowName,rUnit,windowSize[1],windowSize[2])
	mainWindow['window'].showCloseButton = false
	mainWindow['window'].moveable = false
	
	--Создание кнопки сворачивания
	local _size = rUnit * 0.7
	mainWindow['collapse'] = Neltharaku.UIcreateCloseButton(mainWindow['window'],_size)
	if not(mainWindow['collapse']) then
		Debug('closeButtonEroro')
	end
	mainWindow['collapse'].icon = 'data/textures/icons/uiCollapse.png'
	mainWindow['collapse'].onPressedFunction = 'collapseWindow'
	mainWindow['collapse'].tooltip = locLines['button_tooltip_collapse']
	
	--Создание кнопки обновления
	mainWindow['refresh'] = Neltharaku.UIcreateCloseButton(mainWindow['window'],_size,2)
	if not(mainWindow['refresh']) then
		Debug('refreshButtonEroro')
	end
	mainWindow['refresh'].icon = 'data/textures/icons/uiUpdate.png'
	mainWindow['refresh'].onPressedFunction = 'serverIssueToRender'
	mainWindow['refresh'].tooltip = locLines['button_tooltip_refresh']
	
	--Создание кнопки "добавить"
	mainWindow['add'] = Neltharaku.UIcreateCloseButton(mainWindow['window'],_size,3)
	if not(mainWindow['add']) then
		Debug('addButtonEroro')
	end
	mainWindow['add'].icon = 'data/textures/icons/uiPlus.png'
	mainWindow['add'].onPressedFunction = 'onAddButtonPress'
	mainWindow['add'].tooltip = locLines['button_tooltip_settoinvite']
	
	--Сохранение значений ширины/высоты основного окна
	windowSize[1] = mainWindow['window'].width
	windowSize[2] = mainWindow['window'].height
	
	--mainWindow['window']:hide()
	cG.collapseWindow(mainWindow['collapse'])
	
	--local anchorPoint = vec2(rUnit*3,rUnit*3)
	--
	--Позиционирует кнопку на экране
	local resX = getResolution().y * 0.06
	local resY = getResolution().y * 0.3
	local anchorPoint = vec2(resX,resY)
	local debugRect = Neltharaku.GetAchoredRect(0,anchorPoint)
	mainWindow['window'].rect = debugRect
end

--Отвечает за сворачивание
function cG.collapseWindow(_button)

	--Смена иконки, функции кнопки
	_button.icon = 'data/textures/icons/uiFederation.png'
	_button.onPressedFunction = 'expandWindow'
	_button.tooltip = locLines['button_tooltip_expand']
	
	--Выключение лишних элементов интерфейса
	mainWindow['window'].caption = ''
	mainWindow['frame']:hide()
	mainWindow['refresh']:hide()
	mainWindow['add']:hide()
	
	--Сворачивание окна
	local _newWidth = rUnit * 0
	local _newHeight = rUnit * 0
	local _anchorPosition = mainWindow['window'].rect.topLeft
	local _collapsePoint = vec2(_anchorPosition.x + _newWidth,_anchorPosition.y + _newHeight)
	local _collapseRect = Rect(_anchorPosition,_collapsePoint)
	
	mainWindow['window'].rect = _collapseRect

	--Смена позиции кнопки
	Neltharaku.UIplaceCloseButton(_button,mainWindow['window'],1)
	
	--Проверка, не улетело ли окно за экран
	if Neltharaku.isOutOfBorder(_button) then
		local anchorPoint = vec2(rUnit*3,rUnit*3)
		local debugRect = Neltharaku.GetAchoredRect(0,anchorPoint)
		mainWindow['window'].rect = debugRect
		Debug('collapseWindow: out of border')
	end
	
end

--Отвечает за разворачивание
function cG.expandWindow(_button)
	
	--Смена иконки, функции кнопки
	_button.icon = 'data/textures/icons/uiCollapse.png'
	_button.onPressedFunction = 'collapseWindow'
	_button.tooltip = locLines['button_tooltip_collapse']
	
	--Разворачивание окна
	local anchorPoint = mainWindow['window'].rect.topLeft
	local secondPoint = vec2(anchorPoint.x + windowSize[1],anchorPoint.y + windowSize[2])
	local expandRect = Rect(anchorPoint,secondPoint)
	mainWindow['window'].rect = expandRect
	
	--Активация элементов интерфейса
	mainWindow['window'].caption = windowName
	mainWindow['frame']:show()
	mainWindow['refresh']:show()
	mainWindow['add']:show()
	
	--Перемещение кнопки сворачивания
	Neltharaku.UIplaceCloseButton(_button,mainWindow['window'],1)
	
	--Уточнение статуса кнопки "добавить"
	cG.addButtonSwitcher()
end

--Входная функция для выполнения обработки слушателей, распределяет тип обновления, основываясь на текущем активном окне
function cG.callbackIssuePoint()

	Debug('callbackIssuePoint attempt')
	--Назначение потока
	if onServer() then 
		invokeClientFunction(Player(callingPlayer),'callbackIssuePoint')
		return
	end

	--Отсекание
	if not(Player()) or not(mainWindow['add']) then
		Debug('callbackIssuePoint failure: nil')
		return 
	end
	
	--Поиск пути обновления: обновление интерфейса группы
	if mainWindow['add'].icon == addNativeIcon then
		Debug('callbackUpdate for "GROUP"')
		cG.serverIssueToRender()
	else
	--Поиск пути обновления: обновление интерфейса новых игроков
		Debug('callbackUpdate for "NEW"')
		--Поиск игроков
		cG.serverScanPlayersOnline()
	end
end

--Обрабатывает доступность кнопки "добавить"
function cG.addButtonSwitcher()

	--Назначение потока
	if onServer() then 
		invokeClientFunction(Player(callingPlayer),'addButtonSwitcher')
		return
	end

	--Переменные
	local pwayer = Player()
	local button = mainWindow['add']
	
	--Отсекание
	if not(pwayer) or not(button) then return end
	
	--Проверка различных условий
	local isParty = Player().group
	local isLeader = false
		if isParty then
			isLeader = (Player().name == Faction(Player().group.leader).name)
		end
	local isAddState = (button.icon == addNativeIcon)
	
	--Установка активности кнопки
	if not(isParty) then
		button.active = true
		return
	end
	
	if isAddState then
		if isLeader then
			button.active = true
		else
			button.active = false
		end
	else
		button.active = true
	end
	
end

----------------------------------[Интерфейс группы]-------------------------------------

--Входная функция отрисовки группы. Выполняет поиск игроков онлайн и отправляет процесс далее
function cG.serverIssueToRender()
	Debug('serverIssueToRender attempt')
	if onClient() then
		invokeServerFunction('serverIssueToRender')
		
		--cG.addButtonSwitcher()
	else
		--Обновление игроков онлайн
		--cG.serverScanPlayersOnline()

		--Продолжение процедуры на стороне клиента
		invokeClientFunction(Player(),'issueToRenderGroup',playersOnline)
	end
end
callable(cG,'serverIssueToRender')

--Сканирует группу игрока (если доступно) и отрисовывает интерфейс.
function cG.issueToRenderGroup(_tableOnline)
	Debug('issueToRenderGroup attempt')
	--TSR(_tableOnline,'_tableOnline')
	--Отсекание
	if onServer() then return end
	
	--Смена статуса кнопок
	mainWindow['add'].icon = 'data/textures/icons/uiPlus.png'
	mainWindow['add'].onPressedFunction = 'onAddButtonPress'
	mainWindow['add'].tooltip = locLines['button_tooltip_settoinvite']
	mainWindow['refresh'].onPressedFunction = 'serverIssueToRender'
	
	--Синхронизация таблицы игроков онлайн
	playersOnline = _tableOnline

	--Очистка интерфейса для отрисовки нового
	mainWindow['frame']:clear()
	groupUIelements = {}

	--Первая итерация переменных
	local party = Player().group
		if not(party) then return end
	local iconLeader = 'data/textures/icons/group-leader-colored.png'
	local iconNotLeader = 'data/textures/icons/group-leader.png'
	local iconKick = 'data/textures/icons/kick.png'

	--Создание важных переменных
		--if party.leader = Faction().index then isLeader = true end
	local partyPlayers = {party:getPlayers()}
	local offsetY = rPaddingY
	local isCallingPlayerLeader = (Player().name == Faction(party.leader).name)
	Debug('isCallingPlayerLeader: '..tostring(isCallingPlayerLeader))
	
	--Выключение кнопки, переключающей на панель приглашения
	if not(isCallingPlayerLeader) and party then
		mainWindow['add'].active = false
	end
	
	--Поиск игроков, запись и создание элементов интерфейса
	for _index,_rows in pairs(partyPlayers) do
	
		--Имя проверяемого
		local _name = Faction(_rows).name
		Debug('-----------'.._name..'-----------')

		--Назначение статусов
		local isOnline = cG.isPlayerOnline(_name)
			Debug('isOnline check: '..tostring(isOnline))
		local isSelf = (_name == Player().name)
			Debug('isSelf check: '..tostring(isSelf))
		local isLeader = (party.leader==_rows)
			Debug('isLeader check: '..tostring(isLeader))
			
		--Вычисление позиций интерфейса
		local _elements = {1,3,3,1}
		local rects = Neltharaku.UIrowAutoplace(_elements,rUnit,rPaddingX,offsetY)
		offsetY = offsetY + rUnit + rPaddingY
		
		--Создание интерфейса
		local _frame = mainWindow['frame']
		--LEADER
		local _leaderButton = _frame:createRoundButton(rects[1],iconNotLeader,'onLeaderChangePressed')
			if isLeader then _leaderButton.icon = iconLeader end
			if not(isCallingPlayerLeader) then _leaderButton.active = false end
			if not(isOnline) then _leaderButton.active = false end
		
		--NAME
		local _nameTF = _frame:createTextField(rects[2],_name)
			_nameTF.fontSize = rUnit * 0.25
			
		--STATE
		local _statusTF = _frame:createTextField(rects[3],locLines['button_label_online'])
			_statusTF.fontSize = rUnit * 0.25
			_statusTF.fontColor = _colorG
			if not(isOnline) then _statusTF:hide() end
			
		--KICK
		local _kickButton = _frame:createRoundButton(rects[4],iconKick,nil)
			_kickButton.active = false
			--Распределение функционала этой кнопки
			
			--Если это сам игрок - кикает себя
			if isSelf then  _kickButton.onPressedFunction = 'onKickSelfPressed' end
			
			--Если игрок - лидер пати, кнопка обращается к удаленному кику
			if not(isSelf) and isCallingPlayerLeader and isOnline then _kickButton.onPressedFunction = 'onKickOtherPressed' end
			
			--Включает кнопку, если лидер или сам игрок
			if (isCallingPlayerLeader and isOnline) or isSelf then _kickButton.active = true end
			--if (not(isSelf) and not(isCallingPlayerLeader)) or not(isOnline) then _kickButton.active = false end
		
		--Сохранение строки интерфейса в таблицу
		table.insert(groupUIelements,{_leaderButton,_nameTF,_statusTF,_kickButton,_name})
	end
	Debug('issueToRenderGroup successful call')
	
	--Уточнение статуса кнопки "добавить"
	cG.addButtonSwitcher()
	
end


----------------------------------[Подфункции интерфейса группы]-------------------------------------
--Создает/обновляет таблицу имен игроков онлайн
function cG.serverScanPlayersOnline(_table)
	--Debug('serverScanPlayersOnline attempt')
	if onServer() then
		playersOnline = {}
		--local scannedPlayers = 
		for _,_rows in pairs({Server():getOnlinePlayers()}) do
			table.insert(playersOnline,_rows.name)
		end
	end
end

--Проверяет имя игрока на совпадение с игроками онлайн
function cG.isPlayerOnline(_name)
	for _,rows in pairs(playersOnline) do
		if _name == rows then return true end
	end
	return false
end


----------------------------------[Интерфейс "добавить"]-------------------------------------
--Инициализация работы кнопки, сканирование игроков онлайн и запуск рендера
function cG.onAddButtonPress()
	Debug('onAddButtonPress attempt')
	if onClient() then
		--Смена статуса кнопок
		mainWindow['add'].icon = 'data/textures/icons/uiPlayer.png'
		mainWindow['add'].onPressedFunction = 'serverIssueToRender'
		mainWindow['refresh'].onPressedFunction = 'onAddButtonPress'
		mainWindow['add'].tooltip = locLines['button_tooltip_settogroup']
		
		--Запуск серверной части скрипта
		invokeServerFunction('onAddButtonPress')
	else
		--Поиск игроков
		cG.serverScanPlayersOnline()
		
		--Запуск проверки и рендера
		invokeClientFunction(Player(),'renderAddTable',playersOnline)
		
		--Проверка статуса кнопки
		cG.addButtonSwitcher()
	end
end
callable(cG,'onAddButtonPress')

--Составление списка игроков онлайн и запуск рендера
function cG.renderAddTable(_table)
	--Очистка фрейма
	mainWindow['frame']:clear()
	groupUIadd = {}
	
	--Синхронизация таблицы игроков онлайн
	playersOnline = _table
	
	--Переменные группы
	local party = Player().group
	local playersInParty = {}
	local possiblePlayers = {}
	local iconInvite = 'data/textures/icons/uiPlus.png'
	local self = Player().name
	
	--Поиск подходящих игроков
	for _,_rows in pairs(playersOnline) do
		if not(cG.isInSameGroup(_rows)) then
			table.insert(possiblePlayers,_rows)
		end
	end
	
	--TSR(possiblePlayers,'possiblePlayers')
	
	--Рендер списка игроков
	local offsetY = rPaddingY
	local _frame = mainWindow['frame']
	for _index,_rows in pairs(possiblePlayers) do
		local _elements = {1,4}
		local rects = Neltharaku.UIrowAutoplace(_elements,rUnit,rPaddingX,offsetY)
		offsetY = offsetY + rUnit + rPaddingY
		
		--INVITEBUTTON
		local _inviteButton = _frame:createRoundButton(rects[1],iconInvite,'onPlayerInvitePressed')
		
		--PLAYERNAME
		local _nameTF = _frame:createTextField(rects[2],_rows)
			_nameTF.fontSize = rUnit * 0.4
			
		--Запись интерфейса в таблицу
		table.insert(groupUIadd,{_inviteButton,_nameTF})
	end
	
	--Проверка статуса кнопки
	cG.addButtonSwitcher()
end


----------------------------------[Функционал приглашения игрока]-------------------------------------

--Обрабатывает запрос на добавление игрока
function cG.onPlayerInvitePressed(_button)

	--Переключение режима кнопки
	_button.icon = 'data/textures/icons/submit.png'
	_button.active = false

	--Формирование значений для запроса
	local _buttonIndex = cG.getElementIndex(_button, groupUIadd, 1)
	local _name = groupUIadd[_buttonIndex][2].text
	
	--Передача запроса на сервер
	if #_name>0 then
		invokeServerFunction('serverPlayerInvite',_name)
	end
end

--исполняет команду приглашения на стороне сервера и рассылает "приглашения" игрокам
function cG.serverPlayerInvite(_name)

	Server():addChatCommand(Player(),'/invite '.._name)
	local _targetPlayer = Galaxy():findPlayer(_name)
	Debug('_targetPlayer name is '.._name)
	local _index = _targetPlayer.index
	invokeFactionFunction(_index, false, 'combatGroup', 'playerOperateInvite', _name)

end
callable(cG,'serverPlayerInvite')

--Инициирует инвайт на локальном клиенте
function cG.playerOperateInvite(_name)

	--Перевод потока
	if onServer() then
		invokeClientFunction(Player(callingPlayer),'playerOperateInvite')
		return
	end

	Player():invokeFunction('alertCore','entityGroupInvite')

end

----------------------------------[Функционал передачи лидера]-------------------------------------

--Обрабатывает нажатие передачи лидера
function cG.onLeaderChangePressed(button,name)
	Debug('onLeaderChangePressed attempt')

	--Серверный поток: выполнение команды
	if onServer() then
		--Отсекание
		if not(name) then return end
		
		--Выполнение команды
		Server():addChatCommand(Player(),'/leader '..name)
		return
	end
	
	--Клиентский поток: генерация команды
	--Отсекание
	if not(button) then return end
	
	--Назначение переменных
	local _pwayerIndex = cG.getElementIndex(button,groupUIelements,1)
	Debug('_pwayerIndex is '..tostring(_pwayerIndex))
	local name = groupUIelements[_pwayerIndex][2].text
	--Запуск серверной части скрипта
	invokeServerFunction('onLeaderChangePressed',nil,name)
end
callable(cG,'onLeaderChangePressed')

----------------------------------[Функционал кика игрока]-------------------------------------

--Обрабатывает нажатие кнопки "кик" другого игрока
function cG.onKickOtherPressed(button,name)
	Debug('onKickOtherPressed attempt')

	--Серверный поток: выполнение команды
	if onServer() then
		--Отсекание
		if not(name) then return end
		
		--Удаленный запуск команды
		local _targetPlayer = Galaxy():findPlayer(name)
		Debug('_targetPlayer name is '..name)
		local _index = _targetPlayer.index
		invokeFactionFunction(_index, false, 'combatGroup', 'remoteKick')
		return
	end
	
	--Клиентский поток: генерация команды
	--Отсекание
	if not(button) then return end
	
	--Назначение переменных
	local _pwayerIndex = cG.getElementIndex(button,groupUIelements,4)
	Debug('_pwayerIndex is '..tostring(_pwayerIndex))
	local name = groupUIelements[_pwayerIndex][2].text
	--Запуск серверной части скрипта
	invokeServerFunction('onKickOtherPressed',nil,name)
end
callable(cG,'onKickOtherPressed')

--Исполняет запуск команды "кик" на стороннем клиенте
function cG.remoteKick()
	
	--Отсекание
	if not(Player()) then return end
	
	--Разделение потоков
	if onServer() then
	
		--Запуск команды чата
		Server():addChatCommand(Player(),'/leave')
	
		--Перевод потока для вызова алерта
		invokeClientFunction(Player(callingPlayer),'remoteKick')
	else
	
		--Вызов алерта
		Player():invokeFunction('alertCore','playerGroupKick')
		--Обновление кнопки
		cG.addButtonSwitcher()
	end
end

function cG.onKickSelfPressed()

	--Отсекание
	if not(Player()) then return end
	
	--Исполнение команды на сервере
	if onServer() then
		Server():addChatCommand(Player(),'/leave')
		--Обновление кнопки
		cG.addButtonSwitcher()
		return
	end
	
	--Перевод потока на клиенте
	invokeServerFunction('onKickSelfPressed')
	
end
callable(cG,'onKickSelfPressed')

----------------------------------[Подфункции]-------------------------------------
--Сверяет кнопку с таблицей, возвращая ее индекс
function cG.getElementIndex(_element, _table, _pos)
	local _result = nil
	for _index,_rows in pairs(_table) do
		if _rows[_pos].index == _element.index then
			_result =_index
		end
	end
	return _result
end

--Проверяет игрока на наличие в таблице онлайна
function cG.isOnline(_name)
	for _,_rows in pairs(playersOnline) do
		if _name == Player().name then Debug('isOnline self') end
		if playersOnline == _rows then return true end
	end
	
	return false
end

--Проверяет, в одной ли группе указанный игрок с текущим
--Также не возвращает TRUE, есл имя совпадает с именем основного игрока
function cG.isInSameGroup(_name)
	if Player().name == _name then
		Debug('isInSameGroup: same as main player alert')
		return true
	end
	
	local party = Player().group
	if not(party) then return false end
	
	--Получаем индексы игроков
	local indPwayers = {party:getPlayers()}
	--Меняем на имена
	local tableNames = {}
	for _,_rows in pairs(indPwayers) do
		table.insert(tableNames,Player(_rows))
	end
	--TSR(tableNames,'isInSameGroup')
	
	--Сверяем наличие и завершаем, если совпадает
	for _,_rows in pairs(tableNames) do
		if _name == tableNames then return true end
	end
	
	return false
end

--Проверяет наличие имени в указанной таблице
function cG.isPlayerNameInTable(_table,_name)

	--Проверка наличия имени в таблице
	for _,_rows in pairs(_table) do
		local name = Faction(_rows).name
		if _name == name then return true end
	end

	return false
end