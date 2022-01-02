-- Default role hint popup time is 17 seconds
local popupTime = 17

-- Sent whenever this randomat tries to trigger
-- Checks if the 'Hide role' option exists
-- If not this randomat does not trigger
net.Receive("WhatAmIRandomatConVarCheck", function()
    -- If Malivil's 'Hide role' setting is detected,
    if ConVarExists("ttt_hide_role") then
        -- Then tell the server this randomat can trigger,
        net.Start("WhatAmIRandomatCondition")
        net.WriteBool(true)
        net.SendToServer()
    else
        -- Otherwise it cannot
        net.Start("WhatAmIRandomatCondition")
        net.WriteBool(false)
        net.SendToServer()
    end
end)

local function EndWhatAmI()
    -- Resets the role hint popup time
    GetConVar("ttt_startpopup_duration"):SetInt(popupTime)
    -- Un-hides the player's role
    GetConVar("ttt_hide_role"):SetBool(false)
    -- Re-enables the scoreboard and weapon pickup popups
    hook.Remove("PlayerBindPress", "WhoAmIDisableScorboard")
    hook.Remove("HUDShouldDraw", "WhoAmIDisableWeaponHistory")
    hook.Remove("TTTBeginRound", "ForceEndWhatAmIBeginRound")
    hook.Remove("TTTEndRound", "ForceEndWhatAmIEndRound")
end

-- Randomat start
net.Receive("WhatAmIRandomat", function()
    -- Get the role hint popup time and turn it off
    popupTime = GetConVar("ttt_startpopup_duration"):GetInt()
    GetConVar("ttt_startpopup_duration"):SetInt(0)
    -- Hide the player's role
    GetConVar("ttt_hide_role"):SetBool(true)

    -- Prevent them from opening the scoreboard
    hook.Add("PlayerBindPress", "WhoAmIDisableScorboard", function(ply, bind, pressed)
        if (string.find(bind, "+showscores")) then return true end
    end)

    -- Hides the weapon pickup popup on the side as it's colour gives away your role
    hook.Add("HUDShouldDraw", "WhoAmIDisableWeaponHistory", function(name)
        if name == "TTTPickupHistory" then return false end
    end)

    hook.Add("TTTBeginRound", "ForceEndWhatAmIBeginRound", EndWhatAmI())
    hook.Add("TTTEndRound", "ForceEndWhatAmIEndRound", EndWhatAmI())
end)