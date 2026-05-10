package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')

WeaponTypes.addType("PULSEGUN", getWeaponName('pulsegun'), armed)
WeaponTypes.addType("PARTICLEACCELERATOR", getWeaponName('particleaccelerator').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("ASSAULTBLASTER", getWeaponName('assaultblaster').." /* Weapon Type */"%_t, armed)

WeaponTypes.addType("HEPT", getWeaponName('hept').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("PULSELASER", getWeaponName('pulselaser').." /* Weapon Type */"%_t, armed)

WeaponTypes.addType("MANTIS", getWeaponName('mantis').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("PHOTON", getWeaponName('photoncannon').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("HYPERKINETIC", getWeaponName('hyperkinetic').." /* Weapon Type */"%_t, armed)

--WeaponTypes.addType("GRAVITON", "Гравитонный якорь /* Weapon Type */"%_t, armed)
WeaponTypes.addType("NANOREPAIR", getWeaponName('nanorepair').." /* Weapon Type */"%_t, unarmed)
WeaponTypes.addType("CHARGINGBEAM", getWeaponName('chargingbeam').." /* Weapon Type */"%_t, unarmed)

WeaponTypes.addType("SOLARTORPEDO", getWeaponName('ionemitter').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("ASSAULTCANNON", getWeaponName('assaultcannon').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("AVALANCHE", getWeaponName('avalanche').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("CYCLONE", getWeaponName('cyclone').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("PRD", getWeaponName('prd').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("MAGNETICMORTAR", getWeaponName('magneticmortar').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("TRANSPHASIC", getWeaponName('transphasic').." /* Weapon Type */"%_t, armed)
WeaponTypes.addType("PLASMAFLAK", getWeaponName('plasmaflak').." /* Weapon Type */"%_t, defensive)