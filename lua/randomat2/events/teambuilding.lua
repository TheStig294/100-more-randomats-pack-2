local EVENT = {}
EVENT.Title = "Team Building Exercise"
EVENT.Description = "1 detective, 1 traitor, everyone else are beggars"
EVENT.id = "teambuilding"

function EVENT:Begin()
    local tx = 0
    local dx = 0

    for _, ply in pairs(self:GetAlivePlayers(true)) do
        if (ply:GetRole() == ROLE_TRAITOR and tx == 0) or (ply:GetRole() == ROLE_DETECTIVE and dx == 0) then
            if ply:GetRole() ~= ROLE_DETECTIVE then
                tx = 1
                ply:SetMaxHealth(100)
            else
                dx = 1
                ply:SetCredits(2)
                ply:SetHealth(150)
                ply:SetMaxHealth(150)
            end
        else
            Randomat:SetRole(ply, ROLE_BEGGAR)
            ply:SetCredits(0)
            ply:SetMaxHealth(100)

            for _, wep in pairs(ply:GetWeapons()) do
                if wep.Kind == WEAPON_EQUIP1 or wep.Kind == WEAPON_EQUIP2 then
                    ply:StripWeapon(wep:GetClass())
                end
            end

            self:StripRoleWeapons(ply)
        end
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    local has_detective = false
    local has_traitor = false
    local has_beggar = false

    if ConVarExists("ttt_beggar_enabled") and GetConVar("ttt_beggar_enabled"):GetBool() then
        has_beggar = true
    end

    for _, v in pairs(self:GetAlivePlayers()) do
        if v:GetRole() == ROLE_DETECTIVE then
            has_detective = true
        elseif v:GetRole() == ROLE_TRAITOR then
            has_traitor = true
        end
    end

    return has_traitor and has_detective and has_beggar
end

Randomat:register(EVENT)