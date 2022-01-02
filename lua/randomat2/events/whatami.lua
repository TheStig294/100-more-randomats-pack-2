local EVENT = {}
EVENT.Title = "What am I?"
EVENT.Description = "Hides your role on the HUD"
EVENT.id = "whatami"
util.AddNetworkString("WhatAmIRandomat")
util.AddNetworkString("WhatAmIRandomatEnd")
util.AddNetworkString("WhatAmIRandomatConVarCheck")
util.AddNetworkString("WhatAmIRandomatCondition")
local ConVarCheckDone = false
local EventRun = false
-- Variable doesn't work unless it's global
whatAmIRandomatHideRole = false

-- At the start of the first round,
hook.Add("TTTPrepareRound", "WhatAmIRandomatConVarCheckHook", function()
    -- If the convar check hasn't already been done,
    if ConVarCheckDone == false then
        -- Check if the 'Hide Role' Convar exists on the first connected player's client
        net.Start("WhatAmIRandomatConVarCheck")
        net.Send(Entity(1))
        -- Prevent this from happening every round
        ConVarCheckDone = true
    end
end)

-- Receive from the client whether the hide role convar exists
net.Receive("WhatAmIRandomatCondition", function()
    whatAmIRandomatHideRole = net.ReadBool()
end)

function EVENT:Begin()
    -- The action happens client-side
    net.Start("WhatAmIRandomat")
    net.Broadcast()
    EventRun = true
end

function EVENT:Condition()
    -- Don't let this randomat run if the convar doesn't exist or it has run before for this map
    return whatAmIRandomatHideRole and not EventRun
end

Randomat:register(EVENT)