local cs_old_entity_init = initialize
function initialize(...)
    if cs_old_entity_init then cs_old_entity_init(...) end

    if onServer() then
        local thisShip = Entity()
        if (thisShip.isShip or thisShip.isStation) and (Owner(thisShip.id).isPlayer or Owner(thisShip.id).isAlliance) then
            Entity():addScriptOnce("data/scripts/systems/raycast.lua")
            --Entity():addScriptOnce("entity/groupInterface.lua")
            Entity():addScriptOnce("data/scripts/entity/entityAlerts.lua")
            Entity():addScriptOnce("data/scripts/entity/mainCaliber.lua")
        end
    end
end

