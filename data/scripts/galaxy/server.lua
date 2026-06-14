package.path = package.path .. ";data/scripts/lib/?.lua"

local StarfallServer = {}

function StarfallServer.initialize()
    if onServer() then
        Server():registerCallback("onPlayerLogIn", "onPlayerLogIn")
    end
end

function StarfallServer.onPlayerLogIn(playerIndex)
    local player = Player(playerIndex)
    if player then
        player:addScriptOnce("data/scripts/player/starfallcodex.lua")
    end
end

if onServer() then
    local oldInit = initialize or function() end
    function initialize()
        oldInit()
        StarfallServer.initialize()
    end
end
