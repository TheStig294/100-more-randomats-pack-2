local EVENT = {}
EVENT.Title = "What am I?"
EVENT.Description = "Hides your role on the HUD"
EVENT.id = "whatami"
util.AddNetworkString("WhatAmIRandomat")
util.AddNetworkString("WhatAmIRandomatEnd")
util.AddNetworkString("WhatAmIRandomatConVarCheck")
util.AddNetworkString("WhatAmIRandomatCondition")
local ConVarCheckDone = false
-- Variable doesn't work unless it's global
whatAmIRandomatHideRole = false
local whatAmIRandomat = false

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
    -- Prevent the end function triggering before the begin function
    whatAmIRandomat = true
    -- The action happens client-side
    net.Start("WhatAmIRandomat")
    net.Broadcast()
end

function EVENT:End()
    -- Prevent the end function triggering before the begin function
    if whatAmIRandomat then
        net.Start("WhatAmIRandomatEnd")
        net.Broadcast()
        whatAmIRandomat = false
    end
end

function EVENT:Condition()
    -- Don't let this randomat run if the convar doesn't exist
    return whatAmIRandomatHideRole
end

Randomat:register(EVENT)