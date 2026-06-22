-- [Cosmic Starfall] UpgradeGenerator Extension
-- Injects Starfall system upgrades safely into the loot pool by hooking UpgradeGenerator:initialize.

local sf_old_initialize = UpgradeGenerator.initialize
function UpgradeGenerator:initialize(seed)
    if sf_old_initialize then
        sf_old_initialize(self, seed)
    end

    -- Safely inject Starfall systems into the generated script pool
    if self.scripts then
        self.scripts["data/scripts/systems/subspaceCargo.lua"] = {weight = 1}
        self.scripts["data/scripts/systems/repairDrones.lua"] = {weight = 1}
        self.scripts["data/scripts/systems/pulseTractorBeamGenerator.lua"] = {weight = 1}
        self.scripts["data/scripts/systems/XperimentalHypergenerator.lua"] = {weight = 0.5}
        self.scripts["data/scripts/systems/bastionSystem.lua"] = {weight = 0.5}
        self.scripts["data/scripts/systems/macrofieldProjector.lua"] = {weight = 0.5}
    end
end
