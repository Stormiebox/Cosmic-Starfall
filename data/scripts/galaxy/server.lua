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

function onPlayerLogIn(playerIndex) end
