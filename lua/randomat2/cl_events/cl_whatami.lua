local popupTime = 17

net.Receive("WhatAmIRandomatConVarCheck", function()
    if ConVarExists("ttt_hide_role") then
        net.Start("WhatAmIRandomatCondition")
        net.WriteBool(true)
        net.SendToServer()
    else
        net.Start("WhatAmIRandomatCondition")
        net.WriteBool(false)
        net.SendToServer()
    end
end)

net.Receive("WhatAmIRandomat", function()
    popupTime = GetConVar("ttt_startpopup_duration"):GetInt()
    GetConVar("ttt_startpopup_duration"):SetInt(0)
    GetConVar("ttt_hide_role"):SetBool(true)

    hook.Add("PlayerBindPress", "WhoAmIDisableScorboard", function(ply, bind, pressed)
        if (string.find(bind, "+showscores")) then return true end
    end)

    local hud = {
        ["TTTPickupHistory"] = true,
        ["TTTPickupHistory"] = true
    }

    hook.Add("HUDShouldDraw", "WhoAmIDisableWeaponHistory", function(name)
        if name == "TTTPickupHistory" then return false end
    end)
end)

net.Receive("WhatAmIRandomatEnd", function()
    GetConVar("ttt_startpopup_duration"):SetInt(popupTime)
    GetConVar("ttt_hide_role"):SetBool(false)
    hook.Remove("PlayerBindPress", "WhoAmIDisableScorboard")
    hook.Remove("HUDShouldDraw", "WhoAmIDisableWeaponHistory")
end)