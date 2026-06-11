package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

--namespace infoInterfaces
infoInterfaces = {}

local _debug = false
-----------------------------[DATA: MOD]----------------------------

--Types: desc,picture,iconinfo,mainlabel

entities['combatgroupgeneral'] = {
	--Name
	'General info'%_t,
	--Content
	{
		{
			'mainlabel',                   -- Item type
			nil,                           -- Height (nil for iconname/mainlabel)
			'data/textures/icons/FederationSC.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.8, -- Height (nil for iconname/mainlabel)
			"A special interface called by the corresponding button on the screen allows you to perform group management (player invitation, player kick, leader transfer) without using chat commands" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                  -- Item type
			nil,                         -- Height (nil for iconname/mainlabel)
			'data/textures/icons/uiCollapse.png', -- Content. Text or path to the image.
			"'Collapse' button"%_t     -- Content for icon info
		},
		{
			'desc',                                                                                        -- Item type
			1,                                                                                             -- Height (nil for iconname/mainlabel)
			"Minimizes the window, leaving the 'expand' button on its place, allowing you to expand it later"%_t, -- Content. Text or path to the image.
		},
		-- {
		-- 'iconinfo', --Element type
		-- nil, --Height (nil for iconname/mainlabel)
		-- 'data/textures/icons/uiUpdate.png', --Content. Text or path to the image.
		-- "'Update' button"%_t --Content for icon info
		-- },
		-- {
		-- 'desc', --Element type
		-- 1, --Height (nil for iconname/mainlabel)
		-- "Updates information in the active window"%_t, --Content. Text or path to the image.
		-- },
		{
			'iconinfo',              -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			'data/textures/icons/uiPlus.png', -- Content. Text or path to the image.
			"'Switch to adding' button"%_t -- Content for icon info
		},
		{
			'desc',                                                               -- Item type
			1,                                                                    -- Height (nil for iconname/mainlabel)
			"Opens a window with a list of online players who are not in your group"%_t, -- Content. Text or path to the image.
		},
		-- {
		-- 'iconinfo', --Element type
		-- nil, --Height (nil for iconname/mainlabel)
		-- 'data/textures/icons/uiPlayer.png', --Content. Text or path to the image.
		-- "'Switch to Group Management' button"%_t --Content for icon info
		-- },
		-- {
		-- 'desc', --Element type
		-- 1, --Height (nil for iconname/mainlabel)
		-- "Switches the main window to group management mode. Unavailable if you are not a group leader"%_t, --Content. Text or path to the image.
		-- },

	},
}
entities['combatgroupmanage'] = {
	--Name
	'Group Control Panel'%_t,
	--Content
	{
		{
			'mainlabel',               -- Item type
			nil,                       -- Height (nil for iconname/mainlabel)
			'data/textures/icons/uiPlayer.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			"This window contains a list of all the players in the group, and also allows you to transfer leadership and kick players (including yourself). Unavailable functions will not be active" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo', -- Item type
			nil,        -- Height (nil for iconname/mainlabel)
			locIcons['player'], -- Content. Text or path to the image.
			'Player status'%_t -- Content for icon info
		},
		{
			'desc',                                                                                           -- Item type
			1.2,                                                                                              -- Height (nil for iconname/mainlabel)
			"Indicates the status of the player (offline, online, leader) and allows you to transfer the leader"%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',            -- Item type
			nil,                   -- Height (nil for iconname/mainlabel)
			'data/textures/icons/kick.png', -- Content. Text or path to the image.
			"'Kick' button"%_t   -- Content for icon info
		},
		{
			'desc',                                                                                     -- Item type
			1.2,                                                                                        -- Height (nil for iconname/mainlabel)
			"Allows you to kick the player (available only to the leader). You can't kick players offline"%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',  -- Item type
			nil,         -- Height (nil for iconname/mainlabel)
			locIcons['cancel'], -- Content. Text or path to the image.
			"'Leave' button"%_t -- Content for icon info
		},
		{
			'desc',                      -- Item type
			1.2,                         -- Height (nil for iconname/mainlabel)
			"Allows you to leave the group"%_t, -- Content. Text or path to the image.
		},
	},
}
entities['combatgroupinvite'] = {
	--Name
	'Player Invitation Panel'%_t,
	--Content
	{
		{
			'mainlabel',             -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			'data/textures/icons/uiPlus.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.6, -- Height (nil for iconname/mainlabel)
			"This window displays online players who are not in the same group as the current player. Being the leader of the group (or not being in the group), you can invite the specified player, in which case the button will change to a confirmation one and become inactive. The specified player will receive an alert with that allows him to instantly accept/decline the invitation.\n The button is inactive if you are not a leader" %
			_t, -- Content. Text or path to the image.
		},
	},
}
entities['auracoreinfo'] = {
	--Name
	'Active effects'%_t,
	--Content
	{
		{
			'mainlabel',               -- Item type
			nil,                       -- Height (nil for iconname/mainlabel)
			'data/textures/icons/acid-fog.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"An interface element that is initially hidden. As soon as the effects of modules / environment from the Cosmic Starfall mod begin to act on the ship, information about this effect will appear near the vanilla status icons" %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['asiinfo'] = {
	--Name
	'Active System Interface'%_t,
	--Content
	{
		{
			'mainlabel',                     -- Item type
			nil,                             -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_circutry.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                -- Item type
			1.3,                                                                                   -- Height (nil for iconname/mainlabel)
			"Customizable interface that provides access to the active systems installed on the ship"%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                        -- Item type
			nil,                               -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_framesfull.png', -- Content. Text or path to the image.
			"Frame switcher"%_t              -- Content for icon info
		},
		{
			'desc', -- Item type
			1.4, -- Height (nil for iconname/mainlabel)
			"Allows you to include a frame on each system panel to improve visibility. The frame color is similar to the system color" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                           -- Item type
			nil,                                  -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_moveinterface.png', -- Content. Text or path to the image.
			"Movement switcher"%_t              -- Content for icon info
		},
		{
			'desc', -- Item type
			1.5, -- Height (nil for iconname/mainlabel)
			"Allows you to unlock elements with which you can move panels around the screen. To do this, click on them and, holding the left mouse button pressed (the element will turn green), specify a new location" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                          -- Item type
			nil,                                 -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_hideMainIcon.png', -- Content. Text or path to the image.
			"Main icon switcher"%_t            -- Content for icon info
		},
		{
			'desc',                                                                     -- Item type
			1.2,                                                                        -- Height (nil for iconname/mainlabel)
			"Allows you to enable and disable the display of the module icon on its panel"%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                    -- Item type
			nil,                           -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_colors.png', -- Content. Text or path to the image.
			"Color switcher"%_t          -- Content for icon info
		},
		{
			'desc', -- Item type
			1.4, -- Height (nil for iconname/mainlabel)
			"Opens the color selection panel for the progress bars. Clicking on the button next to each bar resets the color to the original one" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                     -- Item type
			nil,                            -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_default.png', -- Content. Text or path to the image.
			"Reset to Default"%_t         -- Content for icon info
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"Resets all panel settings to the original ones. After activation, you need to click on the confirmation button" %
			_t, -- Content. Text or path to the image.
		},
	},
}

function infoInterfaces_injectToCodex()
    Player():invokeFunction('ui/cosmiccodex', 'addCategory', 'sf_interfaces', 'Starfall Interfaces'%_t, 'data/textures/icons/cog.png')

    for key, data in pairs(entities) do
        local name = data[1] or "Unknown"
        local content = data[3] or data[2] or {}
        
        local fullText = ""
        local mainPic = ""
        for _, item in pairs(content) do
            local type = item[1]
            local info = item[3] or ""
            local label = item[4] or ""
            
            if type == "mainlabel" then
                if mainPic == "" then mainPic = info end
            elseif type == "desc" then
                fullText = fullText .. info .. "\n\n"
            elseif type == "iconinfo" then
                fullText = fullText .. "[" .. label .. "]\n"
            end
        end
        
        Player():invokeFunction("ui/cosmiccodex", "addArticle", "sf_interfaces", "sf_"..key, name, fullText, mainPic)
    end
end
