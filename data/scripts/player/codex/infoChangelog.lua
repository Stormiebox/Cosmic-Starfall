package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')

--namespace infoChangelog
infoChangelog = {}

local _debug = false
function infoChangelog.transformToSingleLine(_table)
	local _result = ''
	
	for _,_rows in pairs(_table) do
		_result = _result.." - ".._rows..'\n\n'
	end
	
	return _result
end

-----------------------------[DATA: GENERATION]-----------------------------

local entities = {}
local updateLines = {}

updateLines['2.0.0'] = {
	"Native Cosmic Vault Integration: Replaced legacy cosmicstarfalllib with the global Vault API.",
	"Cinematic UI: Overhauled active subsystems to use CosmicVaultUI for massive lag-free feedback.",
	"Asynchronous Engine: Shifted intense processing like Tractor Pulses to CosmicVaultTask.RunAsync() to preserve TPS.",
	"Economy Hooks: Megacomplexes can now crash the sector market if they overload on cargo.",
	"Crash Immunity: Eradicated dangerous direct entity dereferencing across the codebase.",
	"Localization Purge: Removed bloated translations and standardized entirely on English logs/UI.",
	"Sound Engine: Normalized data/sfx directories to lowercase to resolve Linux server audio crashes.",
	"Arsenal Balance: Nerfed extreme vanilla weapon over-tuning and repaired reversed math in Bastion System.",
	"Native CCM Integration: Stripped Mod Configuration Menu scripts and migrated to server-authoritative CCM.",
	"V2 Finalization: Concluded the structural V2 phase, graduating 70+ scripts to their final internal directory structures.",
	"Alliance Hardware Fix: Hardened subsystem ownership resolution so UI safely renders when piloting an Alliance-owned vessel.",
	"Codex Unity: Scrapped the legacy encyclopedia UI and migrated all lore and telemetry to the lightweight Cosmic Codex."
}

updateLines['0.3'] = {
	"Performance optimization and cleanup.",
	"Balance tweaks across the board."
}

updateLines['0.2'] = {
	"Initial public release of Starfall features."
}

--Types: desc,picture,iconinfo,mainlabel

entities['2.0.0'] = {
	--Name
	'Update 2.0.0',
	--Content
	{
		{
			'mainlabel', -- Element type
			nil, -- Height (nil for iconname/mainlabel)
			'data/textures/icons/clipboard-arrow-down.png', -- Content. Text or image path.
		},
		{
			'desc', -- Element type
			14, -- Height
			infoChangelog.transformToSingleLine(updateLines['2.0.0']), -- Content.
		},
	},
}
entities['0.2'] = {
	--Name
	'Update 0.2',
	--Content
	{
		{
			'mainlabel', -- Element type
			nil, -- Height (nil for iconname/mainlabel)
			'data/textures/icons/clipboard-arrow-down.png', -- Content. Text or image path.
		},
		{
			'desc', -- Element type
			8, -- Height
			infoChangelog.transformToSingleLine(updateLines['0.2']), -- Content.
		},
	},
}
entities['0.3'] = {
	--Name
	'Update 0.3',
	--Content
	{
		{
			'mainlabel', -- Element type
			nil, -- Height (nil for iconname/mainlabel)
			'data/textures/icons/clipboard-arrow-down.png', -- Content. Text or image path.
		},
		{
			'desc', -- Element type
			8, -- Height
			infoChangelog.transformToSingleLine(updateLines['0.3']), -- Content.
		},
	},
}


function infoChangelog_injectToCodex()
    Player():invokeFunction('ui/cosmiccodex', 'addCategory', 'sf_cat', 'Cosmic Starfall'%_t, 'data/textures/icons/vortex.png')
    Player():invokeFunction('ui/cosmiccodex', 'addChapter', 'sf_cat', 'sf_changelog', 'Starfall Changelog'%_t)

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
        
        Player():invokeFunction("ui/cosmiccodex", "addArticle", "sf_changelog", "sf_"..key, name, fullText, mainPic)
    end
end
