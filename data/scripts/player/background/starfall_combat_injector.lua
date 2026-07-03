package.path = package.path .. ";data/scripts/lib/?.lua"

function initialize()
    if onServer() then
        Player():registerCallback("onSectorEntered", "onSectorEntered")
        
        -- Inject into current sector immediately upon login/initialization
        local sector = Sector()
        if sector then
            sector:addScriptOnce("data/scripts/sector/starfall_combat_handler.lua")
        end
    end
end

function onSectorEntered(playerIndex, x, y, sectorChangeType)
    local sector = Sector()
    if sector then
        sector:addScriptOnce("data/scripts/sector/starfall_combat_handler.lua")
    end
end
