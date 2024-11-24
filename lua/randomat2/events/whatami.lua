local EVENT = {}
EVENT.Title = "What am I?"
EVENT.Description = "Hides your role on the HUD"
EVENT.id = "whatami"

EVENT.Categories = {"largeimpact"}

util.AddNetworkString("WhatAmIRandomat")
util.AddNetworkString("WhatAmIRandomatConVarCheck")
util.AddNetworkString("WhatAmIRandomatCondition")
local hideRoleCvarExists = false

hook.Add("TTTPrepareRound", "WhatAmIRandomatConVarCheckHook", function()
    -- Entity(1) always returns the first connected player,
    -- but on dedicated servers there isn't always a guarantee that there is a player on the server
    local firstPly = Entity(1)

    if IsValid(firstPly) then
        net.Start("WhatAmIRandomatConVarCheck")
        net.Send(firstPly)
        hook.Remove("TTTPrepareRound", "WhatAmIRandomatConVarCheckHook")
    end
end)

net.Receive("WhatAmIRandomatCondition", function()
    hideRoleCvarExists = net.ReadBool()
end)

local eventRunBefore = false

function EVENT:Begin()
    net.Start("WhatAmIRandomat")
    net.Broadcast()
    eventRunBefore = true
end

function EVENT:Condition()
    return hideRoleCvarExists and not eventRunBefore
end

Randomat:register(EVENT)