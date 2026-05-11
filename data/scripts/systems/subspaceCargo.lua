package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
include("basesystem")
include("utility")
include("randomext")
include("Tech")
include("cosmicstarfalllib")

-- optimization so that energy requirement doesn't have to be read every frame
FixedEnergyRequirement = true
local systemname = 'subspacecargo'

--Assigns a work bonus as a percentage only (all other functions that call this are also changed to receive only one argument)
function getBonuses(seed, rarity, permanent)
    math.randomseed(seed)

    local _cargo = (math.random(31, 35) + rarity.value * 4) * 0.01
    local _energy = (math.random(14, 18) - rarity.value) * -0.01
    local _shield = (math.random(11, 15) - rarity.value) * -0.01

    if permanent then _cargo = _cargo * 1.4 end


    -- add randomized value, span is based on rarity

    return _cargo, _energy, _shield
end

function onInstalled(seed, rarity, permanent)
    local _cargo, _energy, _shield = getBonuses(seed, rarity, permanent)

    addBaseMultiplier(StatsBonuses.CargoHold, _cargo)
    addBaseMultiplier(StatsBonuses.GeneratedEnergy, _energy) --reduces energy regen
    addMultiplier(StatsBonuses.ShieldDurability, 1 + _shield)
end

function onUninstalled(seed, rarity, permanent)

end

function getName(seed, rarity)
    local mk = rarity.value + 2
    return getTechName(systemname) .. " Mk-" .. tostring(mk)
end

function getIcon(seed, rarity)
    return getTechIcon(systemname)
end

function getEnergy(seed, rarity, permanent)
    local perc, energy, shield = getBonuses(seed, rarity)
    return perc * 2 * 1000 * 1000 * 1000
end

function getPrice(seed, rarity)
    local perc, energy, shield = getBonuses(seed, rarity)
    local price = perc * energy * shield * 125 * 50000 * 1.7 --Quite crooked pricing
    return price * 2.5 ^ rarity.value
end

function getTooltipLines(seed, rarity, permanent)
    local texts = {}
    local bonuses = {}
    local perc, energy, shield = getBonuses(seed, rarity, permanent)
    local basePerc, baseEnergy, baseShield = getBonuses(seed, rarity, false)

    if perc ~= 0 then
        table.insert(texts,
            {
                ltext = "Cargo Hold (relative)" % _t,
                rtext = string.format("%+i%%", round(perc * 100)),
                icon =
                "data/textures/icons/crate.png",
                boosted = permanent
            })
        table.insert(texts,
            {
                ltext = "Generated Energy" % _t,
                rtext = string.format("%+i%%", round(energy * 100)),
                icon =
                "data/textures/icons/electric.png",
                boosted = permanent
            })
        table.insert(texts,
            {
                ltext = "Shield Durability" % _t,
                rtext = string.format("%+i%%", round(shield * 100)),
                icon =
                "data/textures/icons/health-normal.png",
                boosted = permanent
            })

        table.insert(bonuses,
            {
                ltext = "Cargo Hold (relative)" % _t,
                rtext = string.format("%+i%%", round(basePerc * 0.4 * 100)),
                icon =
                "data/textures/icons/crate.png",
                boosted = permanent
            })
    end
    return texts, bonuses
end

function getDescriptionLines(seed, rarity, permanent)
    return
    {
        { ltext = getTechDesc(systemname), lcolor = ColorRGB(1, 0.5, 0.5) }
    }
end

function getComparableValues(seed, rarity)
    local perc, energy, shield = getBonuses(seed, rarity, false)

    local base = {}
    local bonus = {}
    -- if perc ~= 0 then
    -- table.insert(base, {name = "Грузовой отсек"%_t, key = "cargo_hold_relative", value = round(perc *100), comp = UpgradeComparison.MoreIsBetter})
    -- table.insert(bonus, {name = "Грузовой отсек"%_t, key = "cargo_hold_relative", value = round(perc *0.5 *100), comp = UpgradeComparison.MoreIsBetter})
    -- table.insert(bonus, {name = "Объем щитов"%_t, key = "cargo_hold_relative", value = round(shield *0.5 *100), comp = UpgradeComparison.MoreIsBetter})
    -- table.insert(base, {name = "Мощность реактора"%_t, key = "cargo_hold_relative", value = round(energy *100), comp = UpgradeComparison.MoreIsBetter})
    -- end

    return base, bonus
end
