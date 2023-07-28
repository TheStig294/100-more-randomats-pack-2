local EVENT = {}
EVENT.Title = "You're on the case, detective..."
EVENT.Description = "Detectives can search bodies, everyone else can only call a detective over"
EVENT.id = "detectivesearch"
EVENT.IsEnabled = false

EVENT.Categories = {"smallimpact", "biased_traitor", "biased"}

local eventTriggered = false

function EVENT:Begin()
    eventTriggered = true

    -- CR Replicated convar
    Randomat:HandleReplicatedValue(function()
        GetConVar("ttt_detectives_search_only"):SetBool(true)
    end, function()
        GetConVar("ttt_detective_search_only"):SetBool(true)
        SetGlobalBool("ttt_detective_search_only", true)
    end)
end

function EVENT:End()
    if eventTriggered then
        -- CR Replicated convar
        Randomat:HandleReplicatedValue(function()
            GetConVar("ttt_detectives_search_only"):SetBool(false)
        end, function()
            GetConVar("ttt_detective_search_only"):SetBool(false)
        end)
    end
end

function EVENT:Condition()
    local isDetective = false

    for _, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(ply) then
            isDetective = true
            break
        end
    end
    -- CR Replicated convar

    return isDetective and (ConVarExists("ttt_detectives_search_only") and GetConVar("ttt_detectives_search_only"):GetBool() == false) or (ConVarExists("ttt_detective_search_only") and GetConVar("ttt_detective_search_only"):GetBool() == false)
end

Randomat:register(EVENT)