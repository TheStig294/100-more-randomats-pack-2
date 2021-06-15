local EVENT = {}
EVENT.Title = "A killer in disguise..."
EVENT.Description = "There is a killer, but EVERYONE has a knife"
EVENT.id = "killerdisguise"

function EVENT:Begin()
    local innocent = {}
    local killer = nil
    local killerCount = 0

    -- For all alive players,
    for i, ply in pairs(self:GetAlivePlayers(true)) do
        -- Add all innocent players to a table, (but not the detective)
        if Randomat:IsInnocentTeam(ply, true) then
            table.insert(innocent, ply)
        elseif ply:GetRole() == ROLE_KILLER then
            -- And grab the killer if they already exist
            killer = ply
        end

        timer.Simple(0.1, function()
            -- Give everyone a knife, unless they're a killer that naturally spawned in the round
            if ply:GetRole() ~= ROLE_KILLER then
                ply:Give("weapon_ttt_knife")
            end
        end)
    end

    -- If there isn't already a killer, and the table of innocents isn't empty,
    if killer == nil and next(innocent) ~= nil then
        -- Pick a random innocent and set them to the killer
        killer = table.Random(innocent)
        Randomat:SetRole(killer, ROLE_KILLER)
        killer:SetCredits(2)
        -- Let the end-of-round scoreboard know roles have changed
        SendFullStateUpdate()
    end

    -- As a fail-safe, if for whatever reason there are multiple killers alive,
    timer.Simple(0.1, function()
        for k, ply in pairs(self:GetAlivePlayers()) do
            if ply:GetRole() == ROLE_KILLER then
                killerCount = killerCount + 1

                -- Set all but one to an innocent
                if killerCount > 1 then
                    Randomat:SetRole(ply, ROLE_INNOCENT)
                end
            end
        end
    end)
end

function EVENT:Condition()
    local isInnocent = false
    local isKiller = false

    -- Check there is a least one non-detective innocent alive
    for k, ply in pairs(self:GetAlivePlayers()) do
        if Randomat:IsInnocentTeam(ply, true) then
            isInnocent = true
        end
    end

    -- Check the killer role exists
    if isnumber(ROLE_KILLER) and ROLE_KILLER ~= -1 then
        isKiller = true
    end

    return isInnocent and isKiller
end

Randomat:register(EVENT)