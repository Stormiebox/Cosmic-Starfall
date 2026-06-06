local cs_old_player_init = initialize
function initialize(...)
    if cs_old_player_init then cs_old_player_init(...) end

    if onServer() then
        Player():addScriptOnce("ui/alertCore.lua")
        Player():addScriptOnce("ui/auraCore.lua")
        --Player():addScriptOnce("ui/combatGroup.lua")
        Player():addScriptOnce("ui/combatGroupV2.lua")
        Player():addScriptOnce("ui/infoTab/infoTabCore.lua")
        Player():addScriptOnce("ui/interfaces/activeSysInterface.lua")
    end
end
