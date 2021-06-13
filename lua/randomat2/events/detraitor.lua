local EVENT = {}
EVENT.Title = "The detective is acting suspicious..."
EVENT.Description = "Detective could secretly be a traitor"
EVENT.id = "detraitor"
local isDetective = false
local isDetraitor = false
local isImpersonator = false

function EVENT:Begin()
    local detraitorTriggered = false
    local detraitor = nil

    if isnumber(ROLE_DETRAITOR) and ROLE_DETRAITOR ~= -1 then
        isDetraitor = true
    end

    if isnumber(ROLE_IMPERSONATOR) and ROLE_IMPERSONATOR ~= -1 then
        isImpersonator = true
    end

    for k, ply in pairs(self:GetAlivePlayers(true)) do
        if ply:GetRole() == ROLE_DETECTIVE and math.random() < 0.5 then
            if isDetraitor then
                Randomat:SetRole(ply, ROLE_DETRAITOR)

                timer.Simple(1, function()
                    ply:PrintMessage(HUD_PRINTTALK, "DETRAITOR! You're a detective, but on the traitor team!")
                end)

                SendFullStateUpdate()
                detraitorTriggered = true
                detraitor = ply
            else
                Randomat:SetRole(ply, ROLE_IMPERSONATOR)
                ply:SetNWBool("HasPromotion", true)

                timer.Simple(1, function()
                    ply:PrintMessage(HUD_PRINTTALK, "IMPERSONATOR! You look like a detective, but you're a traitor!")
                end)

                SendFullStateUpdate()
                detraitorTriggered = true
                detraitor = ply
            end
        end
    end

    for k, ply in pairs(self:GetAlivePlayers(true)) do
        if detraitorTriggered and Randomat:IsTraitorTeam(ply) and ply ~= detraitor then
            Randomat:SetRole(ply, ROLE_INNOCENT)
            ply:SetCredits(0)
            SendFullStateUpdate()
            detraitorTriggered = false
        end
    end
end

function EVENT:Condition()
    for k, ply in pairs(self:GetAlivePlayers()) do
        if (ply:GetRole() == ROLE_DETECTIVE) or isDetective then
            isDetective = true
        end
    end

    if isnumber(ROLE_DETRAITOR) and ROLE_DETRAITOR ~= -1 then
        isDetraitor = true
    end

    if isnumber(ROLE_IMPERSONATOR) and ROLE_IMPERSONATOR ~= -1 then
        isImpersonator = true
    end

    if isDetective and (isDetraitor or isImpersonator) then
        return true
    else
        return false
    end
end

Randomat:register(EVENT)