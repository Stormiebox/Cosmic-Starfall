package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Neltharaku')
include('ColorLib')

local colors = {}
	colors['buff'] = getColor('auracore_buff')
	colors['debuff'] = getColor('auracore_debuff')
	colors['neutral'] = getColor('auracore_standby')

-- namespace auraCore
auraCore = {}

local _debug = false 
function auraCore.DebugMsg(_text)
	if _debug then
		print('auraCore|',_text)
	end
end

local self = auraCore

local Debug = self.DebugMsg

local sf = string.format



local locLines = {}
	locLines['activeauras'] = "Active effects"%_t
	--locLines['sec'] = "s"%_t

local activeAuras = {}
--1 signature(str)
--2 effect strength(str)
--3 effect length(int)
--4 effect name(str)
--5 aura type(str)
--6 source name(str)
--7 target name(str)
--8 icon(str)
--9 isAura(bool)
--10 isUniq(bool)

--AuraType
	--debuff
	--buff
	--neutral

local UIanchor = nil
local rUnit = nil
local containerSize = nil

local containerUI = nil
local containerDynamicUI = nil
local containerLabelUI = nil
--local auraLinesUI = {}

function auraCore.initialize()
	Debug('--------initialize--------')
	if onClient() then
		--Переменные
		UIanchor = vec2(getResolution().x*0.25,getResolution().y*0.15)
		rUnit = math.min(getResolution().x,getResolution().y) * 0.05
		containerSize = rUnit*4
		
		
		--Действия
		self.CreateContainer()
	end
end

function auraCore.getUpdateInterval()
	return 1
end

function auraCore.update(timeStep)
	if onClient() then
		self.TimerOperate(activeAuras)
		self.ShowAuras()
		
	end
end

--===========================[Функции интерфейса]===================================

function auraCore.CreateContainer()

	--Переменные
	Debug(string.format("rUnit is %i",rUnit))
	local windowPoint =  vec2(UIanchor.x+containerSize,UIanchor.y+rUnit)
	local windowRect = Rect(UIanchor,windowPoint)
	
	--Создание контейнера
	containerUI = Hud():createContainer(windowRect)
	--containerUI:createFrame(Rect(containerUI.size))
	
	--Создание LABEL
	local labelAnchor = vec2(rUnit*0.05,rUnit*0.05)
	local labelTextSize = rUnit * 0.25

	containerLabelUI = containerUI:createLabel(labelAnchor,locLines['activeauras'],labelTextSize)
	
	--Создание dynamicContainer
	containerDynamicUI = containerUI:createContainer(Rect(containerUI.size))
	

end

function auraCore.ShowAuras()
	--Отсекание
	if not(containerDynamicUI) or not(containerLabelUI) then return end
	
	--Создание обзорной таблицы
	local tableToShow = {}
	
	--Очистка интерфейса
	containerDynamicUI:clear()
	
	local yPos = containerLabelUI.height
	
	--Анализ данных activeAuras
	for _,rows in pairs(activeAuras) do
	
		local okToShow = self.isOkToShow(rows)
		
		if okToShow then
			--Debug(sf("ok to show: %s",rows[1]))
			table.insert(tableToShow,rows)
		end
		
	end
	
	for _,_rows in pairs(tableToShow) do
		yPos = self.DrawAuraLine(_rows,yPos)
	end
	
	--Переключение главного label
	if #tableToShow>0 then
		containerLabelUI:show()
	else
		containerLabelUI:hide()
	end

end

--Проверяет, можно ли показывать
function auraCore.isOkToShow(_table)
	if Player().craft ~= nil then
		local currentCraftName = Player().craft.name
		
		if _table[7] == currentCraftName then
			return true
		end
		
		return false
	end
end

--Работа таймеров аур, ликвидация устаревших
function auraCore.TimerOperate(_table)

	for _index,_rows in pairs(activeAuras) do
		local timer = _rows[3]
		_rows[3] = math.max(_rows[3] - 1,0)
		
		--Стереть, если таймер 0
		if _rows[3] == 0 then
			table.remove(activeAuras,_index)
		end
	end
	
end

--Рисует строку ауры
function auraCore.DrawAuraLine(_table,posY)
	
	local iconPath = _table[8]
	
	local xPad = rUnit*0.05
	local yPad = rUnit*0.05 + posY
	local sizeMod = rUnit * 0.3
	local textSize = rUnit * 0.25
	
	--Создание текстовой линии
	local effectSTR = _table[2]
	local effectLNG = _table[3]
	local effectNAME = _table[4]
	local auraType = _table[5]
	local sourceName = _table[6]
	local targetName = _table[7]
	local isAura = _table[9]

	--Для аур длительность не отображается
	if isAura then effectLNG = "" end
	
	--источник не отображается для самого себя, или дорисовать скобочки + пробел
	if targetName == sourceName then
		sourceName = ""
	else
		sourceName = string.format(" (%s)",sourceName)
	end
	
	--Если сила равна "0" - стереть, иначе пробельчик
	if effectSTR == '0' or effectSTR == 0 then
		effectSTR = ''
	else
		effectSTR = string.format("%s ",effectSTR)
	end
	
	--Назначение цвета аур
	local _color = colors[auraType]
	
	--Генерация строки времени
	if not(isAura) then
		local seconds = effectLNG % 60
			if seconds<10 then
				seconds = string.format("0%i",seconds)
			else
				seconds = tostring(seconds)
			end
		local minutes = string.format("%i", math.floor(effectLNG / 60))
		
		effectLNG = string.format(" %s:%s",minutes,seconds)
	end
		
	
	--генерация строки
	local textLine = string.format("%s%s%s%s",effectSTR,effectNAME%_t,sourceName,effectLNG)
	
	--icon
	local iconAnchor = vec2(xPad,yPad)
	local iconPoint = vec2(iconAnchor.x + sizeMod,iconAnchor.y + sizeMod)
	local iconRect = Rect(iconAnchor,iconPoint)
	local pic = containerDynamicUI:createPicture(iconRect,iconPath)
		pic.isIcon = true
		pic.color = _color
		
	--text
	local textAnchor = vec2(iconPoint.x + xPad,yPad)
	local textPoint = vec2(textAnchor.x + sizeMod*20,textAnchor.y + sizeMod)
	local textRect = Rect(textAnchor,textPoint)
	local txt = containerDynamicUI:createLabel(textRect,textLine,textSize)
		txt.color = _color
	
	return textAnchor.y + sizeMod
	
end

--===========================[Функции обработки запросов]===========================

--Проверяет и добавляет эффект в общую таблицу
function auraCore.ApplyAura(_table)
	
	if onServer() then
		invokeClientFunction(Player(),'ApplyAura',_table)
		return
	end
	
	--Проверка и отсекание
	if not(self.isAuraCorrect(_table)) then
		return 1
	end
	
	--Анализ данных
	local isDuplicate,isPossibleToDuplicate = self.isAuraUniqOrCorrect(_table)
	local okToCreate = (not(isDuplicate) or isPossibleToDuplicate)
	
	if okToCreate then
		table.insert(activeAuras,_table)
		Debug(string.format('Successful created %s',_table[1]))
	end
	
	--Обработка аур без таймера (аур постоянного апдейта)
	self.isAuraToUpdate(_table)
	
end

--Прерывает действие ауры
function auraCore.InterruptAura(signature,sourcename)
	if onServer() then
		invokeClientFunction(Player(),'InterruptAura',signature,sourcename)
	end

	for _ind,_rows in pairs(activeAuras) do
		local isFound = ((_rows[1] == signature) and (_rows[6] == sourcename))
		if isFound then
			table.remove(activeAuras,_ind)
			Debug('table removed')
		end
	end
end

--Проверяет корректность поступившего эффекта
function auraCore.isAuraCorrect(_table)

	if _table[1]==nil then
		Debug('isAuraCorrect: signature is nil')
		return false
	end
	
	if _table[2]==nil then
		Debug('isAuraCorrect: effectSTR is nil')
		return false
	end
	
	if _table[3]==nil then
		Debug('isAuraCorrect: effectLNG is nil')
		return false
	end
	
	if _table[4]==nil then
		Debug('isAuraCorrect: effectNAME is nil')
		return false
	end
	
	if _table[5]==nil then
		Debug('isAuraCorrect: auraType is nil')
		return false
	end
	
	if _table[6]==nil then
		Debug('isAuraCorrect: sourceName is nil')
		return false
	end
	
	if _table[7]==nil then
		Debug('isAuraCorrect: targetName is nil')
		return false
	end
	
	if _table[8]==nil then
		Debug('isAuraCorrect: icon is nil')
		return false
	end
	
	if _table[9]==nil then
		Debug('isAuraCorrect: isAura is nil')
		return false
	end
	
	if _table[10]==nil then
		Debug('isAuraCorrect: isUniq is nil')
		return false
	end
	
	return true
	--1 signature(str)
	--2 effect strength(int)
	--3 effect length(int)
	--4 effect name(str)
	--5 aura type(str)
	--6 source name(str)
	--7 target name(str)
	--8 icon(str)
	--9 isAura(bool)
	--10 isUniq(bool)
end


--1 signature(str)
--2 effect strength(str)
--3 effect length(int)
--4 effect name(str)
--5 aura type(str)
--6 source name(str)
--7 target name(str)
--8 icon(str)
--9 isAura(bool)
--10 isUniq(bool)

--Проверяет на дубликаты и на возможность создавать дубликаты
function auraCore.isAuraUniqOrCorrect(_table)

	local signature = _table[1]
	local sourceName = _table[6]
	local targetName = _table[7]
	local isUniq = _table[10]
	local effectSTR = _table[2]
	
	local isUniqDuplicateCheck = false --если true - аура уже действует на корабль
	local isOkToDuplicate = false --если true - аура уже действует из другого источника, можно добавить
	--local isOkToEnhance = false --если true - есть дубликат, но ауру можно усилить, заменив более сильной
	--local enhanceID = nil --ID функции, которую следует заменить
	
	--Если есть флаг "уникальный" и находится подобная аура на том же корабле - ошибка уникальности
	if isUniq then
		
		for _,_rows in pairs(activeAuras) do
			local isSameTargetName = (targetName == _rows[7])
			local isSameSignature = (signature == _rows[1])
			
			if isSameTargetName and isSameSignature then
				isUniqDuplicateCheck = true
			end
		end
		
	end
	
	--Проверка возможности корректной дупликации
	if not(isUniq) then
		
		isOkToDuplicate = true
		
		for _,_rows in pairs(activeAuras) do
			local isSameTargetName = (targetName == _rows[7])
			local isSameSignature = (signature == _rows[1])
			local isSameSource = (sourceName == _rows[6])
			
			if isSameTargetName and isSameSignature and isSameSource then
				Debug('same target, signature, source')
				isOkToDuplicate = false
			end
		end
		
	end

	return isUniqDuplicateCheck,isOkToDuplicate
end

--Проверяет, если эта аура "без таймера" - апдейтит ее
function auraCore.isAuraToUpdate(_table)

	--Отсекание лишних итераций не для аур
	local isAura = _table[9]
	if not(isAura) then return false end
	
	--Переменные
	local signature = _table[1]
	local sourceName = _table[6]
	local targetName = _table[7]
	local effectSTR = _table[2]
	
	--Обработка
	for _ind,_rows in pairs(activeAuras) do
		local isEverythingSame = ((signature == _rows[1]) and (sourceName == _rows[6]) and (targetName == _rows[7]))
		if isEverythingSame then
			Debug(sf("UpdateAura %s",signature))
			_rows[2] = effectSTR
			_rows[3] = 1.5
		end
	end
end