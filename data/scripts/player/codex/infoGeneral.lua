package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
include('Neltharaku')
include('Tech')
include('Stations')

--namespace infoGeneral
infoGeneral = {}

local _debug = false
-----------------------------[DATA: MOD]----------------------------

--Types: desc,picture,iconinfo,mainlabel

entities = entities or {}

entities['weaponclasses'] = {
	--Name
	'Weapon class '%_t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                     -- Item type
			nil,                             -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ASSAULTBLASTER.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"A new characteristic of weapon: 'class' determines the behavior of various types of weapons in some situations. You can see the class of the gun in the information panel of the turret, the corresponding line will be located at the very top" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                          -- Item type
			nil,                                 -- Height (nil for iconname/mainlabel)
			'data/textures/icons/weapon/wpnCyclone2.png', -- Content. Text or path to the image.
			'Weapon class - Main Caliber'%_t   -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			"Extremely powerful weapons, which have a huge fire power after assebmbly at the stations, surpassing any other types of weapons. Each ship can use a maximum of two 'main caliber' class weapons without consequences, otherwise the ship receives a serious penalty to the rate of fire. These weapons cannot be used in the production of fighters" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                                -- Item type
			nil,                                       -- Height (nil for iconname/mainlabel)
			'data/textures/icons/weapon/wpnMagneticmortar.png', -- Content. Text or path to the image.
			'Weapon class - Light'%_t                -- Content for icon info
		},
		{
			'desc', -- Item type
			3, -- Height (nil for iconname/mainlabel)
			"Usually, light-class weapons have modest characteristics, inferior to other weapons systems in almost all parameters, however, this situation changes during the production of fighters.\nEach gun has its own unique bonus to fighter basic characteristics, depending on the technical level of the turret, a bonus (or penalty) to the firing range, and also, most importantly, when producing a fighter, a different damage coefficient is applied to the turrets from the standard:\nCombat turrets - 105% instead of 40%\nRepair and other turrets - 80% instead of 40%" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                            -- Item type
			nil,                                   -- Height (nil for iconname/mainlabel)
			'data/textures/icons/weapon/wpnIonEmitter.png', -- Content. Text or path to the image.
			'Weapon class - Heavy'%_t            -- Content for icon info
		},
		{
			'desc',                                                           -- Item type
			0.6,                                                              -- Height (nil for iconname/mainlabel)
			'Weapons of this class cannot be used in the production of fighters'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                     -- Item type
			nil,                            -- Height (nil for iconname/mainlabel)
			'data/textures/icons/weapon/wpnPrd.png', -- Content. Text or path to the image.
			'Weapon class - Standard'%_t  -- Content for icon info
		},
		{
			'desc',                                          -- Item type
			0.6,                                             -- Height (nil for iconname/mainlabel)
			'Conventional weapons using standard Avorion rules'%_t, -- Content. Text or path to the image.
		},
	},
}

entities['weaponnew'] = {
	--Name
	'New weapons'%_t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                   -- Item type
			nil,                           -- Height (nil for iconname/mainlabel)
			'data/textures/icons/HYPERKINETIC.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                              -- Item type
			1.1,                                                                                                 -- Height (nil for iconname/mainlabel)
			"17 new weapons have been added to the game. You can find out more about each one in the tab 'Weapons'"%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',       -- Item type
			nil,              -- Height (nil for iconname/mainlabel)
			getWeaponPath('pulsegun'), -- Content. Text or path to the image.
			getWeaponName('pulsegun') -- Content for icon info
		},
		{
			'desc',                                                                    -- Item type
			1,                                                                         -- Height (nil for iconname/mainlabel)
			'Class: Standard. Rapid-fire low- and medium range weapon. does not overheat'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                  -- Item type
			nil,                         -- Height (nil for iconname/mainlabel)
			getWeaponPath('particleaccelerator'), -- Content. Text or path to the image.
			getWeaponName('particleaccelerator') -- Content for icon info
		},
		{
			'desc',                                            -- Item type
			1,                                                 -- Height (nil for iconname/mainlabel)
			'Class: Standard. Light accurate medium-range weapon'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',             -- Item type
			nil,                    -- Height (nil for iconname/mainlabel)
			getWeaponPath('assaultblaster'), -- Content. Text or path to the image.
			getWeaponName('assaultblaster') -- Content for icon info
		},
		{
			'desc',                                                                               -- Item type
			1.4,                                                                                  -- Height (nil for iconname/mainlabel)
			'Class: Standard. Medium-range rapid-fire weapon that deals increased damage to shields'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',   -- Item type
			nil,          -- Height (nil for iconname/mainlabel)
			getWeaponPath('hept'), -- Content. Text or path to the image.
			getWeaponName('hept') -- Content for icon info
		},
		{
			'desc',                                              -- Item type
			1.4,                                                 -- Height (nil for iconname/mainlabel)
			'Class: Standard. Universal medium-range plasma cannon'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',     -- Item type
			nil,            -- Height (nil for iconname/mainlabel)
			getWeaponPath('mantis'), -- Content. Text or path to the image.
			getWeaponName('mantis') -- Content for icon info
		},
		{
			'desc',                                                                          -- Item type
			1.4,                                                                             -- Height (nil for iconname/mainlabel)
			'Class: Standard. Long-range homing weapon designed to deal against mobile targets'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',  -- Item type
			nil,         -- Height (nil for iconname/mainlabel)
			getWeaponPath('prd'), -- Content. Text or path to the image.
			getWeaponName('prd') -- Content for icon info
		},
		{
			'desc',                                                                 -- Item type
			1.4,                                                                    -- Height (nil for iconname/mainlabel)
			'Class: Standard. Powerful, but not very accurate rail-type plasma weapon'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',         -- Item type
			nil,                -- Height (nil for iconname/mainlabel)
			getWeaponPath('plasmaflak'), -- Content. Text or path to the image.
			getWeaponName('plasmaflak') -- Content for icon info
		},
		{
			'desc',                                             -- Item type
			1.4,                                                -- Height (nil for iconname/mainlabel)
			'Class: Defensive. Rapid-fire weapon against fighters'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',         -- Item type
			nil,                -- Height (nil for iconname/mainlabel)
			getWeaponPath('pulselaser'), -- Content. Text or path to the image.
			getWeaponName('pulselaser') -- Content for icon info
		},
		{
			'desc',                                                                  -- Item type
			1.4,                                                                     -- Height (nil for iconname/mainlabel)
			'Class: Light. A rapid-firing light low-range weapon designed for fighters'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',            -- Item type
			nil,                   -- Height (nil for iconname/mainlabel)
			getWeaponPath('assaultcannon'), -- Content. Text or path to the image.
			getWeaponName('assaultcannon') -- Content for icon info
		},
		{
			'desc',                                                                                            -- Item type
			1.4,                                                                                               -- Height (nil for iconname/mainlabel)
			'Class: Light. A versatile powerful, but not very accurate medium-range weapon designed for fighters'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',             -- Item type
			nil,                    -- Height (nil for iconname/mainlabel)
			getWeaponPath('magneticmortar'), -- Content. Text or path to the image.
			getWeaponName('magneticmortar') -- Content for icon info
		},
		{
			'desc',                                                      -- Item type
			1.4,                                                         -- Height (nil for iconname/mainlabel)
			'Class: Light. A long-range siege weapon designed for fighters'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',         -- Item type
			nil,                -- Height (nil for iconname/mainlabel)
			getWeaponPath('nanorepair'), -- Content. Text or path to the image.
			getWeaponName('nanorepair') -- Content for icon info
		},
		{
			'desc',                                                         -- Item type
			1.4,                                                            -- Height (nil for iconname/mainlabel)
			'Class: Light. Beam weapon for hull repair, designed for fighters'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',           -- Item type
			nil,                  -- Height (nil for iconname/mainlabel)
			getWeaponPath('chargingbeam'), -- Content. Text or path to the image.
			getWeaponName('chargingbeam') -- Content for icon info
		},
		{
			'desc',                                                              -- Item type
			1.4,                                                                 -- Height (nil for iconname/mainlabel)
			'Class: Light. A beam gun for repairing shields, designed for fighters'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',           -- Item type
			nil,                  -- Height (nil for iconname/mainlabel)
			getWeaponPath('photoncannon'), -- Content. Text or path to the image.
			getWeaponName('photoncannon') -- Content for icon info
		},
		{
			'desc',                                                       -- Item type
			1.4,                                                          -- Height (nil for iconname/mainlabel)
			'Class: Heavy. A powerful siege weapon designed for heavy ships'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',         -- Item type
			nil,                -- Height (nil for iconname/mainlabel)
			getWeaponPath('ionemitter'), -- Content. Text or path to the image.
			getWeaponName('ionemitter') -- Content for icon info
		},
		{
			'desc',                                                                                              -- Item type
			1.4,                                                                                                 -- Height (nil for iconname/mainlabel)
			'Class: Heavy. A powerful siege weapon designed for heavy ships. Deals serious damage to enemy shields'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',           -- Item type
			nil,                  -- Height (nil for iconname/mainlabel)
			getWeaponPath('hyperkinetic'), -- Content. Text or path to the image.
			getWeaponName('hyperkinetic') -- Content for icon info
		},
		{
			'desc', -- Item type
			1.4, -- Height (nil for iconname/mainlabel)
			'Class: Main Caliber. High-powered sniper weapon capable of destroying vulnerable targets with a single shot' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',        -- Item type
			nil,               -- Height (nil for iconname/mainlabel)
			getWeaponPath('avalanche'), -- Content. Text or path to the image.
			getWeaponName('avalanche') -- Content for icon info
		},
		{
			'desc', -- Item type
			1.4, -- Height (nil for iconname/mainlabel)
			'Class: Main Caliber. A siege weapon capable of inflicting massive damage to slow and stationary targets' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',      -- Item type
			nil,             -- Height (nil for iconname/mainlabel)
			getWeaponPath('cyclone'), -- Content. Text or path to the image.
			getWeaponName('cyclone') -- Content for icon info
		},
		{
			'desc', -- Item type
			1.4, -- Height (nil for iconname/mainlabel)
			'Class: Main Caliber. A weapon capable of inflicting great damage to any targets at a long distance, but in need of a long recharge' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',          -- Item type
			nil,                 -- Height (nil for iconname/mainlabel)
			getWeaponPath('transphasic'), -- Content. Text or path to the image.
			getWeaponName('transphasic') -- Content for icon info
		},
		{
			'desc',                                                                                   -- Item type
			1.4,                                                                                      -- Height (nil for iconname/mainlabel)
			'Class: Main Caliber. A universal laser heavy weapon that deals good damage at medium range'%_t, -- Content. Text or path to the image.
		},
	},
}

entities['weaponrebalance'] = {
	--Name
	'Vanilla weapons changes'%_t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',             -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			'data/textures/icons/turret.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"Almost all vanilla weapons have changes that somehow increase their combat potential. This also affects opponents, making them more dangerous. The full list of changes is available in the 'Weapons' tab" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                -- Item type
			nil,                       -- Height (nil for iconname/mainlabel)
			"data/textures/icons/chaingun.png", -- Content. Text or path to the image.
			'Chaingun'%_t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			'Class: Standard. Base damage increased. The damage, range and speed of the projectile will increase further with the technical level' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                 -- Item type
			nil,                        -- Height (nil for iconname/mainlabel)
			"data/textures/icons/laser-gun.png", -- Content. Text or path to the image.
			'Laser'%_t                -- Content for icon info
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			'Class: Standard. The base damage is increased and range is slightly reduced. Now it pierces up to two blocks. During assembly, it receives bonus damage on shields' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                  -- Item type
			nil,                         -- Height (nil for iconname/mainlabel)
			"data/textures/icons/plasma-gun.png", -- Content. Text or path to the image.
			'Plasma Gun'%_t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			"Class: Standard. The base damage is increased and additionally increases with the tech level. The base range also increases slightly with the tech level. Bonus damage to shields increases during assembly" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                       -- Item type
			nil,                              -- Height (nil for iconname/mainlabel)
			"data/textures/icons/rocket-launcher.png", -- Content. Text or path to the image.
			'Rocket Launcher'%_t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1, -- Height (nil for iconname/mainlabel)
			'Class: Heavy. The class has been changed, the damage has been increased, the assembly bonuses have been redesigned. During production, it is possible to increase the flight speed of missiles, but the range has become lower' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',              -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			"data/textures/icons/cannon.png", -- Content. Text or path to the image.
			'Cannon'%_t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			"Class: Heavy. The class has been changed. The base damage has been increased, and the weapon now receives a base bonus to damage on shields and hull. Can no longer receive the Antimatter damage type. Gets big bonuses during assembly" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                -- Item type
			nil,                       -- Height (nil for iconname/mainlabel)
			"data/textures/icons/rail-gun.png", -- Content. Text or path to the image.
			'Railgun'%_t             -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Heavy. The class has been changed. The logic of use has been redesigned - now it is a low- and medium-range weapon operating like a slug gun' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                   -- Item type
			nil,                          -- Height (nil for iconname/mainlabel)
			"data/textures/icons/repair-beam.png", -- Content. Text or path to the image.
			'Repair Laser'%_t           -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Standard. The basic repair has been greatly increased and will be further increased with tech level. During assembly, the range is greatly increased' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',              -- Item type
			nil,                     -- Height (nil for iconname/mainlabel)
			"data/textures/icons/bolter.png", -- Content. Text or path to the image.
			'Bolter'%_t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Standard. The base damage is increased, the threshold of the minimum rate of fire is increased, and the base speed of the projectile will increase with the tech level. Gets more bonuses during assembly' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                     -- Item type
			nil,                            -- Height (nil for iconname/mainlabel)
			"data/textures/icons/lightning-gun.png", -- Content. Text or path to the image.
			'Lightning Gun'%_t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Heavy. The class has been changed. The base damage is increased, the rate of fire is significantly reduced (does not affect damage). Receives strong bonuses during assembly' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                 -- Item type
			nil,                        -- Height (nil for iconname/mainlabel)
			"data/textures/icons/tesla-gun.png", -- Content. Text or path to the image.
			'Tesla Gun'%_t            -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			"Class: Standard. Shield damage increased. Can no longer receive the type of damage 'plasma', however, during assembly, the damage to shields increases significantly, as well as normal damage" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                   -- Item type
			nil,                          -- Height (nil for iconname/mainlabel)
			"data/textures/icons/pulsecannon.png", -- Content. Text or path to the image.
			'Pulse Cannon'%_t           -- Content for icon info
		},
		{
			'desc', -- Item type
			1.2, -- Height (nil for iconname/mainlabel)
			'Class: Standard. Base damage is noticeably increased. The range of fire and the speed of the projectile will increase with tech level. Assembly bonuses are increased' %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['systemnew'] = {
	--Name
	'New systems'%_t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                       -- Item type
			nil,                               -- Height (nil for iconname/mainlabel)
			'data/textures/icons/STArepairPassive.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"The mod contains new ship systems that allow you to more accurately specialize vessels for various tasks. Some of them are active - in addition to providing passive bonuses, they supplement their effect with interactive abilities.\n Learn more in the 'systems' tab" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                       -- Item type
			nil,                              -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSrepairDrones.png', -- Content. Text or path to the image.
			getTechName('repairdrones')       -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			"Designed to improve the survival ability of hull-based ships.\nIncreases  durability, applies additional passive repair in case of serious damage. Active abilities are aimed at repairing hull" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                         -- Item type
			nil,                                -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYShypergenerator.png', -- Content. Text or path to the image.
			getTechName('xperimentalhypergenerator') -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			'A system for heavy carrier ships and scouts. Increases the chances of leaving the sector after an unlucky warp into an enemy fleet.\nImproves the jump range and cooldown, but increases the energy consumption of the jump.\nActive abilities affect jump range, charging speed, and survival before jumping' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                  -- Item type
			nil,                         -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSbastion.png', -- Content. Text or path to the image.
			getTechName('bastionsystem') -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			'Designed for heavy shield-based ships.\nReduces the volume of the shield, but increases its regeneration and reduces the time before charging.\nActive abilities allow you to strengthen the shield, restore it, make it impenetrable and completely protect yourself from any torpedoes for a while' %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                              -- Item type
			nil,                                     -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSmacrofieldprojector.png', -- Content. Text or path to the image.
			getTechName('macrofieldprojector')       -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			"Designed to specialize ship into repair class. Uses the ship's battery to generate repair beams or a powerful repair field" %
			_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                     -- Item type
			nil,                            -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSpReactor3.png', -- Content. Text or path to the image.
			getTechName('pulsetractorbeamgenerator') -- Content for icon info
		},
		{
			'desc',                                                                            -- Item type
			2,                                                                                 -- Height (nil for iconname/mainlabel)
			'Allows you to temporarily accelerate the radius of the tractor beam to large values'%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                        -- Item type
			nil,                               -- Height (nil for iconname/mainlabel)
			'data/textures/icons/SYSsubspacecargo.png', -- Content. Text or path to the image.
			getTechName('subspacecargo')       -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			'Improves the cargo bay, but reduces energy production and slightly reduces the shields. Always a percentage bonus' %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['stationnew'] = {
	--Name
	'New stations'%_t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',              -- Item type
			nil,                      -- Height (nil for iconname/mainlabel)
			'data/textures/icons/station.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                         -- Item type
			1.3,                                                                            -- Height (nil for iconname/mainlabel)
			"New stations added by modification. For more information, see the 'stations' tab"%_t, -- Content. Text or path to the image.
		},
		{
			'iconinfo',                      -- Item type
			nil,                             -- Height (nil for iconname/mainlabel)
			'data/textures/icons/MCXmegaComplex.png', -- Content. Text or path to the image.
			getStationName('mx')             -- Content for icon info
		},
		{
			'desc', -- Item type
			2, -- Height (nil for iconname/mainlabel)
			'Megacomplex is a station that allows you to set up automatic and fast logistics of resources between all docked stations' %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['alertsystem'] = {
	--Name
	'Alert system'%_t,
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
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			'A system of visual and audio alerts. The graphical part in the form of an icon appears on the right side of the screen and unfolds when the cursor is hovered over. The current working types of alerts are indicated in the corresponding tab' %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['combatgroup'] = {
	--Name
	'Combat group'%_t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                   -- Item type
			nil,                           -- Height (nil for iconname/mainlabel)
			'data/textures/icons/FederationSC.png', -- Content. Text or path to the image.
		},
		{
			'desc', -- Item type
			1.3, -- Height (nil for iconname/mainlabel)
			"Graphical interface for working with a group of players. Allows you to search, invite to a group, kick players and transfer leadership without the need to use chat commands. For more information, see the 'interfaces' tab" %
			_t, -- Content. Text or path to the image.
		},
	},
}

entities['asi'] = {
	--Name
	'Active System Interface'%_t,
	--belongs to:
	nil,
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
	},
}

entities['auracore'] = {
	--Name
	'Active effects'%_t,
	--belongs to:
	nil,
	--Content
	{
		{
			'mainlabel',                          -- Item type
			nil,                                  -- Height (nil for iconname/mainlabel)
			'data/textures/icons/ui/ui_invitePending.png', -- Content. Text or path to the image.
		},
		{
			'desc',                                                                                  -- Item type
			1.3,                                                                                     -- Height (nil for iconname/mainlabel)
			"An interface that displays active effects from the Cosmic Starfall mod affecting the ship"%_t, -- Content. Text or path to the image.
		},
	},
}

function infoGeneral_injectToCodex()
    Player():invokeFunction('ui/cosmiccodex', 'addCategory', 'sf_cat', 'Cosmic Starfall'%_t, 'data/textures/icons/vortex.png')
    Player():invokeFunction('ui/cosmiccodex', 'addChapter', 'sf_cat', 'sf_general', 'Starfall General'%_t)

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
        
        Player():invokeFunction("ui/cosmiccodex", "addArticle", "sf_general", "sf_"..key, name, fullText, mainPic)
    end
end
