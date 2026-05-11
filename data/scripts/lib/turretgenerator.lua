--Scaling
scales[WeaponType.PULSEGUN] = scales[WeaponType.ChainGun]

scales[WeaponType.PLASMAFLAK] = scales[WeaponType.AntiFighter]

scales[WeaponType.ASSAULTCANNON] = {
    { from = 0, to = 52, size = 1.0, usedSlots = 1 },
}
scales[WeaponType.MAGNETICMORTAR] = {
    { from = 0, to = 52, size = 1.0, usedSlots = 1 },
}
scales[WeaponType.PARTICLEACCELERATOR] = {
    { from = 0, to = 52, size = 1.0, usedSlots = 1 },
}
scales[WeaponType.ASSAULTBLASTER] = {
    { from = 0,  to = 36, size = 1.0, usedSlots = 1 },
    { from = 37, to = 46, size = 1.5, usedSlots = 2 },
    { from = 47, to = 52, size = 2.0, usedSlots = 3 },
}
scales[WeaponType.HEPT] = scales[WeaponType.PlasmaGun]
scales[WeaponType.PULSELASER] = {
    { from = 0,  to = 36, size = 1.0, usedSlots = 1 },
    { from = 37, to = 46, size = 1.5, usedSlots = 2 },
    { from = 47, to = 52, size = 2.0, usedSlots = 3 },
}
scales[WeaponType.MANTIS] = {
    { from = 0,  to = 40, size = 1.0, usedSlots = 2 },
    { from = 41, to = 48, size = 2.0, usedSlots = 3 },
    { from = 49, to = 52, size = 3.0, usedSlots = 4 },
}
scales[WeaponType.PRD] = {
    { from = 0,  to = 40, size = 1.0, usedSlots = 2 },
    { from = 41, to = 48, size = 2.0, usedSlots = 3 },
    { from = 49, to = 52, size = 3.0, usedSlots = 4 },
}
scales[WeaponType.PHOTON] = {
    { from = 0,  to = 36, size = 1.0, usedSlots = 2 },
    { from = 37, to = 52, size = 2.0, usedSlots = 2 },
}
scales[WeaponType.HYPERKINETIC] = {
    { from = 0,  to = 28, size = 2,   usedSlots = 4 },
    { from = 29, to = 35, size = 2.5, usedSlots = 4 },
    { from = 36, to = 42, size = 4,   usedSlots = 4 },
    { from = 43, to = 49, size = 4,   usedSlots = 4 },
    --dummy for cooaxial, add 1 to size and level
    { from = 50, to = 52, size = 4,   usedSlots = 6 },
}
--[[scales[WeaponType.GRAVITON] = {
    {from = 0, to = 20, size = 0.5, usedSlots = 1},
    {from = 21, to = 36, size = 1.0, usedSlots = 2},
    {from = 37, to = 49, size = 1.5, usedSlots = 3},
    {from = 50, to = 52, size = 3.5, usedSlots = 6},
}]]
scales[WeaponType.NANOREPAIR] = {
    { from = 0,  to = 28, size = 0.5, usedSlots = 1 },
    { from = 29, to = 52, size = 1.0, usedSlots = 2 },
}
scales[WeaponType.CHARGINGBEAM] = {
    { from = 0,  to = 28, size = 0.5, usedSlots = 2 },
    { from = 29, to = 52, size = 1.0, usedSlots = 2 },
}
scales[WeaponType.SOLARTORPEDO] = {
    { from = 0,  to = 36, size = 1.0, usedSlots = 2 },
    { from = 37, to = 52, size = 2.0, usedSlots = 2 },
}
scales[WeaponType.AVALANCHE] = {
    { from = 0,  to = 36, size = 5, usedSlots = 4 },
    { from = 37, to = 52, size = 5, usedSlots = 4 },
}
scales[WeaponType.CYCLONE] = {
    { from = 0, to = 52, size = 4, usedSlots = 4 },
}
scales[WeaponType.TRANSPHASIC] = {
    { from = 0, to = 52, size = 4, usedSlots = 4 },
}



--Specialties -vanilla
possibleSpecialties[WeaponType.RailGun] = {
    { specialty = Specialty.HighShootingTime, probability = 0.25 },
    { specialty = Specialty.HighDamage,       probability = 0.1 },
    { specialty = Specialty.HighFireRate,     probability = 0.10 },
}

--Specializations
possibleSpecialties[WeaponType.PULSEGUN] = {
    { specialty = Specialty.HighDamage, probability = 0.3 },
}
possibleSpecialties[WeaponType.ASSAULTCANNON] = {
    { specialty = Specialty.HighDamage, probability = 0.3 },
}
possibleSpecialties[WeaponType.MAGNETICMORTAR] = {
    { specialty = Specialty.HighDamage, probability = 0.2 },
    { specialty = Specialty.HighRange,  probability = 0.15 },
}
possibleSpecialties[WeaponType.PARTICLEACCELERATOR] = {
    { specialty = Specialty.HighShootingTime, probability = 0.2 },
    { specialty = Specialty.HighDamage,       probability = 0.2 },
    { specialty = Specialty.HighRange,        probability = 0.25 },
    { specialty = Specialty.BurstFire,        probability = 0.1 },
}
possibleSpecialties[WeaponType.ASSAULTBLASTER] = {
    { specialty = Specialty.HighDamage, probability = 0.2 },
}
possibleSpecialties[WeaponType.HEPT] = {
    { specialty = Specialty.LessEnergyConsumption, probability = 0.2 },
    { specialty = Specialty.HighFireRate,          probability = 0.1 },
    { specialty = Specialty.BurstFireEnergy,       probability = 0.1 },
}
possibleSpecialties[WeaponType.PULSELASER] = {
    { specialty = Specialty.BurstFireEnergy, probability = 1 },
}
possibleSpecialties[WeaponType.MANTIS] = {
    { specialty = Specialty.HighShootingTime, probability = 0.2 },
    { specialty = Specialty.HighDamage,       probability = 0.2 },
}
possibleSpecialties[WeaponType.PRD] = {
    { specialty = Specialty.HighShootingTime, probability = 0.2 },
    { specialty = Specialty.HighDamage,       probability = 0.2 },
}
possibleSpecialties[WeaponType.PHOTON] = {
    { specialty = Specialty.LessEnergyConsumption, probability = 0.2 },
    { specialty = Specialty.HighDamage,            probability = 0.1 },
}
possibleSpecialties[WeaponType.HYPERKINETIC] = {
    { specialty = Specialty.HighDamage, probability = 0.1 },
    { specialty = Specialty.HighRange,  probability = 0.25 },
}
--[[possibleSpecialties[WeaponType.GRAVITON] = {
    {specialty = Specialty.HighRange, probability = 0.2},
}]]
possibleSpecialties[WeaponType.NANOREPAIR] = {
    { specialty = Specialty.HighDamage, probability = 0.2 },
    { specialty = Specialty.HighRange,  probability = 0.1 },
}
possibleSpecialties[WeaponType.CHARGINGBEAM] = {
    { specialty = Specialty.HighDamage, probability = 0.2 },
    { specialty = Specialty.HighRange,  probability = 0.1 },
}
possibleSpecialties[WeaponType.SOLARTORPEDO] = {
    { specialty = Specialty.HighDamage, probability = 0.2 },
}
possibleSpecialties[WeaponType.AVALANCHE] = {
    { specialty = Specialty.HighDamage, probability = 0.1 },
}
possibleSpecialties[WeaponType.CYCLONE] = {
    { specialty = Specialty.HighDamage, probability = 0.2 },
}
possibleSpecialties[WeaponType.TRANSPHASIC] = {
    { specialty = Specialty.LessEnergyConsumption, probability = 0.2 },
}

possibleSpecialties[WeaponType.PLASMAFLAK] = {
    { specialty = Specialty.HighRange,    probability = 0.1 },
    { specialty = Specialty.HighFireRate, probability = 0.1 },
    { specialty = Specialty.HighDamage,   probability = 0.1 },
}

--A special function that assigns the solar torpedo the coaxial property always
function TurretGenerator.scaleSolar(rand, turret, type, tech, turnSpeedFactor, coaxialPossible)
    if coaxialPossible == nil then coaxialPossible = true end -- avoid coaxialPossible = coaxialPossible or true, as it will set it to true if "false" is passed

    local scaleTech = tech
    if rand:test(0.5) then
        scaleTech = math.floor(math.max(1, scaleTech * rand:getFloat(0, 1)))
    end

    local scale, lvl = TurretGenerator.getScale(type, scaleTech)

    if coaxialPossible then
        turret.coaxial = (scale.usedSlots >= 5) and 1
    else
        turret.coaxial = false
    end

    turret.size = scale.size
    turret.slots = scale.usedSlots
    turret.turningSpeed = lerp(turret.size, 0.5, 3, 1, 0.5) * rand:getFloat(0.8, 1.2) * turnSpeedFactor

    local coaxialDamageScale = turret.coaxial and 3 or 1

    local weapons = { turret:getWeapons() }
    for _, weapon in pairs(weapons) do
        weapon.localPosition = weapon.localPosition * scale.size

        if scale.usedSlots > 1 then
            -- scale damage, etc. linearly with amount of used slots
            if weapon.damage ~= 0 then
                weapon.damage = weapon.damage * scale.usedSlots * coaxialDamageScale
            end

            if weapon.hullRepair ~= 0 then
                weapon.hullRepair = weapon.hullRepair * scale.usedSlots * coaxialDamageScale
            end

            if weapon.shieldRepair ~= 0 then
                weapon.shieldRepair = weapon.shieldRepair * scale.usedSlots * coaxialDamageScale
            end

            if weapon.selfForce ~= 0 then
                weapon.selfForce = weapon.selfForce * scale.usedSlots * coaxialDamageScale
            end

            if weapon.otherForce ~= 0 then
                weapon.otherForce = weapon.otherForce * scale.usedSlots * coaxialDamageScale
            end

            local increase = 0
            if type == WeaponType.MiningLaser or type == WeaponType.SalvagingLaser then
                -- mining and salvaging laser reach is scaled more
                increase = (scale.size + 0.5) - 1
            else
                -- scale reach a little
                increase = (scale.usedSlots - 1) * 0.15
            end

            weapon.reach = weapon.reach * (1 + increase)

            local shotSizeFactor = scale.size * 2
            if weapon.isProjectile then
                local velocityIncrease = (scale.usedSlots - 1) * 0.25

                weapon.psize = weapon.psize * shotSizeFactor
                weapon.pvelocity = weapon.pvelocity * (1 + velocityIncrease)
            end
            if weapon.isBeam then weapon.bwidth = weapon.bwidth * shotSizeFactor end
        end
    end

    turret:clearWeapons()
    for _, weapon in pairs(weapons) do
        turret:addWeapon(weapon)
    end

    return lvl
end

--Pulse Cannon
function TurretGenerator.generatePULSEGUNTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 3)

    local weapon = WeaponGenerator.generatePULSEGUN(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    TurretGenerator.scale(rand, result, WeaponType.PULSEGUN, tech, 0.75)
    TurretGenerator.addSpecialties(rand, result, WeaponType.PULSEGUN)

    result:updateStaticStats()

    result.title = getWeaponName('pulsegun')

    return result
end

--Particle accelerator
function TurretGenerator.generatePARTICLEACCELERATORTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local weapons = { 1, 2, 4 }
    local numWeapons = weapons[rand:getInt(1, #weapons)]

    local weapon = WeaponGenerator.generatePARTICLEACCELERATOR(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local shootingTime = 8 * rand:getFloat(0.9, 1.3)
    local coolingTime = 3 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    local weapons = { result:getWeapons() }
    result:clearWeapons()
    for _, weapon in pairs(weapons) do
        weapon.damage = weapon.damage * ((coolingTime + shootingTime) / shootingTime)
        result:addWeapon(weapon)
    end

    TurretGenerator.scale(rand, result, WeaponType.PARTICLEACCELERATOR, tech, 0.75)
    TurretGenerator.addSpecialties(rand, result, WeaponType.PARTICLEACCELERATOR)

    result:updateStaticStats()

    result.title = getWeaponName('particleaccelerator')

    return result
end

--Assault Blaster
function TurretGenerator.generateASSAULTBLASTERTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = 2

    local weapon = WeaponGenerator.generateASSAULTBLASTER(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    TurretGenerator.scale(rand, result, WeaponType.ASSAULTBLASTER, tech, 0.75)
    TurretGenerator.addSpecialties(rand, result, WeaponType.ASSAULTBLASTER)

    result:updateStaticStats()

    result.title = getWeaponName('assaultblaster')

    return result
end

--Hept
function TurretGenerator.generateHEPTTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateHEPT(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local rechargeTime = 15 * rand:getFloat(0.8, 1.2)
    local shootingTime = 20 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    -- add further descriptions
    TurretGenerator.scale(rand, result, WeaponType.HEPT, tech, 0.7)
    TurretGenerator.addSpecialties(rand, result, WeaponType.HEPT)

    result:updateStaticStats()

    result.title = getWeaponName('hept')

    return result
end

--Pulse laser
function TurretGenerator.generatePULSELASERTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generatePULSELASER(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local rechargeTime = 10 * rand:getFloat(0.8, 1.2)
    local shootingTime = 6 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    -- add further descriptions
    TurretGenerator.scale(rand, result, WeaponType.PULSELASER, tech, 0.7)
    TurretGenerator.addSpecialties(rand, result, WeaponType.PULSELASER)

    result:updateStaticStats()

    result.title = getWeaponName('pulselaser')

    return result
end

--Installation "Mantis"
function TurretGenerator.generateMANTISTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 3)

    local weapon = WeaponGenerator.generateMANTIS(rand, dps, tech, material, rarity)
    --weapon.fireDelay = weapon.fireDelay *numWeapons

    -- attach weapons to turret
    local positions = {}
    if rand:getBool() then
        table.insert(positions, vec3(0, 0.3, 0))
    else
        table.insert(positions, vec3(0.4, 0.3, 0))
        table.insert(positions, vec3(-0.4, 0.3, 0))
    end

    -- Attach
    for _, position in pairs(positions) do
        weapon.localPosition = position * result.size
        result:addWeapon(weapon)
    end

    local shootingTime = 5
    local coolingTime = 11
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.MANTIS, tech, 0.6)
    TurretGenerator.addSpecialties(rand, result, WeaponType.MANTIS)

    result:updateStaticStats()

    result.title = getWeaponName('mantis')

    return result
end

--Photon cannon
function TurretGenerator.generatePHOTONTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 3)

    local weapon = WeaponGenerator.generatePHOTON(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    --local rechargeTime = 12 *rand:getFloat(0.8, 1.2)
    --local shootingTime = 20 *rand:getFloat(0.8, 1.2)
    local rechargeTime = 7
    local shootingTime = 3
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.PHOTON, tech, 0.5)
    TurretGenerator.addSpecialties(rand, result, WeaponType.PHOTON)

    result:updateStaticStats()

    result.title = getWeaponName('photoncannon')

    return result
end

--Hyperkinetic artillery
function TurretGenerator.generateHYPERKINETICTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = 1

    local weapon = WeaponGenerator.generateHYPERKINETIC(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local shootingTime = 50
    local coolingTime = 10
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.HYPERKINETIC, tech, 0.35)
    TurretGenerator.addSpecialties(rand, result, WeaponType.HYPERKINETIC)

    result:updateStaticStats()

    result.title = getWeaponName('hyperkinetic')

    return result
end

--Ion emitter
function TurretGenerator.generateSOLARTORPEDOTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 3)

    local weapon = WeaponGenerator.generateSOLARTORPEDO(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local rechargeTime = 6
    local shootingTime = 5
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.SOLARTORPEDO, tech, 0.5)
    TurretGenerator.addSpecialties(rand, result, WeaponType.SOLARTORPEDO)

    result:updateStaticStats()

    result.title = getWeaponName('ionemitter')

    return result
end

--Assault Cannon
function TurretGenerator.generateASSAULTCANNONTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = 1

    local weapon = WeaponGenerator.generateASSAULTCANNON(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    TurretGenerator.scale(rand, result, WeaponType.ASSAULTCANNON, tech, 0.75)
    TurretGenerator.addSpecialties(rand, result, WeaponType.ASSAULTCANNON)

    result:updateStaticStats()

    result.title = getWeaponName('assaultcannon')

    return result
end

--Nanorepair unit
function TurretGenerator.generateNANOREPAIRTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Repair))
    result.crew = crew

    -- generate weapons
    local weapon = WeaponGenerator.generateNANOREPAIR(rand, dps, tech, material, rarity)

    TurretGenerator.attachWeapons(rand, result, weapon, 1)

    local rechargeTime = 12 * rand:getFloat(0.8, 1.2)
    local shootingTime = 21 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.NANOREPAIR, tech, 1)
    TurretGenerator.addSpecialties(rand, result, WeaponType.NANOREPAIR)

    result:updateStaticStats()

    result.title = getWeaponName('nanorepair')

    return result
end

--Charging Beam
function TurretGenerator.generateCHARGINGBEAMTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Repair))
    result.crew = crew

    -- generate weapons
    local weapon = WeaponGenerator.generateCHARGINGBEAM(rand, dps, tech, material, rarity)

    TurretGenerator.attachWeapons(rand, result, weapon, 1)

    local rechargeTime = 12 * rand:getFloat(0.8, 1.2)
    local shootingTime = 21 * rand:getFloat(0.8, 1.2)
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.CHARGINGBEAM, tech, 1)
    TurretGenerator.addSpecialties(rand, result, WeaponType.CHARGINGBEAM)

    result:updateStaticStats()

    result.title = getWeaponName('chargingbeam')

    return result
end

--Gravity gun "Avalanche"
function TurretGenerator.generateAVALANCHETurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(2, 2)

    local weapon = WeaponGenerator.generateAVALANCHE(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    -- local shootingTime = 10
    -- local coolingTime = 20
    -- TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.AVALANCHE, tech, 0.5)
    TurretGenerator.addSpecialties(rand, result, WeaponType.AVALANCHE)

    result:updateStaticStats()

    result.title = getWeaponName('avalanche')

    return result
end

--Cyclone
function TurretGenerator.generateCYCLONETurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(5, 5)

    local weapon = WeaponGenerator.generateCYCLONE(rand, dps, tech, material, rarity)
    --weapon.fireDelay = weapon.fireDelay *numWeapons

    -- attach weapons to turret
    local positions = {}
    if rand:getBool() then
        table.insert(positions, vec3(0, 0.3, 0))
    else
        table.insert(positions, vec3(0.4, 0.3, 0))
        table.insert(positions, vec3(-0.4, 0.3, 0))
    end

    -- Attach
    for _, position in pairs(positions) do
        weapon.localPosition = position * result.size
        result:addWeapon(weapon)
    end

    local shootingTime = 15
    local coolingTime = 40
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.CYCLONE, tech, 0.6)
    TurretGenerator.addSpecialties(rand, result, WeaponType.CYCLONE)

    result:updateStaticStats()

    result.title = getWeaponName('cyclone')

    return result
end

--Plasmonithium disintegrator
function TurretGenerator.generatePRDTurret(rand, dps, tech, material, rarity)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 1)

    local weapon = WeaponGenerator.generatePRD(rand, dps, tech, material, rarity)
    --weapon.fireDelay = weapon.fireDelay *numWeapons

    -- attach weapons to turret
    local positions = {}
    if rand:getBool() then
        table.insert(positions, vec3(0, 0.3, 0))
    else
        table.insert(positions, vec3(0.4, 0.3, 0))
        table.insert(positions, vec3(-0.4, 0.3, 0))
    end

    -- Attach
    for _, position in pairs(positions) do
        weapon.localPosition = position * result.size
        result:addWeapon(weapon)
    end

    local shootingTime = 4
    local coolingTime = 3
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.PRD, tech, 0.6)
    TurretGenerator.addSpecialties(rand, result, WeaponType.PRD)

    result:updateStaticStats()

    result.title = getWeaponName('prd')

    return result
end

--Magnetic memo thrower
function TurretGenerator.generateMAGNETICMORTARTurret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = rand:getInt(1, 2)

    local weapon = WeaponGenerator.generateMagneticmortar(rand, dps, tech, material, rarity)
    weapon.fireDelay = weapon.fireDelay * numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    local shootingTime = 11 * rand:getFloat(0.9, 1.1)
    local coolingTime = 7 * rand:getFloat(0.8, 1.0)
    TurretGenerator.createStandardCooling(result, coolingTime, shootingTime)

    TurretGenerator.scale(rand, result, WeaponType.MAGNETICMORTAR, tech, 0.5, coaxialAllowed)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.MAGNETICMORTAR)

    result.slotType = TurretSlotType.Armed
    result:updateStaticStats()

    result.title = getWeaponName('magneticmortar')

    return result
end

--Transphase laser
function TurretGenerator.generateTRANSPHASICturret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps * 3)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = 1

    local weapon = WeaponGenerator.generateTRANSPHASIC(rand, dps, tech, material, rarity)
    weapon.damage = weapon.damage / numWeapons

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)
    local scaleLevel = TurretGenerator.scale(rand, result, WeaponType.TRANSPHASIC, tech, 0.75, coaxialAllowed)

    local rechargeTime = 5
    local shootingTime = 15
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.TRANSPHASIC)


    result.slotType = TurretSlotType.Armed
    result.coaxial = false
    result:updateStaticStats()

    result.title = getWeaponName('transphasic')

    return result
end

--Anti-aircraft plasma launcher
function TurretGenerator.generatePLASMAFLAKturret(rand, dps, tech, material, rarity, coaxialAllowed)
    local result = TurretTemplate()

    -- generate turret
    local requiredCrew = TurretGenerator.dpsToRequiredCrew(dps)
    local crew = Crew()
    crew:add(requiredCrew, CrewMan(CrewProfessionType.Gunner))
    result.crew = crew

    -- generate weapons
    local numWeapons = 2

    local weapon = WeaponGenerator.generatePLASMAFLAK(rand, dps, tech, material, rarity)

    -- attach weapons to turret
    TurretGenerator.attachWeapons(rand, result, weapon, numWeapons)

    TurretGenerator.scale(rand, result, WeaponType.PLASMAFLAK, tech, 1.2, coaxialAllowed)

    local rechargeTime = 2
    local shootingTime = 6
    TurretGenerator.createBatteryChargeCooling(result, rechargeTime, shootingTime)
    local specialties = TurretGenerator.addSpecialties(rand, result, WeaponType.PLASMAFLAK)

    result.slotType = TurretSlotType.PointDefense
    result:updateStaticStats()

    result.title = getWeaponName('plasmaflak')

    return result
end

--Calling the generator
generatorFunction[WeaponType.PULSEGUN] = TurretGenerator.generatePULSEGUNTurret
generatorFunction[WeaponType.PARTICLEACCELERATOR] = TurretGenerator.generatePARTICLEACCELERATORTurret
generatorFunction[WeaponType.ASSAULTBLASTER] = TurretGenerator.generateASSAULTBLASTERTurret
generatorFunction[WeaponType.HEPT] = TurretGenerator.generateHEPTTurret
generatorFunction[WeaponType.PULSELASER] = TurretGenerator.generatePULSELASERTurret
generatorFunction[WeaponType.MANTIS] = TurretGenerator.generateMANTISTurret
generatorFunction[WeaponType.PHOTON] = TurretGenerator.generatePHOTONTurret
generatorFunction[WeaponType.HYPERKINETIC] = TurretGenerator.generateHYPERKINETICTurret

generatorFunction[WeaponType.NANOREPAIR] = TurretGenerator.generateNANOREPAIRTurret
generatorFunction[WeaponType.CHARGINGBEAM] = TurretGenerator.generateCHARGINGBEAMTurret

generatorFunction[WeaponType.SOLARTORPEDO] = TurretGenerator.generateSOLARTORPEDOTurret
generatorFunction[WeaponType.ASSAULTCANNON] = TurretGenerator.generateASSAULTCANNONTurret
generatorFunction[WeaponType.AVALANCHE] = TurretGenerator.generateAVALANCHETurret
generatorFunction[WeaponType.CYCLONE] = TurretGenerator.generateCYCLONETurret
generatorFunction[WeaponType.PRD] = TurretGenerator.generatePRDTurret
generatorFunction[WeaponType.MAGNETICMORTAR] = TurretGenerator.generateMAGNETICMORTARTurret
generatorFunction[WeaponType.TRANSPHASIC] = TurretGenerator.generateTRANSPHASICturret
generatorFunction[WeaponType.PLASMAFLAK] = TurretGenerator.generatePLASMAFLAKturret
