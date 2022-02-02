local EVENT = {}
EVENT.Title = "Everyone's a detective"
EVENT.Description = "Everyone gets a DNA scanner and the ability to search bodies"
EVENT.id = "dna"
local eventTriggered = false

function EVENT:Begin()
    eventTriggered = true

    for i, ply in pairs(self:GetAlivePlayers()) do
        timer.Simple(0.1, function()
            ply:Give("weapon_ttt_wtester")
        end)
    end

    GetConVar("ttt_detective_search_only"):SetBool(false)
end

function EVENT:End()
    if eventTriggered then
        GetConVar("ttt_detective_search_only"):SetBool(true)
    end
end

function EVENT:Condition()
    return ConVarExists("ttt_detective_search_only") and GetConVar("ttt_detective_search_only"):GetBool()
end

Randomat:register(EVENT)