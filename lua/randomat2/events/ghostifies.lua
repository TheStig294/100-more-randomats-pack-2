local EVENT = {}

CreateConVar("randomat_ghostifies_time", "30", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds between randomat votes", 5, 60)

EVENT.Title = "Randomness Ghostifies"
EVENT.Description = "Spectators vote for a randomat every " .. GetConVar("randomat_ghostifies_time"):GetInt() .. " seconds!"
EVENT.id = "ghostifies"

EVENT.Categories = {"spectator", "eventtrigger", "largeimpact"}

local choiceCount
local time
local vote
local deadVoters

function EVENT:Begin()
    self.Description = "Spectators vote for a randomat every " .. GetConVar("randomat_ghostifies_time"):GetInt() .. " seconds!"
    choiceCount = GetConVar("randomat_choose_choices"):GetInt()
    GetConVar("randomat_choose_choices"):SetInt(5)
    time = GetConVar("randomat_choose_time"):GetInt()
    GetConVar("randomat_choose_time"):SetInt(GetConVar("randomat_ghostifies_time"):GetInt())
    vote = GetConVar("randomat_choose_vote"):GetBool()
    GetConVar("randomat_choose_vote"):SetBool(true)
    deadVoters = GetConVar("randomat_choose_deadvoters"):GetBool()
    GetConVar("randomat_choose_deadvoters"):SetBool(true)

    timer.Create("GhostifiesRandomatTimer", GetConVar("randomat_ghostifies_time"):GetInt() + 5, 0, function()
        Randomat:SilentTriggerEvent("choose", nil, true, true, function(ply) return ply:IsSpec() and not ply:Alive() end)
    end)
end

function EVENT:End()
    timer.Remove("GhostifiesRandomatTimer")

    if choiceCount then
        GetConVar("randomat_choose_choices"):SetInt(choiceCount)
        GetConVar("randomat_choose_time"):SetInt(time)
        GetConVar("randomat_choose_vote"):SetBool(vote)
        GetConVar("randomat_choose_deadvoters"):SetBool(deadVoters)
    end
end

function EVENT:Condition()
    return Randomat:CanEventRun("choose")
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"time"}) do
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