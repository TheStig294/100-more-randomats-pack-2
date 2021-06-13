local EVENT = {}
EVENT.Title = "The detective is acting suspicious..."
EVENT.Description = "The detective could secretly be a traitor"
EVENT.id = "detraitor"
local isDetraitor = false

function EVENT:Begin()
    local detraitorTriggered = false
    local detraitor = nil

    -- For all alive players,
    for k, ply in pairs(self:GetAlivePlayers(true)) do
        -- Find the detective and roll a 50% chance to trigger
        if ply:GetRole() == ROLE_DETECTIVE and math.random() < 0.5 then
            -- If Malivil's custom roles is being used,
            if isDetraitor then
                -- Set the detective to a detraitor
                Randomat:SetRole(ply, ROLE_DETRAITOR)

                -- Print a message to chat
                timer.Simple(1, function()
                    ply:PrintMessage(HUD_PRINTTALK, "DETRAITOR! You're a detective, but on the traitor team!")
                end)

                -- Let the round report know roles have changed
                SendFullStateUpdate()
                -- Let the traitor remover function know who the detraitor is and that the effect actually triggered
                detraitorTriggered = true
                detraitor = ply
            else
                -- If Noxx's custom roles is being used, set them to an impersonator again
                Randomat:SetRole(ply, ROLE_IMPERSONATOR)
                -- And promote them to a detective
                ply:SetNWBool("HasPromotion", true)

                -- Print a message to chat
                timer.Simple(1, function()
                    ply:PrintMessage(HUD_PRINTTALK, "IMPERSONATOR! You're a detective, but on the traitor team!")
                end)

                -- Let the round report know roles have changed
                SendFullStateUpdate()
                -- Let the traitor remover function know who the detraitor is and that the effect actually triggered
                detraitorTriggered = true
                detraitor = ply
            end
        end
    end

    -- Removes a traitor if someone was changed to a detraitor/impersonator
    -- For all alive players,
    for k, ply in pairs(self:GetAlivePlayers(true)) do
        -- If someone was turned into a traitor detective, the player is a traitor and not the detraitor/impersonator,
        if detraitorTriggered and Randomat:IsTraitorTeam(ply) and ply ~= detraitor then
            -- Change them to an innocent
            Randomat:SetRole(ply, ROLE_INNOCENT)
            -- Remove any credits they had
            ply:SetCredits(0)
            -- Let the round report know roles have changed
            SendFullStateUpdate()
            -- Stop this from changing more than one traitor
            detraitorTriggered = false
        end
    end
end

function EVENT:Condition()
    local isDetective = false
    isDetraitor = false
    local isImpersonator = false

    -- Check there is a detective alive
    for k, ply in pairs(self:GetAlivePlayers()) do
        if (ply:GetRole() == ROLE_DETECTIVE) or isDetective then
            isDetective = true
        end
    end

    -- Check the detraitor role exists
    if isnumber(ROLE_DETRAITOR) and ROLE_DETRAITOR ~= -1 then
        isDetraitor = true
    end

    -- Check the impersonator role exists
    if isnumber(ROLE_IMPERSONATOR) and ROLE_IMPERSONATOR ~= -1 then
        isImpersonator = true
    end
    -- If there's a detective and at least the detraitor or impersonator roles exist, let this randomat trigger

    return isDetective and (isDetraitor or isImpersonator)
end

Randomat:register(EVENT)