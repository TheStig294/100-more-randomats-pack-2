local EVENT = {}
EVENT.Title = "What's the Mud Scientist?"
EVENT.Description = "Someone is now a \"Mud Scientist\""
EVENT.id = "mudscientist"

EVENT.Categories = {"rolechange", "fun", "smallimpact"}

util.AddNetworkString("MudScientistBegin")
util.AddNetworkString("MudScientistEnd")
local rushConvarValue
local scannerSWEP
local evenTriggered = false

function EVENT:Begin()
    evenTriggered = true
    net.Start("MudScientistBegin")
    net.Broadcast()
    -- Fix to bug where the old man is invincible when manually set like below (Also don't want the adrenaline rush anyway for the mud scientist)
    rushConvarValue = GetConVar("ttt_oldman_adrenaline_rush"):GetInt()
    GetConVar("ttt_oldman_adrenaline_rush"):SetInt(0)
    -- Changed name of old man to mud scientist in net message
    local mudScientist = self:GetAlivePlayers(true)[1]
    self:StripRoleWeapons(mudScientist)
    mudScientist:SetRole(ROLE_OLDMAN)

    -- Set Mud Scientist to a Monkey playermodel if installed
    if util.IsValidModel("models/player/mokeyfix/nosacz.mdl") then
        ForceSetPlayermodel(mudScientist, "models/player/mokeyfix/nosacz.mdl")
    end

    -- Mud scientist gets a unique weapon
    scannerSWEP = mudScientist:Give("weapon_ttt_mud_device_randomat")
    mudScientist:SelectWeapon("weapon_ttt_mud_device_randomat")
    SendFullStateUpdate()

    timer.Simple(5, function()
        mudScientist:PrintMessage(HUD_PRINTCENTER, "Start analysing some mud!")
        mudScientist:PrintMessage(HUD_PRINTTALK, "You're a mud scientist!\nYou don't care about TTT, just start analysing some mud with your 'Mud Analysis Device!'")
    end)
end

function EVENT:End()
    if not evenTriggered then return end
    evenTriggered = false
    net.Start("MudScientistEnd")
    net.Broadcast()

    if IsValid(scannerSWEP) then
        local sampleCount = table.Count(scannerSWEP.ScannedEnts)
        local message = "The Mud Scientist managed to collect " .. sampleCount .. " unique mud sample(s)!"
        PrintMessage(HUD_PRINTTALK, message)

        timer.Simple(3, function()
            self:SmallNotify(message)
            PrintMessage(HUD_PRINTCENTER, message)
        end)
    end

    if rushConvarValue then
        GetConVar("ttt_oldman_adrenaline_rush"):SetInt(rushConvarValue)
    end
end

-- Disallow french randomat to trigger at the same time as either event's role renaming may persist between rounds
function EVENT:Condition()
    return ConVarExists("ttt_oldman_enabled") and not Randomat:IsEventActive("french")
end

Randomat:register(EVENT)