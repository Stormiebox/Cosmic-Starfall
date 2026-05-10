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

function CosmicStarfallLib.getOwnerDescriptor(entity)
    if not entity then return nil end

    local owner = Owner(entity)
    if not owner then return nil end

    return {
        index = owner.index,
        name = owner.name or safeName(entity),
        isPlayer = owner.isPlayer or false,
        isAlliance = owner.isAlliance or false,
        isAIFaction = owner.isAIFaction or false
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
