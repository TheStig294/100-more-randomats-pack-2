local EVENT = {}
EVENT.Title = "A killer in disguise..."
EVENT.Description = "There is a killer, but EVERYONE has a knife"
EVENT.id = "killerdisguise"

function EVENT:Begin()
    local innocent = {}
    local killer, jester
    local killerCount = 0

    for i, ply in pairs(self:GetAlivePlayers()) do
        timer.Simple(0.1, function()
            if ply:GetRole() ~= ROLE_KILLER then
                ply:Give("weapon_ttt_knife")
            end
        end)
    end

    for k, ply in pairs(self:GetAlivePlayers(true)) do
        if (ply:GetRole() == ROLE_INNOCENT) then
            table.insert(innocent, ply)
        elseif (ply:GetRole() == ROLE_KILLER) then
            killer = ply
        elseif ((ply:GetRole() == ROLE_JESTER) or (ply:GetRole() == ROLE_SWAPPER)) then
            jester = ply
        end
    end

    if jester ~= nil then
        killer = jester
        Randomat:SetRole(killer, ROLE_KILLER)
        killer:AddCredits(2)
        SendFullStateUpdate()
    elseif killer == nil then
        if next(innocent) ~= nil then
            killer = table.Random(innocent)
            Randomat:SetRole(killer, ROLE_KILLER)
            killer:AddCredits(2)
            SendFullStateUpdate()
        end
    end

    timer.Simple(0.1, function()
        for k, ply in pairs(self:GetAlivePlayers(true)) do
            if (ply:GetRole() == ROLE_KILLER) then
                killerCount = killerCount + 1

                if killerCount > 1 then
                    Randomat:SetRole(ply, ROLE_INNOCENT)
                end
            end
        end
    end)
end

function EVENT:Condition()
    local isTarget = false
    local isKiller = false

    for k, ply in pairs(self:GetAlivePlayers()) do
        if (ply:GetRole() == ROLE_INNOCENT) or (ply:GetRole() == ROLE_KILLER) or (ply:GetRole() == ROLE_JESTER) or (ply:GetRole() == ROLE_SWAPPER) or isTarget then
            isTarget = true
        end
    end

    if isnumber(ROLE_KILLER) and ROLE_KILLER ~= -1 then
        isKiller = true
    end

    if isTarget and isKiller then
        return true
    else
        return false
    end
end

Randomat:register(EVENT)