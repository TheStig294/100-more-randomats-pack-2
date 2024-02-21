local EVENT = {}
EVENT.Title = "I'll be back..."
EVENT.Description = "Turns ordinary innocents into phantoms"
EVENT.id = "beback"

EVENT.Categories = {"rolechange", "biased_innocent", "biased", "moderateimpact"}

function EVENT:Begin()
    for k, ply in pairs(self:GetAlivePlayers()) do
        if ply:GetRole() == ROLE_INNOCENT then
            Randomat:SetRole(ply, ROLE_PHANTOM)
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()
end

-- Check if the phantom exists and is enabled
function EVENT:Condition()
    return Randomat:CanRoleSpawn(ROLE_PHANTOM)
end

Randomat:register(EVENT)