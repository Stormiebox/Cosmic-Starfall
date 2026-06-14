package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

--namespace infoAlerts
infoAlerts = {}

local _debug = false
-----------------------------[DATA: MOD]----------------------------

--Types: desc,picture,iconinfo,mainlabel
entities = entities or {}

entities['weapons'] = {
	--Name
	'The turret is destroyed'%_t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                            -- Item type
			nil,                                    -- Height (nil for iconname/mainlabel)
			'data/textures/icons/alert/AlertDeadTurret.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                              -- Item type
			0.9,                                                                 -- Height (nil for iconname/mainlabel)
			'Non-interactive - triggered when the enemy destroys one of your turrets'%_t, -- Content. Text or path to the image.
		},
	},
}

function infoAlerts_injectToCodex()
    Player():invokeFunction('ui/cosmiccodex', 'addCategory', 'sf_cat', 'Cosmic Starfall'%_t, 'data/textures/icons/vortex.png')
    Player():invokeFunction('ui/cosmiccodex', 'addChapter', 'sf_cat', 'sf_alerts', 'Starfall Alerts'%_t)

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
        
        Player():invokeFunction("ui/cosmiccodex", "addArticle", "sf_alerts", "sf_"..key, name, fullText, mainPic)
    end
end
