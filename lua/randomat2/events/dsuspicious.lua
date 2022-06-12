local EVENT = {}
EVENT.Title = "The detective is acting suspicious..."
EVENT.Description = "The detective could secretly be a traitor"
EVENT.id = "dsuspicious"
EVENT.MaxRoundCompletePercent = 5

EVENT.Categories = {"rolechange", "largeimpact", "biased_traitor", "biased"}

local isDetraitor = false

function EVENT:Begin()
    -- Changing the description if there is more than one detective
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

    -- 50% chance to transform the/a detective
    if math.random() < 0.5 then
        for k, ply in pairs(self:GetAlivePlayers(true)) do
            -- Choose an ordinary detective, or any detective if detective roles are hidden
            if ply:GetRole() == ROLE_DETECTIVE or (GetConVar("ttt_detective_hide_special_mode"):GetInt() ~= 0 and Randomat:IsGoodDetectiveLike(ply)) then
                -- If the detraitor exists, use it, as the impersonator doesn't exist on that version of Custom Roles
                if isDetraitor then
                    self:StripRoleWeapons(ply)
                    Randomat:SetRole(ply, ROLE_DETRAITOR)

                    timer.Simple(1, function()
                        ply:PrintMessage(HUD_PRINTTALK, "DETRAITOR! \nYou're a detective, but on the traitor team!")
                    end)

                    break
                else
                    -- Else if the latest version of Custom Roles is being used, set them to an impersonator
                    self:StripRoleWeapons(ply)
                    Randomat:SetRole(ply, ROLE_IMPERSONATOR)
                    -- And promote them to a detective
                    ply:SetNWBool("HasPromotion", true)

                    timer.Simple(1, function()
                        ply:PrintMessage(HUD_PRINTTALK, "IMPERSONATOR! \nYou're a detective, but on the traitor team!")
                    end)

                    break
                end
            end
        end
    end

    -- Let the round report know roles have changed
    SendFullStateUpdate()
end

function EVENT:Condition()
    local isDetective = false
    isDetraitor = false
    local isImpersonator = false
    local isIcon = true

    -- Check there is an ordinary detective alive, or any kind of detective when detective roles are hidden
    for k, ply in pairs(self:GetAlivePlayers()) do
        if ply:GetRole() == ROLE_DETECTIVE or (ConVarExists("ttt_detective_hide_special_mode") and GetConVar("ttt_detective_hide_special_mode"):GetInt() ~= 0 and Randomat:IsGoodDetectiveLike(ply)) then
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