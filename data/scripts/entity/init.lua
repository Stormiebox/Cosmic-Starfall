if onServer() then
    local thisShip = Entity()
    if (thisShip.isShip or thisShip.isStation) and (Owner(thisShip.id).isPlayer or Owner(thisShip.id).isAlliance) then
        Entity():addScriptOnce("data/scripts/systems/raycast.lua")
        Entity():addScriptOnce("data/scripts/entity/entityAlerts.lua")
        Entity():addScriptOnce("data/scripts/entity/mainCaliber.lua")
    end
end
