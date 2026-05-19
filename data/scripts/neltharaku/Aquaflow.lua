package.path = package.path .. ";data/scripts/lib/?.lua"
include('callable')

-- namespace Aquaflow
-- [Cosmic Starfall] Security Patch:
-- This file originally used unsafe io.open() and loadstring() calls which posed a
-- massive security risk (Arbitrary Code Execution) and caused server-side crashes.
-- Because it was only utilized by the abandoned experimental debug panel (OCnode.lua),
-- all logic has been replaced with safe stubs to prevent crashes while neutralizing the threat.
Aquaflow = {}

function Aquaflow.initialize()
	-- Deprecated. Removed unsafe Player() calls that crashed dedicated servers.
end

function Aquaflow.loadData(_name)
	print("[Cosmic Starfall] Security Warning: Aquaflow.loadData is deprecated and disabled.")
	return nil
end

function Aquaflow.saveData(_name, _data)
	print("[Cosmic Starfall] Security Warning: Aquaflow.saveData is deprecated and disabled.")
	return false
end

function Aquaflow.serialize(_table, _step)
	return ""
end

function Aquaflow.deserialize(_table, _step)
	return {}
end

function Aquaflow.convert(data)
	return data
end

function Aquaflow.transformColor(name, isLib)
	return {}
end
