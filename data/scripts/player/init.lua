package.path = package.path .. ";data/scripts/lib/?.lua"

if onServer() then
    local player = Player()
    player:addScriptOnce("data/scripts/player/ui/alertCore.lua")
    player:addScriptOnce("data/scripts/player/ui/auraCore.lua")
    player:addScriptOnce("data/scripts/player/ui/combatGroup.lua")
    player:addScriptOnce("data/scripts/player/starfallcodex.lua")
    player:addScriptOnce("data/scripts/player/ui/interfaces/activeSysInterface.lua")
end
