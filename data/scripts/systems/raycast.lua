package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/neltharaku/?.lua"
--include ("basesystem")
include('utility')
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

function isInRangeV3(v1, v2, range)
	local modRange = (range * 100) * (range * 100)
	local calcDist2 = distance2(v1, v2) * 0.85
	if calcDist2 <= modRange and calcDist2 > 0 then
		return true
	else
		return false
	end
end

--Returns the thickness of the beam, checking the distance to the target and other parameters
function inRange(_row)
	local _posSRC = _row[2].translationf
	local _posTGT = _row[3].translationf
	local _dist = _row[5]
	local _bW = _row[6]

	local modRange = (_dist * 100) * (_dist * 100)
	local calcDist2 = distance2(_posSRC, _posTGT) * 0.85

	if calcDist2 <= modRange and calcDist2 > 0 then
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
	for _index, _value in pairs(_table) do
		print(_myName, _index, ' | ', _value)
	end
end

--Checks if the source and target have the same owner, and if the given object is the target
function checkDoubleCast(_row)
	local _sourceID = _row[2].id
	local _targetID = _row[3].id
	local isTarget = Entity().id == _row[3].id
	if (Player(_sourceID).name == Player(_targetID).name) and isTarget then return true end
	return false
end

--Quickly checks the laser line for nil
function LaserTableSelfValid(_row)
	--Neltharaku.table self report( row)
	if _row[1] == nil then
		--DebugMsg(_myName..'laserSelfValid -invalid type')
		return false
	end
	if not (valid(_row[2])) or (_row[2].translationf == nil) then
		--DebugMsg(_myName..'laserSelfValid -invalid source')
		return false
	end
	if not (valid(_row[3])) or (_row[3].translationf == nil) then
		--DebugMsg(_myName..'laserSelfValid -invalid target')
		return false
	end
	if _row[4] == nil then
		--DebugMsg(_myName..'laserSelfValid -invalid color')
		return false
	end
	if _row[5] == nil then
		--DebugMsg(_myName..'laserSelfValid -invalid distance')
		return false
	end
	if _row[6] == nil then
		--DebugMsg(_myName..'laserSelfValid -invalid baseWidth')
		return false
	end

	return true
end

--Analogue for a sphere
function SphereTableSelfValid(_row)
	if _row[1] == nil then
		DebugMsg(_myName .. 'SphereSelfValid - invalid type')
		return false
	end
	if not (valid(_row[2])) or (_row[2].translationf == nil) then
		DebugMsg(_myName .. 'SphereSelfValid - invalid source')
		--Debug msg( row[2].name)
		return false
	end
	if not (_row[3]) or _row[3] <= 0 then
		DebugMsg(_myName .. 'SphereSelfValid - invalid radius')
		return false
	end
	if not (_row[4]) or _row[4] == ivec2(0, 0) then
		DebugMsg(_myName .. 'SphereSelfValid - invalid iRadius')
		return false
	end
	if _row[5] == nil then
		DebugMsg(_myName .. 'SphereSelfValid - invalid color')
		return false
	end
	if not (_row[6]) or _row[6] <= 0 then
		DebugMsg(_myName .. 'SphereSelfValid - invalid intensity')
		return false
	end
	if not (_row[7]) or _row[7] <= 0 then
		DebugMsg(_myName .. 'SphereSelfValid - invalid reflectivity')
		return false
	end
	if _row[8] == nil then
		DebugMsg(_myName .. 'SphereSelfValid - invalid reflColor')
		return false
	end

	return true
end

function LaserOperate()
	--View table of tables
	for _index, _table in pairs(laserTable) do
		--Checking for the existence of a laser (must be a target, must be a source)
		if LaserTableSelfValid(_table) then
			local _type = _table[1]
			local _posSRC = _table[2].translationf
			local _posTGT = _table[3].translationf
			local _distance = _table[5]
			local _width = _table[6]
			--Checking for a laser in the list of animations
			if not (fxTable[_type]) then
				--Create when necessary (cannot create if the given object is the target and the owners are the same to avoid duplicate lasers)
				if not (checkDoubleCast(_table)) then
					Debug('laser created of type ' .. _type .. ' for entity ' .. Entity().name)
					fxTable[_type] = Sector():createLaser(_posSRC, _posTGT, _table[4] or _colorR, _table[6] or 2)
					fxTable[_type].collision = false
				end
			else
				--Move processing ONLY. Laser thickness etc. is handled in another function
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

--Performs sphere processing
function SphereOperate()
	--DebugMsg('sphereOperate')
	--Checking for spheres
	for _index, _rows in pairs(sphereTable) do
		--Cutting off invalid calls
		if not (SphereTableSelfValid(_rows)) then
			DebugMsg('sphereOperate failure: incorrect row of index ' .. _index)
			return
		end

		--Extracting values
		--local entitity = _rows[2]

		local _type = _rows[1]
		local _source = _rows[2].position
		local _radius = _rows[3]
		local _ivec2radius = _rows[4]
		local _color = _rows[5]
		local _intensity = _rows[6]
		local _reflectivity = _rows[7]
		local _reflColor = _rows[8]

		--Checking the existence of a given sphere
		if fxsTable[_type] == nil then
			--Create a sphere if not found
			fxsTable[_type] = Sector():createRefractionSphere(_radius, _ivec2radius)
			fxsTable[_type].color = _color
			fxsTable[_type].intensity = _intensity
			fxsTable[_type].reflectivity = _reflectivity
			fxsTable[_type].reflectivityColor = _reflColor
			DebugMsg('sphereOperate: sphere created of type ' .. _type)
		else
			--Moving the sphere
			fxsTable[_type].position = _source
		end
	end
end

--Checks the validity of the sphere. Removes it if not needed
function fxSphereSelfValid()
	for _index, _rows in pairs(fxsTable) do
		local _valid = false
		for _, _rows2 in pairs(sphereTable) do
			--If it finds a match by type (the sphere really exists), it returns true
			if _rows2[1] == _index then
				_valid = true
			end
		end

		if not (_valid) then
			DebugMsg(_myName .. 'sphere removed: ' .. _index)
			Sector():removeRefractionObject(_rows)
			fxsTable[_index] = nil
		end
	end
end

--Checks if the laser has an associated entry in the main table. If not, deletes it. In addition, it updates the beam thickness depending on the distance
function fxLaserSelfValid()
	if #laserTable ~= #fxTable then
		--Debug('#fxTable = '..tostring(#fxTable))
		--Debug('#laserTable = '..tostring(#laserTable))
		--TSR(laserTable,'laserTable')
		--TSR(fxTable,'fxTable')
	end
	for _key, _rows in pairs(fxTable) do
		local _valid = false
		local _inRange = 0
		for _, _rows2 in pairs(laserTable) do
			--If it finds a match (the laser exists), it calculates the distance to calculate the thickness of the laser
			if _rows2[1] == _key then
				_valid = true
				_inRange = inRange(_rows2)
			end
		end

		if _valid then
			--Updates beam thickness
			_rows.width = _inRange
		else
			DebugMsg(_myName .. 'laser deleted from sector: ' .. _key)
			_rows.maxAliveTime = 0.1
			Sector():removeLaser(_rows)
			--fxTable[_key].maxAliveTime = 0.1
			fxTable[_key] = nil
		end
	end
end

function isEntityCorrect(_entity)
	--Validity check
	if not (valid(_entity)) then
		Debug('isEntityCorrect failure: not entity')
		return false
	end

	local name = _entity.name
	--Name checking (for some reason this is also necessary, otherwise it gives an error. Kek)
	if not (name) then
		Debug('isEntityCorrect failure: not entity')
		return false
	end

	local eroro = 'isEntityCorrect(' .. name .. ') failure: '
	--Availability check
	if not (_entity) then
		Debug(eroro .. 'not entity')
		return false
	end

	if Sector():getEntity(_entity.id) == nil then
		Debug(eroro .. 'cant pick entity in sector')
		return false
	end
	--HP check
	if Durability(_entity.id).durability == 0 then
		Debug(eroro .. 'zero durability')
		return false
	end
	return true
end

---------------------------------------------------------------------------------------------------
function initialize()
	if Entity().name then
		_myName = 'Raycast(' .. Entity().name .. '): '
	end
	Entity():registerCallback("onJump", "ClearGraphicsOnJump")
end

function getUpdateInterval()
	if onClient() then
		if (#laserTable + #sphereTable) > 0 then
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
		if #laserTable > 0 then LaserOperate() end
		if #sphereTable > 0 then SphereOperate() end
	else
		AnalyseTable()
	end
end

--The function checks information received from outside for correctness and allows updating of tables
function importDataCheck(_table)
	--Checking for type presence
	if not (_table[1]) then
		DebugMsg('raycast: laser creation rejected: type invalid')
		return false
	end
	--Single source check
	if not (_table[2]) or not (_table[2].type == EntityType.Ship or _table[2].type == EntityType.Station) or not (valid(_table[2])) then
		DebugMsg('raycast: laser creation rejected: source invalid')
		return false
	end
	--Single target check
	if not (_table[3]) or not (_table[3].type == EntityType.Ship or _table[3].type == EntityType.Station) or not (valid(_table[3])) then
		DebugMsg('raycast: laser creation rejected: target invalid')
		return false
	end
	--Color check
	if not (_table[4]) then
		DebugMsg('raycast: laser creation rejected: color invalid')
		return false
	end
	--Checking distance
	if not (_table[5]) or _table[5] < 1 then
		DebugMsg('raycast: laser creation rejected: distance invalid')
		return false
	end
	--Questionability check
	if not (_table[6]) or _table[6] < 0 then
		DebugMsg('raycast: laser creation rejected: width invalid')
		return false
	end
	--Target-Source Match Check
	if _table[2].index == _table[3].index then
		DebugMsg('raycast: laser creation rejected: source and target are same')
		return false
	end
	--Checking laser matching via type-target relationship
	for _, _rows in pairs(laserTable) do
		if (_rows[1] == _table[1]) and (_rows[3].index == _table[3].index) then
			DebugMsg('raycast: laser creation rejected: another laser detected')
			return false
		end
	end
	DebugMsg('Laser creation check successful')
	return true
end

--Checks if a sphere of this type already exists
function sphereIsUniq(_type)
	for _, _rows in pairs(sphereTable) do
		if (_rows[1] == _type) then
			DebugMsg('raycast: sphere creation rejected: another sphere detected')
			return false
		end
	end

	return true
end

--The function initiates an import attempt
function setLaser(_type, _sourceship, _targetship, _color, _distance, _baseWidth)
	if onClient() then return end
	--Setting Variables
	local _importedRow = { _type, _sourceship, _targetship, _color, _distance, _baseWidth }
	--Checking the correctness of values ​​and importing into the laser table
	if importDataCheck(_importedRow) then
		table.insert(laserTable, _importedRow)
		DebugMsg(_myName .. 'laser imported successful|' .. tostring(#laserTable))
		AnalyseTable()
		return 0
	else
		return 1
	end
end

function setSphere(_type, _source, _radius, _ivec2radius, _color, _intensity, _reflectivity, _reflColor)
	local _importedTable = { _type, _source, _radius, _ivec2radius, _color, _intensity, _reflectivity, _reflColor }

	--Match checking
	if not (sphereIsUniq(_type)) then
		DebugMsg('setSphere failure: same sphere of type detected')
		return 1
	end

	--Validity check and filling of the table
	if SphereTableSelfValid(_importedTable) then
		table.insert(sphereTable, _importedTable)
		DebugMsg(_myName .. 'sphere imported successful|' .. tostring(#sphereTable))
		AnalyseSphereTable()
	else
		DebugMsg('setSphere failure: something incorrect')
		return 1
	end

	return 0
end

--The function performs removal from the side
function removeLaser(_type)
	if onClient() then return end
	DebugMsg(_myName .. 'removeLaser attempt of type ' .. _type)
	AnalyseTable(_type)
end

function RemoveSphere(_type)
	--Change of flow
	if onClient() then
		invokeServerFunction('RemoveSphere', _type)
		return
	end
	DebugMsg(_myName .. 'removeSphere attempt of type ' .. _type)
	AnalyseSphereTable(_type)
end

callable(nil, 'RemoveSphere')


--The function checks the relevance of lasers and updates the table if necessary. Submitting an index deletes the corresponding row
function AnalyseTable(_toRemoveIndex)
	for _index, _rows in pairs(laserTable) do
		--Laser segment
		if not (isEntityCorrect(_rows[2])) or not (isEntityCorrect(_rows[3])) then
			DebugMsg(_myName .. 'laser removed from table (incorrect source or target) with type ' .. _rows[1])
			table.remove(laserTable, _index)
		end

		if _toRemoveIndex and (_toRemoveIndex == _rows[1]) then
			table.remove(laserTable, _index)
			DebugMsg(_myName .. 'remove laser from table (marked for removal)|' .. tostring(#laserTable))
		end
	end
	if not (Player(callingPlayer)) then return end
	invokeClientFunction(Player(callingPlayer), 'SyncToClient', laserTable)
end

--Checks the relevance of spheres. Submitting an index deletes the corresponding row
function AnalyseSphereTable(_toRemoveIndex)
	for _index, _rows in pairs(sphereTable) do
		if not (isEntityCorrect(_rows[2])) then
			DebugMsg(_myName .. 'sphere removed from table (incorrect source)')
			table.remove(sphereTable, _index)
		end
		if _toRemoveIndex and (_toRemoveIndex == _rows[1]) then
			table.remove(sphereTable, _index)
			DebugMsg(_myName .. 'remove sphere from table (marked for removal)|' .. tostring(#sphereTable))
		end
	end
	if not (Player()) then return end
	invokeClientFunction(Player(), 'SyncToClient', nil, sphereTable)
end

function SyncToClient(_table, _sphereTable)
	--Debug('SyncToClient attempt')
	if _table then laserTable = _table end
	if _sphereTable then sphereTable = _sphereTable end
	fxLaserSelfValid()
	fxSphereSelfValid()
	getUpdateInterval()
end

--When jumping, turns off graphics for both itself and the source/target
function ClearGraphicsOnJump()
	Debug('ClearGraphicsOnJump attempt')

	-- for _,_rows in pairs(laserTable) do
	-- local typeFX = _rows[1]
	-- local source = _rows[2]
	-- local target = _rows[3]

	-- End

	laserTable = {}
	sphereTable = {}
	invokeClientFunction(Player(), 'SyncToClient', laserTable, sphereTable)
end
