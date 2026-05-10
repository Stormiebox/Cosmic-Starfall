package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/neltharaku/?.lua"

include("callable")
include('Neltharaku')

-- namespace eA
eA = {}
local _opByPlayer = false
local _initSystem = true

_colorG = ColorHSV(150, 64, 100)
_colorY = ColorHSV(60, 94, 78)
_colorR = ColorHSV(16, 97, 84)
_colorB = ColorHSV(240, 40, 100)
_colorC = ColorHSV(264, 60, 100)


local _debug = true
function eA.DebugMsg(_text)
	if _debug then
		print(_text)
	end
end
local Debug =  eA.DebugMsg
--local toIcon = Neltharaku.convertToIconPath

function eA.getUpdateInterval()
	return 1
end

function eA.update(timeStep)
	if _initSystem then
		_initSystem = false
		eA.initSystem()
	end
	
	if not(Player()) or not(Entity()) or Entity().index~=Player().craftIndex then
		_opByPlayer = false
		return
	else
		_opByPlayer = true
	end
end

function eA.initSystem()
	if onClient() then
		--Player():registerCallback('onShipChanged','testShipChanged')
	end
	if onServer() then
		Entity():registerCallback('onTurretDestroyed','alertTurretDamage')
	end
end

function eA.alertTurretDamage()
	if onServer() then
		invokeClientFunction(Player(),'onTurretDamage')
	else
		Player():invokeFunction('alertCore','entityTurretDestroyed')
	end
end


