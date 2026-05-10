package.path = package.path .. ";data/scripts/lib/?.lua"
include('callable')

--namespace Aquaflow
Aquaflow = {}


local _debug = false
function Aquaflow.DebugMsg(_text)
	if _debug then
		print('Aquaflow|',_text)
	end
end
local Debug = Aquaflow.DebugMsg
local sf = string.format
local self = Aquaflow

local AquaPath = 'moddata/Starfall/'
--local AquaPathClient = 'moddata/Starfall/'
local OpenFlow = io.open

function Aquaflow.initialize()
	Debug('--------initialize--------')
	AquaPath = sf('%s%s/',AquaPath,Player().name)
end



--=======================[ Функционал ]=======================--

function Aquaflow.loadData(_name)
	if _name == nil or name == '' then return end
	local playerindex = Player(callingPlayer).index
	local directory = sf('%s%i/',AquaPath,playerindex)
	local path = sf("%s%s.aqua",directory,_name)
	Debug('loadData loading...')
	local f = OpenFlow(path,'r')
	if not(f) then Debug('loadData failure: file is nil') return end
	Debug('loadData success')
	
	local result = {}
	
	for line in io.lines(path) do
		--result = line
		table.insert(result,line)
	end
	
	f:close()
	local AquaTable = sf("local aTable = %s\nreturn aTable",result[1])
	local AquaGet,eroro = loadstring(AquaTable)
	if eroro then Debug(eroro) end
	local data = AquaGet()
	if not(data) then Debug('loadData failure: incorrect data string from file') return end
	local dData = self.deserialize(data)
	
	Debug('loadData transfer data')
	return dData
end

function Aquaflow.saveData(_name,_data)
	if _name == nil or name == '' then return false end
	if not(_data) then return false end
	
	local data = self.serialize(_data)
	
	local playerindex = Player(callingPlayer).index
	local directory = sf('%s%i/',AquaPath,playerindex)
	local path = sf("%s%s.aqua",directory,_name)
	
	local f = OpenFlow(path,'w+')
	
	if not(f) then 
		return self.createNewFile(_name,data)
	end
	
	f:write(data)
	f:close()
	Debug('Saving data: success')
	return true
end


--=======================[ Служебные ]=======================--

function Aquaflow.createNewFile(_name,_data)
	if onServer() then return Debug('createNewFile: failure(server)') end

	if _name == nil or name == '' then return false end
	local playerindex = Player(callingPlayer).index
	local directory = sf('%s%i/',AquaPath,playerindex)
	local path = sf("%s%s.aqua",directory,_name)
	
	Debug('createNewFile path: '..path)
	
	Debug('Creating directory...')
	createDirectory(directory)
	Debug('Creating directory: success')
	
	local f,e = OpenFlow(path,'w')
	if e then Debug('Creating file: failure') return end
	f:write(_data)
	f:close()
	Debug('Creating file: success')
	return true
end

function Aquaflow.serialize(_table,_step)
	--Debug('serialize attempt')
	--Шаг 1 включает полный вывод, остальное - рекурсивный
	if not(_step) then
		_step = 1
	else 
		_step = _step + 1
	end
	
	local result = ''
	--Таблица
	if type(_table)=='table' then
		
		result = result..'{'
		for _,_rows in pairs(_table) do
			local s = self.serialize(_rows,_step)
			result = result..s
		end
		
		--Если шаг 1 - запятую не рисует, иначе рисует
		if _step > 1 then
			result = result..'},'
		else
			result = result..'}'
		end
		
		
	else
		--Запись значения ячейки
		--Строка
		if type(_table) == 'string' then
			result = sf("'%s',",_table)
		end
		--Булка
		if type(_table) == 'boolean' then
			if _table then
				result = sf("'!true',")
			else
				result = sf("'!false',")
			end
		end
		--I / F 
		if type(_table) == 'number' then
			result = sf("%s,",tostring(_table))
		end
		
	end
	if _step == 1 then Debug('aquaflow result = '..result) end
	--Debug('aquaflow result = '..result)
	return result
end

--Распаковывает bool, color
function Aquaflow.deserialize(_table,_step)
	--Шаг 1 включает полный вывод, остальное - рекурсивный
	if not(_step) then
		_step = 1
	else 
		_step = _step + 1
	end
	
	--local result = _table
	if type(_table)=='table' then
	
		--Рекурсивный проход таблицы
		for _index,_rows in pairs(_table) do
		
			--Булки
			if _rows == '!true' then _table[_index] = true end
			if _rows == '!false' then _table[_index] = false end
			
			--Color
			if type(_rows) == 'table' and _rows[1] == '!color' then
				_table[_index] = ColorHSV(_rows[2],_rows[3],_rows[4])
			end
			--ColorLib
			if type(_rows) == 'table' and _rows[1] == '!colorLib' then
				_table[_index] = _rows[2]
			end
			
			_rows = self.deserialize(_rows,_step)
		end
		
	end
	
	--Вывод
	if _step == 1 then
		local d = {}
		table.insert(d,_table)
		--Neltharaku.TableSelfReport(d)
		return d
	else
		return _table
	end
end

function Aquaflow.convert(data)
	if _table == '!true' then return true end
	if _table == '!false' then return false end
	return data
end

function Aquaflow.transformColor(name,isLib)
	local colorCode = getColorCode(name)
	if not(isLib) then
		return {'!color',colorCode[1],colorCode[2],colorCode[3]}
	else
		return{'!colorLib',name}
	end
end