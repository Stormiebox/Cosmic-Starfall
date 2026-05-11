package.path = package.path .. ";data/scripts/neltharaku/?.lua"

include('Armory')
local _orange = ColorHSV(30, 0.8, 0.9)

local locLines = {}
locLines['weaponclass'] = "Weapon class" % _t
locLines['weaponclass_light'] = "light" % _t
locLines['weaponclass_heavy'] = "heavy" % _t
locLines['weaponclass_mc'] = "main caliber" % _t
locLines['weaponclass_standart'] = "standart" % _t
locLines['accuracy'] = "Accuracy" % _t
locLines['projspeed'] = "Projectile speed" % _t
locLines['instant'] = "Instant" % _t

function makeTurretTooltip(turret, other, tooltipType)
    local tooltip = Tooltip()
    tooltipType = tooltipType or TooltipType.Short

    -- create tooltip
    tooltip.icon = turret.weaponIcon
    tooltip.price = ArmedObjectPrice(turret) * 0.25 -- must be adjusted in shop.lua as well!
    tooltip.rarity = turret.rarity

    -- build title
    local title = ""
    if turret.title then
        title = turret.title:translated()
    end

    if title == "" then
        local weapon = turret.weaponPrefix .. " /* Weapon Prefix*/"
        weapon = weapon % _t

        local tbl = { material = turret.material.name, weaponPrefix = weapon }

        if turret.stoneRefinedEfficiency > 0 or turret.metalRefinedEfficiency > 0
            or turret.stoneRawEfficiency > 0 or turret.metalRawEfficiency > 0 then
            if turret.itemType == InventoryItemType.Turret then
                -- flush
                if turret.numVisibleWeapons == 1 then
                    title = "${material} ${weaponPrefix} Turret" % _t % tbl
                elseif turret.numVisibleWeapons == 2 then
                    title = "Double ${material} ${weaponPrefix} Turret" % _t % tbl
                elseif turret.numVisibleWeapons == 3 then
                    title = "Triple ${material} ${weaponPrefix} Turret" % _t % tbl
                elseif turret.numVisibleWeapons == 4 then
                    title = "Quad ${material} ${weaponPrefix} Turret" % _t % tbl
                else
                    title = "Multi ${material} ${weaponPrefix} Turret" % _t % tbl
                end
            else
                -- turret template
                if turret.numVisibleWeapons == 1 then
                    title = "${material} ${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 2 then
                    title = "Double ${material} ${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 3 then
                    title = "Triple ${material} ${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 4 then
                    title = "Quad ${material} ${weaponPrefix} Blueprint" % _t % tbl
                else
                    title = "Multi ${material} ${weaponPrefix} Blueprint" % _t % tbl
                end
            end
        elseif turret.coaxial then
            if turret.itemType == InventoryItemType.Turret then
                -- flush
                if turret.numVisibleWeapons == 1 then
                    title = "Coaxial ${weaponPrefix}" % _t % tbl
                elseif turret.numVisibleWeapons == 2 then
                    title = "Double Coaxial ${weaponPrefix}" % _t % tbl
                elseif turret.numVisibleWeapons == 3 then
                    title = "Triple Coaxial ${weaponPrefix}" % _t % tbl
                elseif turret.numVisibleWeapons == 4 then
                    title = "Quad Coaxial ${weaponPrefix}" % _t % tbl
                else
                    title = "Coaxial Multi ${weaponPrefix}" % _t % tbl
                end
            else
                -- turret template
                if turret.numVisibleWeapons == 1 then
                    title = "Coaxial ${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 2 then
                    title = "Double Coaxial ${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 3 then
                    title = "Triple Coaxial ${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 4 then
                    title = "Quad Coaxial ${weaponPrefix} Blueprint" % _t % tbl
                else
                    title = "Coaxial Multi ${weaponPrefix} Blueprint" % _t % tbl
                end
            end
        else
            if turret.itemType == InventoryItemType.Turret then
                -- flush
                if turret.numVisibleWeapons == 1 then
                    title = "${weaponPrefix} Turret" % _t % tbl
                elseif turret.numVisibleWeapons == 2 then
                    title = "Double ${weaponPrefix} Turret" % _t % tbl
                elseif turret.numVisibleWeapons == 3 then
                    title = "Triple ${weaponPrefix} Turret" % _t % tbl
                elseif turret.numVisibleWeapons == 4 then
                    title = "Quad ${weaponPrefix} Turret" % _t % tbl
                else
                    title = "Multi ${weaponPrefix} Turret" % _t % tbl
                end
            else
                -- turret template
                if turret.numVisibleWeapons == 1 then
                    title = "${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 2 then
                    title = "Double ${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 3 then
                    title = "Triple ${weaponPrefix} Blueprint" % _t % tbl
                elseif turret.numVisibleWeapons == 4 then
                    title = "Quad ${weaponPrefix} Blueprint" % _t % tbl
                else
                    title = "Multi ${weaponPrefix} Blueprint" % _t % tbl
                end
            end
        end
    end

    -- head line
    local line = TooltipLine(headLineSize, headLineFont)
    line.ctext = title
    line.ccolor = turret.rarity.tooltipFontColor
    tooltip:addLine(line)

    local fontSize = 13
    local lineHeight = 16

    fillWeaponTooltipDataN(turret, tooltip, other, WeaponObjectType.Turret, tooltipType)

    if tooltipType == TooltipType.Verbose then
        -- Size
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Size" % _t
        line.rtext = round(turret.size, 1)
        line.icon = "data/textures/icons/shotgun.png";
        line.iconColor = iconColor
        applyLessBetter(line, turret, other, "size", 1)
        tooltip:addLine(line)
    end

    if tooltipType == TooltipType.Verbose or turret.slots ~= 1 then
        -- Slots
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Slots" % _t
        line.rtext = round(turret.slots, 1)
        line.icon = "data/textures/icons/small-square.png";
        line.iconColor = iconColor
        applyLessBetter(line, turret, other, "slots", 1)
        tooltip:addLine(line)
    end

    -- slot type
    local line = TooltipLine(lineHeight, fontSize)
    line.ltext = "Slot Type" % _t
    if turret.slotType == TurretSlotType.Armed then
        line.rtext = "ARMED" % _t
    elseif turret.slotType == TurretSlotType.Unarmed then
        line.rtext = "UNARMED" % _t
    elseif turret.slotType == TurretSlotType.PointDefense then
        line.rtext = "DEFENSIVE" % _t
    else
        line.rtext = "ARMED" % _t
    end
    line.icon = "data/textures/icons/small-square.png";
    line.iconColor = iconColor
    tooltip:addLine(line)

    -- empty line
    tooltip:addLine(TooltipLine(8, 8))

    -- automatic/independent firing
    if turret.slotType == TurretSlotType.PointDefense then
        local line = TooltipLine(lineHeight, fontSize + 1)
        line.ltext = "Auto-Targeting" % _t
        line.lcolor = ColorRGB(0.4, 0.9, 0.9)
        line.icon = "data/textures/icons/cog.png";
        line.iconColor = iconColor
        tooltip:addLine(line)

        -- empty line
        tooltip:addLine(TooltipLine(8, 8))
    end

    -- Refinement
    if turret.stoneRefinedEfficiency > 0 or turret.metalRefinedEfficiency > 0 then
        local line = TooltipLine(lineHeight, fontSize + 1)
        line.ltext = "Refinement" % _t
        line.lcolor = ColorRGB(0.4, 0.9, 0.9)
        line.icon = "data/textures/icons/metal-bar.png";
        line.iconColor = iconColor
        tooltip:addLine(line)

        -- empty line
        tooltip:addLine(TooltipLine(8, 8))
    end

    -- coaxial weaponry
    if turret.coaxial then
        local line = TooltipLine(lineHeight, fontSize + 1)
        line.ltext = "Coaxial Weapon" % _t
        line.lcolor = ColorRGB(0.4, 0.9, 0.9)
        line.icon = "data/textures/icons/cog.png";
        line.iconColor = iconColor
        tooltip:addLine(line)

        -- empty line
        tooltip:addLine(TooltipLine(8, 8))
    end

    -- crew requirements
    local crew = turret:getCrew()

    for crewman, amount in pairs(crew:getMembers()) do
        if amount > 0 then
            local profession = crewman.profession

            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = profession:name()
            line.rtext = round(amount)
            line.icon = profession.icon;
            line.iconColor = profession.color
            tooltip:addLine(line)
        end
    end

    -- empty line
    tooltip:addLine(TooltipLine(8, 8))

    local description = {}
    fillDescriptions(turret, tooltip, description)

    replaceTooltipFactionNames(tooltip)
    return tooltip
end

function fillWeaponTooltipDataN(obj, tooltip, other, objectType, tooltipType)
    tooltipType = tooltipType or TooltipType.Simple
    -- rarity name
    local line = TooltipLine(5, 12)
    line.ctext = string.upper(tostring(obj.rarity))
    line.ccolor = obj.rarity.tooltipFontColor
    tooltip:addLine(line)

    -- primary stats, one by one
    local fontSize = 13
    local lineHeight = 16

    --Blank line for beauty
    tooltip:addLine(TooltipLine(8, 8))

    --Adds a weapon type
    local line = TooltipLine(lineHeight, fontSize)
    local wType = nil
    local wColor = nil
    line.ltext = locLines['weaponclass']

    if isTurretLight(obj) then
        wType = locLines['weaponclass_light']
        wColor = getTypeColor('light')
    end

    if isTurretHeavy(obj) then
        wType = locLines['weaponclass_heavy']
        wColor = getTypeColor('heavy')
    end

    if isTurretMC(obj) then
        wType = locLines['weaponclass_mc']
        wColor = getTypeColor('MC')
    end

    --Creates color and text type
    if not (wType) and not (wColor) then
        line.rtext = locLines['weaponclass_standart']
    else
        line.rtext = wType
        line.rcolor = wColor
    end

    --line.rtext = round(obj.averageTech, 1)
    line.icon = "data/textures/icons/ASSAULTBLASTER.png";
    line.iconColor = iconColor
    tooltip:addLine(line)

    local line = TooltipLine(lineHeight, fontSize)
    line.ltext = "Tech" % _t
    line.rtext = round(obj.averageTech, 1)
    line.icon = "data/textures/icons/circuitry.png";
    line.iconColor = iconColor
    tooltip:addLine(line)

    local line = TooltipLine(lineHeight, fontSize)
    line.ltext = "Material" % _t
    line.rtext = obj.material.name
    line.rcolor = obj.material.color
    line.icon = "data/textures/icons/metal-bar.png";
    line.iconColor = obj.material.color
    tooltip:addLine(line)

    -- empty line
    tooltip:addLine(TooltipLine(8, 8))

    if obj.damage > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "DPS" % _t
        line.rtext = round(obj.dps, 1)
        line.icon = "data/textures/icons/screen-impact.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "dps", 1, (other and other.damage > 0))
        tooltip:addLine(line)

        local burst = round(obj.damage * obj.shotsPerSecond, 1)
        if burst ~= round(obj.dps, 1) then
            local line = TooltipLine(lineHeight, 12)
            line.ltext = "Burst DPS" % _t
            line.rtext = burst
            line.icon = "data/textures/icons/nothing.png";
            line.iconColor = iconColor
            line.lcolor = ColorRGB(0.7, 0.7, 0.7)
            line.rcolor = ColorRGB(0.7, 0.7, 0.7)
            line.fontType = FontType.Normal
            if other then
                applyMoreBetter(line, { dps_burst = burst },
                    { dps_burst = round(other.damage * other.shotsPerSecond, 1) },
                    "dps_burst", 1, other)
            end
            tooltip:addLine(line)
        end

        if objectType == WeaponObjectType.Turret and obj.slots ~= 1 and tooltipType == TooltipType.Verbose then
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "DPS / Slot" % _t
            line.rtext = round(obj.dps / obj.slots, 1)
            line.icon = "data/textures/icons/screen-impact.png";
            line.iconColor = iconColor
            if other then
                applyMoreBetter(line, { dps = obj.dps / obj.slots }, { dps = other.dps / other.slots }, "dps", 1, other)
            end
            tooltip:addLine(line)
        end

        tooltip:addLine(TooltipLine(8, 8))

        if not obj.continuousBeam then
            -- Damage
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "Damage" % _t
            line.rtext = round(obj.damage, 1)

            local shotsPerFiring = obj.shotsPerFiring
            if obj.simultaneousShooting then
                shotsPerFiring = shotsPerFiring * obj.numWeapons
            end
            if shotsPerFiring > 1 then
                line.rtext = line.rtext .. " x" .. shotsPerFiring
            end
            line.icon = "data/textures/icons/screen-impact.png";
            line.iconColor = iconColor
            applyMoreBetter(line, obj, other, "damage", 1, (other and other.damage > 0 and not other.continuousBeam))
            tooltip:addLine(line)

            -- fire rate
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "Fire Rate" % _t
            if obj.fireRate < 1 then
                line.rtext = round(obj.fireRate, 2)
            else
                line.rtext = round(obj.fireRate, 1)
            end
            line.icon = "data/textures/icons/bullets.png";
            line.iconColor = iconColor
            applyMoreBetter(line, obj, other, "fireRate", 1, (other and other.damage > 0 and not other.continuousBeam))
            tooltip:addLine(line)
        end
    end

    --Projectile speed line
    if obj.shotSpeed then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = locLines['projspeed']

        if obj.shotSpeed > 10000 then
            line.rtext = locLines['instant']
        else
            line.rtext = round(obj.shotSpeed, 0)
        end

        --line.rtext = wAccuracy..'%'
        line.icon = "data/textures/icons/PARTICLEACCELERATOR.png";
        line.iconColor = iconColor
        tooltip:addLine(line)
    end

    --Precision string
    if obj.accuracy > 0 and not (obj.seeker) then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = locLines['accuracy']

        --round(obj.stoneRefinedEfficiency *100, 1)
        local wAccuracy = round(math.min(obj.accuracy, 1) * 100, 1)

        line.rtext = wAccuracy .. '%'
        line.icon = "data/textures/icons/weaponInfo/uiAim.png";
        line.iconColor = iconColor
        tooltip:addLine(line)
    end

    if obj.otherForce > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Push" % _t
        line.rtext = toReadableValue(obj.otherForce, "N /* unit: Newton*/" % _t)
        line.icon = "data/textures/icons/back-forth.png";
        line.iconColor = iconColor
        tooltip:addLine(line)
    elseif obj.otherForce < 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Pull" % _t
        line.rtext = toReadableValue(-obj.otherForce, "N /* unit: Newton*/" % _t)
        line.icon = "data/textures/icons/back-forth.png";
        line.iconColor = iconColor
        tooltip:addLine(line)
    end

    if obj.selfForce > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Self Push" % _t
        line.rtext = toReadableValue(obj.selfForce, "N /* unit: Newton*/" % _t)
        line.icon = "data/textures/icons/back-forth.png";
        line.iconColor = iconColor
        tooltip:addLine(line)
    elseif obj.selfForce < 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Self Pull" % _t
        line.rtext = toReadableValue(-obj.selfForce, "N /* unit: Newton*/" % _t)
        line.icon = "data/textures/icons/back-forth.png";
        line.iconColor = iconColor
        tooltip:addLine(line)
    end

    if obj.holdingForce > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Force Power" % _t
        line.rtext = toReadableValue(obj.holdingForce, "N /* unit: Newton*/" % _t)
        line.icon = "data/textures/icons/back-forth.png";
        line.iconColor = iconColor
        tooltip:addLine(line)
    end

    if obj.stoneRefinedEfficiency > 0 and obj.metalRefinedEfficiency > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Eff. Stone" % _t
        line.rtext = round(obj.stoneRefinedEfficiency * 100, 1)
        line.icon = "data/textures/icons/scrap-metal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "bestEfficiency", 3, (other and other.bestEfficiency > 0))
        tooltip:addLine(line)

        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Eff. Metal" % _t
        line.rtext = round(obj.metalRefinedEfficiency * 100, 1)
        line.icon = "data/textures/icons/scrap-metal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "bestEfficiency", 3, (other and other.bestEfficiency > 0))
        tooltip:addLine(line)
    elseif obj.stoneRefinedEfficiency > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Efficiency" % _t
        line.rtext = round(obj.stoneRefinedEfficiency * 100, 1)
        line.icon = "data/textures/icons/scrap-metal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "bestEfficiency", 3, (other and other.bestEfficiency > 0))
        tooltip:addLine(line)
    elseif obj.metalRefinedEfficiency > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Efficiency" % _t
        line.rtext = round(obj.metalRefinedEfficiency * 100, 1)
        line.icon = "data/textures/icons/scrap-metal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "bestEfficiency", 3, (other and other.bestEfficiency > 0))
        tooltip:addLine(line)
    end

    if obj.stoneRawEfficiency > 0 and obj.metalRawEfficiency > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Eff. Stone" % _t
        line.rtext = round(obj.stoneRawEfficiency * 100, 1)
        line.icon = "data/textures/icons/scrap-metal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "bestEfficiency", 3, (other and other.bestEfficiency > 0))
        tooltip:addLine(line)

        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Eff. Metal" % _t
        line.rtext = round(obj.metalRawEfficiency * 100, 1)
        line.icon = "data/textures/icons/scrap-metal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "bestEfficiency", 3, (other and other.bestEfficiency > 0))
        tooltip:addLine(line)
    elseif obj.stoneRawEfficiency > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Efficiency" % _t
        line.rtext = round(obj.stoneRawEfficiency * 100, 1)
        line.icon = "data/textures/icons/scrap-metal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "bestEfficiency", 3, (other and other.bestEfficiency > 0))
        tooltip:addLine(line)
    elseif obj.metalRawEfficiency > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Efficiency" % _t
        line.rtext = round(obj.metalRawEfficiency * 100, 1)
        line.icon = "data/textures/icons/scrap-metal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "bestEfficiency", 3, (other and other.bestEfficiency > 0))
        tooltip:addLine(line)
    end

    if obj.hullRepairRate > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Hull Repair /s" % _t
        line.rtext = round(obj.hullRepairRate, 1)
        line.icon = "data/textures/icons/health-normal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "hullRepairRate", 1, (other and other.hullRepairRate > 0))
        tooltip:addLine(line)
    end

    if obj.shieldRepairRate > 0 then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Shield Repair /s" % _t
        line.rtext = round(obj.shieldRepairRate, 1)
        line.icon = "data/textures/icons/health-normal.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "shieldRepairRate", 1, (other and other.shieldRepairRate > 0))
        tooltip:addLine(line)
    end

    if tooltipType == TooltipType.Verbose then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Accuracy" % _t
        line.rtext = round(obj.accuracy * 100, 1)
        line.icon = "data/textures/icons/gunner.png";
        line.iconColor = iconColor
        applyMoreBetter(line, obj, other, "accuracy", 3)
        tooltip:addLine(line)
    end

    local line = TooltipLine(lineHeight, fontSize)
    line.ltext = "Range" % _t
    line.rtext = round(obj.reach * 10 / 1000, 2)
    line.icon = "data/textures/icons/target-shot.png";
    line.iconColor = iconColor
    applyMoreBetter(line, obj, other, "reach", 3)
    tooltip:addLine(line)

    if tooltipType == TooltipType.Verbose then
        local weapon = obj:getWeapons() -- take first weapon
        if weapon and weapon.blockPenetration > 1 then
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "Hull Penetration" % _t
            line.rtext = weapon.blockPenetration .. " blocks" % _t
            line.icon = "data/textures/icons/drill.png";
            line.iconColor = iconColor
            tooltip:addLine(line)
        end
    end

    -- empty line
    tooltip:addLine(TooltipLine(8, 8))

    if tooltipType == TooltipType.Verbose then
        if obj.shotsUntilOverheated > 0 then
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "Continuous Shots" % _t
            line.rtext = obj.shotsUntilOverheated
            line.icon = "data/textures/icons/bullets.png";
            line.iconColor = iconColor
            applyMoreBetter(line, obj, other, "shotsUntilOverheated", nil, (other and other.shotsUntilOverheated > 0))
            tooltip:addLine(line)

            local line = TooltipLine(lineHeight, fontSize)
            if obj.coolingType == CoolingType.BatteryCharge then
                line.ltext = "Time Until Depleted" % _t
                line.icon = "data/textures/icons/battery-pack-alt.png";
            else
                line.ltext = "Time Until Overheated" % _t
                line.icon = "data/textures/icons/overheat.png";
            end
            line.rtext = round(obj.shootingTime, 1) .. "s /* Unit for seconds */" % _t
            line.iconColor = iconColor
            applyMoreBetter(line, obj, other, "shootingTime", 1, (other and other.shotsUntilOverheated > 0))
            tooltip:addLine(line)

            local line = TooltipLine(lineHeight, fontSize)
            if obj.coolingType == CoolingType.BatteryCharge then
                line.ltext = "Recharge Time" % _t
                line.icon = "data/textures/icons/anticlockwise-rotation.png";
            else
                line.ltext = "Cooling Time" % _t
                line.icon = "data/textures/icons/weapon-cooldown.png";
            end
            line.rtext = round(obj.coolingTime, 1) .. "s /* Unit for seconds */" % _t
            line.iconColor = iconColor
            applyLessBetter(line, obj, other, "coolingTime", 1, (other and other.shotsUntilOverheated > 0))
            tooltip:addLine(line)

            -- empty line
            tooltip:addLine(TooltipLine(8, 8))
        end

        if obj.coolingType == 1 or obj.coolingType == 2 then
            local line = TooltipLine(lineHeight, fontSize)

            if obj.coolingType == 2 then
                line.ltext = "Energy /s" % _t
            else
                line.ltext = "Energy /shot" % _t
            end
            line.rtext = round(obj.baseEnergyPerSecond)
            line.icon = "data/textures/icons/electric.png";
            line.iconColor = iconColor
            applyLessBetter(line, obj, other, "baseEnergyPerSecond", 0,
                (other and (other.coolingType == 1 or other.coolingType == 2)))
            tooltip:addLine(line)

            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "Energy Increase /s" % _t
            line.rtext = round(obj.energyIncreasePerSecond, 1)
            line.icon = "data/textures/icons/electric.png";
            line.iconColor = iconColor
            applyLessBetter(line, obj, other, "energyIncreasePerSecond", 1,
                (other and (other.coolingType == 1 or other.coolingType == 2)))
            tooltip:addLine(line)

            -- empty line
            tooltip:addLine(TooltipLine(8, 8))
        end
    end


    -- damage type
    if obj.damageType ~= DamageType.None then
        local line = TooltipLine(lineHeight, fontSize)
        line.ltext = "Damage Type" % _t
        line.rtext = getDamageTypeName(obj.damageType)
        line.rcolor = getDamageTypeColor(obj.damageType)
        line.lcolor = getDamageTypeColor(obj.damageType)
        line.icon = getDamageTypeIcon(obj.damageType)
        line.iconColor = getDamageTypeColor(obj.damageType)
        tooltip:addLine(line)

        local ltext, rtext
        if obj.damageType == DamageType.AntiMatter then
            ltext = "More damage vs /* Increased damage against Hull */" % _t
            rtext = "Hull /* Increased damage against Hull */" % _t
        elseif obj.damageType == DamageType.Plasma then
            ltext = "More damage vs /* Increased damage against Shields */" % _t
            rtext = "Shields  /* Increased damage against Shields */" % _t
        elseif obj.damageType == DamageType.Fragments then
            ltext = "More damage vs /* Increased damage against Fighters, Torpedoes */" % _t
            rtext = "Fighters, Torpedoes /* Increased damage against Fighters, Torpedoes */" % _t
        elseif obj.damageType == DamageType.Electric then
            ltext = "No damage vs /* No damage to stone */" % _t
            rtext = "Stone /* No damage to stone */" % _t
        end

        if ltext and rtext then
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = ltext
            line.rtext = rtext
            line.lcolor = getDamageTypeColor(obj.damageType)
            line.rcolor = getDamageTypeColor(obj.damageType)
            line.icon = "data/textures/icons/screen-impact.png"
            line.iconColor = getDamageTypeColor(obj.damageType)
            tooltip:addLine(line)
        end

        if obj.damageType == DamageType.Electric then
            local line = TooltipLine(lineHeight, fontSize)
            line.ltext = "x2 damage vs /* Double damage to Technical Blocks */" % _t
            line.rtext = "Technical Blocks /* Double damage to Technical Blocks */" % _t
            line.lcolor = getDamageTypeColor(obj.damageType)
            line.rcolor = getDamageTypeColor(obj.damageType)
            line.icon = "data/textures/icons/screen-impact.png"
            line.iconColor = getDamageTypeColor(obj.damageType)
            tooltip:addLine(line)
        end

        -- empty line
        tooltip:addLine(TooltipLine(8, 8))
    end
end
