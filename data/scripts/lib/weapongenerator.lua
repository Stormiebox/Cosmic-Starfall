package.path = package.path .. ";data/scripts/neltharaku/?.lua"
include('Armory')
--===========================[Ванильные орудия]===========================

--Пулемет
function WeaponGenerator.generateChaingun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	dps = dps * 1.25

    local fireDelay = rand:getFloat(0.07, 0.11)
    local reach = rand:getFloat(300, 450) + tech*3
    local damage = dps * fireDelay
    local speed = rand:getFloat(500, 700) + tech
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.ChainGun
    weapon.name = "Chaingun /* Weapon Name*/"%_T
    weapon.prefix = "Chaingun /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/chaingun.png" -- previously minigun.png
    weapon.sound = "chaingun"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.06)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1

    weapon.psize = rand:getFloat(0.05, 0.2)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)

    if rand:test(0.05) then
        local shots = {2, 2, 2, 2, 2, 3, 4}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = (weapon.damage * 1.5) / weapon.shotsFired
    end

    -- 7.5 % chance for anti matter damage / plasma damage
    if rand:test(0.075) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 1.5, 0.15, 0.2)
    elseif rand:test(0.075) then
        WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 1.5, 0.1, 0.15)
    elseif rand:test(0.05) then
        WeaponGenerator.addElectricDamage(weapon)
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)
    weapon.recoil = weapon.damage * 20

    return weapon
end

--Болтер
function WeaponGenerator.generateBolter(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	dps = dps*1.15

    local fireDelay = rand:getFloat(0.1, 0.2)
    local reach = rand:getFloat(650, 700)
    local damage = dps * fireDelay
    local velocity = rand:getFloat(800, 1000) + tech
    local maximumTime = reach / velocity

    weapon.pvelocity = velocity
    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.Bolter
    weapon.name = "Bolter /* Weapon Name*/"%_T
    weapon.prefix = "Bolter /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/bolter.png" -- previously sentry-gun.png
    weapon.sound = "bolter"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.03)

    weapon.damage = damage
    weapon.damageType = DamageType.AntiMatter
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1

    -- 100 % chance for antimatter
    WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2.5, 0.15, 0.2)

    weapon.psize = rand:getFloat(0.15, 0.25)
    weapon.pmaximumTime = maximumTime
    local color = Color()
    color:setHSV(rand:getFloat(10, 60), 0.7, 1)
    weapon.pcolor = color

    if rand:test(0.05) then
        local shots = {2, 2, 2, 2, 2, 3, 4}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = weapon.damage * 1.5 / weapon.shotsFired
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 16

    return weapon
end

--Импульсная
function WeaponGenerator.generatePulseCannon(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    -- weaken dps to balance shield penetration
    dps = dps * 1.05

    local fireDelay = rand:getFloat(0.05, 0.2)
    local reach = rand:getFloat(450, 750) + tech*3
    local damage = dps * fireDelay
    local speed = rand:getFloat(700, 800) + tech
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.PulseCannon
    weapon.name = "Pulse Cannon /* Weapon Name*/"%_T
    weapon.prefix = "Pulse Cannon /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/pulsecannon.png"
    weapon.sound = "pulsecannon"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.04)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1

    weapon.psize = rand:getFloat(0.08, 0.3)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(180, 290), 0.7, 1)

    -- 10 % chance for anti matter damage
    if rand:test(0.1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 10

    return weapon
end

--Лазер
function WeaponGenerator.generateLaser(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

	dps = dps * 1.4
	
    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(400, 550)
    local damage = dps * fireDelay * 1.5

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Laser
    weapon.name = "Laser /* Weapon Name*/"%_T
    weapon.prefix = "Laser /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/laser-gun.png" -- previously laser-blast.png
    weapon.sound = "laser"

    local hue = rand:getFloat(0, 360)

    weapon.damage = damage
    weapon.damageType = DamageType.Energy
    weapon.blength = weapon.reach
	weapon.blockPenetration = 2

    -- 10 % chance for plasma
    if rand:test(0.1) then
        WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.bouterColor = ColorHSV(hue, 1, rand:getFloat(0.1, 0.3))
    weapon.binnerColor = ColorHSV(hue + rand:getFloat(-120, 120), 0.3, rand:getFloat(0.7, 0.8))
    weapon.bshape = BeamShape.Straight
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

--Рельса
function WeaponGenerator.generateRailGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

	dps = dps * 0.85

    local fireDelay = rand:getFloat(1, 2.5)
    local reach = rand:getFloat(850, 1100)
    local damage = dps * fireDelay

    weapon.fireDelay = fireDelay
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = reach
    weapon.continuousBeam = false
    weapon.appearance = WeaponAppearance.RailGun
    weapon.name = "Railgun /* Weapon Name*/"%_T
    weapon.prefix = "Railgun /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/rail-gun.png" -- previously beam.png
    weapon.sound = "railgun"
    weapon.accuracy = 0.999 - rand:getFloat(0.05, 0.12)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1
    weapon.blockPenetration = rand:getInt(4, 5 + rarity.value)

    -- 10 % chance for antimatter
    if rand:test(0.1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.blength = weapon.reach
    weapon.bshape = BeamShape.Straight
    weapon.bwidth = 0.5
    weapon.bauraWidth = 3
    weapon.banimationSpeed = 1
    weapon.banimationAcceleration = -2
	weapon.shotsFired = 3

    if rand:getBool() then
        -- shades of red
        weapon.bouterColor = ColorHSV(rand:getFloat(10, 60), rand:getFloat(0.5, 1), rand:getFloat(0.1, 0.5))
        weapon.binnerColor = ColorHSV(rand:getFloat(10, 60), rand:getFloat(0.1, 0.5), 1)
    else
        -- shades of blue
        weapon.bouterColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.5, 1), rand:getFloat(0.1, 0.5))
        weapon.binnerColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.1, 0.5), 1)
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 20

    return weapon
end

--Ракетомет
function WeaponGenerator.generateRocketLauncher(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()
	
	dps = dps * 1.15

    local fireDelay = rand:getFloat(0.5, 1.5)
    local reach = rand:getFloat(1300, 1800)
    local damage = dps * fireDelay
    local speed = rand:getFloat(150, 200)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.seeker = rand:test(1 / 8)
    weapon.appearance = WeaponAppearance.RocketLauncher
    weapon.name = "Rocket Launcher /* Weapon Name*/"%_T
    weapon.prefix = "Launcher /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/rocket-launcher.png" -- previously missile-swarm.png
    weapon.sound = "launcher"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.02)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true

    -- 10 % chance for anti matter damage
    if rand:test(0.1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.psize = rand:getFloat(0.2, 0.4)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)
    weapon.pshape = ProjectileShape.Rocket

    if rand:test(0.05) then
        local shots = {2, 2, 2, 2, 2, 3, 4}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = (weapon.damage * 1.5) / weapon.shotsFired
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 2
    weapon.explosionRadius = math.sqrt(weapon.damage * 5)

    return weapon
end

--Пушко
function WeaponGenerator.generateCannon(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	dps = dps*1.1

    local fireDelay = rand:getFloat(1.5, 2.5)
    local reach = rand:getFloat(1100, 1500)
    local damage = dps * fireDelay
    local speed = rand:getFloat(600, 800)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.Cannon
    weapon.name = "Cannon /* Weapon Name*/"%_T
    weapon.prefix = "Cannon /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/cannon.png" -- previously hypersonic-bolt.png
    weapon.sound = "cannon"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.01)

	weapon.shieldDamageMultiplier = 1.25
	weapon.hullDamageMultiplier = 1.45

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true

    -- 10 % chance for anti matter damage
    -- if rand:test(0.1) then
        -- WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    -- end

    weapon.psize = rand:getFloat(0.2, 0.5)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 20
    weapon.explosionRadius = math.sqrt(weapon.damage * 5)

    return weapon
end

--Тесла
function WeaponGenerator.generateTeslaGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()
	
	dps = dps*1.25

    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(250, 350)
    local damage = dps * fireDelay * 2.0

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Tesla
    weapon.name = "Tesla Gun /* Weapon Name*/"%_T
    weapon.prefix = "Tesla /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/tesla-gun.png" -- previously lightning-frequency.png
    weapon.sound = "tesla"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.06)

    local hue = rand:getFloat(0, 360)

    weapon.damage = damage
    weapon.damageType = DamageType.Electric
    weapon.impactParticles = ImpactParticles.Energy
    weapon.stoneDamageMultiplier = 0
    weapon.blength = weapon.reach

    -- 100 % chance for electric
    WeaponGenerator.addElectricDamage(weapon)
	weapon.shieldDamageMultiplier = 1.31
    -- 10 % chance for plasma
    -- if rand:test(0.1) then
        -- WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    -- end

    weapon.bouterColor = ColorHSV(hue, 1, rand:getFloat(0.1, 0.3))
    weapon.binnerColor = ColorHSV(hue + rand:getFloat(-120, 120), 0.3, rand:getFloat(0.7, 0.8))
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4
    weapon.bshape = BeamShape.Lightning
    weapon.bshapeSize = 5

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

--Вольт
function WeaponGenerator.generateLightningGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()
	
	dps = dps * 1.25

    local fireDelay = rand:getFloat(2.5, 3)
    local reach = rand:getFloat(950, 1400)
    local damage = dps * fireDelay * 1.15

    weapon.fireDelay = fireDelay
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = reach
    weapon.continuousBeam = false
    weapon.appearance = WeaponAppearance.Tesla
    weapon.name = "Lightning Gun /* Weapon Name*/"%_T
    weapon.prefix = "Lightning /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/lightning-gun.png" -- previously lightning-branches.png
    weapon.sound = "lightning"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.03)

    weapon.damage = damage
    weapon.damageType = DamageType.Electric
    weapon.impactParticles = ImpactParticles.Energy
    weapon.stoneDamageMultiplier = 0
    weapon.impactSound = 1

    -- 100 % chance for electric damage
    WeaponGenerator.addElectricDamage(weapon)

    -- 10 % chance for plasma
    if rand:test(0.1) then
        WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.blength = weapon.reach
    weapon.bshape = BeamShape.Lightning
    weapon.bwidth = 0.5
    weapon.bauraWidth = 3
    weapon.banimationSpeed = 0
    weapon.banimationAcceleration = 0
    weapon.bshapeSize = 13

    -- shades of blue
    weapon.bouterColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.5, 1), rand:getFloat(0.1, 0.5))
    weapon.binnerColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.1, 0.5), 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 5

    return weapon
end

--Плазмаган
function WeaponGenerator.generatePlasmaGun(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()
	
	dps = dps * (1.3 + tech*0.02)
	
    local fireDelay = rand:getFloat(0.15, 0.2)
    local reach = rand:getFloat(550, 800) + tech
    local damage = dps * fireDelay
    local speed = rand:getFloat(500, 700)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.PlasmaGun
    weapon.name = "Plasma Gun /* Weapon Name*/"%_T
    weapon.prefix = "Plasma /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/plasma-gun.png" -- previously tesla-turret.png
    weapon.sound = "plasma"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.03)

    weapon.damage = damage
    weapon.damageType = DamageType.Plasma
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1
    weapon.pshape = ProjectileShape.Plasma

    -- 100 % chance for plasma damage
    WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2.5, 0.15, 0.2)

    weapon.psize = rand:getFloat(0.4, 0.8)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(0, 360), 0.7, 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 4

    return weapon
end

--Ремонтник
function WeaponGenerator.generateRepairBeamEmitter(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(300, 450)

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Repair
    weapon.name = "Repair Beam /* Weapon Name*/"%_T
    weapon.prefix = "Repair /* Weapon Prefix*/"%_T
    weapon.icon = "data/textures/icons/repair-beam.png" -- previously laser-heal.png
    weapon.sound = "repair"

    weapon.damageType = DamageType.Energy
    weapon.impactParticles = ImpactParticles.Energy
    if rand:test(0.5) then
        weapon.shieldRepair = dps * fireDelay * rand:getFloat(0.9, 1.1) * (1.6+tech*0.02)
        weapon.bouterColor = ColorRGB(0.1, 0.2, 0.4)
        weapon.binnerColor = ColorRGB(0.2, 0.4, 0.9)
    else
        weapon.hullRepair = dps * fireDelay * rand:getFloat(0.9, 1.1) * (1.6+tech*0.02)
        weapon.bouterColor = ColorARGB(0.5, 0, 0.5, 0)
        weapon.binnerColor = ColorRGB(1, 1, 1)

        weapon.shieldPenetration = 1
    end

    weapon.blength = weapon.reach
    weapon.bwidth = 0.5
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 4
    weapon.bshapeSize = 2
    weapon.bshape = BeamShape.Swirly

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

--===========================[Кастомные орудия]===========================
--Импульсная пушка
function WeaponGenerator.generatePULSEGUN(rand, dps, tech, material, rarity)
	local weapon = Weapon()
    weapon:setProjectile()

	--dps = dps * 0.85
	dps = dps * (1+tech*0.01)

    local fireDelay = rand:getFloat(0.1, 0.2)
    local reach = rand:getFloat(350, 500) + tech*4
    local damage = dps * fireDelay
    local speed = rand:getFloat(350, 450) + tech*1.5
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.ChainGun
    weapon.name = getWeaponName('pulsegun').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('pulsegun').." /* Weapon Prefix*/"%_t
	--weapon.name = "PEWPEW"%_t
    --weapon.prefix = "PEWPEW"%_t
    --weapon.icon = "data/textures/icons/PULSEGUN.png"
	weapon.icon = getWeaponPath('pulsegun')
    weapon.sound = "PULSEGUN"
    weapon.accuracy = 0.98

    weapon.damage = damage
    weapon.damageType = DamageType.Energy
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1

    weapon.psize = rand:getFloat(0.1, 0.2)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(16, 97, 84)

    if rand:test(0.05) then
        local shots = {1, 1, 1, 1, 1, 2, 3}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = (weapon.damage * 1.5) / weapon.shotsFired
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)
    weapon.recoil = weapon.damage * 20

    return weapon
end

--Ускоритель частиц
function WeaponGenerator.generatePARTICLEACCELERATOR(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	dps = dps * 0.9

    local fireDelay = rand:getFloat(0.9, 1.3)
    local reach = rand:getFloat(700, 900)
    local damage = dps * fireDelay
    local velocity = rand:getFloat(650, 900)
    local maximumTime = reach / velocity

    weapon.pvelocity = velocity
    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.Bolter
    weapon.name = getWeaponName('particleaccelerator').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('particleaccelerator').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('particleaccelerator') -- previously sentry-gun.png
    weapon.sound = "PARTICLEACCELERATOR"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.02)

    weapon.damage = damage
    weapon.damageType = DamageType.AntiMatter
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1

     -- 100 % chance for anti matter damage
    if rand:test(1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 1.5, 0.15, 0.2)
    end

    weapon.psize = rand:getFloat(0.3, 0.4)
    weapon.pmaximumTime = maximumTime
    --local color = Color()
    weapon.pcolor = ColorHSV(150, 64, 100)

    if rand:test(0.05) then
        local shots = {1, 1, 1, 1, 2, 3, 4}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = weapon.damage * 1.5 / weapon.shotsFired
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 16

    return weapon
end

--Фотонный бластер
function WeaponGenerator.generateASSAULTBLASTER(rand, dps, tech, material, rarity)
   local weapon = Weapon()
    weapon:setProjectile()

	dps = dps * 1.5

    local fireDelay = rand:getFloat(0.2, 0.4)
    local reach = rand:getFloat(500, 780)
    local damage = dps * fireDelay
    local speed = rand:getFloat(450, 500)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.ChainGun
    weapon.name = getWeaponName('assaultblaster').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('assaultblaster').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('assaultblaster')
    weapon.sound = "ASSAULTBLASTER"
    weapon.accuracy = 1

    weapon.damage = damage
    weapon.damageType = DamageType.Electric
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1

    weapon.psize = rand:getFloat(0.12, 0.20)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(240, 0, 100)
	
	weapon.shieldDamageMultiplier = 1 + tech*0.01
	
	

    if rand:test(0.05) then
        local shots = {1, 1, 1, 1, 1, 2, 2}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = (weapon.damage * 1.5) / weapon.shotsFired
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)
    weapon.recoil = weapon.damage * 1
	weapon.explosionRadius = math.sqrt(weapon.damage * 3)

    return weapon
end

--Вихревая пушка
function WeaponGenerator.generateHEPT(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	dps = dps * (1.5 + tech*0.01)

    local fireDelay = rand:getFloat(0.4, 0.6)
    local reach = rand:getFloat(600, 850) + tech
    local damage = dps * fireDelay
    local speed = rand:getFloat(320, 420) + tech*0.5
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.PlasmaGun
    weapon.name = getWeaponName('hept').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('hept').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('hept')
    weapon.sound = "HEPT"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.02)
	weapon.hullDamageMultiplier = 1.20
	weapon.shieldDamageMultiplier = 2.1

    weapon.damage = damage
    weapon.damageType = DamageType.Plasma
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1
    weapon.pshape = ProjectileShape.Plasma

    weapon.psize = rand:getFloat(0.4, 0.5)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    --weapon.pcolor = ColorHSV(114, 82, 29)
	weapon.pcolor = ColorHSV(0, 100, 100)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 8

    return weapon
end

--Импульсный лазер
function WeaponGenerator.generatePULSELASER(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	dps = dps

    local fireDelay = rand:getFloat(0.05, 0.1)
    local reach = rand:getFloat(400, 500)
    local damage = dps * fireDelay
    local speed = rand:getFloat(600, 800)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.PlasmaGun
    weapon.name = getWeaponName('pulselaser').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('pulselaser').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('pulselaser')
    weapon.sound = "PULSELASER"
    weapon.accuracy = 0.97 - rand:getFloat(0, 0.03)

    weapon.damage = damage
    weapon.damageType = DamageType.Energy
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1
	--weapon.pshape = ProjectileShape.Plasma

    weapon.psize = rand:getFloat(0.2, 0.3)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(60, 94, 78)
	weapon.shotsFired = 2

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 3

    return weapon
end

--Установка "Богомол"
function WeaponGenerator.generateMANTIS(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()
	
	dps = dps * 1.7

    local fireDelay = 4
    local reach = rand:getFloat(2000, 2800)
    local damage = dps
    local speed = rand:getFloat(150, 180)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.seeker = true
    weapon.appearance = WeaponAppearance.RocketLauncher
    weapon.name = getWeaponName('mantis').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('mantis').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('mantis')
    weapon.sound = "MANTIS"
    weapon.accuracy = 0.6 - rand:getFloat(0, 0.02)

    weapon.damage = damage
    weapon.damageType = DamageType.Electric
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true

    -- 10 % chance for anti matter damage
    if rand:test(0.1) then
        WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.psize = rand:getFloat(0.1, 0.1)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(180, 6, 100)
    weapon.pshape = ProjectileShape.Rocket
	weapon.shotsFired = 4

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 2
    weapon.explosionRadius = math.sqrt(weapon.damage * 5)

    return weapon
end

--Фотонная пушка
function WeaponGenerator.generatePHOTON(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	dps = dps * 2

    --local fireDelay = rand:getFloat(1.4, 2.2)
	local fireDelay = 1
    local reach = rand:getFloat(900, 1000)
    local damage = dps * fireDelay
    local speed = rand:getFloat(500, 650)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
	weapon.fireRate = 1.5
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.Cannon
    weapon.name = getWeaponName('photoncannon').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('photoncannon').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('photoncannon')
    weapon.sound = "PHOTON"
    weapon.accuracy = 1 - rand:getFloat(0.07, 0.14)

    weapon.damage = damage
    weapon.damageType = DamageType.Energy
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true

    weapon.psize = 1.5
	weapon.pshape = ProjectileShape.Rocket
	weapon.shotsFired = 1
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(240, 0, 100)
	

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 30
    weapon.explosionRadius = math.sqrt(weapon.damage * 7)

    return weapon
end

--Гиперкинетическая артиллерия
function WeaponGenerator.generateHYPERKINETIC(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

	dps = dps * 1.6

    local fireDelay = 6
    local reach = rand:getFloat(1400, 2000)
    local damage = dps * fireDelay

    weapon.fireDelay = fireDelay
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = reach
    weapon.continuousBeam = false
    weapon.appearance = WeaponAppearance.RailGun
    weapon.name = getWeaponName('hyperkinetic').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('hyperkinetic').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('hyperkinetic')
    weapon.sound = "HYPERKINETIC"
    weapon.accuracy = 0.999 - rand:getFloat(0, 0.01)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 2
    weapon.blockPenetration = 2

    WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)

    weapon.blength = weapon.reach * 0.75
    weapon.bshape = BeamShape.Straight
    weapon.bwidth = 1.5
    weapon.bauraWidth = 3
    weapon.banimationSpeed = 1.2
    weapon.banimationAcceleration = -2

    if rand:getBool() then
        -- shades of red
        weapon.bouterColor = ColorHSV(rand:getFloat(10, 60), rand:getFloat(0.5, 1), rand:getFloat(0.1, 0.5))
        weapon.binnerColor = ColorHSV(rand:getFloat(10, 60), rand:getFloat(0.1, 0.5), 1)
    else
        -- shades of blue
        weapon.bouterColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.5, 1), rand:getFloat(0.1, 0.5))
        weapon.binnerColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.1, 0.5), 1)
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 50

    return weapon
end

--Наноремонтная установка
function WeaponGenerator.generateNANOREPAIR(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

	dps = dps * 1.35

    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(100, 150)

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Repair
    weapon.name = getWeaponName('nanorepair').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('nanorepair').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('nanorepair')
    weapon.sound = "NANOREPAIR"

    weapon.damageType = DamageType.Energy
    weapon.impactParticles = ImpactParticles.Energy

    weapon.hullRepair = dps * fireDelay * rand:getFloat(0.9, 1.1)
    weapon.bouterColor = ColorARGB(0.5, 0, 0.5, 0)
    weapon.binnerColor = ColorRGB(1, 1, 1)
    weapon.shieldPenetration = 1

    weapon.blength = weapon.reach
    weapon.bwidth = 0.7
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 7
    weapon.bshapeSize = 2
    weapon.bshape = BeamShape.Swirly

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

--Заряжающий луч
function WeaponGenerator.generateCHARGINGBEAM(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

	dps = dps * 1.75

    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(100, 150)

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Repair
    weapon.name = getWeaponName('chargingbeam').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('chargingbeam').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('chargingbeam')
    weapon.sound = "RECHARGERAY"

    weapon.damageType = DamageType.Energy
    weapon.impactParticles = ImpactParticles.Energy

    weapon.shieldRepair = dps * fireDelay * rand:getFloat(0.9, 1.1)
    weapon.bouterColor = ColorHSV(212, 0.75, 0.75)
    weapon.binnerColor = ColorRGB(0, 1, 0)
    weapon.shieldPenetration = 1

    weapon.blength = weapon.reach
    weapon.bwidth = 0.7
    weapon.bauraWidth = 1
    weapon.banimationSpeed = 7
    weapon.bshapeSize = 2
    weapon.bshape = BeamShape.Straight

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

--Трансфазный лазер
function WeaponGenerator.generateTRANSPHASIC(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

	dps = dps * 2
	
    local fireDelay = 0.2 -- always the same with beams, does not really matter
    local reach = rand:getFloat(780, 920)
    local damage = dps * fireDelay * 1.5

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.continuousBeam = true
    weapon.appearance = WeaponAppearance.Laser
    weapon.name = getWeaponName('transphasic').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('transphasic').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('transphasic')
    weapon.sound = "TRANSPHASIC"

    local hue = rand:getFloat(0, 360)

    weapon.damage = damage
    weapon.damageType = DamageType.Energy
    weapon.blength = weapon.reach
	weapon.blockPenetration = 2

    -- 10 % chance for plasma
    if rand:test(0.1) then
        WeaponGenerator.addPlasmaDamage(rand, weapon, rarity, 2, 0.15, 0.2)
    end

    weapon.bouterColor = ColorHSV(60, 94, 78)
	weapon.binnerColor = ColorHSV(rand:getFloat(180, 260), rand:getFloat(0.1, 0.5), 1)
    weapon.bshape = BeamShape.Straight
    weapon.bwidth = 1.5
    weapon.bauraWidth = 3
    weapon.banimationSpeed = 4

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    return weapon
end

--Штурмовая пушка
function WeaponGenerator.generateASSAULTCANNON(rand, dps, tech, material, rarity)
	local weapon = Weapon()
    weapon:setProjectile()

	dps = dps * 1.2

    local fireDelay = rand:getFloat(0.7, 1.1)
    local reach = rand:getFloat(300, 450)
    local damage = dps * fireDelay
    local speed = 1800
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.ChainGun
    weapon.name = getWeaponName('assaultcannon').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('assaultcannon').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('assaultcannon')
    weapon.sound = "ASSAULTCANNON"
    weapon.accuracy = 0.8

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1
	weapon.pshape = ProjectileShape.Plasma

    weapon.psize = rand:getFloat(0.7, 1.1)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(34, 100, 86)

    if rand:test(0.05) then
        local shots = {1}
        weapon.shotsFired = shots[rand:getInt(1, #shots)]
        weapon.damage = (weapon.damage * 1.5) / weapon.shotsFired
    end

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)
    weapon.recoil = 0

    return weapon
end

--Плазмонитиевый дезинтегратор
function WeaponGenerator.generatePRD(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setBeam()

	dps = dps*1.5

    local fireDelay = rand:getFloat(1.4, 1.8)
    local reach = rand:getFloat(600, 750)
    local damage = dps * fireDelay

    weapon.fireDelay = fireDelay
    weapon.appearanceSeed = rand:getInt()
    weapon.reach = reach
    weapon.continuousBeam = false
    weapon.appearance = WeaponAppearance.RailGun
    weapon.name = getWeaponName('prd').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('prd').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('prd')
    weapon.sound = "PRD"
    weapon.accuracy = 1 - rand:getFloat(0, 0.03)

    weapon.damage = damage
    weapon.damageType = DamageType.Plasma
    weapon.impactParticles = ImpactParticles.Energy
    weapon.impactSound = 1
    weapon.blockPenetration = 2
	
	weapon.shieldDamageMultiplier = 2.8

    weapon.blength = weapon.reach
    weapon.bshape = BeamShape.Straight
    weapon.bwidth = 0.5
    weapon.bauraWidth = 3
    weapon.banimationSpeed = 1
    weapon.banimationAcceleration = -2

	weapon.bouterColor = ColorHSV(150, 64, 100)
    weapon.binnerColor = ColorHSV(240, 0, 100)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 20

    return weapon
end

--Лавина
function WeaponGenerator.generateAVALANCHE(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()
	
	dps = dps * 2.3

    local fireDelay = 10
    local reach = rand:getFloat(700, 745)
    local damage = dps
    local speed = rand:getFloat(90, 110)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.seeker = true
    weapon.appearance = WeaponAppearance.RocketLauncher
    weapon.name = getWeaponName('avalanche').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('avalanche').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('avalanche')
    weapon.sound = "AVALANCHE"
    weapon.accuracy = 0.6 - rand:getFloat(0, 0.02)

    weapon.damage = damage
    weapon.damageType = DamageType.Physical
    weapon.impactParticles = ImpactParticles.Physical
    weapon.impactSound = 1
    weapon.impactExplosion = true
	WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
	
	--weapon.bouterColor = ColorHSV(150, 64, 100)
	--weapon.binnerColor = ColorHSV(240, 0, 100)
	weapon.pcolor = ColorHSV(39, 100, 100)
	
    weapon.psize = 0.7
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    --_colorC = ColorHSV(264, 60, 100)
    weapon.pshape = ProjectileShape.Plasma
	weapon.shotsFired = 2

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 2
    weapon.explosionRadius = math.sqrt(weapon.damage * 5)

    return weapon
end

--Циклон
function WeaponGenerator.generateCYCLONE(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()
	
	--dps = dps * 1.9

    local fireDelay = 3
    local reach = rand:getFloat(1700, 1900)
    local damage = dps
    local speed = rand:getFloat(180, 200)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.seeker = true
    weapon.appearance = WeaponAppearance.RocketLauncher
    weapon.name = getWeaponName('cyclone').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('cyclone').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('cyclone')
    weapon.sound = "CYCLONE"
    weapon.accuracy = 0.6 - rand:getFloat(0, 0.02)

    weapon.damage = damage
    weapon.damageType = DamageType.Electric
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true
	WeaponGenerator.addAntiMatterDamage(rand, weapon, rarity, 2, 0.15, 0.2)
	weapon.hullDamageMultiplier = 1.35

    weapon.psize = rand:getFloat(0.2, 0.2)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(240, 0, 100)
    weapon.pshape = ProjectileShape.Rocket
	weapon.shotsFired = 5

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 2
    weapon.explosionRadius = math.sqrt(weapon.damage * 5)

    return weapon
end

--Магнитный миномет
function WeaponGenerator.generateMagneticmortar(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	dps = dps * 1.75

    local fireDelay = rand:getFloat(2.8, 3.2)
    local reach = rand:getFloat(700, 850)
    local damage = dps * fireDelay
    local speed = rand:getFloat(280, 320)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.Cannon
    weapon.name = getWeaponName('magneticmortar').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('magneticmortar').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('magneticmortar')
    weapon.sound = "MAGNETICMORTAR"
    weapon.accuracy = 0.99 - rand:getFloat(0, 0.01)

    weapon.damage = damage
    weapon.damageType = DamageType.AntiMatter
	
	weapon.hullDamageMultiplier = 1.65
	weapon.shieldDamageMultiplier = 1.25
	
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true

    weapon.psize = rand:getFloat(0.6, 0.7)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(rand:getFloat(10, 60), 0.7, 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 5
    weapon.explosionRadius = math.sqrt(weapon.damage)

    return weapon
end

--Ионный излучатель
function WeaponGenerator.generateSOLARTORPEDO(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

	--dps = dps * 1.2

    --local fireDelay = rand:getFloat(1.4, 2.2)
	local fireDelay = 1
    local reach = rand:getFloat(800, 900)
    local damage = dps * fireDelay
    local speed = rand:getFloat(450, 550)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
	weapon.fireRate = 0.9
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.Cannon
    weapon.name = getWeaponName('ionemitter').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('ionemitter').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('ionemitter')
    weapon.sound = "IONEMITTER"
    weapon.accuracy = 1 - rand:getFloat(0.02, 0.08)

    weapon.damage = damage
    weapon.damageType = DamageType.Electric
    weapon.impactParticles = ImpactParticles.Explosion
    weapon.impactSound = 1
    weapon.impactExplosion = true

    weapon.psize = 1.8
	weapon.pshape = ProjectileShape.Rocket
	weapon.shotsFired = 1
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(180, 66, 100)
	
	weapon.shieldDamageMultiplier = tech * 0.03 + 2.1
	

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    -- these have to be assigned after the weapon was adjusted since the damage might be changed
    weapon.recoil = weapon.damage * 5
    weapon.explosionRadius = math.sqrt(weapon.damage * 3)

    return weapon
end

function WeaponGenerator.generatePLASMAFLAK(rand, dps, tech, material, rarity)
    local weapon = Weapon()
    weapon:setProjectile()

    dps = dps * 0.2

    local fireDelay = rand:getFloat(0.4, 0.5)
    local reach = rand:getFloat(280, 310)
    local damage = dps * fireDelay
    damage = damage + tech * 0.05

    local speed = rand:getFloat(350, 450)
    local existingTime = reach / speed

    weapon.fireDelay = fireDelay
    weapon.reach = reach
    weapon.appearanceSeed = rand:getInt()
    weapon.appearance = WeaponAppearance.AntiFighter
    weapon.name = getWeaponName('plasmaflak').." /* Weapon Name*/"%_t
    weapon.prefix = getWeaponName('plasmaflak').." /* Weapon Prefix*/"%_t
    weapon.icon = getWeaponPath('plasmaflak')
    weapon.sound = "PLASMAFLAK"
    weapon.accuracy = 0.99 - rand:getFloat(0.09, 0.13)

    weapon.damage = damage
    weapon.damageType = DamageType.Fragments
    weapon.impactParticles = ImpactParticles.DustExplosion
    weapon.impactSound = 1
    weapon.deathExplosion = true
    weapon.timedDeath = true
    weapon.explosionRadius = 20
	weapon.shotsFired = 2

    weapon.psize = rand:getFloat(0.3, 0.3)
    weapon.pmaximumTime = existingTime
    weapon.pvelocity = speed
    weapon.pcolor = ColorHSV(160, 0.9, 1)

    WeaponGenerator.adaptWeapon(rand, weapon, tech, material, rarity)

    weapon.recoil = weapon.damage * 50

    return weapon
end

--Вызов генераторов
generatorFunction[WeaponType.PULSEGUN]= WeaponGenerator.generatePULSEGUN
generatorFunction[WeaponType.PARTICLEACCELERATOR]= WeaponGenerator.generatePARTICLEACCELERATOR
generatorFunction[WeaponType.ASSAULTBLASTER]= WeaponGenerator.generateASSAULTBLASTER
generatorFunction[WeaponType.HEPT]= WeaponGenerator.generateHEPT
generatorFunction[WeaponType.PULSELASER]= WeaponGenerator.generatePULSELASER
generatorFunction[WeaponType.MANTIS]= WeaponGenerator.generateMANTIS
generatorFunction[WeaponType.PHOTON]= WeaponGenerator.generatePHOTON
generatorFunction[WeaponType.HYPERKINETIC]= WeaponGenerator.generateHYPERKINETIC

generatorFunction[WeaponType.NANOREPAIR]= WeaponGenerator.generateNANOREPAIR
generatorFunction[WeaponType.CHARGINGBEAM]= WeaponGenerator.generateCHARGINGBEAM

generatorFunction[WeaponType.SOLARTORPEDO]= WeaponGenerator.generateSOLARTORPEDO
generatorFunction[WeaponType.ASSAULTCANNON]= WeaponGenerator.generateASSAULTCANNON
generatorFunction[WeaponType.AVALANCHE]= WeaponGenerator.generateAVALANCHE
generatorFunction[WeaponType.CYCLONE]= WeaponGenerator.generateCYCLONE
generatorFunction[WeaponType.PRD]= WeaponGenerator.generatePRD
generatorFunction[WeaponType.MAGNETICMORTAR]= WeaponGenerator.generateMagneticmortar
generatorFunction[WeaponType.TRANSPHASIC]= WeaponGenerator.generateTRANSPHASIC
generatorFunction[WeaponType.PLASMAFLAK]= WeaponGenerator.generatePLASMAFLAK