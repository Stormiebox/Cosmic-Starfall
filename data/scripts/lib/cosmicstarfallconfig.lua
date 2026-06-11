package.path = package.path .. ";data/scripts/lib/?.lua"

local ccm = include("ccm")
local config = ccm and ccm.bind("Cosmic_Starfall") or nil

CosmicStarfallConfig = CosmicStarfallConfig or {}

if ccm then
    ccm.register("Cosmic_Starfall", {
        pages = {
            {
                title = "General Settings",
                options = {
                    -- Examples for future implementation:
                    -- { key = "enableBossDrops", type = "bool", title = "Enable Starfall Boss Drops", description = "Allow Starfall tech to drop from bosses.", default = true },
                    -- { key = "globalDropMultiplier", type = "number", title = "Drop Multiplier", description = "Multiply the drop rate of Starfall tech.", default = 1.0, min = 0.1, max = 5.0 },
                },
            },
        },
    })
end

local defaults =
{
    -- enableBossDrops = true,
    -- globalDropMultiplier = 1.0,
}

local function readBool(key, fallback)
    if not config then return fallback end
    local value = config.get(key)
    if type(value) ~= "boolean" then return fallback end
    return value
end

local function readNumber(key, fallback)
    if not config then return fallback end
    local value = config.get(key)
    if type(value) ~= "number" then return fallback end
    return value
end

local function build()
    local out = {}

    -- out.enableBossDrops = readBool("enableBossDrops", defaults.enableBossDrops)
    -- out.globalDropMultiplier = readNumber("globalDropMultiplier", defaults.globalDropMultiplier)

    return out
end

function CosmicStarfallConfig.get()
    return build()
end
