package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')
include('Stations')

--namespace infoStations
infoStations = {}

local _debug = false
-----------------------------[DATA: MOD]----------------------------

--Types: desc,picture,iconinfo,mainlabel

entities['megacomplex'] = {
	--Name
	getStationName('mx'),
	--Content
	{
		{
			'mainlabel', -- Item type
			nil,         -- Height (nil for iconname/mainlabel)
			getStationIcon('mx'), -- Content. Text or path to the image.
		},
		{
			'desc',      -- Item type
			1.8,         -- Height (nil for iconname/mainlabel)
			getStationDesc('mx'), -- Content. Text or path to the image.
		},
		{
			'iconinfo',             -- Item type
			nil,                    -- Height (nil for iconname/mainlabel)
			getInnerStationIcon('mxoutput'), -- Content. Text or path to the image.
			"'Production' tab"%_t -- Content for icon info
		},
		{
			'desc', -- Item type
			1.8, -- Height (nil for iconname/mainlabel)
			"The first tab (production) displays all stations that produce resources and transfer them to the complex. Each line represents a station and all its production streams (including the ratio of active production to off)" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',               -- Item type
			nil,                      -- Height (nil for iconname/mainlabel)
			getInnerStationIcon('mxexpand'), -- Content. Text or path to the image.
			'Detailed Information button'%_t -- Content for icon info
		},
		{
			'desc', -- Item type
			1.8, -- Height (nil for iconname/mainlabel)
			"Expands an additional window in which all the production streams of the station are listed in detail. They can be turned on and off at your discretion. By disabling the stream, you will prohibit the megacomplex from taking a specific resource from a specific station" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',            -- Item type
			nil,                   -- Height (nil for iconname/mainlabel)
			getInnerStationIcon('mxinput'), -- Content. Text or path to the image.
			"'Consumption' tab"%_t -- Content for icon info
		},
		{
			'desc', -- Item type
			1.8, -- Height (nil for iconname/mainlabel)
			"Displays all stations that need resources to work. Additionally displays the capabilities of the megacomplex to supply the station with resources produced by other docked stations. Here you can completely disable the supply of resources to the station by using the shutdown button to the right border of line" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',              -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			getInnerStationIcon('mxexpand'), -- Content. Text or path to the image.
			'Consumption Details button'%_t -- Content for icon info
		},
		{
			'desc', -- Item type
			1.8, -- Height (nil for iconname/mainlabel)
			"Expands an additional window in which all the consumption streams of the station are listed in detail. They can be turned on and off at your discretion. By disabling the stream, you will prohibit the megacomplex from transferring a specific resource to a specific station" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                 -- Item type
			nil,                        -- Height (nil for iconname/mainlabel)
			getInnerStationIcon('mxstorage'), -- Content. Text or path to the image.
			"'Storage and utilization' tab"%_t -- Content for icon info
		},
		{
			'desc', -- Item type
			1.8, -- Height (nil for iconname/mainlabel)
			"This tab lists all the resources produced/consumed by the stations in one way or another. Here you can set a limit for a specific resource, check the consumption/production streams associated with the resource, and activate a special 'utilization' mode" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',               -- Item type
			nil,                      -- Height (nil for iconname/mainlabel)
			getInnerStationIcon('mxtodelete'), -- Content. Text or path to the image.
			"'Utilization' Mode"%_t -- Content for icon info
		},
		{
			'desc', -- Item type
			1.8, -- Height (nil for iconname/mainlabel)
			"Experimental modification of the request from the stations: the complex will take this resource from them in the usual manner, but as soon as the stock on the complex reaches the limit, it will begin to completely remove this product from the warehouse of the manufacturing stations, thereby not allowing it to accumulate and stop the production process" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',             -- Item type
			nil,                    -- Height (nil for iconname/mainlabel)
			getInnerStationIcon('mxexport'), -- Content. Text or path to the image.
			"'Export' tab"%_t     -- Content for icon info
		},
		{
			'desc',                                           -- Item type
			1,                                                -- Height (nil for iconname/mainlabel)
			"The functionality of this tab is under development"%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',               -- Item type
			nil,                      -- Height (nil for iconname/mainlabel)
			getInnerStationIcon('mxsettings'), -- Content. Text or path to the image.
			"'Settings' tab"%_t     -- Content for icon info
		},
		{
			'desc',                                                                                 -- Item type
			1,                                                                                      -- Height (nil for iconname/mainlabel)
			"Allows you to forcibly initiate some procedures if their automatic initialization failed"%_t, -- Content. Text or path to the image.
		},
	},
}

function infoStations_injectToCodex()
    Player():invokeFunction('ui/cosmiccodex', 'addCategory', 'sf_stations', 'Starfall Stations'%_t, 'data/textures/icons/station.png')

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
        
        Player():invokeFunction("ui/cosmiccodex", "addArticle", "sf_stations", "sf_"..key, name, fullText, mainPic)
    end
end
