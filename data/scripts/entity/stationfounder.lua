package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Stations')
local _debug = false

table.insert(StationFounder.stations, {
	name = getStationName('mx'),
	tooltip = getStationDesc('mx'),
	scripts = {
		{script = "data/scripts/complexCraft/complexCoreV2.lua"}
	},
	price = 1000000
})

-- table.insert(StationFounder.stations, {
	-- name = "Мегакомплекс"%_t,
	-- tooltip = "Распределяет товары между пристыкованными к нему станциями для эффективных производственных цепочек"%_t,
	-- scripts = {
		-- --{script = "data/scripts/complexCraft/complexCore.lua"}
		-- {script = "data/scripts/complexCraft/complexCoreV2.lua"}
	-- },
	-- price = 2000000
-- })

