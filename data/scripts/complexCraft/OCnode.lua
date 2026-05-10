package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/systems/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/player/ui/?.lua"

include('Neltharaku')
include('Aquaflow')
include('callable')

--namespace OCore
OCore = {}

local _debug = false
local testTable = {}
local TSR = Neltharaku.TableSelfReport
local colorResultRect = nil

local iconNew = 'data/textures/icons/ui/ui_submitWOring.png'

local locIcons = {}
	locIcons['party'] = 'data/textures/icons/party.png'

local elements = {}
local colorH
local colorS
local colorV

function OCore.DebugMsg(_text)
	if _debug then
		print('OCore('..Entity().name..')| ',_text)
	end
end
local Debug = OCore.DebugMsg

local OCCwindow,OCCbutton1,OCCbutton2,OCCbutton3

function OCore.interactionPossible(playerIndex, option)
    local player = Player()
    if Entity().index == player.craftIndex then
        return true
    end
end

function OCore.CreateTestTable()
	
	if onClient() then
		invokeServerFunction('CreateTestTable')
	else
		OCore.DebugMsg('function: CreateTable')
		testTable = {'Oh, my,','this is','Patrick!'}
	end
	
end
callable(OCore,'CreateTestTable')

function OCore.RestoreTestTable()
	if onClient() then
		invokeServerFunction('RestoreTestTable')
	else
		OCore.DebugMsg('function: RestoreTable')
		if #testTable==0 then OCore.DebugMsg('table is empty') return end
		for _,_str in pairs(testTable) do
			OCore.DebugMsg(_str)
		end
	end
end
callable(OCore,'RestoreTestTable')

function OCore.initUI()
	local res = getResolution()
	local size = vec2(400, 350)
	local frameV2 = vec2(370,270) --вторая точка для ректа скроллера первых двух вкладок
	
	OCCwindow = ScriptUI():createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))
	ScriptUI():registerWindow(OCCwindow, 'Экспериментальный функционал')
	OCCwindow.caption = "Экспериментальный функционал"
	OCCwindow.showCloseButton = true
    OCCwindow.moveable = true
	
	local rPaddingX = 5
	local rUnit = 35
	local rPaddingY = 5
	local rectButtons = {}
	local rectPicker = {}
	for i=0,4 do
		local X1 = (rPaddingX * (i+1) + rUnit*i)
		local X2 = X1 + rUnit
		local _rectResult = Rect(X1,rPaddingY,X2,rPaddingY+rUnit)
		table.insert(rectButtons,_rectResult)
	end
	
	-- local button1 = Rect(5,5,35,35)
	-- local button2 = Rect(40,5,70,35)
	-- local button3 = Rect(75,5,105,35)
	
	OCCbutton1=OCCwindow:createRoundButton(rectButtons[1], "data/textures/icons/SUBSYSPolarisationNanobots.png","inventoryCheck")
		OCCbutton1.tooltip = "Inventory check"
	OCCbutton2=OCCwindow:createRoundButton(rectButtons[2], "data/textures/icons/SUBSYSPolarisationNanobots.png","RestoreTestTable")
		OCCbutton2.tooltip = "Отобразить таблицу"
	OCCbutton3=OCCwindow:createRoundButton(rectButtons[3], "data/textures/icons/fill-up-arrow.png","aquaSave")
		OCCbutton3.tooltip = "Save"
	OCCbutton4=OCCwindow:createRoundButton(rectButtons[4], locIcons['party'],"aquaLoad")
		OCCbutton4.tooltip = "Load"
		
	local colorPickerY = rPaddingY * 2 + rUnit
	
	for i=0,4 do
		local X1 = (rPaddingX * (i+1) + rUnit * 2 * i)
		local X2 = X1 + rUnit*2
		local _rectResult = Rect(X1,colorPickerY,X2,colorPickerY+rUnit)
		table.insert(rectPicker,_rectResult)
	end
	
	colorH = OCCwindow:createTextBox(rectPicker[1],'colorChangeH')
	colorS = OCCwindow:createTextBox(rectPicker[2],'colorChangeV')
	colorV = OCCwindow:createTextBox(rectPicker[3],'colorChangeS')
	colorResultRect = OCCwindow:createProgressBar(rectPicker[4],ColorHSV(264, 60, 100))
		colorResultRect.progress = 1
		
	local h = tostring(colorResultRect.color.hue)
	local v = tostring(colorResultRect.color.value)
	local s = tostring(colorResultRect.color.saturation)
	Debug('current start hsv is '..h..'|'..v..'|'..s)
	
	local cont = OCCwindow
	local recto = OCore.createRect
	local labelFontSize = rUnit
	local labelN = {
		rUnit * 0.1, colorPickerY + rUnit,
		rUnit*2,
		rUnit
	}
	local iconN = {
		labelN[1] + labelN[3], labelN[2],
		rUnit,
		rUnit
	}
	local buttonN = {
		iconN[1] + iconN[3] + rUnit, labelN[2],
		rUnit,
		rUnit
	}
	
	elements['label'] = cont:createLabel(recto(labelN),'123',labelFontSize)
	elements['icon'] = cont:createPicture(recto(iconN),iconNew)
		elements['icon'].isIcon = true
	elements['button'] = cont:createRoundButton(recto(buttonN),iconNew,'applyButtonChanges')
	
end

function OCore.aquaSave()
	--if onClient() then invokeServerFunction('aquaSave') return end
	-- local testTable = {
		-- true,
		-- {'data1','data2'},
		-- 123
	-- }
	Aquaflow.createNewFileC('AquaTest','Meow!')
	--Aquaflow.saveData('OCnode',testTable)
end
callable(OCore,'aquaSave')

function OCore.aquaLoad() 
	if onClient() then invokeServerFunction('aquaLoad') return end

	local data = Aquaflow.loadData('OCnode')
	TSR(data,'loaded data')
end
callable(OCore,'aquaLoad')

function OCore.tryNewFile()
	if onClient() then
		invokeServerFunction('tryNewFile')
		return
	else
		local testTable = {
			true,
			{'data1','data2'},
			123
		}
		Aquaflow.saveData('OCnode',testTable)
	end
	
end
callable(OCore,'tryNewFile')

function OCore.applyButtonChanges()
	local H = tonumber(colorH.text)
	local S = tonumber(colorS.text)
	local V = tonumber(colorV.text)
	
	local isNotNils = (H and S and V)
	
	if not(isNotNils) then return end
	
	local isOk = ((H>0) and (S>0) and (V>0))
	
	if not(isOk) then return end
	
	local newColor = ColorHSV(H,S,V)
	
	elements['label'].color = newColor
	elements['icon'].color = newColor
	
end

function OCore.colorChangeH(_element)
	if _element.text == '' then return end

	local _color = colorResultRect.color
	
	--_color.hue = tonumber(_element.text)*0.01
	local _hue = tonumber(_element.text)
	Debug(tostring(_hue)..' _hue')
	Debug(_element.text)
	_color.hue = _hue
	
	colorResultRect.color = _color
	local h = tostring(colorResultRect.color.hue)
	local v = tostring(colorResultRect.color.value)
	local s = tostring(colorResultRect.color.saturation)
	Debug('current hsv is '..h..'|'..v..'|'..s)
end

function OCore.colorChangeV(_element)
	if _element.text == '' then return end
	
	local _color = colorResultRect.color
	_color.value = tonumber(_element.text)*0.01
	colorResultRect.color = _color
	local h = tostring(colorResultRect.color.hue)
	local v = tostring(colorResultRect.color.value)
	local s = tostring(colorResultRect.color.saturation)
	Debug('current hsv is '..h..'|'..v..'|'..s)
end

function OCore.colorChangeS(_element)
	if _element.text == '' then return end
	
	local _color = colorResultRect.color
	_color.saturation = tonumber(_element.text)*0.01
	colorResultRect.color = _color
	local h = tostring(colorResultRect.color.hue)
	local v = tostring(colorResultRect.color.value)
	local s = tostring(colorResultRect.color.saturation)
	Debug('current hsv is '..h..'|'..v..'|'..s)
end

function OCore.ScanShips()
	OCore.DebugMsg('Scan ships attempt')

	local _d = {Sector():getEntitiesByType(EntityType.Ship)}
	
	for i=1,#_d do
		if _d[i]. playerOrAllianceOwned then
			local _entity = _d[i]
			if _entity.name=='Destro' then OCore.DebugMsg('Destro Detected!') end
			local _id = _entity.id
			local _descriptor = EntityDescriptor(_id)
			
			OCore.DebugMsg(_entity.name)
			OCore.DebugMsg('Can pass rifts: '..tostring(_descriptor.canPassRifts))
			
			--print('Position: ',_descriptor.position.position.x,_descriptor.position.position.y,_descriptor.position.position.z)
			local _resultScan = false
			OCore.DebugMsg('___________________')
		end
	end
end

function OCore.generateTestAlert()
	Player():invokeFunction('alertCore','TestGeneralAlertCreation') 
end

function OCore.generateTestAlertGreen()
	Player():invokeFunction('alertCore','TestGeneralAlertCreation2') 
end

function OCore.inventoryCheck()
	Debug('inventoryCheck attempt')
	local _name = 'Штурмовая'
	local turret = Player():getInventory():find(14)
	if turret then
		if turret.flavorText then Debug('turret flavorText: '..turret.flavorText) end
		if turret.category then Debug('turret category: '..turret.category) end	
		if turret.weaponName then Debug('turret weaponName: '..turret.weaponName) end	
		Debug('turret name: '..turret.name)
	end
	local wpn = turret:getWeapons()
	TSR(wpn,'wpn')
	local iconpath = wpn.icon
	Debug(iconpath)
	
	local inventory = Player():getInventory()
	--TSR(inventory)
	--Debug('inventoryLength: '..tostring(#inventory))
	local _calc = 0
	local occupiedSlots = inventory.occupiedSlots
	
	Debug('occupiedSlots '..tostring(occupiedSlots))
	
	-- for _index,_rows in pairs(inventory) do
		-- --if _rows[1]~=nil then
			-- Debug(_rows[1].name)
			-- _calc = _calc + 1
		-- --end
	-- end
	Debug('calc is '..tostring(_calc))
end

function OCore.fullID()
	if onClient() then
		print(Player().fullLogId)
		invokeServerFunction('fullID')
	else
		print(Player().fullLogId)
		print(Faction().fullLogId)
	end
	
	
end
callable(OCore,'fullID')

function OCore.checkTurrets()
	local me = Entity()
	local anyturret = {me:getTurrets()}
	local turrets = ReadOnlyWeapons(anyturret[1].id)
	Debug(turrets.weaponIcon)
	Debug(turrets.weaponName)
	--TSR(turrets,'turrets')
end

function OCore.secure()
	local savedTable = {}
	return {savedTable = testTable}
end

function OCore.restore(values)
	if values.savedTable then
		OCore.DebugMsg('restore attempt')
		testTable = values.savedTable
	end
end

function OCore.createRect(_table)
	local Anchor = vec2(_table[1],_table[2])
	local Point = vec2(Anchor.x + _table[3],Anchor.y + _table[4])
	local resultRect = Rect(Anchor,Point)
	return resultRect
end