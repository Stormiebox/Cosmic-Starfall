package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/player/ui/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

include('Armory')
include("callable")
include("utility")
include('Neltharaku')

--namespace mainCaliber
mainCaliber = {}

local _debug = false
local MCallowed = 2    --Number of main guns available for installation. If there are more turrets, the ship receives penalties
local ASPDpenalty = 25 --Percentages, reduction in rate of fire for each extra main battery on the ship above the norm
local _icon = ''

local MCfound = 0
local debuffValue = 0
local DoNotShowAlert = false
local initSW = true

local locLines = {}
locLines['overload'] =
"Overload of weapon systems! Weapons of the 'main caliber' class are set to exceed the safe limit. The rate of fire of the weapons is reduced by " %
_t

_colorG = ColorHSV(150, 64, 100)
_colorY = ColorHSV(60, 94, 78)
_colorR = ColorHSV(16, 97, 84)
_colorB = ColorHSV(240, 40, 100)
_colorC = ColorHSV(264, 60, 100)

function mainCaliber.DebugMsg(_text)
	if _debug then
		print('Main Caliber|', _text)
	end
end

local Debug = mainCaliber.DebugMsg
local TSR = Neltharaku.TableSelfReport

--------------------------------------------------------------------------------------------

function mainCaliber.getUpdateInterval()
	return 1
end

function mainCaliber.update(timeStep)
	if onClient() then
		mainCaliber.visuals()
	else
		--Main caliber.check weapons()
	end
end

function mainCaliber.initialize()
	Debug('initialize')
	if onServer() then
		local self = Entity()
		self:registerCallback('onTurretDestroyed', 'checkWeaponsDeleted')
		self:registerCallback('onTurretRemoved', 'checkWeaponsDeleted')
		self:registerCallback('onTurretonTurretRemovedByPlayerDestroyed', 'checkWeaponsDeleted')
		self:registerCallback('onTurretAdded', 'checkWeaponsAdded')
	end
	_icon = getWeaponPath('cyclone')
end

function mainCaliber.initializationFinished()
	if onClient() then
		mainCaliber.checkWeaponsDeleted()
	end
end

--Counts the number of installed "main caliber" weapons for calls with the addition of a turret
function mainCaliber.checkWeaponsAdded(shipIndex, turretIndex, isMC)
	--Cutting off the flow
	if onServer() then
		if Player(callingPlayer) then
			local isHeavy = false

			--Control of the installation of a "main caliber" type gun
			if Weapons(turretIndex) then
				if isTurretMC(nil, nil, Weapons(turretIndex)) then
					Debug('weapon is MC')
					isHeavy = true
				end
			else
				Debug('Weapons - failure: nil')
				return
			end

			invokeClientFunction(Player(callingPlayer), 'checkWeaponsAdded', shipIndex, turretIndex, isHeavy)
			return
		end
	end

	--Additional clipping check: the script only fires if the mounted weapon belongs to the MC
	if not (isMC) then return end

	local self = Entity()
	MCfound = 1

	--Cutting off
	if not (self) then return end

	--Search for installed tourettes
	local installedTurrets = { self:getTurrets() }

	--Enumerating tourettes, searching and counting matches with the main code
	for _, _rows in pairs(installedTurrets) do
		local _weapon = ReadOnlyWeapons(_rows.id)
		if isTurretMC(nil, nil, _weapon) then
			MCfound = MCfound + 1
			Debug('MC found | ' .. self.name)
		end
	end

	--Calls the penalty handler
	mainCaliber.setRestrictions()
	Debug(tostring(MCfound) .. ' MCfound')
end

--Counts the number of installed "main caliber" weapons for calls with turret removal
function mainCaliber.checkWeaponsDeleted()
	if onServer() then
		invokeClientFunction(Player(), 'checkWeaponsDeleted')
		return
	end

	--Starting variables
	Debug('checkWeapons attempt')
	local self = Entity()
	MCfound = 0

	--Cutting off
	if not (self) then return end

	--Search for installed tourettes
	local installedTurrets = { self:getTurrets() }

	--Enumerating tourettes, searching and counting matches with the main code
	for _, _rows in pairs(installedTurrets) do
		local _weapon = ReadOnlyWeapons(_rows.id)
		if isTurretMC(nil, nil, _weapon) then
			MCfound = MCfound + 1
			Debug('MC found | ' .. self.name)
		end
	end

	--Calls the penalty handler
	mainCaliber.setRestrictions()
	Debug(tostring(MCfound) .. ' MCfound')
end

--Responsible for processing assigned fines
function mainCaliber.setRestrictions()
	--Concretization
	if onServer() then return end

	Debug('setRestrictions attempt')
	--Variables
	local self = Entity()
	local difference = MCfound - MCallowed --For convenience: the coefficient of the imposed fine
	local penalty = ASPDpenalty * -0.01 * difference
	Debug('difference is: ' .. tostring(difference))

	--Cutting off
	if not (self) then return end

	--Fines processing: within the limit
	if difference <= 0 then
		--Removal of the established fine
		invokeServerFunction('serverApplyFirerate', 0)
	else
		--Assignment of the fine
		invokeServerFunction('serverApplyFirerate', penalty)
	end
end

function mainCaliber.serverApplyFirerate(_amount)
	--Variables
	local self = Entity()
	Debug('serverApplyFirerate + amount: ' .. tostring(_amount) .. ' | ' .. self.name)

	--Cutting off
	if not (_amount) then return end

	--Bonus purpose
	if _amount < 0 then
		self:removeBonus(1001)
		self:addKeyedAbsoluteBias(StatsBonuses.FireRate, 1001, _amount)
		Debug('Bonus applied')
	else
		--Bonus exclusion
		self:removeBonus(1001)
		Debug('Bonus removed')
	end
end

callable(mainCaliber, 'serverApplyFirerate')

--Processes visual effects
function mainCaliber.visuals()
	if onServer() then return end
	--Debug('visuals attempt')
	--Variables
	local self = Entity()
	local difference = MCfound - MCallowed --For convenience: the coefficient of the imposed fine
	local penalty = ASPDpenalty * difference

	--Cutting off
	if not (self) then return end

	--Processing the problem icon: resetting the icon if there is no penalty
	if MCfound <= MCallowed then
		removeShipProblem("MCpenalty", self.id)
	else
		local line = string.format("%s%i%%", locLines['overload'], penalty)
		addShipProblem("MCpenalty", self.id, line, getWeaponPath('cyclone'), _colorR, false)
	end
end

--Handles an alert button click
function mainCaliber.onDontShowPress(_button)
	_button.active = false
	DoNotShowAlert = true
end
