local starfall_old_init = initialize
function initialize(...)
    if starfall_old_init then starfall_old_init(...) end

    -- Dynamically inject Starfall Weapons into the vanilla ShipUtility pool
    local StarfallInjector = include("starfall_injector")
    if StarfallInjector then StarfallInjector.inject() end
end