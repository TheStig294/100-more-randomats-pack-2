local EVENT = {}
EVENT.Title = "Everyone's a little trickster..."
EVENT.Description = "Traitor traps can be used by anybody"
EVENT.id = "trickster"

EVENT.Categories = {"biased_innocent", "biased", "smallimpact"}

util.AddNetworkString("TricksterRandomatBegin")
util.AddNetworkString("TricksterRandomatEnd")
local traitorButtonTableOrig

function EVENT:Begin()
    traitorButtonTableOrig = table.Copy(TRAITOR_BUTTON_ROLES)

    for id, _ in pairs(ROLE_STRINGS) do
        TRAITOR_BUTTON_ROLES[tonumber(id)] = true
    end

    net.Start("TricksterRandomatBegin")
    net.Broadcast()
end

function EVENT:End()
    if traitorButtonTableOrig then
        TRAITOR_BUTTON_ROLES = traitorButtonTableOrig
        net.Start("TricksterRandomatEnd")
        net.Broadcast()
    end
end

Randomat:register(EVENT)