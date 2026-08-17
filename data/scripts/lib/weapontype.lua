package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include("stringutility")
include('Armory')

local unarmed = 0
local armed = 1
local defensive = 2

WeaponTypes.addType("PULSEGUN", getWeaponName('pulsegun'), armed)
WeaponTypes.addType("PARTICLEACCELERATOR", getWeaponName('particleaccelerator'), armed)
WeaponTypes.addType("ASSAULTBLASTER", getWeaponName('assaultblaster'), armed)

WeaponTypes.addType("HEPT", getWeaponName('hept'), armed)
WeaponTypes.addType("PULSELASER", getWeaponName('pulselaser'), armed)

WeaponTypes.addType("MANTIS", getWeaponName('mantis'), armed)
WeaponTypes.addType("PHOTON", getWeaponName('photoncannon'), armed)
WeaponTypes.addType("HYPERKINETIC", getWeaponName('hyperkinetic'), armed)

--WeaponTypes.addType("GRAVITON", "Гравитонный якорь /* Weapon Type */"%_t, armed)
WeaponTypes.addType("NANOREPAIR", getWeaponName('nanorepair'), unarmed)
WeaponTypes.addType("CHARGINGBEAM", getWeaponName('chargingbeam'), unarmed)

WeaponTypes.addType("SOLARTORPEDO", getWeaponName('ionemitter'), armed)
WeaponTypes.addType("ASSAULTCANNON", getWeaponName('assaultcannon'), armed)
WeaponTypes.addType("AVALANCHE", getWeaponName('avalanche'), armed)
WeaponTypes.addType("CYCLONE", getWeaponName('cyclone'), armed)
WeaponTypes.addType("PRD", getWeaponName('prd'), armed)
WeaponTypes.addType("MAGNETICMORTAR", getWeaponName('magneticmortar'), armed)
WeaponTypes.addType("TRANSPHASIC", getWeaponName('transphasic'), armed)
WeaponTypes.addType("PLASMAFLAK", getWeaponName('plasmaflak'), defensive)
