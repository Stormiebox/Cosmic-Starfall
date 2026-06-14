package.path = package.path .. ";data/scripts/lib/?.lua"
package.path = package.path .. ";data/scripts/?.lua"

include("utility")

function initialize()
    if onClient() then
        Player():registerCallback("onCosmicCodexGatherData", "onCosmicCodexGatherData")
    end
end

function onCosmicCodexGatherData()
    include("player/codex/infoWeapons")
    infoWeapons_injectToCodex()
    include("player/codex/infoGeneral")
    infoGeneral_injectToCodex()
    include("player/codex/infoSystems")
    infoSystems_injectToCodex()
    include("player/codex/infoStations")
    infoStations_injectToCodex()
    include("player/codex/infoInterfaces")
    infoInterfaces_injectToCodex()
    include("player/codex/infoAlerts")
    infoAlerts_injectToCodex()
    include("player/codex/infoChangelog")
    infoChangelog_injectToCodex()
end
