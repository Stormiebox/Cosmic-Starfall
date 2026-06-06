local cs_old_player_init = initialize
function initialize(...)
    if cs_old_player_init then cs_old_player_init(...) end

    if onServer() then
        Player():addScriptOnce("data/scripts/player/ui/alertCore.lua")
        Player():addScriptOnce("data/scripts/player/ui/auraCore.lua")
        --Player():addScriptOnce("ui/combatGroup.lua")
        Player():addScriptOnce("data/scripts/player/ui/combatGroupV2.lua")
        Player():addScriptOnce("data/scripts/player/ui/infoTab/infoTabCore.lua")
        Player():addScriptOnce("data/scripts/player/ui/interfaces/activeSysInterface.lua")
    end
end

