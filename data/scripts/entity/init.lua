if onServer() then
	local thisShip = Entity()
	if (thisShip.isShip or thisShip.isStation) and (Owner(thisShip.id).isPlayer or Owner(thisShip.id).isAlliance) then
		Entity():addScriptOnce("systems/raycast.lua")
		--Entity():addScriptOnce("entity/groupInterface.lua")
		Entity():addScriptOnce("entity/entityAlerts.lua")
		Entity():addScriptOnce("entity/mainCaliber.lua")
	end
end