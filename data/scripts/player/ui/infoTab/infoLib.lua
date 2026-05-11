package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

--namespace infoLib
infoLib = {}

local _debug = false
function infoLib.DebugMsg(_text)
	if _debug then
		print('infoLib|', _text)
	end
end

local Debug = infoLib.DebugMsg

local self = infoLib

--Sorts the table
function infoLib.TableSort(_table)
	local buf = {}
	local result = {}
	if not (_table) then return false end

	for i = 0, #_table do

	end

	return result
end
