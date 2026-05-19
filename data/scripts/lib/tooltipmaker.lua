package.path = package.path .. ";data/scripts/neltharaku/?.lua"

include('Armory')

local locLines = {}
locLines['weaponclass'] = "Weapon class" % _t
locLines['weaponclass_light'] = "Light" % _t
locLines['weaponclass_heavy'] = "Heavy" % _t
locLines['weaponclass_mc'] = "Main Caliber" % _t
locLines['weaponclass_Standard'] = "Standard" % _t
locLines['projspeed'] = "Projectile speed" % _t
locLines['instant'] = "Instant" % _t

local old_makeTurretTooltip = makeTurretTooltip
function makeTurretTooltip(turret, other, tooltipType)
    local tooltip = old_makeTurretTooltip(turret, other, tooltipType)

    if not tooltip then return tooltip end

    local fontSize = 13
    local lineHeight = 16
    local iconColor = ColorRGB(1, 1, 1)

    tooltip:addLine(TooltipLine(8, 8))

    -- Add weapon class
    local line = TooltipLine(lineHeight, fontSize)
    local wType = nil
    local wColor = nil
    line.ltext = locLines['weaponclass']

    if isTurretLight(turret) then
        wType = locLines['weaponclass_light']
        wColor = getTypeColor('Light')
    end

    if isTurretHeavy(turret) then
        wType = locLines['weaponclass_heavy']
        wColor = getTypeColor('Heavy')
    end

    if isTurretMC(turret) then
        wType = locLines['weaponclass_mc']
        wColor = getTypeColor('MC')
    end

    if not (wType) and not (wColor) then
        line.rtext = locLines['weaponclass_Standard']
    else
        line.rtext = wType
        line.rcolor = wColor
    end

    line.icon = "data/textures/icons/ASSAULTBLASTER.png";
    line.iconColor = iconColor
    tooltip:addLine(line)
    -- Projectile speed line
    if turret.shotSpeed then
        local pLine = TooltipLine(lineHeight, fontSize)
        pLine.ltext = locLines['projspeed']

        if turret.shotSpeed > 10000 then
            pLine.rtext = locLines['instant']
        else
            pLine.rtext = round(turret.shotSpeed, 0)
        end

        pLine.icon = "data/textures/icons/PARTICLEACCELERATOR.png"
        pLine.iconColor = iconColor
        tooltip:addLine(pLine)
    end

    return tooltip
end
