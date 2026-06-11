package.path = package.path .. ";data/scripts/lib/?.lua"

include("utility")

function initialize()
    if onClient() then
        Player():registerCallback("onCosmicCodexGatherData", "onCosmicCodexGatherData")
    end
end

function onCosmicCodexGatherData()
    include("codex/infoWeapons")
    infoWeapons_injectToCodex()
    include("codex/infoGeneral")
    infoGeneral_injectToCodex()
    include("codex/infoSystems")
    infoSystems_injectToCodex()
    include("codex/infoStations")
    infoStations_injectToCodex()
    include("codex/infoInterfaces")
    infoInterfaces_injectToCodex()
    include("codex/infoAlerts")
    infoAlerts_injectToCodex()
    include("codex/infoChangelog")
    infoChangelog_injectToCodex()
end
