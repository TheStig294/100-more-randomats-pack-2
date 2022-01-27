local EVENT = {}
EVENT.Title = "The detective is acting suspicious..."
EVENT.Description = "The detective could secretly be a traitor"
EVENT.id = "dsuspicious"
EVENT.MaxRoundCompletePercent = 5
local isDetraitor = false

function EVENT:Begin()
    local detectiveCount = 0

    for i, ply in ipairs(player.GetAll()) do
        if Randomat:IsGoodDetectiveLike(ply) then
            detectiveCount = detectiveCount + 1
        end
    end

    local description = "The detective could secretly be a traitor"

    if detectiveCount > 1 then
        description = "A detective could secretly be a traitor"
    end

    self.Description = description
    -- Check to ensure only one detective is ever transformed into a traitor
    local detraitorTriggered = false

    for k, ply in pairs(self:GetAlivePlayers(true)) do
        if detraitorTriggered == false and Randomat:IsGoodDetectiveLike(ply) and math.random() < 0.5 then
            -- If Malivil's custom roles is being used
            if isDetraitor then
                self:StripRoleWeapons(ply)
                Randomat:SetRole(ply, ROLE_DETRAITOR)

                timer.Simple(1, function()
                    ply:PrintMessage(HUD_PRINTTALK, "DETRAITOR! \nYou're a detective, but on the traitor team!")
                end)

                -- Let the round report know roles have changed
                SendFullStateUpdate()
                detraitorTriggered = true
                -- Let the traitor remover function know who the detraitor is and that the effect actually triggered
            elseif detraitorTriggered == false then
                -- If Noxx's custom roles is being used, set them to an impersonator again
                self:StripRoleWeapons(ply)
                Randomat:SetRole(ply, ROLE_IMPERSONATOR)
                -- And promote them to a detective
                ply:SetNWBool("HasPromotion", true)

                timer.Simple(1, function()
                    ply:PrintMessage(HUD_PRINTTALK, "IMPERSONATOR! \nYou're a detective, but on the traitor team!")
                end)

                SendFullStateUpdate()
                detraitorTriggered = true
            end
        end
    end
end

function EVENT:Condition()
    local isDetective = false
    isDetraitor = false
    local isImpersonator = false
    local isIcon = true

    -- Check there is a detective alive
    for k, ply in pairs(self:GetAlivePlayers()) do
        if Randomat:IsGoodDetectiveLike(ply) then
            isDetective = true
            break
        end
    end

    -- Check the detraitor role exists...
    if isnumber(ROLE_DETRAITOR) and ROLE_DETRAITOR ~= -1 then
        isDetraitor = true
    end

    -- ...or the impersonator role exists
    if isnumber(ROLE_IMPERSONATOR) and ROLE_IMPERSONATOR ~= -1 then
        isImpersonator = true
    end

    -- Check the deputy icon won't instantly out the impersonator
    if ConVarExists("ttt_deputy_use_detective_icon") and GetConVar("ttt_deputy_use_detective_icon"):GetBool() == false then
        isIcon = false
    end

    return isDetective and (isDetraitor or isImpersonator) and isIcon
end

Randomat:register(EVENT)