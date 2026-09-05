-- [Cosmic Starfall] UpgradeGenerator Extension
-- Injects Starfall system upgrades safely into the loot pool by hooking UpgradeGenerator:initialize.

-- Registers each system's shop category with Cosmic Vault's shared registry (Category.Military/
-- Civilian/Misc) so Cosmic Overhaul's split Equipment Dock tabs -- and any other category-based
-- shop UI -- sort these correctly instead of defaulting to Misc. Runs once at file load; Cosmic
-- Vault is a hard dependency (see modinfo.lua), so no pcall guard is needed here.
local CosmicVaultUpgradeCategories = include("cosmicvaultupgradecategories")
if CosmicVaultUpgradeCategories then
    local Category = CosmicVaultUpgradeCategories.Category
    CosmicVaultUpgradeCategories.registerCategory("data/scripts/systems/subspaceCargo.lua", Category.Civilian)
    CosmicVaultUpgradeCategories.registerCategory("data/scripts/systems/repairDrones.lua", Category.Military)
    CosmicVaultUpgradeCategories.registerCategory("data/scripts/systems/pulseTractorBeamGenerator.lua", Category.Misc)
    CosmicVaultUpgradeCategories.registerCategory("data/scripts/systems/XperimentalHypergenerator.lua", Category.Misc)
    CosmicVaultUpgradeCategories.registerCategory("data/scripts/systems/bastionSystem.lua", Category.Military)
    CosmicVaultUpgradeCategories.registerCategory("data/scripts/systems/macrofieldProjector.lua", Category.Military)
end

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
