local EVENT = {}
EVENT.Title = "A killer in disguise..."
EVENT.Description = "There is a killer, but EVERYONE has a knife"
EVENT.id = "killerdisguise"

EVENT.Categories = {"rolechange", "item", "moderateimpact"}

function EVENT:Begin()
    local innocent = {}
    local killer = nil

    -- For all alive players,
    for i, ply in pairs(self:GetAlivePlayers()) do
        -- Add all innocent players to a table, except the detective
        if Randomat:IsInnocentTeam(ply, true) then
            table.insert(innocent, ply)
        elseif ply:GetRole() == ROLE_KILLER then
            -- If there is already a killer, this will prevent another player from being turned into one
            killer = ply
        end

        timer.Simple(0.1, function()
            -- Give everyone a knife, unless they are a killer that naturally spawned in the round
            if ply:GetRole() ~= ROLE_KILLER then
                ply:Give("weapon_ttt_knife")
                Randomat:CallShopHooks(false, "weapon_ttt_knife", ply)
            end
        end)
    end

    -- Pick a random innocent and set them to the killer, if there isn't one already
    if killer == nil then
        killer = table.Random(innocent)
        self:StripRoleWeapons(killer)
        Randomat:SetRole(killer, ROLE_KILLER)
        killer:SetDefaultCredits()
        SetRoleHealth(killer)
        -- Let the end-of-round scoreboard know roles have changed
        SendFullStateUpdate()
    end
end

function EVENT:Condition()
    local has_innocent = false

    -- Check there is a non-detective innocent alive
    for i, ply in pairs(self:GetAlivePlayers()) do
        if Randomat:IsInnocentTeam(ply, true) then
            has_innocent = true
        end
    end
    -- Check if the killer exists, is enabled, and that there is an alive innocent

    return ConVarExists("ttt_killer_enabled") and GetConVar("ttt_killer_enabled"):GetBool() and has_innocent
end

Randomat:register(EVENT)