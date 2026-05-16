package.path = package.path .. ";data/scripts/lib/?.lua"

local okDebug, CosmicVaultDebug = pcall(include, "cosmicvaultdebug")
local okConfig, CosmicVaultConfig = pcall(include, "cosmicvaultconfig")

CosmicStarfallLib = CosmicStarfallLib or {}

local function safeName(entity)
    if entity and entity.name then return entity.name end
    return "unknown"
end

local function fallbackPrint(level, scope, msg, ...)
    print(string.format("[Cosmic Starfall][%s][%s] %s", tostring(level), tostring(scope), tostring(msg)), ...)
end

function CosmicStarfallLib.logInfo(scope, msg, ...)
    if okDebug and CosmicVaultDebug and CosmicVaultDebug.info then
        CosmicVaultDebug.info("CosmicStarfall-" .. tostring(scope), msg, ...)
        return
    end
    fallbackPrint("INFO", scope, msg, ...)
end

function CosmicStarfallLib.logWarn(scope, msg, ...)
    if okDebug and CosmicVaultDebug and CosmicVaultDebug.warn then
        CosmicVaultDebug.warn("CosmicStarfall-" .. tostring(scope), msg, ...)
        return
    end
    fallbackPrint("WARN", scope, msg, ...)
end

function CosmicStarfallLib.logError(scope, msg, ...)
    if okDebug and CosmicVaultDebug and CosmicVaultDebug.error then
        CosmicVaultDebug.error("CosmicStarfall-" .. tostring(scope), msg, ...)
        return
    end
    fallbackPrint("ERROR", scope, msg, ...)
end

function CosmicStarfallLib.getConfig()
    if okConfig and CosmicVaultConfig and CosmicVaultConfig.get then
        local cfg = CosmicVaultConfig.get()
        if type(cfg) == "table" then return cfg end
    end
    return {}
end

local function resolveOwner(entity)
    if not entity then return nil end
    local ok, owner = pcall(Owner, entity)
    if not ok or not owner then return nil end
    return owner
end

local function resolveOwnerIndex(entity, owner)
    if entity then
        local okFactionIndex, factionIndex = pcall(function() return entity.factionIndex end)
        if okFactionIndex and factionIndex ~= nil then
            return factionIndex
        end
    end

    if owner then
        local okIndex, ownerIndex = pcall(function() return owner.index end)
        if okIndex and ownerIndex ~= nil then
            return ownerIndex
        end
    end

    return nil
end

function CosmicStarfallLib.getOwnerDescriptor(entity)
    if not entity then return nil end

    local owner = resolveOwner(entity)
    local ownerIndex = resolveOwnerIndex(entity, owner)
    if ownerIndex == nil then return nil end

    local ownerName = nil
    local isPlayer = false
    local isAlliance = false
    local isAIFaction = false

    if owner then
        local okName, vName = pcall(function() return owner.name end)
        local okIsPlayer, vIsPlayer = pcall(function() return owner.isPlayer end)
        local okIsAlliance, vIsAlliance = pcall(function() return owner.isAlliance end)
        local okIsAIFaction, vIsAIFaction = pcall(function() return owner.isAIFaction end)

        if okName then ownerName = vName end
        if okIsPlayer and vIsPlayer ~= nil then isPlayer = vIsPlayer end
        if okIsAlliance and vIsAlliance ~= nil then isAlliance = vIsAlliance end
        if okIsAIFaction and vIsAIFaction ~= nil then isAIFaction = vIsAIFaction end
    end

    return {
        index = ownerIndex,
        name = ownerName or safeName(entity),
        isPlayer = isPlayer,
        isAlliance = isAlliance,
        isAIFaction = isAIFaction
    }
end

function CosmicStarfallLib.getOwnerIndex(entity)
    local d = CosmicStarfallLib.getOwnerDescriptor(entity)
    if not d then return nil end
    return d.index
end

function CosmicStarfallLib.hasOwnerIndex(entity)
    return CosmicStarfallLib.getOwnerIndex(entity) ~= nil
end

function CosmicStarfallLib.invokeOwnerFunction(entity, script, fn, ...)
    local ownerIndex = CosmicStarfallLib.getOwnerIndex(entity)
    if not ownerIndex then return false end
    return invokeFactionFunction(ownerIndex, false, script, fn, ...)
end

function CosmicStarfallLib.invokeOwnerFunctionIfOnline(entity, script, fn, ...)
    local ownerIndex = CosmicStarfallLib.getOwnerIndex(entity)
    if not ownerIndex then return false end

    local server = Server()
    if not server or not server.isOnline or not server:isOnline(ownerIndex) then
        return false
    end

    return invokeFactionFunction(ownerIndex, false, script, fn, ...)
end
