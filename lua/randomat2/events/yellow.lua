local EVENT = {}

CreateConVar("randomat_yellow_credits", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How many credits the Mercenaries get", 0, 5)

EVENT.Title = "I'm a mercenary!"
EVENT.Description = "Ordinary innocents are now mercenaries"
EVENT.id = "yellow"

EVENT.Categories = {"rolechange", "biased_innocent", "biased", "moderateimpact"}

function EVENT:Begin()
    -- For all alive players,
    for k, ply in pairs(self:GetAlivePlayers(true)) do
        -- If they are a pure innocent,
        if ply:GetRole() == ROLE_INNOCENT then
            -- Set them to be a mercenary and give them the set amount of credits
            self:StripRoleWeapons(ply)
            Randomat:SetRole(ply, ROLE_MERCENARY)
            ply:SetCredits(GetConVar("randomat_yellow_credits"):GetInt())
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()
end

function EVENT:Condition()
    local isInnocent = false
    local isMercenary = false

    -- Check if there is at least one innocent alive
    for k, ply in pairs(self:GetAlivePlayers()) do
        if ply:GetRole() == ROLE_INNOCENT then
            isInnocent = true
        end
    end

    -- Check if the mercenary exists and is enabled
    if Randomat:CanRoleSpawn(ROLE_MERCENARY) then
        isMercenary = true
    end
    -- Only trigger this randomat if there is an innocent and the mercenary exists

    return isInnocent and isMercenary
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in pairs({"credits"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(sliders, {
                cmd = v, -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText(), -- The description of the ConVar
                min = convar:GetMin(), -- The minimum value for this slider-based ConVar
                max = convar:GetMax(), -- The maximum value for this slider-based ConVar
                dcm = 0 -- The number of decimal points to support in this slider-based ConVar
                
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)