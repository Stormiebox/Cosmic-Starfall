include('utility')
package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')
include('Tech')

--namespace infoSystems
infoSystems = {}

local _debug = false
-----------------------------[DATA: ACTIVE]------------------------------------------
entities = entities or {}

entities['bastionSystem'] = {
	--Icon
	getTechIcon('bastionsystem'),
	--Name
	getTechName('bastionsystem'),
	--Description
	{
		"A unique system designed to be installed on ships based on a shield. Modifies the ship's shields, reducing their volume, but in return increases their charging speed and reduces the time before it starts.\nActive Bastion systems allow you to reduce damage to the shield at the cost of reducing weapons fire rate (while repairing the hull), accumulate a charge from the damage received to replenish the shield, make it temporarily impenetrable, and also instantly destroy hostile torpedoes for a short time" %
		_t,
		1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ "data/textures/icons/health-normal.png", "Shield Durability"%_t,    '- (rand(27,31) - R * 2)%' },
		{ "data/textures/icons/shield-charge.png", "Shield Recharge Rate"%_t, '+ (rand(14,19) + R * 3)%' },
		{ "data/textures/icons/recharge-time.png", "Time Until Recharge"%_t,  '- (rand(19,21) + R * 2)%' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('bastionsystem', 1),

			getSubtechName('bastionsystem', 1),
			"Activating the module increases the shield's resistance to all damage, and also slowly restores the ship's hull. During the operation of the module, the rate of fire of all weapons drops" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('bastionsystem', 2),

			getSubtechName('bastionsystem', 2),
			"Plasma, energy and electrical damage received by the shield accumulates a charge that can be used to restore shields" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('bastionsystem', 3),

			getSubtechName('bastionsystem', 3),
			"Activation makes the shields impenetrable for the duration of the module. Also, for a short time after activation, the delay before regeneration after receiving damage is significantly reduced" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('bastionsystem', 4),

			getSubtechName('bastionsystem', 4),
			"During operation, your ship will automatically and instantly shoot down all torpedoes that are aimed at it, as well as all hostile torpedoes within the range of the module. Anti-aircraft weapons are not required for operation" %
			_t,

			1 -- description window height modifier from standard
		},
	},
}

entities['macrofieldProjector'] = {
	--Icon
	getTechIcon('macrofieldprojector'),
	--Name
	getTechName('macrofieldprojector'),
	--Description
	{
		"A special system designed to fully specialize ship to repair-class at the cost of a significant reduction in defensive and offensive capabilities. To achieve an acceptable amount of repairs per second, it is necessary to turn the ship into a flying battery, since three of the four active systems directly depend on its volume (and on the rate of energy replenishment).\nActive systems allow you to send a beam to an ally restoring the hull or shield, absorbing battery energy for operation, or, in critical situations, at the cost of huge energy costs, activate mass repairs of the hull in a large radius.\nIn addition, it allows you to link the shields of your and any other player's ship, gradually equalizing their percentage of volume" %
		_t,
		1.4, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ 'data/textures/icons/electric.png',         "Generated Energy"%_t, '+ 20 + R * 4 %' },
		{ "data/textures/icons/battery-pack-alt.png", "Energy Capacity"%_t,  '+ 130 + R * 15 %' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('macrofieldprojector', 1),

			getSubtechName('macrofieldprojector', 1),

			string.format(
				"Activating the module burns the ship's energy very quickly, restoring the hull to all allied ships of the players. This effect also works on the ship itself, restoring the increased volume of the hull to it. Wave activation disables %s and %s" %
				_t, getSubtechName('macrofieldprojector', 2), getSubtechName('macrofieldprojector', 3)),

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('macrofieldprojector', 2),

			getSubtechName('macrofieldprojector', 2),
			"Gradually burns the battery's energy reserve, repairing the hull of the selected allied ship. The amount of repair directly depends on the amount of energy burned. The beam does not work if the target has flown out of range or if its hull is 100%. Activation turns off the operation of the 'Shield Amplifier'.\nWorks only on ships owned by players!" %
			_t,

			1.1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('macrofieldprojector', 3),

			getSubtechName('macrofieldprojector', 3),
			"Works as a 'Renovation ray', but restores the shields of an allied target. The amount of repair directly depends on the amount of energy burned. The booster does not work if the target has flown out of range, if its shields have dropped below the minimum threshold, or if they have reached 100%. Activation disables the operation of the 'Renovation ray'.\nWorks only on ships owned by players!" %
			_t,

			1.2 -- description window height modifier from standard
		},

		{
			getSubtechIcon('macrofieldprojector', 4),

			getSubtechName('macrofieldprojector', 4),
			'Forms a link between your ship and the target. The module will gradually syphon the shields in both directions, trying to equalize their percentage. It does not consume energy and can work independently of the other three modules./nWorks only on ships owned by players!' %
			_t,

			1 -- description window height modifier from standard
		},
	},
}

entities['repairDrones'] = {
	--Icon
	getTechIcon('repairdrones'),
	--Name
	getTechName('repairdrones'),
	--Description
	{
		"Designed for combat vessels based on the hull. When installed, it slightly increases its volume and provides a unique bonus in the form of accelerated repairs when the hull is at a critical level. Active systems allow you to accelerate repairs in combat, increase the chances of surviving in a dangerous situation and restore hull faster out of combat" %
		_t,
		1.1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ 'data/textures/icons/staDurability.png', "Hull Durability"%_t,      '+ (6 + R * 3)%' },
		{ "data/textures/icons/staRepair.png",     "Auto-repair treshold"%_t, '+ (10 + R * 2)%' },
		{ "data/textures/icons/staRepair.png",     "Auto-repair value"%_t,    '0.2% / s.' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('repairdrones', 1),

			getSubtechName('repairdrones', 1),
			"Activation of this system restores hull for a limited time. However, this system will not restore hull if its volume exceeds 50%" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('repairdrones', 2),

			getSubtechName('repairdrones', 2),
			"Gradually restores the hull for a long time, works even in the negative environment of rifts. Receiving any damage or repairs with the help of repair lasers interrupts the operation of the module and reduces the remaining recharge time by 60%" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('repairdrones', 3),

			getSubtechName('repairdrones', 3),
			"Activation puts the module in standby mode for 20 seconds. If during this time hull durability falls below a certain value, the module turns on, simultaneously restoring a certain percentage of hull and accelerates passive repair three times" %
			_t,

			1 -- description window height modifier from standard
		},

	},
}

entities['XperimentalHypergenerator'] = {
	--Icon
	getTechIcon('xperimentalhypergenerator'),
	--Name
	getTechName('xperimentalhypergenerator'),
	--Description
	{
		"An excellent module for risky travel and exploration. Slightly increases the jump range and reduces its cooldown at the cost of a decent increase in energy consumption.\nThe active systems of this module allow you to significantly increase the jump range at the cost of increasing the recharge time after its execution, accelerate the charging of the hyperdrive in critical situations and sacrifice the combat capability of the ship to get additional survival during the calculation of the jump route" %
		_t,
		1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ "data/textures/icons/hourglass.png",  "Hyperspace Cooldown"%_t,      '+ (rand(8,12) + R * 3)%' },
		{ "data/textures/icons/electric.png",   "Hyperspace Charge Energy"%_t, '+ (rand(37,43) - R * 2)%' },
		{ "data/textures/icons/star-cycle.png", "Jump Range"%_t,               '- (rand(1,3) + R)%' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('xperimentalhypergenerator', 1),

			getSubtechName('xperimentalhypergenerator', 1),
			"Activation puts the module into standby mode. As soon as the ship begins to calculate the jump route, the module is activated and begins to quickly restore shields, while the rate of fire of the weapons will be seriously reduced before the jump" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('xperimentalhypergenerator', 2),

			getSubtechName('xperimentalhypergenerator', 2),
			"The activation of the module greatly accelerates the recharge of the hyperdrive, causing damage to the ship's hull during operation. For the module to work, it is necessary that the volume of the ship's shields fall below a certain threshold" %
			_t,

			1 -- description window height modifier from standard
		},

		{
			getSubtechIcon('xperimentalhypergenerator', 3),

			getSubtechName('xperimentalhypergenerator', 3),
			"Activation requires additional hyperdrive charging (cannot be performed if the hyperdrive is still charging) and increases the allowable jump range by more than twice. Adds extra time to recharge after performing a jump, depending on the range bonus provided." %
			_t,

			1 -- description window height modifier from standard
		},
	},
}

entities['pulseTractorBeamGenerator'] = {
	--Icon
	getTechIcon('pulsetractorbeamgenerator'),
	--Name
	getTechName('pulsetractorbeamgenerator'),
	--Description
	{
		"Does not provide any passive bonuses. It is equipped with only one active system, which gradually expands the radius of the attracting beam to large values, allowing you to collect loot in a huge radius during the action" %
		_t,
		1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ "data/textures/icons/SYSpReactor3.png", "Number of pulses"%_t, '+ ((R+2) * 4)' },
		{ "data/textures/icons/SYSpReactor3.png", "Range"%_t,            '+ 200' },
	},
	--Active Effects
	{
		{
			getSubtechIcon('pulsetractorbeamgenerator', 1),

			getSubtechName('pulsetractorbeamgenerator', 1),
			"During operation, every two seconds it makes an impulse that increases the range of the attracting beam by a fixed value. The number of pulses depends on the rarity level of the system. At the end of the work, the beam range returns to the initial value" %
			_t,

			1 -- description window height modifier from standard
		},
	},
}
-----------------------------[DATA: PASSIVE]----------------------------

entities['subspaceCargo'] = {
	--Icon
	getTechIcon('subspacecargo'),
	--Name
	getTechName('subspacecargo'),
	--Description
	{
		"Using rift technology creates a stable subspace storage"%_t,
		1, -- description window height modifier from standard
	},
	--Passive bonuses/penalties
	{
		{ 'data/textures/icons/crate.png',         "Cargo Hold (relative)"%_t, '+ (rand(31,35) + R * 4)%' },
		{ "data/textures/icons/electric.png",      "Generated Energy"%_t,      '- (rand(14,18) - R)%' },
		{ "data/textures/icons/health-normal.png", "Shield Durability"%_t,     '- (rand(11,15) - R)%' },
	},
	--Active Effects
	nil,
}


function infoSystems_injectToCodex()
    Player():invokeFunction('ui/cosmiccodex', 'addCategory', 'sf_cat', 'Cosmic Starfall'%_t, 'data/textures/icons/vortex.png')
    Player():invokeFunction('ui/cosmiccodex', 'addChapter', 'sf_cat', 'sf_systems', 'Starfall Systems'%_t)

    for key, data in pairs(entities) do
        local icon = data[1] or ""
        local name = data[2] or "Unknown"
        local descTable = data[3] or {"", 1}
        local desc = descTable[1] or ""
        local bonuses = data[4] or {}
        local spells = data[5] or {}
        
        local fullText = desc .. "\n\nBonuses:\n"
        for _, b in pairs(bonuses) do
            fullText = fullText .. "- " .. (b[2] or "") .. ": " .. (b[3] or "") .. "\n"
        end
        
        if spells and #spells > 0 then
            fullText = fullText .. "\nActive Abilities:\n"
            for _, s in pairs(spells) do
                fullText = fullText .. "\n[" .. (s[2] or "") .. "]\n" .. (s[3] or "") .. "\n"
            end
        end
        
        Player():invokeFunction("ui/cosmiccodex", "addArticle", "sf_systems", "sf_sys_"..key, name, fullText, icon)
    end
end
