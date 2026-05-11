package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Neltharaku')
include('callable')
include('ColorLib')
include('SoundLib')

--namespace combatGroup
combatGroup = {}

local locIcons = {}
locIcons['leader'] = 'data/textures/icons/ui/ui_playerLeader.png'
locIcons['online'] = 'data/textures/icons/ui/ui_playerOnline.png'
locIcons['offline'] = 'data/textures/icons/ui/ui_playerOffline.png'
locIcons['kick'] = 'data/textures/icons/kick.png'

locIcons['collapse'] = 'data/textures/icons/uiCollapse.png'
locIcons['collapseleft'] = 'data/textures/icons/ui/ui_collapseleft.png'
locIcons['expand'] = 'data/textures/icons/uiFederation.png'
locIcons['pendinginvite'] = 'data/textures/icons/ui/ui_invitePending.png'
locIcons['refresh'] = 'data/textures/icons/uiUpdate.png'
locIcons['add'] = 'data/textures/icons/uiPlus.png'
locIcons['sent'] = 'data/textures/icons/submit.png'
locIcons['cancel'] = 'data/textures/icons/cancel.png'
locIcons['cancelnoring'] = 'data/textures/icons/ui/ui_cancelWOring.png'
locIcons['submitnoring'] = 'data/textures/icons/ui/ui_submitWOring.png'
locIcons['mail'] = 'data/textures/icons/ui/ui_mail.png'


local locLines = {}
locLines['button_tooltip_expand'] = "Expand combat group window" % _t
locLines['button_tooltip_collapse'] = "Collapse window" % _t
locLines['button_tooltip_refresh'] = "Refresh window" % _t

locLines['button_tooltip_collapseLeft'] = "Collapse invitation window" % _t
locLines['button_tooltip_openadd'] = "Open invitation window" % _t
locLines['label_caption_invited'] = "You are invited to the group!" % _t
locLines['label_caption_noplayers'] = "Cannot find players to invite" % _t
locLines['button_tooltip_leave'] = "Leave the group" % _t
--locLines['button_tooltip_transferleader'] = "Transfer leader"%_t

locLines['window_name'] = "Combat group" % _t

local UIE = {}


local _debug = false
function combatGroup.DebugMsg(_text)
	if _debug then
		print('combatGroupV2|', _text)
	end
end

local Debug = combatGroup.DebugMsg
local sf = string.format
local self = combatGroup
local TSR = Neltharaku.TableSelfReport
local RR = Neltharaku.ReportRect
local getrect = Neltharaku.createRect

local colors = {}
colors['buff'] = ColorHSV(90, 0.8, 0.65)
colors['debuff'] = ColorHSV(16, 97, 84)
colors['neutral'] = ColorHSV(60, 94, 78)
colors['st'] = ColorHSV(240, 0, 100)

local rUnit
local mainContainer
local innerContainers = {}
local buttons = {}
--local partyPlayers = {}
local onlinePwayers = {}

local invintationFlag = 0
local invintationPendingFlag = false

local updateFlag = 0
local updateFlagValue = 5

function combatGroup.initialize()
	Debug('--------initialize--------')
	if onClient() then
		--Variables
		--UIAnchor = vec2(getResolution().x*0.25,getResolution().y*0.15)
		rUnit = math.min(getResolution().x, getResolution().y) * 0.05
		--containerSize = rUnit*4

		--Actions
		self.CreateInterface()
	end
end

function combatGroup.DoMeow()
	Debug('Meow')
end

local Meow = combatGroup.DoMeow

--======================================[Built-in functions]======================================================

function combatGroup.getUpdateInterval()
	return 2
end

function combatGroup.update(timeStep)
	if onClient() then
		if buttons['expand'] ~= nil then
			local but = buttons['expand']
			if invintationFlag > 0 then
				invintationFlag = math.max(invintationFlag - timeStep, 0)
				if invintationPendingFlag then
					invintationPendingFlag = false
					but.icon = locIcons['pendinginvite']
				else
					invintationPendingFlag = true
					but.icon = locIcons['expand']
				end
				if invintationFlag == 0 then
					but.icon = locIcons['expand']
				end
			end
		end

		if updateFlag > 0 then
			updateFlag = math.max(updateFlag - timeStep, 0)
			if updateFlag == 0 then
				self.resetInvintationIcons()
			end
		end
	end
end

--===================================[Creating/rendering the interface]================================================
function combatGroup.CreateInterface()
	if onServer() then return end

	--Control Variables
	local mainWidth = rUnit * 4  --Window width
	local mainHeight = rUnit * 3 --Window height
	local topContHeight = rUnit * 0.7 --Top line height

	local res = getResolution()
	local mainAnchor = vec2(res.x * 0.035, res.y * 0.22)

	local bottomContainer = { --Bottom container (group management)
		0, topContHeight,
		mainWidth,
		mainHeight - topContHeight
	}
	local rightContainer = { --Right container (append)
		mainWidth + rUnit * 0.4, 0,
		mainWidth,
		mainHeight
	}
	local mainLabel = {      --Name square
		rUnit * 0.3, rUnit * 0.05, --Anchor
		rUnit * 2,           --Width
		rUnit * 0.95         --Height
	}
	local collapseButton = { --Collapse (expand) button
		rUnit * -0.7, rUnit * 0.05,
		rUnit * 0.6,
		rUnit * 0.6
	}
	local addButton = { --Add button
		collapseButton[1], collapseButton[2] + collapseButton[4] + rUnit * 0.2,
		rUnit * 0.5,
		rUnit * 0.5
	}
	local collapseLeftButton = { --Collapse-menu-add button
		mainWidth - rUnit * 0.5, rUnit * 0.05,
		rUnit * 0.5,
		rUnit * 0.5
	}
	local acceptinvitelabel = { --invitation acceptance label
		rUnit * 0.3, rUnit * 0.2,
		rUnit * 4,
		rUnit * 0.6
	}
	local acceptinvitebutton = { --Accept invitation button
		rUnit * 0.3, acceptinvitelabel[2] + acceptinvitelabel[4],
		rUnit * 0.5,
		rUnit * 0.5
	}
	local declineinvitebutton = { --Decline invitation button
		acceptinvitebutton[1] + acceptinvitebutton[3] + rUnit * 0.2, acceptinvitebutton[2],
		rUnit * 0.5,
		rUnit * 0.5
	}

	--Creating a shared container
	local res = getResolution()
	local containerAnchor = vec2(res.x * 0.035, res.y * 0.26)
	local containerPoint = vec2(containerAnchor.x + mainWidth, containerAnchor.y + mainHeight)
	local containerRect = Rect(containerAnchor, containerPoint)

	local getrect = self.createRect
	mainContainer = Hud():createContainer(containerRect)
	--Main container:create frame(rect(main container.size))

	--Creating Internal Zones
	local topContainerPoint = vec2(mainContainer.width, topContHeight)
	innerContainers['top'] = mainContainer:createContainer(Rect(topContainerPoint))
	--local topFrame = innerContainers['top']:createFrame(Rect(innerContainers['top'].size))
	--topFrame.backgroundColor = colors['buff']

	innerContainers['bottom'] = mainContainer:createContainer(self.createRect(bottomContainer))
	--local botFrame = innerContainers['bottom']:createFrame(Rect(innerContainers['bottom'].size))
	--botFrame.backgroundColor = colors['neutral']
	innerContainers['bottom_invite'] = mainContainer:createContainer(self.createRect(bottomContainer))

	innerContainers['right'] = mainContainer:createContainer(self.createRect(rightContainer))
	innerContainers['right']:createFrame(Rect(innerContainers['right'].size))



	--Filling the header zone
	--Title
	local mainLabelRect = self.createRect(mainLabel)
	local labelFontSize = rUnit * 0.25
	local mainLabel = innerContainers['top']:createLabel(mainLabelRect, locLines['window_name'], labelFontSize)
	--Collapse button
	local collapseRect = self.createRect(collapseButton)
	buttons['collapse'] = innerContainers['top']:createRoundButton(collapseRect, locIcons['collapse'], 'Collapse')
	buttons['collapse'].tooltip = locLines['button_tooltip_collapse']
	--"Collapse adding" button
	buttons['collapseLeft'] = innerContainers['top']:createRoundButton(getrect(collapseLeftButton),
		locIcons['collapseleft'], 'collapseAdd')
	buttons['collapseLeft'].tooltip = locLines['button_tooltip_collapseLeft']
	buttons['collapseLeft']:hide()
	--"Expand" button
	local collapseRect = self.createRect(collapseButton)
	buttons['expand'] = mainContainer:createRoundButton(collapseRect, locIcons['expand'], 'Expand')
	buttons['expand'].tooltip = locLines['button_tooltip_expand']
	--"Add" button
	local addRect = self.createRect(addButton)
	buttons['add'] = innerContainers['top']:createRoundButton(addRect, locIcons['add'], 'ExpandAdd')
	buttons['add'].tooltip = locLines['button_tooltip_openadd']
	buttons['add']:hide()

	--Filling the invite zone
	--labelFontSize = rUnit *0.3
	--Inscription
	local invitelabel = innerContainers['bottom_invite']:createLabel(getrect(acceptinvitelabel),
		locLines['label_caption_invited'], labelFontSize)
	--"Accept" button
	buttons['acceptinvite'] = innerContainers['bottom_invite']:createRoundButton(getrect(acceptinvitebutton),
		locIcons['sent'], 'AcceptInvite')
	--"Refuse" button
	buttons['declineinvite'] = innerContainers['bottom_invite']:createRoundButton(getrect(declineinvitebutton),
		locIcons['cancel'], 'interruptInvite')


	--Initiating folding
	self.Collapse()

	--Initialize the renderer
	--self.RenderGroup()

	--Initializing lines
	--Top
	local top_lineLeftSide = {
		0, 0,
		0,
		innerContainers['top'].height
	}
	innerContainers['top']:createLine(self.getLines(top_lineLeftSide))

	--Initializing hooks and interface
	invokeServerFunction('getOnlinePwayers')
	invokeServerFunction('applyHooks')
end

function combatGroup.RenderGroup()
	local isGroup = Player().group

	--Cleaning the interface
	partyPlayers = {}
	innerContainers['bottom']:clear()

	--Cuts off the render and opens the "add" button if the player is not in a group
	if isGroup == nil then
		buttons['add']:show()
		return
	end

	--If the group exists, generates its lines
	local party = Player().group
	local partyGuys = { party:getPlayers() }
	local isSelfLeader = (Player().index == party.leader)

	--Opens the "add" button
	if isSelfLeader then
		buttons['add']:show()
	else
		buttons['add']:hide()
	end

	yPos = 0

	for _, _rows in pairs(partyGuys) do
		local elements = {}
		local name = Faction(_rows).name
		elements, yPos = self.GenerateGroupLine(yPos)

		--Calculating flags
		--local isLeader = (Player(party.leader).name == _rows)
		local isLeader = (party.leader == _rows)
		local isOnline = (self.isPlayerOnline(_rows))
		local isSelf = (Player().index == _rows)

		Debug(sf("(%s)\nisLeader - %s\nisOnline - %s\nisSelf - %s,\nisSelfLeader - %s", name, tostring(isLeader),
			tostring(isOnline), tostring(isSelf), tostring(isSelfLeader)))

		--Selectively include elements
		--===[Leader Button Block]===--
		--Show button
		if isOnline and isSelfLeader and not (isLeader) then
			elements['but_online']:show()
			elements['but_online'].tooltip = name
			elements['but_online'].onPressedFunction = 'transferLeader'
		end
		--Show online icon
		if isOnline and not (isLeader) and not (isSelfLeader) then
			elements['pic_online']:show()
		end
		--Show leader icon
		if isOnline and isLeader then
			elements['pic_leader']:show()
		end
		--Show offline icon
		if not (isOnline) then
			elements['pic_offline']:show()
		end

		--===[Name block]===--
		elements['label_name']:show()
		elements['label_name'].caption = name
		if isLeader then
			elements['label_name'].color = colors['neutral']
		end
		if not (isOnline) then
			elements['label_name'].color = getColor('lightgray')
		end
		Debug(sf("Trying to add caption: %s", name))

		--===[Kick button block]===--
		--Show kik icon
		if not (isSelf) and isSelfLeader and isOnline then
			elements['but_kick']:show()
			elements['but_kick'].tooltip = name
			elements['but_kick'].onPressedFunction = 'kickPlayer'
		end
		--Show liwa icon
		if isSelf then
			elements['but_leave']:show()
			elements['but_leave'].onPressedFunction = 'leaveGroup'
		end
	end

	if yPos == 0 then
		yPos = rUnit
	end

	--Drawing lines
	local bottom_lineLeftSide = {
		0, 0,
		0,
		yPos
	}

	--Bottom
	innerContainers['bottom']:createLine(self.getLines(bottom_lineLeftSide))
end

function combatGroup.RenderAdd()
	local pwayers = self.getPwayersToInvite()
	local yPos = 0
	if not (pwayers) then return end

	UIE['add_lines'] = {}
	local t = UIE['add_lines']

	innerContainers['right']:clear()

	Debug('RenderAdd attempt')

	for _index, _rows in pairs(pwayers) do
		local elements = {}

		elements, yPos = self.GenerateAddLine(yPos)


		elements['but_add']:show()
		elements['but_add'].onPressedFunction = 'sendInvite'
		elements['but_add'].tooltip = _rows[1]
		elements['label_name'].caption = _rows[1]
		elements['label_name']:show()

		t[_index] = { elements['but_add'], elements['pic_sent'] }
	end

	if #pwayers == 0 then
		elements, yPos = self.GenerateAddLine(yPos)
		elements['pic_eroro']:show()
		elements['label_name']:show()
	end

	--Render lines
	local right_lineLeftSide = {
		0, 0,
		0,
		yPos
	}

	innerContainers['right']:createLine(self.getLines(right_lineLeftSide))
end

function combatGroup.GenerateGroupLine(yPos)
	--leader/online/offline
	--name
	--kick

	--Variables
	local yPadding = rUnit * 0.05 + yPos --vertical displacement of the entire line
	local fontSize = rUnit * 0.23
	local localSize = rUnit * 0.6

	local leaderButton = { --Leader button/icon
		rUnit * 0.1, yPadding,
		localSize,
		localSize
	}
	local nameLabel = { --Player name
		leaderButton[1] + leaderButton[3], yPadding + localSize * 0.35,
		localSize * 4,
		localSize * 1.35
	}
	local kickButton = { --Kick/pour button
		nameLabel[1] + nameLabel[3], yPadding + localSize * 0.22,
		localSize * 0.8,
		localSize * 0.8 + localSize * 0.22
	}
	local uiElems = {}
	local cont = innerContainers['bottom']
	local getrect = self.createRect

	--=====[Leader Button Block]=====--
	--generating a leader transfer button
	uiElems['but_online'] = cont:createRoundButton(getrect(leaderButton), locIcons['online'], 'DoMeow')
	--leader image generation
	uiElems['pic_leader'] = cont:createPicture(getrect(leaderButton), locIcons['leader'])
	uiElems['pic_leader'].isIcon = true
	--online image generation
	uiElems['pic_online'] = cont:createPicture(getrect(leaderButton), locIcons['online'])
	uiElems['pic_online'].isIcon = true
	--offline image generation
	uiElems['pic_offline'] = cont:createPicture(getrect(leaderButton), locIcons['offline'])
	uiElems['pic_offline'].isIcon = true

	--=====[Name block]=====--
	uiElems['label_name'] = cont:createLabel(getrect(nameLabel), 'default', fontSize)

	--=====[Kick button block]=====--
	--generating a kik button
	uiElems['but_kick'] = cont:createRoundButton(getrect(kickButton), locIcons['kick'], 'DoMeow')
	--the generation button is left
	uiElems['but_leave'] = cont:createRoundButton(getrect(kickButton), locIcons['cancel'], 'DoMeow')
	uiElems['but_leave'].tooltip = locLines['button_tooltip_leave']
	--Precap all row elements
	for _, _rows in pairs(uiElems) do
		_rows:hide()
	end

	--return table and yPos
	return uiElems, (yPos + localSize)
end

function combatGroup.GenerateAddLine(yPos)
	--Variables
	local yPadding = rUnit * 0.05 + yPos --vertical displacement of the entire line
	local fontSize = rUnit * 0.23
	local localSize = rUnit * 0.5

	local addButton = { --Plus button
		rUnit * 0.1, yPadding,
		localSize,
		localSize
	}
	local nameLabel = { --Player name
		addButton[1] + addButton[3] + rUnit * 0.1, yPadding + localSize * 0.3,
		localSize * 6,
		localSize * 1.3
	}

	local uiElems = {}
	local cont = innerContainers['right']
	local getrect = self.createRect

	--=====[Add button block]=====--
	--"Add" button
	uiElems['but_add'] = cont:createRoundButton(getrect(addButton), locIcons['add'], 'DoMeow')
	--Sent icon
	uiElems['pic_sent'] = cont:createPicture(getrect(addButton), locIcons['mail'])
	uiElems['pic_sent'].isIcon = true
	--"No matches" icon
	uiElems['pic_eroro'] = cont:createPicture(getrect(addButton), locIcons['cancelnoring'])
	uiElems['pic_eroro'].isIcon = true

	--=====[Name block]=====--
	uiElems['label_name'] = cont:createLabel(getrect(nameLabel), locLines['label_caption_noplayers'], fontSize)

	--Precap all row elements
	for _, _rows in pairs(uiElems) do
		_rows:hide()
	end

	--return table and yPos
	return uiElems, (yPos + localSize)
end

--======================================================[Search for information]=====================================================

--Server->Client search for players is online, in addition, it is initiated by hooks for updating information
function combatGroup.getOnlinePwayers(_table)
	if onServer() then
		--Information scanning and synchronization
		scanned = { Server():getOnlinePlayers() }
		onlinePwayers = {}

		for _, _rows in pairs(scanned) do
			table.insert(onlinePwayers, { _rows.name, _rows.index })
		end

		if _debug then
			onlinePwayers = {
				{ 'Twilight Sparkle', 190 },
				{ 'Rainbow Dash',     191 },
				{ 'Applejack',        192 },
				{ 'Pinkie Pie',       193 },
				{ 'Rarity',           194 },
				{ 'Fluttershy',       195 },
			}
		end

		invokeClientFunction(Player(), 'getOnlinePwayers', onlinePwayers)
	else
		onlinePwayers = _table
		self.RenderGroup()
		self.RenderAdd()
	end
end

callable(combatGroup, 'getOnlinePwayers')

function combatGroup.getPwayersToInvite()
	local result = {}
	local party = Player().group

	-- --If there is no group, does not check the group
	if party == nil then
		for _, _rows in pairs(onlinePwayers) do
			local isSelf = (_rows[2] == Player().index)

			if not (isSelf) then
				table.insert(result, _rows)
			end
		end

		return result
	end

	--Checks with the group
	for _, _rows in pairs(onlinePwayers) do
		Debug(sf('Check party with name %s and index %i', _rows[1], _rows[2]))
		local isInGroup = (party:contains(_rows[2]))
		--if (_debug and _rows[2]>192) then isInGroup = true end
		local isSelf = (_rows[2] == Player().index)

		if not (isInGroup) and not (isSelf) then
			table.insert(result, _rows)
		end
	end

	return result
end

--===================================[Handling interface buttons]================================================

function combatGroup.Collapse()
	for _, _rows in pairs(innerContainers) do
		_rows:hide()
	end
	buttons['collapseLeft']:hide()
	buttons['expand']:show()
end

function combatGroup.Expand()
	innerContainers['top']:show()

	if invintationFlag > 0 then
		innerContainers['bottom_invite']:show()
		innerContainers['bottom']:hide()
	else
		innerContainers['bottom']:show()
		innerContainers['bottom_invite']:hide()
	end

	buttons['expand']:hide()
end

function combatGroup.ExpandAdd()
	Debug('ExpandAdd attempt')
	innerContainers['right']:show()
	RR(innerContainers['right'].rect)
	buttons['collapseLeft']:show()
end

function combatGroup.collapseAdd()
	innerContainers['right']:hide()
	buttons['collapseLeft']:hide()
end

--=========[invite]

function combatGroup.AcceptInvite()
	local command = '/join'
	self.executeServerCmd('simple', command)
	self.interruptInvite()
end

function combatGroup.sendInvite(button)
	local name = button.tooltip
	local command = sf("/invite %s", name)

	for _index, _rows in pairs(UIE['add_lines']) do
		if button.index == _rows[1].index then
			_rows[1]:hide()
			_rows[2]:show()
			self.setUpdate()
			break
		end
	end

	self.executeServerCmd('invite', command, name)
end

function combatGroup.interruptInvite()
	invintationFlag = 1
	innerContainers['bottom_invite']:hide()
	innerContainers['bottom']:show()
end

--This function is called by the server to create an incoming message.
function combatGroup.remoteInvite()
	if onServer() then
		invokeClientFunction(Player(), 'remoteInvite')
	else
		invintationFlag = 40 --button blinking period
		SLplaysoundUI('combatgroup_invite', 2)
		--innerContainers['bottom']:hide()
		--innerContainers['bottom_invite']:show()
	end
end

--=========[leave]

function combatGroup.leaveGroup()
	local command = '/leave'
	self.executeServerCmd('simple', command)
end

--=========[kick]

function combatGroup.kickPlayer(button)
	local name = button.tooltip
	local command = '/leave'
	self.executeServerCmd('kick', command, name)
end

--This function is called by the server for a remote kick
function combatGroup.remoteKick()
	if onServer() then
		local command = '/leave'
		self.executeServerCmd('simple', command)
	end
end

--=========[leader]

function combatGroup.transferLeader(button)
	local name = button.tooltip
	local command = sf("/leader %s", name)
	self.executeServerCmd('simple', command)
end

--===================================[Service]================================================
--Simulates a chat command
function combatGroup.executeServerCmd(_type, _cmd, _name)
	if onClient() then
		invokeServerFunction('executeServerCmd', _type, _cmd, _name)
	else
		if _type == 'invite' then
			Server():addChatCommand(Player(), _cmd)
			local targetID = Galaxy():findPlayer(_name).index
			invokeFactionFunction(targetID, false, 'combatGroupV2', 'remoteInvite', _name)
		end

		if _type == 'kick' then
			local targetID = Galaxy():findPlayer(_name).index
			invokeFactionFunction(targetID, false, 'combatGroupV2', 'remoteKick', _name)
		end

		if _type == 'simple' then
			Server():addChatCommand(Player(), _cmd)
		end

		self.getOnlinePwayers()
	end
end

callable(combatGroup, 'executeServerCmd')

--Hangs hooks during initialization
function combatGroup.applyHooks()
	if onServer() then
		Server():registerCallback("onPlayerLogIn", "getOnlinePwayers")
		Server():registerCallback("onPlayerLogOff", "getOnlinePwayers")
		Player():registerCallback("onGroupChanged", "getOnlinePwayers")
		Player():registerCallback("onGroupLeaderChanged", "getOnlinePwayers")
		Player():registerCallback("onPlayerEnteredGroup", "getOnlinePwayers")
		Player():registerCallback("onPlayerLeftGroup", "getOnlinePwayers")
	end
end

callable(combatGroup, 'applyHooks')

--A simple way to create a square using the anchor-dot principle
function combatGroup.createRect(_table)
	local Anchor = vec2(_table[1], _table[2])
	local Point = vec2(Anchor.x + _table[3], Anchor.y + _table[4])
	local resultRect = Rect(Anchor, Point)
	return resultRect
end

--Returns vectors for a line
function combatGroup.getLines(_table)
	local line1points = { vec2(_table[1], _table[2]), vec2(_table[1] + _table[3], _table[2] + _table[4]) }
	return line1points[1], line1points[2]
end

--Checks the presence of a name/index in the list of names online
function combatGroup.isPlayerOnline(_element)
	--Debug('Element set: '..tostring(_element))
	--TSR(onlinePwayers)
	for _, _rows in pairs(onlinePwayers) do
		Debug(sf("Element is %s\nrows1 is %s\nrows2 is %s", tostring(_element), _rows[1], tostring(_rows[2])))
		if _element == _rows[1] then
			Debug('isPlayerOnline same name - online')
			return true
		end
		if _element == _rows[2] then
			Debug('isPlayerOnline same index - online')
			return true
		end
	end

	return false
end

function combatGroup.setUpdate()
	updateFlag = updateFlagValue
end

function combatGroup.resetInvintationIcons()
	for _, _rows in pairs(UIE['add_lines']) do
		_rows[1]:show()
		_rows[2]:hide()
	end
end
