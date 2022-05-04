local EVENT = {}

CreateConVar("randomat_democracyintensifies_timer", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds between randomat votes", 10, 90)

EVENT.Title = "Amogus"
EVENT.Description = "Triggers a vote to kill a player, whenever a body is found"
EVENT.id = "amogus"

EVENT.Categories = {"eventtrigger", "moderateimpact"}

local chooseChoices
local chooseTimer
local chooseVote
local eventTriggered

function EVENT:Begin()
    eventTriggered = true
    self.Description = "Everyone votes for a randomat every " .. GetConVar("randomat_democracyintensifies_timer"):GetInt() .. " seconds!"
    chooseChoices = GetConVar("randomat_choose_choices"):GetInt()
    chooseTimer = GetConVar("randomat_choose_votetimer"):GetInt()
    chooseVote = GetConVar("randomat_choose_vote"):GetBool()
    GetConVar("randomat_choose_choices"):SetInt(5)
    GetConVar("randomat_choose_votetimer"):SetInt(GetConVar("randomat_democracyintensifies_timer"):GetInt() - 5)
    GetConVar("randomat_choose_vote"):SetBool(true)
    Randomat:SilentTriggerEvent("choose")

    timer.Create("DemocracyIntensifiesRandomatTimer", GetConVar("randomat_democracyintensifies_timer"):GetInt(), 0, function()
        Randomat:SilentTriggerEvent("choose")
    end)
end

function EVENT:End()
    if eventTriggered then
        GetConVar("randomat_choose_choices"):SetInt(chooseChoices)
        GetConVar("randomat_choose_votetimer"):SetInt(chooseTimer)
        GetConVar("randomat_choose_vote"):SetBool(chooseVote)
        timer.Remove("DemocracyIntensifiesRandomatTimer")
    end
end

function EVENT:Condition()
    return Randomat:CanEventRun("choose")
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"timer"}) do
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