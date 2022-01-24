local EVENT = {}
EVENT.Title = "Team Building Exercise"
EVENT.Description = "1 detective, 1 traitor, everyone else are beggars"
EVENT.id = "teambuilding"

function EVENT:Begin()
    local tx = 0
    local dx = 0

    -- For all alive players,
    for _, ply in pairs(self:GetAlivePlayers(true)) do
        -- If the credits and health of the traitor and detective haven't been set yet, and they're a detective or a traitor,
        if (ply:GetRole() == ROLE_TRAITOR and tx == 0) or (ply:GetRole() == ROLE_DETECTIVE and dx == 0) then
            -- If they're not the detective, (and thus the traitor)
            if ply:GetRole() ~= ROLE_DETECTIVE then
                -- Say the traitor's credits have been changed and set them to 2
                tx = 1
                ply:SetCredits(2)
            else
                -- Else, they must be the detective, and change their credits and health
                dx = 1
                ply:SetCredits(2)
                -- Detective is set to 200 health to compensate for the traitor knowing who the detective is but not the other way around
                ply:SetHealth(200)
                ply:SetMaxHealth(200)
            end
        else
            -- Heal any Old Man back to full when they are converted. From Noxx's custom roles, this role starts with 1 health.
            if ply:GetRole() == ROLE_OLDMAN then
                ply:SetHealth(100)
                ply:SetMaxHealth(100)
            end

            -- Set everyone else to beggars
            self:StripRoleWeapons(ply)
            Randomat:SetRole(ply, ROLE_BEGGAR)

            -- And remove any bought weapons or role weapons
            for _, wep in pairs(ply:GetWeapons()) do
                -- Checking this way instead of wep.Kind ~= WEAPON_ROLE or wep.Kind ~= WEAPON_EQUIP for compatibility with my slot removal mod
                if wep.Kind ~= WEAPON_PISTOL and wep.Kind ~= WEAPON_HEAVY and wep.Kind ~= WEAPON_NADE and wep.Kind ~= WEAPON_MELEE and wep.Kind ~= WEAPON_CARRY and wep.Kind ~= WEAPON_UNARMED then
                    ply:StripWeapon(wep:GetClass())
                end
            end
        end
    end

    -- Let end-of-round report know roles have changed
    SendFullStateUpdate()
end

function EVENT:Condition()
    local has_detective = false
    local has_traitor = false
    local has_beggar = false

    -- Check if the beggar exists and is enabled
    if ConVarExists("ttt_beggar_enabled") and GetConVar("ttt_beggar_enabled"):GetBool() then
        has_beggar = true
    end

    -- Check if there is a detective and a traitor in the round
    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_DETECTIVE then
            has_detective = true
        elseif v:GetRole() == ROLE_TRAITOR then
            has_traitor = true
        end
    end
    -- Let this randomat trigger if there is a traitor and detective and the beggar role is enabled

    return has_traitor and has_detective and has_beggar
end

Randomat:register(EVENT)