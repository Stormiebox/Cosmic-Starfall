include("data/scripts/entity/init.lua")
if onServer() then
    local thisShip = Entity()
    local thisOwner = Owner(thisShip.id)
    if (thisShip.isShip or thisShip.isStation) and thisOwner and (thisOwner.isPlayer or thisOwner.isAlliance) then
        Entity():addScriptOnce("data/scripts/systems/raycast.lua")
        Entity():addScriptOnce("data/scripts/entity/entityAlerts.lua")
        Entity():addScriptOnce("data/scripts/entity/mainCaliber.lua")
        Entity():addScriptOnce("data/scripts/entity/starfall_setbonuses.lua")
    end
end