package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/player/ui/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

include('Armory')
include("callable")
include("utility")
include('Neltharaku')

--namespace mainCaliber
mainCaliber = {}

local _debug = false
local MCallowed = 2    --Number of main guns available for installation. If there are more turrets, the ship receives penalties
local ASPDpenalty = 25 --Percentages, reduction in rate of fire for each extra main battery on the ship above the norm
local _icon = ''

local MCfound = 0
local DoNotShowAlert = false

local locLines = {}
locLines['overload'] =
    "Overload of weapon systems! Weapons of the 'main caliber' class are set to exceed the safe limit. The rate of fire of the weapons is reduced by " %
    _t

local _colorR = ColorHSV(16, 97, 84)

function mainCaliber.DebugMsg(_text)
    if _debug then
        print('Main Caliber|', _text)
    end
end

local Debug = mainCaliber.DebugMsg

function mainCaliber.initialize()
    Debug('initialize')
    _icon = getWeaponPath('cyclone')
    if onServer() then
        local self = Entity()
        self:registerCallback('onTurretDestroyed', 'checkWeapons')
        self:registerCallback('onTurretRemoved', 'checkWeapons')
        self:registerCallback('onTurretAdded', 'checkWeapons')
        deferredCallback(1.0, "checkWeapons")
    end
end

function mainCaliber.initializationFinished()
    if onClient() then
        invokeServerFunction("requestVisualSync")
    end
end

function mainCaliber.requestVisualSync()
    if onClient() then return end
    invokeClientFunction(Player(callingPlayer), "syncVisuals", MCfound)
end

callable(mainCaliber, "requestVisualSync")

function mainCaliber.checkWeapons()
    if onClient() then return end
    local self = Entity()
    if not (self) then return end

    MCfound = 0
    local installedTurrets = { self:getTurrets() }

    for _, _rows in pairs(installedTurrets) do
        local _weapon = ReadOnlyWeapons(_rows.id)
        if isTurretMC(nil, nil, _weapon) then
            MCfound = MCfound + 1
        end
    end

    mainCaliber.setRestrictions()
    self:broadcastInvokeClientFunction('syncVisuals', MCfound)
end

function mainCaliber.setRestrictions()
    if onClient() then return end

    local self = Entity()
    if not (self) then return end

    local difference = MCfound - MCallowed

    if difference > 0 then
        local penalty = ASPDpenalty * -0.01 * difference
        self:removeBonus(1001)
        self:addKeyedAbsoluteBias(StatsBonuses.FireRate, 1001, penalty)
    else
        self:removeBonus(1001)
    end
end

function mainCaliber.syncVisuals(found)
    if onServer() then return end
    MCfound = found
    mainCaliber.visuals()
end

function mainCaliber.visuals()
    if onServer() then return end
    local self = Entity()
    if not (self) then return end

    if MCfound <= MCallowed then
        removeShipProblem("MCpenalty", self.id)
    else
        local difference = MCfound - MCallowed
        local penalty = ASPDpenalty * difference
        local line = string.format("%s%i%%", locLines['overload'], penalty)
        addShipProblem("MCpenalty", self.id, line, _icon, _colorR, false)
    end
end

--Handles an alert button click
function mainCaliber.onDontShowPress(_button)
    _button.active = false
    DoNotShowAlert = true
end
