package.path = package.path .. ";data/scripts/neltharaku/?.lua"
package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/entity/?.lua"
package.path = package.path .. ";data/scripts/player/ui/?.lua"

include('utility')
include('callable')
include('Neltharaku')

--namespace cG
cG = {}

_colorG = ColorHSV(150, 64, 100)
_colorY = ColorHSV(60, 94, 78)
_colorR = ColorHSV(16, 97, 84)
_colorB = ColorHSV(240, 40, 100)
_colorC = ColorHSV(264, 60, 100)

local rUnit = 40
local rPaddingX = 15
local rPaddingY = 10

local windowSize = { 10, 6 }

local addNativeIcon = 'data/textures/icons/uiPlus.png'
local addSwitchedIcon = 'data/textures/icons/uiPlayer.png'

local cGwindow = nil
local cGframe = nil

local locLines = {}
locLines['button_tooltip_expand'] = "Expand combat group window" % _t
locLines['button_tooltip_collapse'] = "Collapse window" % _t
locLines['button_tooltip_refresh'] = "Refresh window" % _t
locLines['button_tooltip_settoinvite'] = "Switch to the mode of adding players" % _t
locLines['button_tooltip_settogroup'] = "Switch to the current group display mode" % _t
locLines['button_label_online'] = "Online" % _t

locLines['window_name'] = "Combat group" % _t

local windowName = locLines['window_name']
local mainWindow = {}
--window
--frame
--iconCollapse
--iconRefresh
--buttonInit

local groupUIelements = {}
--icon
--name
--status
--kick

local groupUIadd = {}
--inviteButton
--name

local playersOnline = {}
--Name

local _debug = false
function cG.DebugMsg(_text)
	if _debug then
		print('combatGroup|', _text)
	end
end

local Debug = cG.DebugMsg
local TSR = Neltharaku.TableSelfReport

function cG.DoMeow()
	Debug('Meow')
end

--Searches for the index of an element in the specified table
function cG.getElementByIndex(_element, _table, _pos)
	--The element itself in _element
	--Table to search in _table
	--Position of the button in the line in _pos
	local _result = nil
	for _index, _rows in pairs(_table) do
		if _rows[_pos].index == _element.index then
			_result = _index
		end
	end
	return _result
end

function cG.initialize()
	terminate()
	if onServer() then
		--Calls to update data
		Server():registerCallback("onPlayerLogIn", "callbackIssuePoint")
		Server():registerCallback("onPlayerLogOff", "callbackIssuePoint")
		Player():registerCallback("onGroupChanged", "callbackIssuePoint")
		Player():registerCallback("onGroupLeaderChanged", "callbackIssuePoint")
		Player():registerCallback("onPlayerEnteredGroup", "callbackIssuePoint")
		Player():registerCallback("onPlayerLeftGroup", "callbackIssuePoint")
	end

	if onClient() then
		cG.createWindow()
	end
end

----[service]



----------------------------------[Drawing the basic interface]-------------------------------------
--Creates a main window
function cG.createWindow()
	if _debug then
		rUnit = 40
		Debug('createWindow local unit corrected')
	end

	--Creating the Main Window
	mainWindow['window'], mainWindow['frame'] = Neltharaku.CreateHudWindow(windowName, rUnit, windowSize[1],
		windowSize[2])
	mainWindow['window'].showCloseButton = false
	mainWindow['window'].moveable = false

	--Creating a Collapse Button
	local _size = rUnit * 0.7
	mainWindow['collapse'] = Neltharaku.UIcreateCloseButton(mainWindow['window'], _size)
	if not (mainWindow['collapse']) then
		Debug('closeButtonEroro')
	end
	mainWindow['collapse'].icon = 'data/textures/icons/uiCollapse.png'
	mainWindow['collapse'].onPressedFunction = 'collapseWindow'
	mainWindow['collapse'].tooltip = locLines['button_tooltip_collapse']

	--Creating a Refresh Button
	mainWindow['refresh'] = Neltharaku.UIcreateCloseButton(mainWindow['window'], _size, 2)
	if not (mainWindow['refresh']) then
		Debug('refreshButtonEroro')
	end
	mainWindow['refresh'].icon = 'data/textures/icons/uiUpdate.png'
	mainWindow['refresh'].onPressedFunction = 'serverIssueToRender'
	mainWindow['refresh'].tooltip = locLines['button_tooltip_refresh']

	--Creating an "add" button
	mainWindow['add'] = Neltharaku.UIcreateCloseButton(mainWindow['window'], _size, 3)
	if not (mainWindow['add']) then
		Debug('addButtonEroro')
	end
	mainWindow['add'].icon = 'data/textures/icons/uiPlus.png'
	mainWindow['add'].onPressedFunction = 'onAddButtonPress'
	mainWindow['add'].tooltip = locLines['button_tooltip_settoinvite']

	--Saving the width/height values ​​of the main window
	windowSize[1] = mainWindow['window'].width
	windowSize[2] = mainWindow['window'].height

	--Main window['window']:hide()
	cG.collapseWindow(mainWindow['collapse'])

	--local anchorPoint = vec2(rUnit*3,rUnit*3)
	--
	--Positions the button on the screen
	local resX = getResolution().y * 0.06
	local resY = getResolution().y * 0.3
	local anchorPoint = vec2(resX, resY)
	local debugRect = Neltharaku.GetAchoredRect(0, anchorPoint)
	mainWindow['window'].rect = debugRect
end

--Responsible for folding
function cG.collapseWindow(_button)
	--Changing icons, button functions
	_button.icon = 'data/textures/icons/uiFederation.png'
	_button.onPressedFunction = 'expandWindow'
	_button.tooltip = locLines['button_tooltip_expand']

	--Turning off unnecessary interface elements
	mainWindow['window'].caption = ''
	mainWindow['frame']:hide()
	mainWindow['refresh']:hide()
	mainWindow['add']:hide()

	--Minimizing a window
	local _newWidth = rUnit * 0
	local _newHeight = rUnit * 0
	local _anchorPosition = mainWindow['window'].rect.topLeft
	local _collapsePoint = vec2(_anchorPosition.x + _newWidth, _anchorPosition.y + _newHeight)
	local _collapseRect = Rect(_anchorPosition, _collapsePoint)

	mainWindow['window'].rect = _collapseRect

	--Changing the button position
	Neltharaku.UIplaceCloseButton(_button, mainWindow['window'], 1)

	--Checking if the window has flown off the screen
	if Neltharaku.isOutOfBorder(_button) then
		local anchorPoint = vec2(rUnit * 3, rUnit * 3)
		local debugRect = Neltharaku.GetAchoredRect(0, anchorPoint)
		mainWindow['window'].rect = debugRect
		Debug('collapseWindow: out of border')
	end
end

--Responsible for unfolding
function cG.expandWindow(_button)
	--Changing icons, button functions
	_button.icon = 'data/textures/icons/uiCollapse.png'
	_button.onPressedFunction = 'collapseWindow'
	_button.tooltip = locLines['button_tooltip_collapse']

	--Maximizing a window
	local anchorPoint = mainWindow['window'].rect.topLeft
	local secondPoint = vec2(anchorPoint.x + windowSize[1], anchorPoint.y + windowSize[2])
	local expandRect = Rect(anchorPoint, secondPoint)
	mainWindow['window'].rect = expandRect

	--Activating interface elements
	mainWindow['window'].caption = windowName
	mainWindow['frame']:show()
	mainWindow['refresh']:show()
	mainWindow['add']:show()

	--Moving the minimize button
	Neltharaku.UIplaceCloseButton(_button, mainWindow['window'], 1)

	--Clarifying the status of the "add" button
	cG.addButtonSwitcher()
end

--Input function to perform listener processing, distributes update type based on current active window
function cG.callbackIssuePoint()
	Debug('callbackIssuePoint attempt')
	--Stream destination
	if onServer() then
		invokeClientFunction(Player(callingPlayer), 'callbackIssuePoint')
		return
	end

	--Cutting off
	if not (Player()) or not (mainWindow['add']) then
		Debug('callbackIssuePoint failure: nil')
		return
	end

	--Finding the update path: group interface update
	if mainWindow['add'].icon == addNativeIcon then
		Debug('callbackUpdate for "GROUP"')
		cG.serverIssueToRender()
	else
		--Finding the update path: updating the interface of new players
		Debug('callbackUpdate for "NEW"')
		--Search for players
		cG.serverScanPlayersOnline()
	end
end

--Handles the accessibility of the "add" button
function cG.addButtonSwitcher()
	--Stream destination
	if onServer() then
		invokeClientFunction(Player(callingPlayer), 'addButtonSwitcher')
		return
	end

	--Variables
	local pwayer = Player()
	local button = mainWindow['add']

	--Cutting off
	if not (pwayer) or not (button) then return end

	--Testing Various Conditions
	local isParty = Player().group
	local isLeader = false
	if isParty then
		isLeader = (Player().name == Faction(Player().group.leader).name)
	end
	local isAddState = (button.icon == addNativeIcon)

	--Setting the button activity
	if not (isParty) then
		button.active = true
		return
	end

	if isAddState then
		if isLeader then
			button.active = true
		else
			button.active = false
		end
	else
		button.active = true
	end
end

----------------------------------[Group Interface]-------------------------------------

--Input group rendering function. Searches for players online and sends the process further
function cG.serverIssueToRender()
	Debug('serverIssueToRender attempt')
	if onClient() then
		invokeServerFunction('serverIssueToRender')

		--C g.add button switcher()
	else
		--Update players online
		--cG.serverScanPlayersOnline()

		--Continuation of the procedure on the client side
		invokeClientFunction(Player(), 'issueToRenderGroup', playersOnline)
	end
end

callable(cG, 'serverIssueToRender')

--Scans the player's group (if available) and renders the interface.
function cG.issueToRenderGroup(_tableOnline)
	Debug('issueToRenderGroup attempt')
	--TSR(_tableOnline,'_tableOnline')
	--Clipping
	if onServer() then return end

	--Changing button status
	mainWindow['add'].icon = 'data/textures/icons/uiPlus.png'
	mainWindow['add'].onPressedFunction = 'onAddButtonPress'
	mainWindow['add'].tooltip = locLines['button_tooltip_settoinvite']
	mainWindow['refresh'].onPressedFunction = 'serverIssueToRender'

	--Online player table synchronization
	playersOnline = _tableOnline

	--Clearing the interface to render a new one
	mainWindow['frame']:clear()
	groupUIelements = {}

	--First iteration of variables
	local party = Player().group
	if not (party) then return end
	local iconLeader = 'data/textures/icons/group-leader-colored.png'
	local iconNotLeader = 'data/textures/icons/group-leader.png'
	local iconKick = 'data/textures/icons/kick.png'

	--Creating Important Variables
	--if party.leader = Faction().index then isLeader = true end
	local partyPlayers = { party:getPlayers() }
	local offsetY = rPaddingY
	local isCallingPlayerLeader = (Player().name == Faction(party.leader).name)
	Debug('isCallingPlayerLeader: ' .. tostring(isCallingPlayerLeader))

	--Disable the button that switches to the invitation panel
	if not (isCallingPlayerLeader) and party then
		mainWindow['add'].active = false
	end

	--Searching for players, recording and creating interface elements
	for _index, _rows in pairs(partyPlayers) do
		--Person's name
		local _name = Faction(_rows).name
		Debug('-----------' .. _name .. '-----------')

		--Assigning statuses
		local isOnline = cG.isPlayerOnline(_name)
		Debug('isOnline check: ' .. tostring(isOnline))
		local isSelf = (_name == Player().name)
		Debug('isSelf check: ' .. tostring(isSelf))
		local isLeader = (party.leader == _rows)
		Debug('isLeader check: ' .. tostring(isLeader))

		--Calculating Interface Positions
		local _elements = { 1, 3, 3, 1 }
		local rects = Neltharaku.UIrowAutoplace(_elements, rUnit, rPaddingX, offsetY)
		offsetY = offsetY + rUnit + rPaddingY

		--Interface creation
		local _frame = mainWindow['frame']
		--Leader
		local _leaderButton = _frame:createRoundButton(rects[1], iconNotLeader, 'onLeaderChangePressed')
		if isLeader then _leaderButton.icon = iconLeader end
		if not (isCallingPlayerLeader) then _leaderButton.active = false end
		if not (isOnline) then _leaderButton.active = false end

		--Name
		local _nameTF = _frame:createTextField(rects[2], _name)
		_nameTF.fontSize = rUnit * 0.25

		--State
		local _statusTF = _frame:createTextField(rects[3], locLines['button_label_online'])
		_statusTF.fontSize = rUnit * 0.25
		_statusTF.fontColor = _colorG
		if not (isOnline) then _statusTF:hide() end

		--Kick
		local _kickButton = _frame:createRoundButton(rects[4], iconKick, nil)
		_kickButton.active = false
		--Distribution of the functionality of this button

		--If it is the player himself, he kicks himself
		if isSelf then _kickButton.onPressedFunction = 'onKickSelfPressed' end

		--If the player is the leader of the party, the button refers to the remote kick
		if not (isSelf) and isCallingPlayerLeader and isOnline then _kickButton.onPressedFunction = 'onKickOtherPressed' end

		--Enables the button if the leader or the player himself
		if (isCallingPlayerLeader and isOnline) or isSelf then _kickButton.active = true end
		--if (not(isSelf) and not(isCallingPlayerLeader)) or not(isOnline) then _kickButton.active = false end

		--Saving an interface string to a table
		table.insert(groupUIelements, { _leaderButton, _nameTF, _statusTF, _kickButton, _name })
	end
	Debug('issueToRenderGroup successful call')

	--Clarifying the status of the "add" button
	cG.addButtonSwitcher()
end

----------------------------------[Group interface subfunctions]-------------------------------------
--Creates/updates table of online player names
function cG.serverScanPlayersOnline(_table)
	--Debug('serverScanPlayersOnline attempt')
	if onServer() then
		playersOnline = {}
		--local scannedPlayers =
		for _, _rows in pairs({ Server():getOnlinePlayers() }) do
			table.insert(playersOnline, _rows.name)
		end
	end
end

--Checks the player's name for a match with online players
function cG.isPlayerOnline(_name)
	for _, rows in pairs(playersOnline) do
		if _name == rows then return true end
	end
	return false
end

----------------------------------[Interface "add"]-------------------------------------
--Initializing the button, scanning players online and starting rendering
function cG.onAddButtonPress()
	Debug('onAddButtonPress attempt')
	if onClient() then
		--Changing button status
		mainWindow['add'].icon = 'data/textures/icons/uiPlayer.png'
		mainWindow['add'].onPressedFunction = 'serverIssueToRender'
		mainWindow['refresh'].onPressedFunction = 'onAddButtonPress'
		mainWindow['add'].tooltip = locLines['button_tooltip_settogroup']

		--Running the server side of the script
		invokeServerFunction('onAddButtonPress')
	else
		--Search for players
		cG.serverScanPlayersOnline()

		--Running check and render
		invokeClientFunction(Player(), 'renderAddTable', playersOnline)

		--Checking button status
		cG.addButtonSwitcher()
	end
end

callable(cG, 'onAddButtonPress')

--Compiling a list of online players and starting rendering
function cG.renderAddTable(_table)
	--Frame clearing
	mainWindow['frame']:clear()
	groupUIadd = {}

	--Online player table synchronization
	playersOnline = _table

	--Group Variables
	local party = Player().group
	local playersInParty = {}
	local possiblePlayers = {}
	local iconInvite = 'data/textures/icons/uiPlus.png'
	local self = Player().name

	--Finding suitable players
	for _, _rows in pairs(playersOnline) do
		if not (cG.isInSameGroup(_rows)) then
			table.insert(possiblePlayers, _rows)
		end
	end

	--Tsr(possible players,'possible players')

	--Player list render
	local offsetY = rPaddingY
	local _frame = mainWindow['frame']
	for _index, _rows in pairs(possiblePlayers) do
		local _elements = { 1, 4 }
		local rects = Neltharaku.UIrowAutoplace(_elements, rUnit, rPaddingX, offsetY)
		offsetY = offsetY + rUnit + rPaddingY

		--Invitebutton
		local _inviteButton = _frame:createRoundButton(rects[1], iconInvite, 'onPlayerInvitePressed')

		--Playername
		local _nameTF = _frame:createTextField(rects[2], _rows)
		_nameTF.fontSize = rUnit * 0.4

		--Recording an interface in a table
		table.insert(groupUIadd, { _inviteButton, _nameTF })
	end

	--Checking button status
	cG.addButtonSwitcher()
end

----------------------------------[Player invitation functionality]-------------------------------------

--Processes a request to add a player
function cG.onPlayerInvitePressed(_button)
	--Switching button mode
	_button.icon = 'data/textures/icons/submit.png'
	_button.active = false

	--Generating values ​​for a request
	local _buttonIndex = cG.getElementIndex(_button, groupUIadd, 1)
	local _name = groupUIadd[_buttonIndex][2].text

	--Submitting a request to the server
	if #_name > 0 then
		invokeServerFunction('serverPlayerInvite', _name)
	end
end

--executes the invite command on the server side and sends "invitations" to players
function cG.serverPlayerInvite(_name)
	Server():addChatCommand(Player(), '/invite ' .. _name)
	local _targetPlayer = Galaxy():findPlayer(_name)
	Debug('_targetPlayer name is ' .. _name)
	local _index = _targetPlayer.index
	invokeFactionFunction(_index, false, 'combatGroup', 'playerOperateInvite', _name)
end

callable(cG, 'serverPlayerInvite')

--Initiates an invite on the local client
function cG.playerOperateInvite(_name)
	--Translation of stream
	if onServer() then
		invokeClientFunction(Player(callingPlayer), 'playerOperateInvite')
		return
	end

	Player():invokeFunction('alertCore', 'entityGroupInvite')
end

----------------------------------[Leader transfer functionality]-------------------------------------

--Handles leader transfer push
function cG.onLeaderChangePressed(button, name)
	Debug('onLeaderChangePressed attempt')

	--Server thread: command execution
	if onServer() then
		--Cutting off
		if not (name) then return end

		--Executing a command
		Server():addChatCommand(Player(), '/leader ' .. name)
		return
	end

	--Client Flow: Command Generation
	--Clipping
	if not (button) then return end

	--Assigning Variables
	local _pwayerIndex = cG.getElementIndex(button, groupUIelements, 1)
	Debug('_pwayerIndex is ' .. tostring(_pwayerIndex))
	local name = groupUIelements[_pwayerIndex][2].text
	--Running the server side of the script
	invokeServerFunction('onLeaderChangePressed', nil, name)
end

callable(cG, 'onLeaderChangePressed')

----------------------------------[Player kick functionality]-------------------------------------

--Handles another player's kick button click
function cG.onKickOtherPressed(button, name)
	Debug('onKickOtherPressed attempt')

	--Server thread: command execution
	if onServer() then
		--Cutting off
		if not (name) then return end

		--Remote command launch
		local _targetPlayer = Galaxy():findPlayer(name)
		Debug('_targetPlayer name is ' .. name)
		local _index = _targetPlayer.index
		invokeFactionFunction(_index, false, 'combatGroup', 'remoteKick')
		return
	end

	--Client Flow: Command Generation
	--Clipping
	if not (button) then return end

	--Assigning Variables
	local _pwayerIndex = cG.getElementIndex(button, groupUIelements, 4)
	Debug('_pwayerIndex is ' .. tostring(_pwayerIndex))
	local name = groupUIelements[_pwayerIndex][2].text
	--Running the server side of the script
	invokeServerFunction('onKickOtherPressed', nil, name)
end

callable(cG, 'onKickOtherPressed')

--Runs the kick command on a third-party client
function cG.remoteKick()
	--Cutting off
	if not (Player()) then return end

	--Thread separation
	if onServer() then
		--Run a chat command
		Server():addChatCommand(Player(), '/leave')

		--Translating the stream to trigger an alert
		invokeClientFunction(Player(callingPlayer), 'remoteKick')
	else
		--Calling an alert
		Player():invokeFunction('alertCore', 'playerGroupKick')
		--Updating a Button
		cG.addButtonSwitcher()
	end
end

function cG.onKickSelfPressed()
	--Cutting off
	if not (Player()) then return end

	--Executing a command on the server
	if onServer() then
		Server():addChatCommand(Player(), '/leave')
		--Updating a Button
		cG.addButtonSwitcher()
		return
	end

	--Translating the stream on the client
	invokeServerFunction('onKickSelfPressed')
end

callable(cG, 'onKickSelfPressed')

----------------------------------[Subfunctions]-------------------------------------
--Checks the button against the table, returning its index
function cG.getElementIndex(_element, _table, _pos)
	local _result = nil
	for _index, _rows in pairs(_table) do
		if _rows[_pos].index == _element.index then
			_result = _index
		end
	end
	return _result
end

--Checks the player for presence in the online table
function cG.isOnline(_name)
	for _, _rows in pairs(playersOnline) do
		if _name == Player().name then Debug('isOnline self') end
		if playersOnline == _rows then return true end
	end

	return false
end

--Checks whether the specified player is in the same group as the current one
--Also does not return TRUE if the name matches the name of the main player
function cG.isInSameGroup(_name)
	if Player().name == _name then
		Debug('isInSameGroup: same as main player alert')
		return true
	end

	local party = Player().group
	if not (party) then return false end

	--Getting player indices
	local indPwayers = { party:getPlayers() }
	--Change to names
	local tableNames = {}
	for _, _rows in pairs(indPwayers) do
		table.insert(tableNames, Player(_rows))
	end
	--Tsr(table names,'is in same group')

	--We check availability and complete if it matches
	for _, _rows in pairs(tableNames) do
		if _name == tableNames then return true end
	end

	return false
end

--Checks if a name exists in the specified table
function cG.isPlayerNameInTable(_table, _name)
	--Checking if a name exists in a table
	for _, _rows in pairs(_table) do
		local name = Faction(_rows).name
		if _name == name then return true end
	end

	return false
end
