
package.path = package.path .. ";data/scripts/lib/?.lua"

if onServer() then
    local player = Player()
    player:addScriptOnce("data/scripts/player/ui/alertCore.lua")
    player:addScriptOnce("data/scripts/player/ui/auraCore.lua")
    player:addScriptOnce("data/scripts/player/ui/combatGroup.lua")
    player:addScriptOnce("data/scripts/player/ui/infoTab/infoTabCore.lua")
    player:addScriptOnce("data/scripts/player/ui/interfaces/activeSysInterface.lua")

    -- [[ Cosmic Vault: Legendary DoT Hooks ]] --
    player:addScriptOnce("data/scripts/player/background/starfall_combat_injector.lua")
end
