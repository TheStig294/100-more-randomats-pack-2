local EVENT = {}

CreateConVar("randomat_ghostifies_votetimer", "20", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds between randomat votes", 5, 60)

EVENT.Title = "Randomness Ghostifies"
EVENT.Description = "Spectators vote for a randomat every " .. GetConVar("randomat_ghostifies_votetimer"):GetInt() .. " seconds!"
EVENT.id = "ghostifies"

EVENT.Categories = {"spectator", "eventtrigger", "largeimpact"}

local choiceCount
local voteTimer

function EVENT:Begin()
    self.Description = "Spectators vote for a randomat every " .. GetConVar("randomat_ghostifies_votetimer"):GetInt() .. " seconds!"
    choiceCount = GetConVar("randomat_choose_choices"):GetInt()
    GetConVar("randomat_choose_choices"):SetInt(5)
    voteTimer = GetConVar("randomat_choose_votetimer"):GetInt()
    GetConVar("randomat_choose_votetimer"):SetInt(GetConVar("randomat_ghostifies_votetimer"):GetInt())

    timer.Create("GhostifiesRandomatTimer", GetConVar("randomat_ghostifies_votetimer"):GetInt() + 5, 0, function()
        Randomat:SilentTriggerEvent("choose", nil, true, true, function(ply) return ply:IsSpec() and not ply:Alive() end)
    end)
end

function EVENT:End()
    timer.Remove("GhostifiesRandomatTimer")

    if choiceCount then
        GetConVar("randomat_choose_choices"):SetInt(choiceCount)
        GetConVar("randomat_choose_votetimer"):SetInt(voteTimer)
    end
end

function EVENT:Condition()
    return Randomat:CanEventRun("choose")
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"votetimer"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)