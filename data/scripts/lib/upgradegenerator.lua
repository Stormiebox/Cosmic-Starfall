-- [Cosmic Starfall] UpgradeGenerator Extension
-- Injects Starfall system upgrades into the loot pool by hooking UpgradeGenerator:generateSystem.

local sf_starfall_systems = {
    { script = "data/scripts/systems/subspaceCargo.lua",          weight = 1 },
    { script = "data/scripts/systems/repairDrones.lua",           weight = 1 },
    { script = "data/scripts/systems/pulseTractorBeamGenerator.lua", weight = 1 },
    { script = "data/scripts/systems/XperimentalHypergenerator.lua", weight = 0.5 },
    { script = "data/scripts/systems/bastionSystem.lua",          weight = 0.5 },
    { script = "data/scripts/systems/macrofieldProjector.lua",    weight = 0.5 },
}

local sf_total_weight = 0
for _, entry in ipairs(sf_starfall_systems) do
    sf_total_weight = sf_total_weight + entry.weight
end

-- Vanilla total weight is roughly around 30. We want Starfall systems to drop naturally.
-- We can give it a combined chance to drop instead of a vanilla script.
local sf_chance_to_drop = sf_total_weight / (30 + sf_total_weight)

local sf_old_generateSystem = UpgradeGenerator.generateSystem
function UpgradeGenerator:generateSystem(rarity, rarities_in)
    if self.random:test(sf_chance_to_drop) then
        if rarity == nil then
            local rarities = rarities_in or self:getDefaultRarityDistribution()
            rarity = getValueFromDistribution(rarities, self.random)
            if type(rarity) == "number" then rarity = Rarity(rarity) end
        end

        if self.minRarity then
            if rarity < self.minRarity then rarity = self.minRarity end
        end
        if self.maxRarity then
            if rarity > self.maxRarity then rarity = self.maxRarity end
        end

        local randValue = self.random:getFloat(0, sf_total_weight)
        local currentWeight = 0
        local selectedScript = sf_starfall_systems[1].script
        for _, entry in ipairs(sf_starfall_systems) do
            currentWeight = currentWeight + entry.weight
            if randValue <= currentWeight then
                selectedScript = entry.script
                break
            end
        end

        local seed = self.random:createSeed()
        return SystemUpgradeTemplate(selectedScript, rarity, seed)
    end

    if sf_old_generateSystem then
        return sf_old_generateSystem(self, rarity, rarities_in)
    end
end
