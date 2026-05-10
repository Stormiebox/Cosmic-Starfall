--===========================[Ванильные орудия]===========================

TurretIngredients[WeaponType.ChainGun] =
{
    {name = "Servo",            amount = 15,    investable = 10,    minimum = 3, rarityFactor = 0.75,   weaponStat = "fireRate", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Steel Tube",       amount = 6,     investable = 7,              weaponStat = "reach", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Ammunition S",     amount = 5,     investable = 12,    minimum = 1,   weaponStat = "damage", investFactor = 0.6, changeType = StatChanges.Percentage},
	{name = "High Pressure Tube",     amount = 5,     investable = 7,    minimum = 1,                        weaponStat = "hullDamageMultiplier", investFactor = 0.2, changeType = StatChanges.Percentage},
    {name = "Steel",            amount = 5,     investable = 10,    minimum = 3},
    {name = "Aluminum",         amount = 7,     investable = 5,     minimum = 3},
    {name = "Lead",             amount = 10,    investable = 10,    minimum = 1},
}

TurretIngredients[WeaponType.RailGun] =
{
    {name = "Servo",                amount = 15,   investable = 10, minimum = 6,   weaponStat = "fireRate", investFactor = 1.0, changeType = StatChanges.Percentage},
    {name = "Electromagnetic Charge",amount = 5,   investable = 6,  minimum = 1,   weaponStat = "damage", investFactor = 0.3, changeType = StatChanges.Percentage},
    {name = "Electro Magnet",       amount = 8,    investable = 10, minimum = 3,    weaponStat = "shieldDamageMultiplier", investFactor = 0.35, changeType = StatChanges.Percentage},
    {name = "Gauss Rail",           amount = 5,    investable = 6,  minimum = 1,    weaponStat = "damage", investFactor = 0.3, changeType = StatChanges.Percentage},
    {name = "High Pressure Tube",   amount = 2,    investable = 4,  minimum = 1,    weaponStat = "reach",  investFactor = 0.25, changeType = StatChanges.Percentage},
    {name = "Steel",                amount = 5,    investable = 10, minimum = 3,},
    {name = "Copper",               amount = 2,    investable = 10, minimum = 1,},
}

TurretIngredients[WeaponType.RocketLauncher] =
{
    {name = "Servo",                amount = 15,   investable = 10, minimum = 5,  weaponStat = "fireRate", investFactor = 1.0, changeType = StatChanges.Percentage},
    {name = "Rocket",               amount = 5,    investable = 6,  minimum = 1,    weaponStat = "damage", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "High Pressure Tube",   amount = 2,    investable = 6,  minimum = 1,    weaponStat = "reach", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Fuel",                 amount = 2,    investable = 10,  minimum = 1,    weaponStat = "damage", investFactor = 0.2, changeType = StatChanges.Percentage},
	{name = "Explosive Charge",                 amount = 2,    investable = 5,  minimum = 1,    weaponStat = "hullDamageMultiplier", investFactor = 0.2, changeType = StatChanges.Percentage},
    {name = "Targeting Card",       amount = 5,    investable = 5,  minimum = 0,     weaponStat = "seeker", investFactor = 1, changeType = StatChanges.Flat},
	{name = "Coolant",                 amount = 2,    investable = 12,  minimum = 2,    weaponStat = "pvelocity", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Steel",                amount = 8,    investable = 10, minimum = 3,},
    {name = "Wire",                 amount = 5,    investable = 10, minimum = 3,},
}

TurretIngredients[WeaponType.Laser] =
{
    {name = "Laser Head",           amount = 4,    investable = 4,              weaponStat = "damage", investFactor = 0.3, changeType = StatChanges.Percentage },
    {name = "Laser Compressor",     amount = 2,    investable = 2,              weaponStat = "damage", investFactor = 0.5, changeType = StatChanges.Percentage },
    {name = "High Capacity Lens",   amount = 2,    investable = 4,              weaponStat = "reach", investFactor = 1.3, changeType = StatChanges.Percentage},
    {name = "Laser Modulator",      amount = 2,    investable = 4,  minimum = 2,},
    {name = "Power Unit",           amount = 5,    investable = 3,  minimum = 3, turretStat = "maxHeat", investFactor = 0.75, changeType = StatChanges.Percentage},
	{name = "Conductor", amount = 2,    investable = 6,  minimum = 2,    weaponStat = "shieldDamageMultiplier", investFactor = 0.5, changeType = StatChanges.Percentage },
    {name = "Steel",                amount = 5,    investable = 10, minimum = 3,},
    {name = "Crystal",              amount = 2,    investable = 10, minimum = 1, },
}

TurretIngredients[WeaponType.PulseCannon] =
{
    {name = "Servo",                amount = 8,    investable = 8,  minimum = 3, rarityFactor = 0.75,   weaponStat = "fireRate", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Steel Tube",           amount = 6,    investable = 7,                                      weaponStat = "reach", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Ammunition S",         amount = 5,    investable = 12,  minimum = 1,                       weaponStat = "damage", investFactor = 0.6, changeType = StatChanges.Percentage},
    {name = "Steel",                amount = 5,    investable = 10, minimum = 4},
    {name = "Copper",               amount = 5,    investable = 10, minimum = 3,},
    {name = "Energy Cell",          amount = 3,    investable = 5,  minimum = 2,},
}

TurretIngredients[WeaponType.Bolter] =
{
    {name = "Servo",                amount = 15,    investable = 8,     minimum = 5,    rarityFactor = 0.75, weaponStat = "fireRate", investFactor = 1.1, changeType = StatChanges.Percentage},
    {name = "High Pressure Tube",   amount = 1,     investable = 5,                     weaponStat = "reach", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Ammunition M",         amount = 5,     investable = 12,    minimum = 1,    weaponStat = "damage", investFactor = 0.2, changeType = StatChanges.Percentage},
    {name = "Explosive Charge",     amount = 2,     investable = 4,     minimum = 1,    weaponStat = "damage", investFactor = 0.4, changeType = StatChanges.Percentage},
	{name = "Power Unit",	amount = 2,    investable = 4,  minimum = 2,    weaponStat = "pvelocity", investFactor = 0.2, changeType = StatChanges.Percentage},
    {name = "Steel",                amount = 5,     investable = 10,    minimum = 3,},
    {name = "Aluminum",            amount = 7,     investable = 5,     minimum = 3,},
}

TurretIngredients[WeaponType.Cannon] =
{
    {name = "Servo",                amount = 15,   investable = 10, minimum = 5,  weaponStat = "fireRate", investFactor = 1.0, changeType = StatChanges.Percentage},
	{name = "Fusion Generator", amount = 0,   investable = 2, minimum = 0,  weaponStat = "hullDamageMultiplier", investFactor = 1.0, changeType = StatChanges.Percentage},
	{name = "Gauss Rail",	amount = 0,    investable = 4,  minimum = 0,    weaponStat = "pvelocity", investFactor = 0.3, changeType = StatChanges.Percentage},
    {name = "Warhead",              amount = 5,    investable = 8,  minimum = 1,    weaponStat = "damage", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "High Pressure Tube",   amount = 2,    investable = 6,  minimum = 1,    weaponStat = "reach", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Explosive Charge",     amount = 2,    investable = 8,  minimum = 1,    weaponStat = "damage", investFactor = 0.2, changeType = StatChanges.Percentage},
	{name = "Coolant",           amount = 2,    investable = 7,  minimum = 3, turretStat = "maxHeat", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Steel",                amount = 8,    investable = 10, minimum = 3,},
    {name = "Wire",                 amount = 5,    investable = 10, minimum = 3,},
}

TurretIngredients[WeaponType.TeslaGun] =
{
    {name = "Industrial Tesla Coil",amount = 5,    investable = 9,  minimum = 1,    weaponStat = "damage", investFactor = 0.5, changeType = StatChanges.Percentage},
    {name = "Electromagnetic Charge",amount = 2,   investable = 4,  minimum = 1,    weaponStat = "reach", investFactor = 0.2, changeType = StatChanges.Percentage },
    {name = "Energy Inverter",      amount = 2,    investable = 4,  minimum = 1,weaponStat = "shieldDamageMultiplier", investFactor = 0.3, changeType = StatChanges.Percentage },
    {name = "Conductor",            amount = 5,    investable = 6,  minimum = 2,},
    {name = "Power Unit",           amount = 5,    investable = 5,  minimum = 3, turretStat = "maxHeat", investFactor = 0.75, changeType = StatChanges.Percentage},
    {name = "Copper",               amount = 5,    investable = 10, minimum = 3,},
    {name = "Energy Cell",          amount = 5,    investable = 10, minimum = 3,},
}

TurretIngredients[WeaponType.PlasmaGun] =
{
    {name = "Plasma Cell",          amount = 8,    investable = 12,  minimum = 1,   weaponStat = "damage", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Energy Tube",          amount = 2,    investable = 5,  minimum = 1,    weaponStat = "reach", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Conductor",            amount = 5,    investable = 6,  minimum = 1,},
    {name = "Energy Container",     amount = 5,    investable = 3,  minimum = 1, weaponStat = "pvelocity", investFactor = 0.3, changeType = StatChanges.Percentage},
    {name = "Power Unit",           amount = 5,    investable = 7,  minimum = 3,    turretStat = "maxHeat", investFactor = 0.70, changeType = StatChanges.Percentage},
	{name = "Industrial Tesla Coil", amount = 0,    investable = 4,  minimum = 0, weaponStat = "shieldDamageMultiplier", investFactor = 0.3, changeType = StatChanges.Percentage},
    {name = "Steel",                amount = 4,    investable = 10, minimum = 3,},
    {name = "Crystal",              amount = 2,    investable = 10, minimum = 1,},
}

TurretIngredients[WeaponType.LightningGun] =
{
    {name = "Military Tesla Coil",  amount = 5,    investable = 12,  minimum = 1,    weaponStat = "damage", investFactor = 0.55, changeType = StatChanges.Percentage},
    {name = "High Capacity Lens",   amount = 2,    investable = 4,  minimum = 1,    weaponStat = "reach", investFactor = 0.2, changeType = StatChanges.Percentage },
	
    {name = "Electromagnetic Charge",amount = 2,   investable = 4,  minimum = 1,},
    {name = "Conductor",            amount = 5,    investable = 6,  minimum = 2,},
    {name = "Power Unit",           amount = 5,    investable = 4,  minimum = 3,    weaponStat = "fireRate", investFactor = 0.4, changeType = StatChanges.Percentage},
	{name = "Fusion Core",           amount = 0,    investable = 6,  minimum = 0,    turretStat = "maxHeat", investFactor = 0.7, changeType = StatChanges.Percentage},
    {name = "Copper",               amount = 5,    investable = 10, minimum = 3,},
    {name = "Energy Cell",          amount = 5,    investable = 10, minimum = 3,},
}

TurretIngredients[WeaponType.RepairBeam] =
{
    {name = "Nanobot",              amount = 5,    investable = 10,  minimum = 1,      weaponStat = "hullRepair", investFactor = 0.6, changeType = StatChanges.Percentage},
    {name = "Transformator",        amount = 2,    investable = 12,  minimum = 1,    weaponStat = "shieldRepair", investFactor = 0.65, changeType = StatChanges.Percentage},
    {name = "Laser Modulator",      amount = 2,    investable = 6,  minimum = 0,    weaponStat = "reach", investFactor = 0.75, changeType = StatChanges.Percentage},
    {name = "Conductor",            amount = 2,    investable = 6,  minimum = 0,    turretStat = "energyIncreasePerSecond",  investFactor = -0.5, changeType = StatChanges.Percentage},
	{name = "Power Unit",           amount = 0,    investable = 8,  minimum = 0,    turretStat = "maxHeat", investFactor = 0.70, changeType = StatChanges.Percentage},
    {name = "Gold",                 amount = 3,    investable = 10, minimum = 1,},
    {name = "Steel",                amount = 8,    investable = 10, minimum = 3,},
}

--===========================[Кастомные орудия]===========================
TurretIngredients[WeaponType.PULSEGUN] =
{
    {name = "Servo",            	amount = 15,   investable = 10, minimum = 3, rarityFactor = 0.75, weaponStat = "fireRate", investFactor = 0.5},
    {name = "Energy Tube",          amount = 5,    investable = 6,  minimum = 1,    weaponStat = "damage", investFactor = 1.1},
    {name = "Conductor",            amount = 5,    investable = 6,  minimum = 5, weaponStat = "reach", investFactor = 0.3},
    {name = "Energy Container",     amount = 5,    investable = 6,  minimum = 5,},
    {name = "Power Unit",           amount = 3,    investable = 4,  minimum = 2,},
    {name = "Steel",                amount = 4,    investable = 10, minimum = 4,},
    {name = "Copper",               amount = 2,    investable = 10, minimum = 2,},
}

TurretIngredients[WeaponType.PARTICLEACCELERATOR] =
{
    {name = "Servo",                amount = 15,    investable = 8,     minimum = 5,    rarityFactor = 0.75, weaponStat = "fireRate", investFactor = 0.3, },
    {name = "High Pressure Tube",   amount = 1,     investable = 3,                     weaponStat = "reach", investFactor = 1.5},
    {name = "Ammunition M",         amount = 5,     investable = 10,    minimum = 1,    weaponStat = "damage", investFactor = 0.25},
    {name = "Explosive Charge",     amount = 2,     investable = 6,     minimum = 1,    weaponStat = "damage", investFactor = 0.75},
    {name = "Steel",                amount = 5,     investable = 10,    minimum = 3,},
    {name = "Aluminum",            amount = 7,     investable = 5,     minimum = 3,},
}

TurretIngredients[WeaponType.ASSAULTBLASTER] =
{
    {name = "Servo",            amount = 15,    investable = 10,    minimum = 3, rarityFactor = 0.75, weaponStat = "fireRate", investFactor = 0.3, },
    {name = "Energy Tube",       amount = 6,     investable = 7,     weaponStat = "reach"},
    {name = "Ammunition M",     amount = 5,     investable = 10,    minimum = 1, weaponStat = "damage", investFactor = 0.7},
	{name = "Energy Inverter",      amount = 0,    investable = 2,  minimum = 0,weaponStat = "shieldDamageMultiplier", investFactor = 0.2, changeType = StatChanges.Percentage },
    {name = "Steel",            amount = 5,     investable = 10,    minimum = 3},
    {name = "Aluminum",         amount = 7,     investable = 5,     minimum = 3},
    {name = "Power Unit",       amount = 10,    investable = 3,    minimum = 1,    weaponStat = "pvelocity", investFactor = 0.3, changeType = StatChanges.Percentage},
}

TurretIngredients[WeaponType.HEPT] =
{
    {name = "Plasma Cell",          amount = 8,    investable = 8,  minimum = 1,   weaponStat = "damage", investFactor = 1},
    {name = "Energy Tube",          amount = 2,    investable = 6,  minimum = 1,    weaponStat = "reach",investFactor = 1.2},
    {name = "Conductor",            amount = 5,    investable = 10,  minimum = 1, weaponStat = "hullDamageMultiplier", investFactor = 0.2, changeType = StatChanges.Percentage},
    {name = "Energy Container",     amount = 5,    investable = 12,  minimum = 1,weaponStat = "shieldDamageMultiplier", investFactor = 0.1, changeType = StatChanges.Percentage},
    {name = "Power Unit",           amount = 5,    investable = 2,  minimum = 3, weaponStat = "pvelocity", investFactor = 0.2, changeType = StatChanges.Percentage},
    {name = "Steel",                amount = 4,    investable = 10, minimum = 3,},
    {name = "Crystal",              amount = 2,    investable = 10, minimum = 1,},
}

TurretIngredients[WeaponType.PULSELASER] =
{
    {name = "Plasma Cell",          amount = 8,    investable = 4,  minimum = 1,   weaponStat = "damage",investFactor = 1},
    {name = "Energy Tube",          amount = 2,    investable = 6,  minimum = 1,    weaponStat = "reach",investFactor = 0.7},
    {name = "Conductor",            amount = 5,    investable = 6,  minimum = 1,},
    {name = "Energy Container",     amount = 5,    investable = 6,  minimum = 1,},
    {name = "Power Unit",           amount = 5,    investable = 3,  minimum = 3,},
    {name = "Steel",                amount = 4,    investable = 10, minimum = 3,},
    {name = "Crystal",              amount = 2,    investable = 10, minimum = 1,},
}

TurretIngredients[WeaponType.MANTIS] =
{
    {name = "Servo",                amount = 15,   investable = 10, minimum = 5,  weaponStat = "fireRate", investFactor = 1.0, changeType = StatChanges.Percentage},
    {name = "Rocket",               amount = 5,    investable = 8,  minimum = 1,    weaponStat = "damage",  },
    {name = "High Pressure Tube",   amount = 2,    investable = 6,  minimum = 1,    weaponStat = "reach", },
    {name = "Fuel",                 amount = 2,    investable = 6,  minimum = 1,    weaponStat = "reach", investFactor = 0.5,},
    {name = "Targeting Card",       amount = 2,    investable = 0,  minimum = 2,     weaponStat = "seeker", investFactor = 1, changeType = StatChanges.Flat},
    {name = "Steel",                amount = 8,    investable = 10, minimum = 3,},
    {name = "Wire",                 amount = 5,    investable = 10, minimum = 3,},
}

TurretIngredients[WeaponType.PHOTON] =
{
    {name = "Military Tesla Coil",  amount = 5,    investable = 12,  minimum = 1,    weaponStat = "damage", investFactor = 1.3},
    {name = "High Capacity Lens",   amount = 2,    investable = 10,  minimum = 1,    weaponStat = "reach", investFactor = 0.2, changeType = StatChanges.Percentage },
    {name = "Electromagnetic Charge",amount = 2,   investable = 4,  minimum = 1,},
    {name = "Conductor",            amount = 5,    investable = 6,  minimum = 2,},
    {name = "Power Unit",           amount = 5,    investable = 3,  minimum = 3,},
    {name = "Copper",               amount = 5,    investable = 10, minimum = 3,},
    {name = "Energy Cell",          amount = 5,    investable = 10, minimum = 3,},
}
TurretIngredients[WeaponType.HYPERKINETIC] =
{
    {name = "Servo",                amount = 15,   investable = 10, minimum = 6,   weaponStat = "fireRate", investFactor = 1.0, changeType = StatChanges.Percentage},
    {name = "Electromagnetic Charge",amount = 5,   investable = 10,  minimum = 1,   weaponStat = "damage", investFactor = 0.75,},
    {name = "Electro Magnet",       amount = 8,    investable = 10, minimum = 3,    weaponStat = "reach", investFactor = 0.75,},
    {name = "Gauss Rail",           amount = 5,    investable = 10,  minimum = 1,    weaponStat = "damage", investFactor = 0.75,},
    {name = "High Pressure Tube",   amount = 2,    investable = 6,  minimum = 1,    weaponStat = "reach",  investFactor = 0.75,},
    {name = "Steel",                amount = 5,    investable = 10, minimum = 3,},
    {name = "Copper",               amount = 2,    investable = 10, minimum = 1,},
}

TurretIngredients[WeaponType.PRD] =
{
    {name = "Servo",                amount = 15,   investable = 10, minimum = 6,   weaponStat = "fireRate", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Electromagnetic Charge",amount = 5,   investable = 9,  minimum = 1,   weaponStat = "damage", investFactor = 0.5,},
    {name = "Laser Modulator",       amount = 8,    investable = 10, minimum = 3,    weaponStat = "reach", investFactor = 0.4,},
    {name = "Plasma Cell",           amount = 20,    investable = 25,  minimum = 10,    weaponStat = "damage", investFactor = 0.2,},
    {name = "High Pressure Tube",   amount = 2,    investable = 4,  minimum = 1,    weaponStat = "reach",  investFactor = 0.5,},
    {name = "Steel",                amount = 5,    investable = 10, minimum = 3,},
    {name = "Power Unit",               amount = 2,    investable = 10, minimum = 1,},
}

TurretIngredients[WeaponType.NANOREPAIR] =
{
    {name = "Nanobot",              amount = 5,    investable = 5,  minimum = 1,      weaponStat = "hullRepair", investFactor = 1,},
    {name = "Laser Modulator",      amount = 2,    investable = 3,  minimum = 0,    weaponStat = "reach",  investFactor = 0.75, changeType = StatChanges.Percentage},
    {name = "Conductor",            amount = 2,    investable = 6,  minimum = 0,    turretStat = "energyIncreasePerSecond",  investFactor = -0.5, changeType = StatChanges.Percentage},
    {name = "Gold",                 amount = 3,    investable = 10, minimum = 1,},
    {name = "Steel",                amount = 8,    investable = 10, minimum = 3,},
}

TurretIngredients[WeaponType.CHARGINGBEAM] =
{
    {name = "Transformator",              amount = 5,    investable = 5,  minimum = 1,      weaponStat = "shieldRepair", investFactor = 1,},
    {name = "Laser Modulator",      amount = 2,    investable = 3,  minimum = 0,    weaponStat = "reach",  investFactor = 0.75, changeType = StatChanges.Percentage},
    {name = "Conductor",            amount = 2,    investable = 6,  minimum = 0,    turretStat = "energyIncreasePerSecond",  investFactor = -0.5, changeType = StatChanges.Percentage},
    {name = "Gold",                 amount = 3,    investable = 10, minimum = 1,},
    {name = "Steel",                amount = 8,    investable = 10, minimum = 3,},
}

TurretIngredients[WeaponType.SOLARTORPEDO] =
{
    {name = "Force Generator",  amount = 5,    investable = 12,  minimum = 1,    weaponStat = "damage", investFactor = 1.2},
    {name = "High Capacity Lens",   amount = 2,    investable = 8,  minimum = 1,    weaponStat = "reach", investFactor = 0.2, changeType = StatChanges.Percentage },
    {name = "Laser Head", amount = 2,    investable = 8,  minimum = 1,    weaponStat = "shieldDamageMultiplier", investFactor = 0.6, changeType = StatChanges.Percentage },
    {name = "Conductor",            amount = 2,    investable = 6,  minimum = 1,    turretStat = "energyIncreasePerSecond",  investFactor = -0.2, changeType = StatChanges.Percentage},
    {name = "Power Unit",           amount = 5,    investable = 3,  minimum = 3,},
    {name = "Copper",               amount = 5,    investable = 10, minimum = 3,},
    {name = "Energy Cell",          amount = 5,    investable = 10, minimum = 3,},
}
TurretIngredients[WeaponType.ASSAULTCANNON] =
{
    {name = "Servo",            	amount = 15,   investable = 10, minimum = 3, rarityFactor = 0.75, weaponStat = "fireRate", investFactor = 0.3, },
    {name = "Energy Tube",          amount = 5,    investable = 10,  minimum = 1,    weaponStat = "damage",  },
    {name = "Conductor",            amount = 5,    investable = 6,  minimum = 5,},
    {name = "Energy Container",     amount = 5,    investable = 6,  minimum = 5,},
    {name = "Power Unit",           amount = 3,    investable = 4,  minimum = 2,},
    {name = "Steel",                amount = 4,    investable = 10, minimum = 4,},
    {name = "Copper",               amount = 2,    investable = 10, minimum = 2,},
}

TurretIngredients[WeaponType.AVALANCHE] =
{
    {name = "Antigrav Unit",  amount = 5,    investable = 17,  minimum = 1,    weaponStat = "damage", investFactor = 1.5},
    {name = "Servo",   amount = 2,    investable = 8,  minimum = 1,    weaponStat = "fireRate", investFactor = 0.1, changeType = StatChanges.Percentage },
	{name = "Force Generator",amount = 2,   investable = 4,  minimum = 1,},
    {name = "Lead",               amount = 5,    investable = 10, minimum = 3,},
	{name = "Fusion Generator",amount = 2,investable = 3,minimum = 1,weaponStat = "damage", investFactor = 2.5},
	{name = "Proton Accelerator",amount = 2,investable = 4,minimum = 1,weaponStat = "damage", investFactor = 2.5},
	{name = "Electron Accelerator",amount = 2,investable = 3,minimum = 1,weaponStat = "damage", investFactor = 2.5},
	
}

TurretIngredients[WeaponType.CYCLONE] =
{
    {name = "Servo",                amount = 15,   investable = 6, minimum = 5,  weaponStat = "fireRate", investFactor = 1.0, changeType = StatChanges.Percentage},
    {name = "Rocket",               amount = 5,    investable = 16,  minimum = 1,    weaponStat = "damage",  },
    {name = "High Pressure Tube",   amount = 2,    investable = 3,  minimum = 1,    weaponStat = "reach", },
    {name = "Fuel",                 amount = 2,    investable = 3,  minimum = 1,    weaponStat = "reach", investFactor = 0.3,},
    {name = "Steel",                amount = 8,    investable = 10, minimum = 3,},
    {name = "Wire",                 amount = 5,    investable = 10, minimum = 3,},
}

TurretIngredients[WeaponType.MAGNETICMORTAR] =
{
    {name = "Servo",            	amount = 15,   investable = 11, minimum = 3, rarityFactor = 0.75, weaponStat = "fireRate", investFactor = 0.35, },
    {name = "High Pressure Tube",          amount = 5,    investable = 8,  minimum = 1,    weaponStat = "damage",  },
    {name = "Conductor",            amount = 5,    investable = 6,  minimum = 5,},
    {name = "Electromagnetic Charge",     amount = 5,    investable = 4,  minimum = 5, weaponStat = "damage",},
    {name = "Power Unit",           amount = 3,    investable = 4,  minimum = 2,},
    {name = "Steel",                amount = 4,    investable = 10, minimum = 4,},
    {name = "Lead",               amount = 2,    investable = 10, minimum = 2,},
}

TurretIngredients[WeaponType.TRANSPHASIC] =
{
    {name = "Laser Head",           amount = 4,    investable = 4,              weaponStat = "damage", investFactor = 0.3, changeType = StatChanges.Percentage },
    {name = "Laser Compressor",     amount = 2,    investable = 2,              weaponStat = "damage", investFactor = 0.4, changeType = StatChanges.Percentage },
    {name = "High Capacity Lens",   amount = 2,    investable = 5,              weaponStat = "reach", investFactor = 0.9, changeType = StatChanges.Percentage},
    {name = "Laser Modulator",      amount = 2,    investable = 4,  minimum = 2,},
    {name = "Power Unit",           amount = 5,    investable = 3,  minimum = 3, turretStat = "maxHeat", investFactor = 0.75, changeType = StatChanges.Percentage},
	{name = "Conductor", amount = 2,    investable = 6,  minimum = 2,    weaponStat = "shieldDamageMultiplier", investFactor = 0.6, changeType = StatChanges.Percentage },
	{name = "Fusion Generator",amount = 0,investable = 3,minimum = 0,weaponStat = "damage", investFactor = 1.2},
    {name = "Steel",                amount = 5,    investable = 10, minimum = 3,},
    {name = "Crystal",              amount = 2,    investable = 10, minimum = 1, },
}

TurretIngredients[WeaponType.PLASMAFLAK] =
{
    {name = "Servo",                amount = 17,    investable = 8,     minimum = 10, rarityFactor = 0.75,  weaponStat = "fireRate", investFactor = 0.3, changeType = StatChanges.Percentage },
    {name = "Energy Tube",   amount = 1,     investable = 3,                                         weaponStat = "reach", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Plasma Cell",         amount = 5,     investable = 5,     minimum = 1,                        weaponStat = "damage", investFactor = 0.2, changeType = StatChanges.Percentage},
    {name = "Conductor",     amount = 2,     investable = 4,     minimum = 1,                        weaponStat = "damage", investFactor = 0.4, changeType = StatChanges.Percentage},
    {name = "Steel",                amount = 5,     investable = 10,    minimum = 3,},
    {name = "Aluminum",            amount = 7,     investable = 5,     minimum = 3,},
}