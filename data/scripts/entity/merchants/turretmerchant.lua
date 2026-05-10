function TurretMerchant.shop:addItems()

    -- simply init with a 'random' seed
    local station = Entity()

    -- create all turrets
    local turrets = {}
    local generator = SectorTurretGenerator()

    for i = 1, 13 do
        local x, y = Sector():getCoordinates()
        local turret = InventoryTurret(generator:generate(x, y))
        local amount = 1
        if i == 1 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.MiningLaser))
            amount = 2
        elseif i == 2 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.PointDefenseChainGun))
            amount = 2
        elseif i == 3 then
            turret = InventoryTurret(generator:generate(x, y, nil, nil, WeaponType.ChainGun))
            amount = 2
        end

        local pair = {}
        pair.turret = turret
        pair.amount = 4 

        if turret.rarity.value == 0 then -- petty weapons 6-10
            pair.amount = pair.amount + 2
            if math.random() < 0.5 then
                pair.amount = pair.amount + 1
            end
            if math.random() < 0.5 then
                pair.amount = pair.amount + 1
            end            
            if math.random() < 0.5 then
                pair.amount = pair.amount + 2
            end               
        elseif turret.rarity.value == 1 then  -- common weapons 5-7
            pair.amount = pair.amount + 1            
            if math.random() < 0.5 then
                pair.amount = pair.amount + 1
            end
            if math.random() < 0.5 then
                pair.amount = pair.amount + 1
            end            
        elseif turret.rarity.value == 2 then -- uncommon weapons 4-6
            if math.random() < 0.3 then
                pair.amount = pair.amount + 1
            end
            if math.random() < 0.3 then
                pair.amount = pair.amount + 1
            end
        elseif turret.rarity.value >= 3 then -- >=rare weapons 3-4
            if math.random() < 0.5 then
                pair.amount = pair.amount - 1
            end
        end        

        table.insert(turrets, pair)
    end

    table.sort(turrets, comp)

    for _, pair in pairs(turrets) do
        TurretMerchant.shop:add(pair.turret, pair.amount)
    end
end