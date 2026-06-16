package.path = package.path .. ";data/scripts/lib/?.lua"

local cv_success, CosmicVaultCombat = pcall(include, "cosmicvaultcombat")

function initialize()
    if onServer() then
        Sector():registerCallback("onDamaged", "onDamaged")
    end
end

local inflictorCache = {}

function getUpdateInterval()
    return 5
end

function updateServer(timeStep)
    inflictorCache = {} 
end

function onDamaged(objectIndex, amount, inflictor, damageSource, damageType)
    if not cv_success or not CosmicVaultCombat then return end
    if not inflictor then return end
    if damageSource ~= DamageSource.Turret then return end

    if damageType ~= DamageType.Plasma and damageType ~= DamageType.AntiMatter then return end

    local inflictorId = inflictor.string
    
    if inflictorCache[inflictorId] == nil then
        local inflictorEntity = Entity(inflictorId)
        local hasBurn = false
        local hasMelt = false
        
        if valid(inflictorEntity) and inflictorEntity.hasComponent and inflictorEntity:hasComponent(ComponentType.Turrets) then
            local turrets = {inflictorEntity:getTurrets()}
            for _, turret in pairs(turrets) do
                local prefix = turret.prefix or ""
                if string.find(prefix, "%[Burn%]") then
                    hasBurn = true
                end
                if string.find(prefix, "%[Melt%]") then
                    hasMelt = true
                end
            end
        end
        inflictorCache[inflictorId] = { burn = hasBurn, melt = hasMelt }
    end
    
    local cacheEntry = inflictorCache[inflictorId]
    
    if damageType == DamageType.Plasma and cacheEntry.burn then
        -- Apply Burn DoT: 20% of hit damage over 5 seconds
        CosmicVaultCombat.applyDoT(objectIndex, "Plasma Burn", amount * 0.20, 5, inflictorId)
    elseif damageType == DamageType.AntiMatter and cacheEntry.melt then
        -- Apply Corrosive Melt: 15% of hit damage over 3 seconds
        CosmicVaultCombat.applyDoT(objectIndex, "Corrosive Melt", amount * 0.15, 3, inflictorId)
    end
end
