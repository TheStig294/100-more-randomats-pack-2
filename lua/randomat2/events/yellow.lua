local EVENT = {}

CreateConVar("randomat_yellow_credits", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How many credits the Mercenaries get (def. 1)", 0, 5)

EVENT.Title = "Yellow Is The New Green!"
EVENT.Description = "Innocents are now mercenaries"
EVENT.id = "yellow"

function EVENT:Begin()
    for k, ply in pairs(self:GetAlivePlayers(true)) do
        if (ply:GetRole() == ROLE_INNOCENT) then
            Randomat:SetRole(ply, ROLE_MERCENARY)
            ply:AddCredits(GetConVar("randomat_yellow_credits"):GetInt())
        end
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    local isInnocent = false
    local isMercenary = false

    for k, ply in pairs(self:GetAlivePlayers()) do
        if (ply:GetRole() == ROLE_INNOCENT) or isInnocent then
            isInnocent = true
        end
    end

    if isnumber(ROLE_MERCENARY) and ROLE_MERCENARY ~= -1 then
        isMercenary = true
    end

    if isInnocent and isMercenary then
        return true
    else
        return false
    end
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

    return sliders, {}, {}
end

Randomat:register(EVENT)