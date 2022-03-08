local EVENT = {}
EVENT.Title = "Everyone's a detective"
EVENT.Description = "Everyone gets a DNA scanner and the ability to search bodies"
EVENT.id = "dna"

EVENT.Categories = {"biased_innocent", "biased", "smallimpact"}

local eventTriggered = false

function EVENT:Begin()
    eventTriggered = true

    for i, ply in pairs(self:GetAlivePlayers()) do
        timer.Simple(0.1, function()
            ply:Give("weapon_ttt_wtester")
        end)
    end

    GetConVar("ttt_detective_search_only"):SetBool(false)
    SetGlobalBool("ttt_detective_search_only", false)

    -- Adds a message to chat when a player looks at a body while they have a DNA scanner to use it
    self:AddHook("TTTOnCorpseCreated", function(corpse)
        corpse.IsBody = true
    end)

    local nonTraitors = {}

    for i, ply in ipairs(self:GetAlivePlayers()) do
        if not Randomat:IsTraitorTeam(ply) then
            table.insert(nonTraitors, ply)
        end
    end

    timer.Create("RandomatDNAScannerBodyCheck", 0.5, 0, function()
        for i, ply in ipairs(nonTraitors) do
            local ent = ply:GetEyeTrace().Entity

            if IsValid(ent) and ent.IsBody and ply:HasWeapon("weapon_ttt_wtester") and not ply:GetNWBool("DNARandomatSeenBody") then
                ply:ChatPrint("Left-click with the DNA scanner on the body!")
                ply:SetNWBool("DNARandomatSeenBody", true)
            end
        end
    end)
end

function EVENT:End()
    if eventTriggered then
        GetConVar("ttt_detective_search_only"):SetBool(true)
        timer.Remove("RandomatDNAScannerBodyCheck")

        for i, ply in ipairs(player.GetAll()) do
            ply:SetNWBool("DNARandomatSeenBody", false)
        end
    end
end

function EVENT:Condition()
    return ConVarExists("ttt_detective_search_only") and GetConVar("ttt_detective_search_only"):GetBool()
end

Randomat:register(EVENT)