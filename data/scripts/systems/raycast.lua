package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/neltharaku/?.lua"
--include ("basesystem")
include ('utility')
include('callable')
include("Neltharaku")

local _debug = false
local _myName = ''
local _colorG = ColorHSV(150, 64, 100)
local _colorY = ColorHSV(60, 94, 78)
local _colorR = ColorHSV(16, 97, 84)
local _colorB = ColorHSV(240, 40, 100)
local _colorC = ColorHSV(264, 60, 100)

local TSR = Neltharaku.TableSelfReport

function isInRangeV3(v1,v2,range)
	local modRange = (range*100)*(range*100)
	local calcDist2 = distance2(v1,v2) * 0.85
	if calcDist2 <= modRange and calcDist2>0 then
		return true
	else
		return false
	end
end

--Возвращает толщину луча, проверяя дистанцию до цели и прочие параметры
function inRange(_row)
	local _posSRC = _row[2].translationf
	local _posTGT = _row[3].translationf
	local _dist = _row[5]
	local _bW = _row[6]

	local modRange = (_dist*100)*(_dist*100)
	local calcDist2 = distance2(_posSRC,_posTGT) * 0.85

	if calcDist2 <= modRange and calcDist2>0 then
		return _bW
	else
		return 0.1
	end
end

function DebugMsg(_text)
	if _debug then
		print(_text)
	end
end
local Debug = DebugMsg

local laserTable = {}
	--type
	--source
	--target
	--color
	--distance
	--baseWidth
	--laser
local fxTable = {}
local sphereTable = {}
	--type
	--source
	--radius
	--ivec2radius
	--color
	--intensity
	--reflectivity
	--reflColor
	--sphere
local fxsTable = {}

function tableSelfReport(_table)
	for _index,_value in pairs(_table) do
		print(_myName,_index,' | ',_value)
	end
end

--Проверяет, если источник и цель имеют единого владельца, а также данный объект является целью
function checkDoubleCast(_row)
	local _sourceID = _row[2].id
	local _targetID = _row[3].id
	local isTarget = Entity().id==_row[3].id
	if (Player(_sourceID).name==Player(_targetID).name) and isTarget then return true end
	return false
end

--Быстро проверяет строку лазера на наличие nil
function LaserTableSelfValid(_row)
	--Neltharaku.TableSelfReport(_row)
	if _row[1]==nil then
		--DebugMsg(_myName..'laserSelfValid - invalid type')
		return false
	end
	if not(valid(_row[2])) or (_row[2].translationf==nil) then
		--DebugMsg(_myName..'laserSelfValid - invalid source')
		return false
	end
	if not(valid(_row[3])) or (_row[3].translationf==nil) then
		--DebugMsg(_myName..'laserSelfValid - invalid target')
		return false
	end
	if _row[4]==nil then
		--DebugMsg(_myName..'laserSelfValid - invalid color')
		return false
	end
	if _row[5]==nil then
		--DebugMsg(_myName..'laserSelfValid - invalid distance')
		return false
	end
	if _row[6]==nil then
		--DebugMsg(_myName..'laserSelfValid - invalid baseWidth')
		return false
	end

	return true
end

--Аналог для сферки
function SphereTableSelfValid(_row)

	if _row[1]==nil then
		DebugMsg(_myName..'SphereSelfValid - invalid type')
		return false
	end
	if not(valid(_row[2])) or (_row[2].translationf==nil) then
		DebugMsg(_myName..'SphereSelfValid - invalid source')
		--DebugMsg(_row[2].name)
		return false
	end
	if not(_row[3]) or _row[3] <= 0 then
		DebugMsg(_myName..'SphereSelfValid - invalid radius')
		return false
	end
	if not(_row[4]) or _row[4] == ivec2(0,0) then
		DebugMsg(_myName..'SphereSelfValid - invalid iRadius')
		return false
	end
	if _row[5]==nil then
		DebugMsg(_myName..'SphereSelfValid - invalid color')
		return false
	end
	if not(_row[6]) or _row[6]<=0 then
		DebugMsg(_myName..'SphereSelfValid - invalid intensity')
		return false
	end
	if not(_row[7]) or _row[7]<=0 then
		DebugMsg(_myName..'SphereSelfValid - invalid reflectivity')
		return false
	end
	if _row[8]==nil then
		DebugMsg(_myName..'SphereSelfValid - invalid reflColor')
		return false
	end

	return true
end

function LaserOperate()
	--Просмотр таблицы таблиц
	for _index,_table in pairs(laserTable) do
		--Проверка на существование лазера (должна быть цель, должен быть источник)
		if LaserTableSelfValid(_table) then
			local _type = _table[1]
			local _posSRC = _table[2].translationf
			local _posTGT = _table[3].translationf
			local _distance = _table[5]
			local _width = _table[6]
			--Проверка наличия лазера в списке анимаций
			if not(fxTable[_type]) then
				--Создание при необходимости (не может создать, если данный объект является целью и владельцы совпадают во избежание дубля лазеров)
				if not(checkDoubleCast(_table)) then
					Debug('laser created of type '.._type..' for entity '..Entity().name)
					fxTable[_type] = Sector():createLaser(_posSRC, _posTGT, _table[4] or _colorR, _table[6] or 2)
					fxTable[_type].collision = false
				end
			else
				--Обработка перемещения ИСКЛЮЧИТЕЛЬНО. Толщина лазера и прочее обрабатывается в другой функции
				fxTable[_type].from = _posSRC
				fxTable[_type].to = _posTGT
			end
		-- else
			-- if _table[1] then
				-- if fxTable[_table[1]] then
					-- fxTable[_table[1]].maxAliveTime = 0.2
					-- fxTable[_table[1]] = nil
					-- Debug('kill laser of type '..tostring(_table[1]))
				-- end
			-- end
		end
	end
end

--Выполняет обработку сфер
function SphereOperate()
	--DebugMsg('sphereOperate')
	--Проверка наличия сфер
	for _index,_rows in pairs(sphereTable) do
	
		--Отсекание некорректных вызовов
		if not(SphereTableSelfValid(_rows)) then
			DebugMsg('sphereOperate failure: incorrect row of index '.._index)
			return 
		end
		
		--Извлечение значений
		--local entititity = _rows[2]
		
		local _type = _rows[1]
		local _source = _rows[2].position
		local _radius = _rows[3]
		local _ivec2radius = _rows[4]
		local _color = _rows[5]
		local _intensity = _rows[6]
		local _reflectivity = _rows[7]
		local _reflColor = _rows[8]
		
		--Проверка наличие существования данной сферы
		if fxsTable[_type] == nil then
			
			--Создание сферы, если не найдена
			fxsTable[_type] = Sector():createRefractionSphere(_radius, _ivec2radius)
			fxsTable[_type].color = _color
			fxsTable[_type].intensity = _intensity
			fxsTable[_type].reflectivity = _reflectivity
			fxsTable[_type].reflectivityColor = _reflColor
			DebugMsg('sphereOperate: sphere created of type '.._type)
			
		else
		
			--Перемещение сферы
			fxsTable[_type].position = _source
		end
	end
end

--Проверяет валидность сферы. Удаляет ее, если не нужна
function fxSphereSelfValid()
	for _index,_rows in pairs(fxsTable) do
		local _valid = false
		for _,_rows2 in pairs(sphereTable) do
			--Если находит совпадение по типу (сфера действительно существует), то возвращает true
			if _rows2[1]==_index then
				_valid = true
			end
		end

		if not(_valid) then
			DebugMsg(_myName..'sphere removed: '.._index)
			Sector():removeRefractionObject(_rows)
			fxsTable[_index] = nil
		end
	end
end

--Проверяет, есть ли у лазера связанная запись в основной таблице. Если нет - удаляет его. Помимо этого обновляет толщину луча в зависимости от дистанции
function fxLaserSelfValid()
	if #laserTable~=#fxTable then
		--Debug('#fxTable = '..tostring(#fxTable))
		--Debug('#laserTable = '..tostring(#laserTable))
		--TSR(laserTable,'laserTable')
		--TSR(fxTable,'fxTable')
	end
	for _key,_rows in pairs(fxTable) do
		local _valid = false
		local _inRange = 0
		for _,_rows2 in pairs(laserTable) do
			--Если находит совпадение (лазер существует), то вычисляет дистанцию для рассчета толщины лазера
			if _rows2[1]==_key then
				_valid = true
				_inRange = inRange(_rows2)
			end
		end

		if _valid then
			--Обновляет толщину луча
			_rows.width = _inRange
		else
			DebugMsg(_myName..'laser deleted from sector: '.._key)
			_rows.maxAliveTime = 0.1
			Sector():removeLaser(_rows)
			--fxTable[_key].maxAliveTime = 0.1
			fxTable[_key] = nil
		end
	end
end

function isEntityCorrect(_entity)

	--Проверка валидности
	if not(valid(_entity)) then 
		Debug('isEntityCorrect failure: not entity')
		return false
	end
	
	local name = _entity.name
	--Проверка имени (почему то тоже нужна, иначе выдает ошибку. Кек)
	if not(name) then
		Debug('isEntityCorrect failure: not entity')
		return false
	end
	
	local eroro = 'isEntityCorrect('..name..') failure: '
	--Проверка наличия
	if not(_entity) then 
		Debug(eroro..'not entity')
		return false
	end
	
	if Sector():getEntity(_entity.id) == nil then
		Debug(eroro..'cant pick entity in sector')
		return false
	end
	--Проверка хп
	if Durability(_entity.id).durability==0 then
		Debug(eroro..'zero durability')
		return false 
	end
	return true
end

---------------------------------------------------------------------------------------------------
function initialize()
	if Entity().name then
		_myName = 'Raycast('..Entity().name..'): '
	end
	Entity():registerCallback("onJump", "ClearGraphicsOnJump")
end

function getUpdateInterval()
	if onClient() then
		if (#laserTable + #sphereTable)>0 then
			return 0.01
		else
			return 1
		end
	else
		return 1
	end
end

function update(timeStep)
	if onClient() then
		--DebugMsg('sphereTable length = '..tostring(#sphereTable))
		if #laserTable>0 then LaserOperate() end
		if #sphereTable>0 then SphereOperate() end
	else
		AnalyseTable()
	end
end

--Функция проверяет поступающую со стороны информацию на корректность и разрешает обновление таблиц
function importDataCheck(_table)
	--Проверка наличия типа
	if not(_table[1]) then
		DebugMsg('raycast: laser creation rejected: type invalid')
		return false
	end
	--Одиночная проверка источника
	if not(_table[2]) or not(_table[2].type==EntityType.Ship or _table[2].type==EntityType.Station) or not(valid(_table[2])) then
		DebugMsg('raycast: laser creation rejected: source invalid')
		return false
	end
	--Одиночная проверка цели
	if not(_table[3]) or not(_table[3].type==EntityType.Ship or _table[3].type==EntityType.Station) or not(valid(_table[3])) then
		DebugMsg('raycast: laser creation rejected: target invalid')
		return false
	end
	--Проверка цвета
	if not(_table[4]) then
		DebugMsg('raycast: laser creation rejected: color invalid')
		return false
	end
	--Проверка расстояния
	if not(_table[5]) or _table[5]<1 then
		DebugMsg('raycast: laser creation rejected: distance invalid')
		return false
	end
	--Проверка упитанности
	if not(_table[6]) or _table[6]<0 then
		DebugMsg('raycast: laser creation rejected: width invalid')
		return false
	end
	--Проверка совпадения цель-источник
	if _table[2].index==_table[3].index then
		DebugMsg('raycast: laser creation rejected: source and target are same')
		return false
	end
	--Проверка совпадения лазера по связи тип-цель
	for _,_rows in pairs(laserTable) do
		if (_rows[1] == _table[1]) and (_rows[3].index==_table[3].index) then
			DebugMsg('raycast: laser creation rejected: another laser detected')
			return false
		end
	end
	DebugMsg('Laser creation check successful')
	return true
end

--Проверяет, нет ли сферы такого типа уже
function sphereIsUniq(_type)
	for _,_rows in pairs(sphereTable) do
		if (_rows[1] == _type) then
			DebugMsg('raycast: sphere creation rejected: another sphere detected')
			return false
		end
	end
	
	return true
end

--Функция инициирует попытку импорта
function setLaser(_type,_sourceship,_targetship,_color,_distance,_baseWidth)
	if onClient() then return end
	--Установка переменных
	local _importedRow = {_type,_sourceship,_targetship,_color,_distance,_baseWidth}
	--Проверка корректности значений и импорт в таблицу лазеров
	if importDataCheck(_importedRow) then
		table.insert(laserTable,_importedRow)
		DebugMsg(_myName..'laser imported successful|'..tostring(#laserTable))
		AnalyseTable()
		return 0
	else
		return 1
	end
end

function setSphere(_type,_source,_radius,_ivec2radius,_color,_intensity,_reflectivity,_reflColor)
	local _importedTable = {_type,_source,_radius,_ivec2radius,_color,_intensity,_reflectivity,_reflColor}
	
	--Проверка на совпадения
	if not(sphereIsUniq(_type)) then
		DebugMsg('setSphere failure: same sphere of type detected')
		return 1 
	end
	
	--Проверка валидности и заполение таблицы
	if SphereTableSelfValid(_importedTable) then
		table.insert(sphereTable,_importedTable)
		DebugMsg(_myName..'sphere imported successful|'..tostring(#sphereTable))
		AnalyseSphereTable()
	else
		DebugMsg('setSphere failure: something incorrect')
		return 1
	end
	
	return 0
end

--Функция выполняет удаление со стороны
function removeLaser(_type)
	if onClient() then return end
	DebugMsg(_myName..'removeLaser attempt of type '.._type)
	AnalyseTable(_type)
end

function RemoveSphere(_type)
	--Смена потока
	if onClient() then 
		invokeServerFunction('RemoveSphere',_type)
		return
	end
	DebugMsg(_myName..'removeSphere attempt of type '.._type)
	AnalyseSphereTable(_type)
end
callable(nil,'RemoveSphere')


--Функция выполняет проверку актуальности лазеров и обновляет таблицу при необходимости. Отправка индекса удаляет соответствующую строку
function AnalyseTable(_toRemoveIndex)
	for _index,_rows in pairs(laserTable) do
	
		--Сегмент лазера
		if not(isEntityCorrect(_rows[2])) or not(isEntityCorrect(_rows[3])) then
			DebugMsg(_myName..'laser removed from table (incorrect source or target) with type '.._rows[1])
			table.remove(laserTable,_index)
		end
		
		if _toRemoveIndex and (_toRemoveIndex == _rows[1]) then
			table.remove(laserTable,_index)
			DebugMsg(_myName..'remove laser from table (marked for removal)|'..tostring(#laserTable))
		end
		
		
	end
	if not(Player(callingPlayer)) then return end
	invokeClientFunction(Player(callingPlayer),'SyncToClient',laserTable)
end

--Выполняет проверку актуальности сферок. Отправка индекса удаляет соответствующую строку
function AnalyseSphereTable(_toRemoveIndex)
	for _index,_rows in pairs(sphereTable) do
	
		if not(isEntityCorrect(_rows[2])) then
			DebugMsg(_myName..'sphere removed from table (incorrect source)')
			table.remove(sphereTable,_index)
		end
		if _toRemoveIndex and (_toRemoveIndex == _rows[1]) then
			table.remove(sphereTable,_index)
			DebugMsg(_myName..'remove sphere from table (marked for removal)|'..tostring(#sphereTable))
		end

	end
	if not(Player()) then return end
	invokeClientFunction(Player(),'SyncToClient',nil,sphereTable)
end

function SyncToClient(_table,_sphereTable)
	--Debug('SyncToClient attempt')
	if _table then laserTable = _table end
	if _sphereTable then sphereTable = _sphereTable end
	fxLaserSelfValid()
	fxSphereSelfValid()
	getUpdateInterval()
end

--При прыжке выключает графику и у себя, и у источника/цели
function ClearGraphicsOnJump()
	Debug('ClearGraphicsOnJump attempt')
	
	-- for _,_rows in pairs(laserTable) do
		-- local typeFX = _rows[1]
		-- local source = _rows[2]
		-- local target = _rows[3]
		
	-- end
	
	laserTable = {}
	sphereTable = {}
	invokeClientFunction(Player(),'SyncToClient',laserTable,sphereTable)
end
