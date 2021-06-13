local EVENT = {}
EVENT.Title = "What am I?"
EVENT.Description = "Hides your role on the HUD"
EVENT.id = "whatami"
util.AddNetworkString("WhatAmIRandomat")
util.AddNetworkString("WhatAmIRandomatEnd")
util.AddNetworkString("WhatAmIRandomatConVarCheck")
util.AddNetworkString("WhatAmIRandomatCondition")
local ConVarCheckDone = false
whatAmIRandomatHideRole = false
local whatAmIRandomat = false

hook.Add("TTTPrepareRound", "WhatAmIRandomatConVarCheckHook", function()
    if ConVarCheckDone == false then
        net.Start("WhatAmIRandomatConVarCheck")
        net.Send(Entity(1))
        ConVarCheckDone = true
    end
end)

net.Receive("WhatAmIRandomatCondition", function()
    whatAmIRandomatHideRole = net.ReadBool()
end)

function EVENT:Begin()
    whatAmIRandomat = true
    net.Start("WhatAmIRandomat")
    net.Broadcast()
end

function EVENT:End()
    if whatAmIRandomat then
        net.Start("WhatAmIRandomatEnd")
        net.Broadcast()
        whatAmIRandomat = false
    end
end

function EVENT:Condition()
    if whatAmIRandomatHideRole then
        return true
    else
        return false
    end
end

Randomat:register(EVENT)