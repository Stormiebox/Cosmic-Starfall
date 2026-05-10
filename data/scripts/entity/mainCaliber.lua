package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/player/ui/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"

include('Armory')
include("callable")
include ("utility")
include('Neltharaku')

--namespace mainCaliber
mainCaliber = {}

local _debug = false
local MCallowed = 2 --Кол-во доступных для установки пушек типа ГК. Если турелей больше - корабль получает штрафы
local ASPDpenalty = 25 --Проценты, снижение скорострельности за каждый лишний ГК на корабле сверх нормы
local _icon = ''

local MCfound = 0
local debuffValue = 0
local DoNotShowAlert = false
local initSW = true

local locLines = {}
	locLines['overload'] = "Overload of weapon systems! Weapons of the 'main caliber' class are set to exceed the safe limit. The rate of fire of the weapons is reduced by "%_t

_colorG = ColorHSV(150, 64, 100)
_colorY = ColorHSV(60, 94, 78)
_colorR = ColorHSV(16, 97, 84)
_colorB = ColorHSV(240, 40, 100)
_colorC = ColorHSV(264, 60, 100)

function mainCaliber.DebugMsg(_text)
	if _debug then
		print('Main Caliber|',_text)
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
		--mainCaliber.checkWeapons()
	end
end

function mainCaliber.initialize()
	Debug('initialize')
	if onServer() then
		local self = Entity()
		self:registerCallback('onTurretDestroyed','checkWeaponsDeleted')
		self:registerCallback('onTurretRemoved','checkWeaponsDeleted')
		self:registerCallback('onTurretonTurretRemovedByPlayerDestroyed','checkWeaponsDeleted')
		self:registerCallback('onTurretAdded','checkWeaponsAdded')
	end
	_icon = getWeaponPath('cyclone')
end

function mainCaliber.initializationFinished()
	if onClient() then
		mainCaliber.checkWeaponsDeleted()
	end
end

--Подсчитывает кол-во установленных орудий типа "главный калибр" для вызовов с добавлением туреты
function mainCaliber.checkWeaponsAdded(shipIndex, turretIndex, isMC)

	--Отсекание потока
	if onServer() then
		if Player(callingPlayer) then
			local isHeavy = false
		
			--Контроль установки орудия типа "главный калибр"
			if Weapons(turretIndex) then
				if isTurretMC(nil,nil,Weapons(turretIndex)) then
					Debug('weapon is MC')
					isHeavy = true
				end
			else
				Debug('Weapons - failure: nil')
				return
			end
		
			invokeClientFunction(Player(callingPlayer),'checkWeaponsAdded',shipIndex,turretIndex,isHeavy)
			return
		end
	end
	
	--Дополнительная проверка отсекания: скрипт срабатывает, только если устанавливаемое орудие принадледит MC
	if not(isMC) then return end

	local self = Entity()
	MCfound = 1

	--Отсекание
	if not(self) then return end
	
	--Поиск установленных туреток
	local installedTurrets = {self:getTurrets()}
	
	--Перебор туреток, поиск и подсчет совпадений с ГК
	for _,_rows in pairs(installedTurrets) do
		local _weapon = ReadOnlyWeapons(_rows.id)
		if isTurretMC(nil,nil,_weapon) then
			MCfound = MCfound + 1
			Debug('MC found | '..self.name)
		end
	end
	
	--Вызывает обработчик штрафов
	mainCaliber.setRestrictions()
	Debug(tostring(MCfound)..' MCfound')
end

--Подсчитывает кол-во установленных орудий типа "главный калибр" для вызовов с удалением туреты
function mainCaliber.checkWeaponsDeleted()

	if onServer() then
		invokeClientFunction(Player(),'checkWeaponsDeleted')
		return
	end
	
	--Стартовые переменные
	Debug('checkWeapons attempt')
	local self = Entity()
	MCfound = 0
	
	--Отсекание
	if not(self) then return end
	
	--Поиск установленных туреток
	local installedTurrets = {self:getTurrets()}
	
	--Перебор туреток, поиск и подсчет совпадений с ГК
	for _,_rows in pairs(installedTurrets) do
		local _weapon = ReadOnlyWeapons(_rows.id)
		if isTurretMC(nil,nil,_weapon) then
			MCfound = MCfound + 1
			Debug('MC found | '..self.name)
		end
	end
	
	--Вызывает обработчик штрафов
	mainCaliber.setRestrictions()
	Debug(tostring(MCfound)..' MCfound')
end

--Отвечает за обработку назначаемых штрафов
function mainCaliber.setRestrictions()

	--Конкретизация
	if onServer() then return end
	
	Debug('setRestrictions attempt')
	--Переменные
	local self = Entity()
	local difference = MCfound - MCallowed --Для удобства: коэффициент накладываемого штрафа
	local penalty = ASPDpenalty * -0.01 * difference
	Debug('difference is: '..tostring(difference))
	
	--Отсекание
	if not(self) then return end
	
	--Обработка штрафов: в пределах лимита
	if difference<=0 then
		--Снятие установленного штрафа
		invokeServerFunction('serverApplyFirerate',0)
	else
		--Назначение штрафа
		invokeServerFunction('serverApplyFirerate',penalty)
	end
end

function mainCaliber.serverApplyFirerate(_amount)
	--Переменные
	local self = Entity()
	Debug('serverApplyFirerate + amount: '..tostring(_amount)..' | '..self.name)
	
	--Отсекание
	if not(_amount) then return end
	
	--Назначение бонуса
	if _amount<0 then
		self:removeBonus(1001)
		self:addKeyedAbsoluteBias(StatsBonuses.FireRate,1001,_amount)
		Debug('Bonus applied')
	else
	--Исключение бонуса
		self:removeBonus(1001)
		Debug('Bonus removed')
	end
end
callable(mainCaliber,'serverApplyFirerate')

--Обрабатывает визуальные эффекты
function mainCaliber.visuals()
	if onServer() then return end
	--Debug('visuals attempt')
	--Переменные
	local self = Entity()
	local difference = MCfound - MCallowed --Для удобства: коэффициент накладываемого штрафа
	local penalty = ASPDpenalty * difference
	
	--Отсекание
	if not(self) then return end
	
	--Обработка иконки проблем: сброс иконки при отсутствии штрафа
	if MCfound<=MCallowed then
		removeShipProblem("MCpenalty", self.id)
	else
		local line = string.format("%s%i%%",locLines['overload'],penalty)
		addShipProblem("MCpenalty", self.id, line, getWeaponPath('cyclone'), _colorR,false)
	end
	
end

--Обрабатывает нажатие кнопки алерта
function mainCaliber.onDontShowPress(_button)
	_button.active = false
	DoNotShowAlert = true
end