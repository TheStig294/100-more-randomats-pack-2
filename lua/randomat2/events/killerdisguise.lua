local EVENT = {}
EVENT.Title = "A killer in disguise..."
EVENT.Description = "There is a killer, but EVERYONE has a knife"
EVENT.id = "killerdisguise"

function EVENT:Begin()
    local innocent = {}
    local killer = nil
    local killerCount = 0

    -- For all alive players,
    for i, ply in pairs(self:GetAlivePlayers()) do
        -- Add all innocent players to a table
        if Randomat:IsInnocentTeam(ply) then
            table.insert(innocent, ply)
        elseif ply:GetRole() == ROLE_KILLER then
            -- If there is already a killer, this will prevent another player from being turned into one
            killer = ply
        end

        timer.Simple(0.1, function()
            -- Give everyone a knife, unless they are a killer that naturally spawned in the round
            if ply:GetRole() ~= ROLE_KILLER then
                ply:Give("weapon_ttt_knife")
            end
        end)
    end

    -- Pick a random innocent and set them to the killer, if there isn't one already
    if killer == nil then
        killer = table.Random(innocent)
        Randomat:SetRole(killer, ROLE_KILLER)
        killer:SetCredits(2)
        -- Let the end-of-round scoreboard know roles have changed
        SendFullStateUpdate()
    end
end

function EVENT:Condition()
    local has_innocent = false

    -- Check there is an innocent alive
    for i, ply in pairs(self:GetAlivePlayers()) do
        if Randomat:IsInnocentTeam(ply) then
            has_innocent = true
        end
    end
    -- Check if the killer exists, is enabled, and that there is an alive innocent

    return ConVarExists("ttt_killer_enabled") and GetConVar("ttt_killer_enabled"):GetBool() and has_innocent
end

Randomat:register(EVENT)