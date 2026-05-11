package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('callable')
include('ColorLib')
include('Tech')
include('Aquaflow')
include('Neltharaku')

--namespace activeSysInterface
activeSysInterface = {}

local locLines = {}
locLines['switchframes'] = "Switch frames on/off" % _t
locLines['movewindows'] = "Enable/disable window move mode" % _t
locLines['hideMainIcon'] = "Switch system icon on/off" % _t
locLines['pickcolors'] = "Change progressbar colors" % _t
locLines['default'] = "Reset settings to default" % _t
locLines['maintooltip'] = "Open/close 'active system interface' settings" % _t

locLines['frameready'] = "Set 'ready' color" % _t
locLines['framestandby'] = "Set 'standby' color" % _t
locLines['framecooldown'] = "Set 'cooldown' color" % _t
locLines['framerecharge'] = "Set 'recharge' color" % _t
local locIcons = {}
locIcons['system'] = 'data/textures/icons/ui/ui_circutry.png'
locIcons['framesfull'] = 'data/textures/icons/ui/ui_framesfull.png'
locIcons['framesempty'] = 'data/textures/icons/ui/ui_framesempty.png'
locIcons['moveactivate'] = 'data/textures/icons/ui/ui_moveinterface.png'
locIcons['movedeactivate'] = 'data/textures/icons/ui/ui_point.png'
locIcons['movedragicon'] = 'data/textures/icons/ui/ui_arrowsnoring.png'
locIcons['movedragiconexpanded'] = 'data/textures/icons/ui/ui_arrowsexpanded.png'
locIcons['hidemainicon'] = 'data/textures/icons/ui/ui_hideMainIcon.png'
locIcons['colors'] = 'data/textures/icons/ui/ui_colors.png'
locIcons['colorsclose'] = 'data/textures/icons/ui/ui_colorsClose.png'
locIcons['default'] = 'data/textures/icons/ui/ui_default.png'
locIcons['update'] = 'data/textures/icons/uiUpdate.png'
locIcons['submit'] = 'data/textures/icons/submit.png'
locIcons['cancel'] = 'data/textures/icons/cancel.png'


locIcons['bg_rows'] = 'data/textures/icons/ui/bg-4w.png'
local locColors = {}
locColors['systemready'] = 'activeSysInterface_ready'
locColors['systemoncooldown'] = 'activeSysInterface_notready'
locColors['systemstandby'] = 'activeSysInterface_working'
locColors['systemscharge'] = 'weaponclass_light'

local colorsToPick = {
	{
		'activeSysInterface_ready',
		'activeSysInterface_working',
		'activeSysInterface_notready',
		'weaponclass_light',
		'white',
		'green',
	},
	{
		'purple',
		'aqua',
		'grass',
		'radiate',
		'sand',
		'danger',
	},
	{
		'cake',
		'avorion',
		'brown',
		'frozenbear',
		'frozengrass',
		'ice',
	}
}

local _debug = false
function activeSysInterface.DebugMsg(_text)
	if _debug then
		print('activeSysInterface|', _text)
	end
end

local Debug = activeSysInterface.DebugMsg
local sf = string.format
local self = activeSysInterface
local getrect = Neltharaku.createRect
local getline = Neltharaku.getLines
local TSR = Neltharaku.TableSelfReport
local RR = Neltharaku.ReportRect

local rUnit
local mainIconSize
local dragFlag = 1
local updateTimer = 0       --Responsible for the time after which changes are saved
local updateTimerDelay = 10 -- Countdown time before saving
if _debug then updateTimerDelay = 2 end
local sw_drag = false
local sw_isFrames = false
local sw_isRestored = false
local Aquaname = 'aSI'


function activeSysInterface.updateDelay(v)
	if onClient() then
		if not (v) then
			updateTimer = updateTimerDelay
		else
			updateTimer = v
		end
	end
end

local toSave = activeSysInterface.updateDelay

function activeSysInterface.initialize()
	Debug('--------initialize--------')
	if onClient() then
		--Initializing Variables
		rUnit = math.min(getResolution().x, getResolution().y) * 0.05
		mainIconSize = rUnit

		--Actions
		Player():registerCallback("onShipChanged", "showInterface")
		--Player():registerCallback("onShipChanged", "showInterface")
		self.initInterface()
	end
end

--======================================[Initializing variables]======================================================

local activeSystemsOrder = {
	getTechName('repairdrones'),
	getTechName('bastionsystem'),
	getTechName('xperimentalhypergenerator'),
	getTechName('macrofieldprojector'),
	getTechName('pulsetractorbeamgenerator'),
}

local anchorContainers = {}
local syncedData = {}  --for secure needs

local registeredSystems = {}
--registeredSystems[scriptname] = sourcename

local containers = {}
--1 container
--2 script
--3 sourceID
--4 frame

local buttons = {}
--1 button
--2 command
--3 script
--4 sourceID
--5 bar1
--6 index
--7 bar2

local frames = {}
--1 frame
local mainIcons = {}
--1 mainIcon

local dragIcons = {}
--1 icon

local dragStatus = {}
--1 isDrag
--2 offset

local mainIF = {}

local setColors = {}
setColors['ready'] = locColors['systemready']
setColors['cooldown'] = locColors['systemoncooldown']
setColors['standby'] = locColors['systemstandby']
setColors['charge'] = locColors['systemscharge']


--=====================[Update functions]===================================

function activeSysInterface.getUpdateInterval()
	return dragFlag
end

function activeSysInterface.updateClient(timeStep)
	--Checks whether changes need to be saved (default -10 seconds after each window movement)
	if updateTimer > 0 and timeStep then
		updateTimer = math.max(updateTimer - timeStep, 0)
		if updateTimer == 0 then self.executeSave() end
	end

	--Scans active icons and is responsible for movement functionality
	if mainIF['button_sw_move'].icon == locIcons['movedeactivate'] then
		for _name, _rows in pairs(dragIcons) do
			--Window drag functionality
			self.dragContainer(_name)
		end
	end
end

function activeSysInterface.dragContainer(_name)
	local cursor = Mouse()
	local container = anchorContainers[_name]
	local dragIcon = dragIcons[_name]

	local onPressed = cursor:mousePressed(MouseButton.Left)

	--If the cursor is on the icon /flag is raised -draws the icon
	if dragIcon.mouseOver or dragStatus[_name][1] then
		--If the flag is raised, colors the icon and changes the cursor
		if dragStatus[_name][1] then
			dragIcon.color = getColor('auracore_buff')
		else
			dragIcon.color = getColor('white')
		end
		dragIcon.picture = locIcons['movedragiconexpanded']
	else
		dragIcon.picture = locIcons['movedragicon']
		dragIcon.color = getColor('white')
	end

	--If the cursor is pressed on the icon, but there is no flag, sets the flag and fixes the offset
	if not (dragStatus[_name][1]) and onPressed and dragIcon.mouseOver then
		dragStatus[_name][1] = true
		dragStatus[_name][2] = vec2(cursor.position.x - container.position.x, cursor.position.y - container.position.y)
	end

	--If the cursor is not pressed, but the flag is there, remove the flag and drag the window
	if dragStatus[_name][1] and not (onPressed) then
		dragStatus[_name][1] = false
		local offset = dragStatus[_name][2]
		container.position = vec2(cursor.position.x - offset.x, cursor.position.y - offset.y)
		toSave()
		--updateTimer = updateTimerDelay
	end
end

function activeSysInterface.forceUpdate()
	if mainIF['button_sw_move'].icon == locIcons['movedeactivate'] then
		--Speeds up cycles
		dragFlag = 0
	else
		--Slows down cycles
		dragFlag = 1
	end

	self.getUpdateInterval()
	self.updateClient()
end

--=====================[Saving/Loading]====================================

function activeSysInterface.executeSave(data)
	if onClient() then
		local data = {}

		table.insert(data, self.isState(1))

		table.insert(data, self.isState(2))

		local colors = {
			Aquaflow.transformColor(setColors['ready'], true),
			Aquaflow.transformColor(setColors['cooldown'], true),
			Aquaflow.transformColor(setColors['standby'], true),
			Aquaflow.transformColor(setColors['charge'], true)
		}

		table.insert(data, colors)

		for _name, _rows in pairs(anchorContainers) do
			table.insert(data, { _name, _rows.position.x, _rows.position.y })
		end
		Aquaflow.saveData(Aquaname, data)
		return
	end
end

callable(activeSysInterface, 'executeSave')

function activeSysInterface.executeLoad()
	if onClient() then
		local data = Aquaflow.loadData(Aquaname)
		if data then
			self.applyLoadChanges(data)
		end
		return
	end
end

callable(activeSysInterface, 'executeLoad')

function activeSysInterface.applyLoadChanges(data)
	if onServer() then
		-- invokeClientFunction(Player(callingPlayer),'applyLoadChanges',data)
		-- return
	else
		Debug('Loading...')
		data = data[1]

		--Frames
		local flag = data[1]
		if type(flag) ~= 'boolean' then return end
		if flag then
			self.settingsShowFrames()
		end
		--Home icon
		local mainIcon = data[2]
		if type(mainIcon) ~= 'boolean' then return end
		if mainIcon then
			self.settingsShowHideMainIcon()
		end

		--Interface colors
		local colorPack = data[3]
		if colorPack[1] ~= nil then
			setColors['ready'] = colorPack[1]
		end
		if colorPack[2] ~= nil then
			setColors['cooldown'] = colorPack[2]
		end
		if colorPack[3] ~= nil then
			setColors['standby'] = colorPack[3]
		end
		if colorPack[4] ~= nil then
			setColors['charge'] = colorPack[4]
		end

		--Positions
		for i = 4, #data do
			local name = data[i][1]
			local pos = vec2(data[i][2], data[i][3])
			if _debug then
				print('name: ', data[i][1], '| pos: ', pos)
			end
			anchorContainers[name].position = pos
		end

		--Update colors
		self.resetPBcolors()
	end
	Debug('Loading - ok')
end

--====================================[ Rendering interface elements ]================================================

function activeSysInterface.initInterface()
	if onServer() then return end

	local res = getResolution()
	local mainAnchor = vec2(res.x * 0.035, res.y * 0.22)
	local labelFontSize = rUnit * 0.25

	local buttonSize = rUnit * 0.6

	--Creating Anchor Containers and Move Windows
	local anchorIconSize = rUnit * 0.8
	local anchor_drag_button = {
		anchorIconSize * -1, anchorIconSize * -1,
		anchorIconSize,
		anchorIconSize
	}
	for _index, _rows in pairs(getASIinfo()) do
		local anchor_container = {
			res.x * 0.2, res.y * 0.4 + rUnit * (1.2 * _index),
			rUnit * 1,
			rUnit * 1
		}
		anchorContainers[_rows] = Hud():createContainer(getrect(anchor_container))

		dragIcons[_rows] = anchorContainers[_rows]:createPicture(getrect(anchor_drag_button), locIcons['movedragicon'])
		dragIcons[_rows].isIcon = true
		dragIcons[_rows]:hide()
		dragStatus[_rows] = { false, nil }
	end


	--Creating a settings menu
	local main_container = {
		mainAnchor.x, mainAnchor.y,
		rUnit * 1,
		rUnit * 3
	}

	local main_button = {
		rUnit * -0.7, rUnit * 0.05,
		buttonSize,
		buttonSize
	}

	local side_container = {
		main_container[3], 0,
		rUnit * 4,
		rUnit * 3
	}
	local side_line = {
		0, 0,
		0,
		side_container[4]
	}

	mainIF['container'] = Hud():createContainer(getrect(main_container))
	local cont = mainIF['container']

	mainIF['main_button'] = cont:createRoundButton(getrect(main_button), locIcons['system'], 'settingsExpandCollapse')
	mainIF['main_button'].tooltip = locLines['maintooltip']

	mainIF['right_container'] = cont:createContainer(getrect(side_container))
	local contR = mainIF['right_container']
	contR:hide()

	local linesPaddingY = rUnit * 0.1
	local linesPaddingX = rUnit * 0.1
	local labelShift = rUnit * 0.1

	--Line: enable/disable frames
	local button_frames = {
		linesPaddingX, linesPaddingY,
		buttonSize,
		buttonSize
	}
	local label_frames = {
		button_frames[1] + button_frames[3] + linesPaddingX, linesPaddingY + labelShift,
		rUnit * 4,
		buttonSize + labelShift
	}
	local background_frames = {
		linesPaddingX / 2, linesPaddingY / 2,
		label_frames[1] + label_frames[3] + linesPaddingX / 2,
		buttonSize + linesPaddingY
	}

	mainIF['button_sw_frames'] = contR:createRoundButton(getrect(button_frames), locIcons['framesfull'],
		'settingsShowFrames')
	mainIF['label_sw_frames'] = contR:createLabel(getrect(label_frames), locLines['switchframes'], labelFontSize)
	local bg = contR:createPicture(getrect(background_frames), locIcons['bg_rows'])
	bg.color = getUIcolor()


	--Line: enable/disable moving mode
	local button_move = {
		linesPaddingX, linesPaddingY * 2 + buttonSize,
		buttonSize,
		buttonSize
	}
	local label_move = {
		button_move[1] + button_move[3] + linesPaddingX, button_move[2] + labelShift,
		rUnit * 4,
		buttonSize + labelShift
	}
	local background_move = {
		linesPaddingX / 2, button_move[2] - linesPaddingY / 2,
		label_frames[1] + label_frames[3] + linesPaddingX / 2,
		buttonSize + linesPaddingY
	}
	mainIF['button_sw_move'] = contR:createRoundButton(getrect(button_move), locIcons['moveactivate'],
		'settingsShowMovement')
	mainIF['label_sw_move'] = contR:createLabel(getrect(label_move), locLines['movewindows'], labelFontSize)
	bg = contR:createPicture(getrect(background_move), locIcons['bg_rows'])
	bg.color = getUIcolor()

	--Line: turn on/off the main icon
	local button_mainIcon = {
		linesPaddingX, linesPaddingY * 3 + buttonSize * 2,
		buttonSize,
		buttonSize
	}
	local label_mainIcon = {
		button_mainIcon[1] + button_mainIcon[3] + linesPaddingX, button_mainIcon[2] + labelShift,
		rUnit * 4,
		buttonSize + labelShift
	}
	local background_mainIcon = {
		linesPaddingX / 2, button_mainIcon[2] - linesPaddingY / 2,
		label_frames[1] + label_frames[3] + linesPaddingX / 2,
		buttonSize + linesPaddingY
	}
	mainIF['button_sw_mainIcon'] = contR:createRoundButton(getrect(button_mainIcon), locIcons['hidemainicon'],
		'settingsShowHideMainIcon')
	mainIF['label_sw_mainIcon'] = contR:createLabel(getrect(label_mainIcon), locLines['hideMainIcon'], labelFontSize)
	bg = contR:createPicture(getrect(background_mainIcon), locIcons['bg_rows'])
	bg.color = getUIcolor()

	--Line: colors + separate container
	local button_colors = {
		linesPaddingX, linesPaddingY * 4 + buttonSize * 3,
		buttonSize,
		buttonSize
	}
	local label_colors = {
		button_colors[1] + button_colors[3] + linesPaddingX, button_colors[2] + labelShift,
		rUnit * 4,
		buttonSize + labelShift
	}
	local background_colors = {
		linesPaddingX / 2, button_colors[2] - linesPaddingY / 2,
		label_frames[1] + label_frames[3] + linesPaddingX / 2,
		buttonSize + linesPaddingY
	}
	mainIF['button_sw_colors'] = contR:createRoundButton(getrect(button_colors), locIcons['colors'],
		'expColColorPickerWindow')
	mainIF['label_sw_colors'] = contR:createLabel(getrect(label_colors), locLines['pickcolors'], labelFontSize)
	bg = contR:createPicture(getrect(background_colors), locIcons['bg_rows'])
	bg.color = getUIcolor()

	--Progressbar color selection segment
	local container_CP = {
		linesPaddingX * 4, button_colors[2] + button_colors[4] + labelShift,
		rUnit * 4,
		rUnit * 2
	}
	mainIF['containerColors'] = contR:createContainer(getrect(container_CP))
	local contCLR = mainIF['containerColors']
	contCLR:hide()

	local yPos = 0
	local cpReadyBTN, cpReadyPB, cpReadyLBL
	--Ready state
	yPos, cpBTN, cpPB, cpLBL, cpCL = self.renderColorPickLine(yPos, contCLR, linesPaddingX, linesPaddingY, labelShift,
		buttonSize, labelFontSize)
	cpBTN.icon = locIcons['update']
	cpBTN.onPressedFunction = 'onClickResetColor'
	cpPB.progress = 1
	cpPB.color = getColor(setColors['ready'])
	cpLBL.caption = locLines['frameready']
	for _, _rows in pairs(cpCL) do
		_rows[1].onPressedFunction = 'setReadyColor'
	end
	mainIF['colorpick_ready'] = {
		cpBTN, cpPB, cpCL
	}
	--Standby state
	yPos, cpBTN, cpPB, cpLBL, cpCL = self.renderColorPickLine(yPos, contCLR, linesPaddingX, linesPaddingY, labelShift,
		buttonSize, labelFontSize)
	cpBTN.icon = locIcons['update']
	cpBTN.onPressedFunction = 'onClickResetColor'
	cpPB.progress = 1
	cpPB.color = getColor(setColors['standby'])
	cpLBL.caption = locLines['framestandby']
	for _, _rows in pairs(cpCL) do
		_rows[1].onPressedFunction = 'setStandbyColor'
	end
	mainIF['colorpick_standby'] = {
		cpBTN, cpPB, cpCL
	}
	--Cooldown state
	yPos, cpBTN, cpPB, cpLBL, cpCL = self.renderColorPickLine(yPos, contCLR, linesPaddingX, linesPaddingY, labelShift,
		buttonSize, labelFontSize)
	cpBTN.icon = locIcons['update']
	cpBTN.onPressedFunction = 'onClickResetColor'
	cpPB.progress = 0.6
	cpPB.color = getColor(setColors['cooldown'])
	cpLBL.caption = locLines['framecooldown']
	for _, _rows in pairs(cpCL) do
		_rows[1].onPressedFunction = 'setCooldownColor'
	end
	mainIF['colorpick_cooldown'] = {
		cpBTN, cpPB, cpCL
	}
	--Charged state
	yPos, cpBTN, cpPB, cpLBL, cpCL = self.renderColorPickLine(yPos, contCLR, linesPaddingX, linesPaddingY, labelShift,
		buttonSize, labelFontSize)
	cpBTN.icon = locIcons['update']
	cpBTN.onPressedFunction = 'onClickResetColor'
	cpPB.progress = 0.8
	cpPB.color = getColor(setColors['charge'])
	cpLBL.caption = locLines['framerecharge']
	for _, _rows in pairs(cpCL) do
		_rows[1].onPressedFunction = 'setChargesColor'
	end
	mainIF['colorpick_charge'] = {
		cpBTN, cpPB, cpCL
	}

	--Line: factory reset (separate container)
	local default_container = {
		0, linesPaddingY * 4 + buttonSize * 4,
		buttonSize,
		buttonSize
	}

	local button_default = {
		linesPaddingX, linesPaddingY,
		buttonSize,
		buttonSize
	}

	local button_submit = {
		button_default[1] + button_default[3] + linesPaddingX, button_default[2] + button_default[4] + linesPaddingY,
		buttonSize,
		buttonSize
	}

	local button_cancel = {
		button_submit[1] + button_submit[3] + linesPaddingX, button_submit[2],
		buttonSize,
		buttonSize
	}

	local label_default = {
		button_default[1] + button_default[3] + linesPaddingX, button_default[2] + labelShift,
		rUnit * 4,
		buttonSize + labelShift
	}
	local background_default = {
		linesPaddingX / 2, button_default[2] - linesPaddingY / 2,
		label_default[1] + label_default[3] + linesPaddingX / 2,
		buttonSize + linesPaddingY
	}
	mainIF['container_line_default'] = contR:createContainer(getrect(default_container))
	local contDEF = mainIF['container_line_default']

	mainIF['button_sw_default'] = contDEF:createRoundButton(getrect(button_default), locIcons['default'],
		'onDefaultClicks')
	mainIF['label_sw_default'] = contDEF:createLabel(getrect(label_default), locLines['default'], labelFontSize)
	bg = contDEF:createPicture(getrect(background_default), locIcons['bg_rows'])
	bg.color = getUIcolor()

	mainIF['button_sw_default_submit'] = contDEF:createRoundButton(getrect(button_submit), locIcons['submit'],
		'onDefaultClicks')
	mainIF['button_sw_default_submit']:hide()
	mainIF['button_sw_default_cancel'] = contDEF:createRoundButton(getrect(button_cancel), locIcons['cancel'],
		'onDefaultClicks')
	mainIF['button_sw_default_cancel']:hide()

	--Post Loading saved interface data
	self.executeLoad()
end

function activeSysInterface.showInterface()
	local selfship = tostring(Player().craft.id)
	--Disables move mode
	if mainIF['button_sw_move'].icon == locIcons['movedeactivate'] then
		self.settingsShowMovement()
	end

	--Toggles the visibility of panels
	for _, _rows in pairs(containers) do
		local ship = _rows[3]
		local isSameShip = (ship == selfship)
		if isSameShip then
			_rows[1]:show()
		else
			_rows[1]:hide()
		end
	end
end

--Draws color picker lines for the corresponding container
function activeSysInterface.renderColorPickLine(yPos, cont, paddX, paddY, lblShift, btnSize, textSize)
	local pickers = {}

	local yShift = yPos + paddY

	local button = {
		paddX, yShift,
		btnSize,
		btnSize
	}

	local pb = {
		button[1] + button[3] + paddX, yShift + btnSize * 0.3,
		btnSize * 1.5,
		btnSize * 0.4
	}

	local label = {
		pb[1] + pb[3] + paddX, button[2] + lblShift,
		rUnit * 4,
		btnSize + lblShift
	}

	local createdButton = cont:createRoundButton(getrect(button), nil, nil)
	local createdPB = cont:createProgressBar(getrect(pb), getUIcolor())
	local createdLabel = cont:createLabel(getrect(label), 'default', textSize)



	for _out, _rows in pairs(colorsToPick) do
		yShift = btnSize + yShift
		local buttons_group = {}
		for _in, _rows2 in pairs(_rows) do
			local colorPicker = {
				paddX * (_in + 1) + btnSize * _in, yShift + btnSize * 0.3,
				btnSize,
				btnSize * 0.3
			}
			local colorBckg = {
				paddX * (_in + 1) + btnSize * _in, yShift + btnSize * 0.3 - rUnit * 0.02,
				btnSize,
				btnSize * 0.3 + rUnit * 0.04
			}
			local frame = cont:createFrame(getrect(colorBckg))
			frame.backgroundColor = getColor(_rows2)
			local resultButton = cont:createButton(getrect(colorPicker), '', nil)
			table.insert(pickers, { resultButton, _rows2 })
		end
	end

	return yShift + btnSize, createdButton, createdPB, createdLabel, pickers
end

--====================================[ External interface commands ]================================================

--Receives information from outside
--1 systemScript
--2 systemName
--3 systemIcon
--4 entityID
--5 subsys{}
--1 name
--2 icon
--3 desc
--4 command
--5 additionalbar (can be nil)

--_addElement
--_addElement[subsysnumber] = {type,count?} count can be nil
--type = progressbar,charges

function activeSysInterface.executeDraw(_table, _addElement)
	--Debug('executeDraw: attempt')
	if onServer() then
		invokeClientFunction(Player(callingPlayer), 'executeDraw', _table, _addElement)
		return
	else
		--Check duplicates
		if self.checkDuplicate(_table) then
			Debug('executeDraw: duplicate error')
			return
		end

		--Variables
		local sysScript = _table[1]
		local sysName = _table[2]
		local sysIcon = _table[3]
		local sysShip = _table[4]
		local subsystems = _table[5]

		--Checking for missing entity
		if not (Entity(sysShip)) then
			Debug('executeDraw failure: invalid entity')
		end

		local isWindowAvialable = (anchorContainers[sysScript] ~= nil)
		if not (isWindowAvialable) then
			Debug(sf('anchorContainers failure: script %s not found', sysScript))
			return
		end

		--Registration
		Debug(sf('Registr registeredSystems[%s]=%s', sysScript, sysShip))
		if not (registeredSystems[sysScript]) then
			registeredSystems[sysScript] = {}
		end

		table.insert(registeredSystems[sysScript], sysShip)

		--Main window
		local main_window = {
			0, 0,
			rUnit * 2,
			rUnit * 2
		}

		--Home icon
		local main_icon = {
			0, 0,
			mainIconSize,
			mainIconSize
		}
		--Creating a Linked Interface
		local cont = anchorContainers[sysScript]:createContainer(getrect(main_window))

		--Main icon
		local mainIcon = cont:createPicture(getrect(main_icon), sysIcon)
		mainIcon.isIcon = true

		--Basic buttons
		local subAnchor = vec2(rUnit * 0.5, 0)
		local interval = rUnit * 0.1
		local buttonSize = rUnit * 0.7
		local barPadding = rUnit * 0.06
		local barHeight = rUnit * 0.08

		local totalwidth = 0

		for _index, _rows in pairs(subsystems) do
			--Variables
			local sub_button = {
				subAnchor.x + _index * buttonSize + interval * (_index - 1), subAnchor.y,
				buttonSize,
				buttonSize
			}
			local sub_progressMain = {
				sub_button[1], sub_button[2] + sub_button[4] + barPadding,
				sub_button[3],
				barHeight
			}

			local sub_progressSecond = {
				sub_button[1], sub_progressMain[2] + sub_progressMain[4] + barPadding,
				sub_button[3],
				barHeight
			}

			--Button
			local icon = _rows[2]
			local button = cont:createRoundButton(getrect(sub_button), icon, 'onButtonPress')
			button.tooltip = _rows[3]

			--Progress bar
			local barMain = cont:createProgressBar(getrect(sub_progressMain), getColor(setColors['ready']))
			barMain.progress = 1

			--Additional progressbar
			local barAdd = nil
			if _addElement ~= nil and _addElement[_index] ~= nil then
				barAdd = self.drawAdditionalBarOfType(_addElement[_index][1], cont, getrect(sub_progressSecond),
					_addElement[_index][2])
			end

			--Registration
			local result = {
				button,
				_rows[4],
				sysScript,
				sysShip,
				barMain,
				_index,
				barAdd
			}

			table.insert(buttons, result)
			--Debug('register ok')
		end

		--Creating a Frame
		local subSize = #subsystems
		local frameShift = rUnit * 0.1
		local frameWidth = mainIcon.width + buttonSize * subSize + interval * subSize + frameShift * 2 -- + subAnchor.x

		local bckg_frame = {
			-frameShift, -frameShift,
			frameWidth + frameShift * 2,
			rUnit + frameShift * 2
		}
		local frameCont = cont:createContainer(getrect(bckg_frame))
		if (mainIF['button_sw_frames'].icon == locIcons['framesfull']) then
			frameCont:hide()
		end
		local frame = frameCont:createFrame(Rect(frameCont.size))
		frame.layer = -1
		local color = getUIcolor()
		color.a = 0.5
		frame.backgroundColor = color --Get u icolor()
		Neltharaku.GLapplyBorderFrame(frameCont, rUnit * 0.04, getUIcolor())

		--Overlaying Present Changes
		if self.isState(2) then
			--Icon + resize
			self.resizeMIcontainer(cont, true)
			mainIcon:hide()
			self.resizeMIframe(frameCont, true)
		end

		if self.isState(1) then
			frameCont:show()
		end
		--Creating a _debug label
		if _debug then
			local dbg_lbl = {
				rUnit, rUnit * -1,
				rUnit * 0.5,
				rUnit
			}
			cont:createLabel(getrect(dbg_lbl), Entity(sysShip).name, rUnit * 0.2)
		end

		--Registration of objects
		table.insert(containers, { cont, sysScript, sysShip })
		table.insert(frames, frameCont)
		table.insert(mainIcons, mainIcon)

		--First folding
		self.showInterface()
	end
end

function activeSysInterface.executeUpdateProgress(_index, _scriptName, _entityID, _progress, _isStandby)
	if onServer() then
		invokeClientFunction(Player(), 'executeUpdateProgress', _index, _scriptName, _entityID, _progress, _isStandby)
	else
		local buttonTable = self.getButtonTable(_index, _scriptName, _entityID)

		--Cutting off
		if buttonTable == false then
			local name = 'Entity failure'
			if valid(Entity(_entityID)) then name = Entity(_entityID).name end

			return
		end

		local bar = buttonTable[5]
		bar.progress = 1 - _progress
		if _progress == 0 then
			if _isStandby then
				bar.color = getColor(setColors['standby']) --Standby
			else
				bar.color = getColor(setColors['ready']) --Ready
			end
		else
			bar.color = getColor(setColors['cooldown']) --Cooldown
		end
	end
end

function activeSysInterface.executeUpdateSecondary(_index, _scriptName, _entityID, _progress)
	if onServer() then
		invokeClientFunction(Player(), 'executeUpdateSecondary', _index, _scriptName, _entityID, _progress)
	else
		local buttonTable = self.getButtonTable(_index, _scriptName, _entityID)

		--Cutting off
		if buttonTable == false then
			return
		end

		local bar = buttonTable[7]
		--If the bar is not a table (charges = table), a secondary progressbar is defined
		if type(bar) ~= 'table' then
			bar.progress = _progress

			if _progress == 0 then
				bar.progress = 0.1
				bar.color = getColor(setColors['cooldown']) --no charge
			else
				bar.color = getColor(setColors['charge']) --Charged
			end
		end
		--Debug('executeUpdateSecondary -ok')
	end
end

function activeSysInterface.executeDelete(_scriptName, _entityID)
	if onServer() then
		invokeClientFunction(Player(callingPlayer), 'executeDelete', _scriptName, _entityID)
		return
	else
		Debug('executeDelete attempt')

		self.unRegister(_scriptName, _entityID)

		self.removeContainer(_scriptName, _entityID)

		Debug('executeDelete success')
	end
end

--====================================[ Main interface functions ]=================================================

function activeSysInterface.settingsExpandCollapse()
	if mainIF['right_container'].visible then
		mainIF['right_container']:hide()

		--Minimizing travel mode
		if self.isState(4) then
			self.settingsShowMovement()
		end

		--Collapse color selection
		if self.isState(3) then
			self.expColColorPickerWindow()
		end

		--Curtailment of default
		self.onDefaultClicks('reset')
	else
		mainIF['right_container']:show()
	end
end

function activeSysInterface.settingsShowFrames()
	if not (self.isState(1)) then
		--Enabling Frames
		for _, _rows in pairs(frames) do
			if _rows then
				_rows:show()
			end
		end
		mainIF['button_sw_frames'].icon = locIcons['framesempty']
	else
		--turning off frames
		for _, _rows in pairs(frames) do
			if _rows then
				_rows:hide()
			end
		end
		mainIF['button_sw_frames'].icon = locIcons['framesfull']
	end

	toSave(3)
end

--Switches the displayed active modules, and also controls the display of movement symbols if the player leaves/changes ship
function activeSysInterface.settingsShowMovement()
	if mainIF['button_sw_move'].icon == locIcons['moveactivate'] then
		--Enabling Frames
		for _name, _rows in pairs(dragIcons) do
			local isRegistered = self.isRegisteredSys(_name)
			if isRegistered then
				_rows:show()
			end
		end
		mainIF['button_sw_move'].icon = locIcons['movedeactivate']
	else
		--turning off frames
		for _, _rows in pairs(dragIcons) do
			_rows:hide()
		end
		mainIF['button_sw_move'].icon = locIcons['moveactivate']
	end

	activeSysInterface.forceUpdate()

	--self.showInterface() --Enables/disables the main interface
end

function activeSysInterface.onButtonPress(button)
	local _command, _script, _source = self.getButtonInfo(button)
	self.executeActivation(_command, _script, _source)
end

function activeSysInterface.executeActivation(_command, _script, _source)
	if onClient() then
		invokeServerFunction('executeActivation', _command, _script, _source)
		local name = Entity(_source).name
		Debug(sf('Script %s activation (command = %s) for entity |%s|', _script, _command, name))
	else
		--Invoke faction function(faction().index,false, script)
		local x, y = Sector():getCoordinates()
		Debug(_source)
		invokeEntityFunction(x, y, false, _source, _script, _command)
	end
end

callable(activeSysInterface, 'executeActivation')

function activeSysInterface.settingsShowHideMainIcon()
	if not (self.isState(2)) then
		--Collapse
		mainIF['button_sw_mainIcon'].icon = locIcons['system']

		local iconWidth

		--Hiding all main icons
		for _, _rows in pairs(mainIcons) do
			if _rows then
				iconWidth = _rows.width
				_rows:hide()
			end
		end

		--Container shift
		for _, _rows in pairs(containers) do
			self.resizeMIcontainer(_rows[1], true)
		end

		--Frame shift
		for _, _rows in pairs(frames) do
			if _rows then
				self.resizeMIframe(_rows, true)
			end
		end
	else
		--Expand
		mainIF['button_sw_mainIcon'].icon = locIcons['hidemainicon']

		local iconWidth = mainIconSize

		--Display all main icons + remove deleted ones
		for _index, _rows in pairs(mainIcons) do
			if valid(_rows) then
				_rows:show()
			end
		end

		--Container shift
		for _, _rows in pairs(containers) do
			self.resizeMIcontainer(_rows[1], false)
		end

		--Frame shift
		for _, _rows in pairs(frames) do
			if _rows then
				self.resizeMIframe(_rows, false)
			end
		end
	end
	toSave(3)
end

function activeSysInterface.expColColorPickerWindow()
	if not (self.isState(3)) then
		mainIF['button_sw_colors'].icon = locIcons['colorsclose']
		mainIF['container_line_default']:hide()
		mainIF['containerColors']:show()
	else
		mainIF['button_sw_colors'].icon = locIcons['colors']
		mainIF['container_line_default']:show()
		mainIF['containerColors']:hide()
	end
end

function activeSysInterface.onClickResetColor(button)
	--Technical
	if button == 'reset' then
		setColors['ready'] = locColors['systemready']
		setColors['cooldown'] = locColors['systemoncooldown']
		setColors['standby'] = locColors['systemstandby']
		setColors['charge'] = locColors['systemscharge']
	end

	Debug('onClickResetColor attempt')
	if button.index == mainIF['colorpick_ready'][1].index then
		setColors['ready'] = locColors['systemready']
	end

	if button.index == mainIF['colorpick_cooldown'][1].index then
		setColors['cooldown'] = locColors['systemoncooldown']
	end

	if button.index == mainIF['colorpick_standby'][1].index then
		setColors['standby'] = locColors['systemstandby']
	end

	if button.index == mainIF['colorpick_charge'][1].index then
		setColors['charge'] = locColors['systemscharge']
	end

	self.resetPBcolors()
end

function activeSysInterface.setReadyColor(button)
	Debug('setReadyColor attempt')
	for _, _rows in pairs(mainIF['colorpick_ready'][3]) do
		if button.index == _rows[1].index then
			setColors['ready'] = _rows[2]
			self.resetPBcolors()
			break
		end
	end
	toSave(4)
end

function activeSysInterface.setCooldownColor(button)
	Debug('setCooldownColor attempt')
	for _, _rows in pairs(mainIF['colorpick_cooldown'][3]) do
		if button.index == _rows[1].index then
			setColors['cooldown'] = _rows[2]
			self.resetPBcolors()
			break
		end
	end
	toSave(4)
end

function activeSysInterface.setStandbyColor(button)
	Debug('setStandbyColor attempt')
	for _, _rows in pairs(mainIF['colorpick_standby'][3]) do
		if button.index == _rows[1].index then
			setColors['standby'] = _rows[2]
			self.resetPBcolors()
			break
		end
	end
	toSave(4)
end

function activeSysInterface.setChargesColor(button)
	Debug('setChargesColor attempt')
	for _, _rows in pairs(mainIF['colorpick_charge'][3]) do
		if button.index == _rows[1].index then
			setColors['charge'] = _rows[2]
			self.resetPBcolors()
			break
		end
	end
	toSave(4)
end

function activeSysInterface.onDefaultClicks(button)
	--Technical challenge
	if button == 'reset' then
		mainIF['button_sw_default_submit']:hide()
		mainIF['button_sw_default_cancel']:hide()
		return
	end

	--Disclosure
	if button.index == mainIF['button_sw_default'].index then
		mainIF['button_sw_default_submit']:show()
		mainIF['button_sw_default_cancel']:show()
		return
	end

	--Collapse
	if button.index == mainIF['button_sw_default_cancel'].index then
		mainIF['button_sw_default_submit']:hide()
		mainIF['button_sw_default_cancel']:hide()
		return
	end

	--Reset to default
	if button.index == mainIF['button_sw_default_submit'].index then
		mainIF['button_sw_default_submit']:hide()
		mainIF['button_sw_default_cancel']:hide()

		--Changing the positions of the main containers to default ones
		local res = getResolution()
		for _index, _rows in pairs(getASIinfo()) do
			anchorContainers[_rows].position = vec2(res.x * 0.2, res.y * 0.4 + rUnit * (1.2 * _index))
		end

		--Changing colors to default
		self.onClickResetColor('reset')

		--Collapsing frames
		if self.isState(1) then
			self.settingsShowFrames()
		end

		--Expanding icons
		if self.isState(2) then
			self.settingsShowHideMainIcon()
		end

		return
	end
end

--=====================[Processing active systems: service]=================================================

--Checks if it is trying to create an interface that is already present
function activeSysInterface.checkDuplicate(_table)
	local sysScript = _table[1]
	local sysShip = _table[4]

	if registeredSystems[sysScript] == nil then return false end

	for _id, _rows in pairs(registeredSystems[sysScript]) do
		--local isSameScript = (_id == sysScript)
		local isSameEntity = (_rows == sysShip)
		--Debug(sf('Duplicate ID %s = %s',_id,sysScript))
		Debug(sf('Duplicate Entity %s = %s', _rows, sysShip))
		--if isSameScript and isSameEntity then
		if isSameEntity then
			Debug('DUP detected')
			return true
		end
	end

	return false
end

--Determines the X ordinal coordinate of the module according to the specified TODO order
function activeSysInterface.getOrderCoordinate(_name)
	for _index, _rows in pairs(activeSystemsOrder) do
		if _rows == _name then return _index end
	end
	return 0
end

--Returns information about the button being used
function activeSysInterface.getButtonInfo(button)
	for _, _rows in pairs(buttons) do
		if button.index == _rows[1].index then
			return _rows[2], _rows[3], _rows[4]
		end
	end

	return false
end

--Returns the searched row from the buttons table by script+entity (for the update function)
function activeSysInterface.getButtonTable(_index, _script, _source)
	for _, _rows in pairs(buttons) do
		local isSameScript = (_script == _rows[3])
		local isSameEntity = (_source == _rows[4])
		local isSameIndex = (_index == _rows[6])

		if isSameScript and isSameEntity and isSameIndex then
			return _rows
		end
	end

	return false
end

--Deletes a container matching the information on request
function activeSysInterface.removeContainer(_script, _source)
	for _index, _rows in pairs(containers) do
		if not (Entity(_source)) then break end

		local name = Entity(_source).name
		local isSameScript = (_script == _rows[2])
		local isSameEntity = (_source == _rows[3])

		if isSameScript and isSameEntity then
			Debug(sf('Container deleted for script %s and ship name %s', _script, name))
			--Debug('container deleted for script '.._script)
			_rows[1]:clear()
			table.remove(containers, _index)
			self.removeButtonTable(_script, _source)
			return
		end
	end

	return false
end

--Collapses empty elements after deleting a container
function activeSysInterface.removeButtonTable(_script, _source)
	for _index, _rows in pairs(buttons) do
		local isSameScript = (_script == _rows[3])
		local isSameEntity = (_source == _rows[4])
		local name = Entity(_source).name

		if (isSameScript and isSameEntity) then
			Debug(sf('Button of index %i deleted for script %s and ship name %s. Reason: filter', _rows[6], _script, name))
			table.remove(buttons, _index)
			self.removeButtonTable(_script, _source)
			break
		end
	end
end

--Removes a system register
function activeSysInterface.unRegister(_script, _entityID)
	if not (registeredSystems[_script]) then return end

	for _index, _rows in pairs(registeredSystems[_script]) do
		if _rows == _entityID then
			table.remove(registeredSystems, _index)
			return
		end
	end
end

--_addElement
--_addElement[subsysnumber] = {type,count?} count can be nil
--type = progressbar,charges
--Draws an additional progress bar or charges
function activeSysInterface.drawAdditionalBarOfType(_type, container, rect, _numberOfCharges)
	if _type == 'progressbar' then
		local bar = container:createProgressBar(rect, getColor(locColors['systemscharge']))
		bar.progress = 1
		return bar
	end

	if _type == 'charges' then

	end
end

--Checks if the vessel is in the list of registered ones by the script (to display the move icon only on active elements)
function activeSysInterface.isRegisteredSys(_script)
	local ID = tostring(Player().craft.id)

	if not (registeredSystems[_script]) then return false end

	for _, _rows in pairs(registeredSystems[_script]) do
		if _rows == ID then return true end
	end

	return false
end

--Returns the status of the subsystem (frame switching, etc.)
function activeSysInterface.isState(_type)
	--frames
	--mainIcon
	--colors
	--move
	if _type == 1 then
		return (mainIF['button_sw_frames'].icon == locIcons['framesempty'])
	end
	if _type == 2 then
		return (mainIF['button_sw_mainIcon'].icon == locIcons['system'])
	end
	if _type == 3 then
		return (mainIF['button_sw_colors'].icon == locIcons['colorsclose'])
	end
	if _type == 4 then
		return (mainIF['button_sw_move'].icon == locIcons['movedeactivate'])
	end
end

--Changes the main container of the system (button to disable the main icon)
function activeSysInterface.resizeMIcontainer(container, isCollapse)
	local newpos = vec2(container.position.x + mainIconSize, container.position.y)

	if isCollapse then
		newpos = vec2(container.position.x - mainIconSize, container.position.y)
	end

	container.position = newpos
end

--Changes the background frame of the system (button to disable the main icon)
function activeSysInterface.resizeMIframe(container, isCollapse)
	if valid(container) then
		--Container shift
		local shiftValueCont = mainIconSize * -1
		local shiftValueFrame = mainIconSize * 0.9
		if isCollapse then
			shiftValueCont = shiftValueCont * -1
			shiftValueFrame = shiftValueFrame * -1
		end

		local newpos = vec2(container.position.x + shiftValueCont, container.position.y)
		container.position = newpos

		--Redrawing the frame
		container.width = container.width + shiftValueFrame
		container:clear()
		local frame = container:createFrame(Rect(container.size))
		frame.layer = -1
		local color = getUIcolor()
		color.a = 0.5
		frame.backgroundColor = color --Get u icolor()
		Neltharaku.GLapplyBorderFrame(container, rUnit * 0.04, getUIcolor())
	end
end

--Performs a forced color change of all PBs
function activeSysInterface.resetPBcolors()
	for _, _rows in pairs(buttons) do
		if _rows[5] then
			if _rows[5].progress == 1 then
				_rows[5].color = getColor(setColors['ready'])
			end
		end
		if _rows[7] then
			if _rows[7].progress > 0 then
				_rows[7].color = getColor(setColors['charge'])
			end
		end
	end

	mainIF['colorpick_ready'][2].color = getColor(setColors['ready'])
	mainIF['colorpick_cooldown'][2].color = getColor(setColors['cooldown'])
	mainIF['colorpick_standby'][2].color = getColor(setColors['standby'])
	mainIF['colorpick_charge'][2].color = getColor(setColors['charge'])

	toSave(4)
end
