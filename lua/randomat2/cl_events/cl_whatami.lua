-- Default role hint popup time is 17 seconds
local popupTime = 17

net.Receive("WhatAmIRandomatConVarCheck", function()
    local hideRoleCvarExists = ConVarExists("ttt_hide_role")
    net.Start("WhatAmIRandomatCondition")
    net.WriteBool(hideRoleCvarExists)
    net.SendToServer()
end)

local function EndWhatAmI()
    cvars.RemoveChangeCallback("ttt_hide_role", "WhatAmIPreventUnhide")
    GetConVar("ttt_startpopup_duration"):SetInt(popupTime)
    GetConVar("ttt_hide_role"):SetBool(false)
    hook.Remove("PlayerBindPress", "WhatAmIDisableScoreboard")
    hook.Remove("HUDShouldDraw", "WhatAmIDisableWeaponHistory")
    hook.Remove("TTTBeginRound", "ForceEndWhatAmIBeginRound")
    hook.Remove("TTTEndRound", "ForceEndWhatAmIEndRound")
    hook.Remove("ShutDown", "ForceEndWhatAmIEndRound")
end

net.Receive("WhatAmIRandomat", function()
    popupTime = GetConVar("ttt_startpopup_duration"):GetInt()
    GetConVar("ttt_startpopup_duration"):SetInt(0)
    GetConVar("ttt_hide_role"):SetBool(true)

    local function WhatAmIPreventUnhide(convar, oldValue, newValue)
        if convar == "ttt_hide_role" then
            GetConVar("ttt_hide_role"):SetBool(true)
        end
    end

    cvars.AddChangeCallback("ttt_hide_role", WhatAmIPreventUnhide, "WhatAmIPreventUnhide")

    hook.Add("PlayerBindPress", "WhatAmIDisableScoreboard", function(ply, bind, pressed)
        if string.find(bind, "+showscores") then return true end
    end)

    hook.Add("HUDShouldDraw", "WhatAmIDisableWeaponHistory", function(name)
        if name == "TTTPickupHistory" then return false end
    end)

    hook.Add("TTTBeginRound", "ForceEndWhatAmIBeginRound", EndWhatAmI)
    hook.Add("TTTEndRound", "ForceEndWhatAmIEndRound", EndWhatAmI)
    hook.Add("ShutDown", "ForceEndWhatAmIShutDown", EndWhatAmI)
end)