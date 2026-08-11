
package.path = package.path .. ";data/scripts/lib/?.lua"

local StarfallServer = {}

function StarfallServer.initialize()
    if onServer() then
        Server():registerCallback("onPlayerLogIn", "onPlayerLogIn")
    end
end


if onServer() then
    local oldInit = initialize or function() end
    function initialize()
        oldInit()
        StarfallServer.initialize()
    end
end

local old_onPlayerLogIn = onPlayerLogIn
function onPlayerLogIn(playerIndex)
    if old_onPlayerLogIn then old_onPlayerLogIn(playerIndex) end
    local player = Player(playerIndex)
    if player then
        player:addScriptOnce("data/scripts/player/ui/alertCore.lua")
        player:addScriptOnce("data/scripts/player/ui/auraCore.lua")
        player:addScriptOnce("data/scripts/player/ui/combatGroup.lua")
        player:addScriptOnce("data/scripts/player/ui/infoTab/infoTabCore.lua")
        player:addScriptOnce("data/scripts/player/ui/interfaces/activeSysInterface.lua")
        player:addScriptOnce("data/scripts/player/background/starfall_combat_injector.lua")
    end
end
