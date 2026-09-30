local EVENT = {}
EVENT.Title = "I'll be back..."
EVENT.Description = "Turns ordinary innocents into phantoms"
EVENT.id = "beback"

EVENT.Categories = {"rolechange", "biased_innocent", "biased", "moderateimpact"}

function EVENT:Begin()
    for _, ply in player.Iterator() do
        if not ply:Alive() or ply:IsSpec() then continue end

        if ply:GetRole() == ROLE_INNOCENT then
            Randomat:SetRole(ply, ROLE_PHANTOM)
        end
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    local isInnocent = false

    -- Check if there is at least one innocent alive
    for _, ply in player.Iterator() do
        if ply:Alive() and not ply:IsSpec() and ply:GetRole() == ROLE_INNOCENT then
            isInnocent = true
            break
        end
    end
    -- Only trigger this randomat if there is an innocent and the phantom exists

    return isInnocent and Randomat:CanRoleSpawn(ROLE_PHANTOM)
end

Randomat:register(EVENT)