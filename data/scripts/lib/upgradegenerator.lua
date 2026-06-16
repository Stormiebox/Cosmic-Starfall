-- [Cosmic Starfall] UpgradeGenerator Extension
-- Injects Starfall system upgrades into the loot pool by hooking UpgradeGenerator:initialize.
-- Vanilla already returns UpgradeGenerator at the end of this concatenated file.

local sf_starfall_systems = {
    { script = "data/scripts/systems/subspaceCargo.lua",          weight = 1 },
    { script = "data/scripts/systems/repairDrones.lua",           weight = 1 },
    { script = "data/scripts/systems/pulseTractorBeamGenerator.lua", weight = 1 },
    { script = "data/scripts/systems/XperimentalHypergenerator.lua", weight = 0.5 },
    { script = "data/scripts/systems/bastionSystem.lua",          weight = 0.5 },
    { script = "data/scripts/systems/macrofieldProjector.lua",    weight = 0.5 },
}

local sf_old_initialize = UpgradeGenerator.initialize
function UpgradeGenerator:initialize(seed)
    if sf_old_initialize then sf_old_initialize(self, seed) end

    -- Inject Starfall systems into this instance's script pool
    for _, entry in ipairs(sf_starfall_systems) do
        self.scripts[entry.script] = { weight = entry.weight, dist2ToCenter = nil }
    end
end

-- [Cosmic Starfall] Append ends here. Vanilla already returns UpgradeGenerator above.