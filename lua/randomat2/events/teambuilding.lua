local EVENT = {}
EVENT.Title = "Team Building Exercise"
EVENT.Description = "1 detective, 1 traitor. Everyone else is a beggar!"
EVENT.id = "teambuilding"

EVENT.Categories = {"rolechange", "largeimpact", "biased_traitor", "biased"}

function EVENT:Begin()
    local detective
    local traitor

    -- Set the detective and traitor to their vanilla variants so they have the most chance of actually having giftable items in their buy menus
    for _, ply in ipairs(self:GetAlivePlayers(true)) do
        self:StripRoleWeapons(ply)

        if not detective and ply ~= traitor then
            detective = ply
            Randomat:SetRole(ply, ROLE_DETECTIVE)
            ply:SetCredits(2)
            -- Detective gets 200 health to balance the fact that the traitor knows who is a beggar or not
            ply:SetHealth(200)
            ply:SetMaxHealth(200)
        elseif not traitor and ply ~= detective then
            traitor = ply
            Randomat:SetRole(ply, ROLE_TRAITOR)
            ply:SetCredits(2)
        elseif ply ~= detective and ply ~= traitor then
            Randomat:SetRole(ply, ROLE_BEGGAR)

            -- Remove any giftable bought weapons the beggars may have
            for _, wep in ipairs(ply:GetWeapons()) do
                -- .BoughtBy is a special property set by Custom Roles itself and used by the beggar role to determine if a given weapon should convert the beggar's role
                if wep.BoughtBy then
                    wep:Remove()
                end
            end
        end
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    return Randomat:CanRoleSpawn(ROLE_BEGGAR)
end

Randomat:register(EVENT)