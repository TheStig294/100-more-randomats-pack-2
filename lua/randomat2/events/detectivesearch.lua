local EVENT = {}
EVENT.Title = "You're on the case, detective..."
EVENT.Description = "Detectives can search bodies, everyone else can only call a detective over"
EVENT.id = "detectivesearch"

EVENT.Categories = {"smallimpact"}

local eventTriggered = false

function EVENT:Begin()
    eventTriggered = true
    GetConVar("ttt_detective_search_only"):SetBool(true)
    SetGlobalBool("ttt_detective_search_only", true)
end

function EVENT:End()
    if eventTriggered then
        GetConVar("ttt_detective_search_only"):SetBool(false)
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

    return isDetective and ConVarExists("ttt_detective_search_only") and GetConVar("ttt_detective_search_only"):GetBool() == false
end

Randomat:register(EVENT)