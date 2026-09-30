local EVENT = {}
EVENT.Title = "I'm a mercenary!"
EVENT.Description = "Ordinary innocents are now mercenaries"
EVENT.id = "yellow"

EVENT.Categories = {"rolechange", "biased_innocent", "biased", "moderateimpact"}

local creditsCvar = CreateConVar("randomat_yellow_credits", 1, FCVAR_NONE, "How many credits the Mercenaries get", 0, 5)

function EVENT:Begin()
    for _, ply in player.Iterator() do
        if not ply:Alive() or ply:IsSpec() then continue end

        if ply:GetRole() == ROLE_INNOCENT then
            Randomat:SetRole(ply, ROLE_MERCENARY)
            ply:SetCredits(creditsCvar:GetInt())
        end
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    local isInnocent = false

    -- Check if there is at least one innocent alive
    for _, ply in player.Iterator() do
        if ply:Alive() and not ply:IsSpec() and ply:GetRole() == ROLE_INNOCENT then
            isInnocent = true
            break
        end
    end
    -- Only trigger this randomat if there is an innocent and the mercenary exists

    return isInnocent and Randomat:CanRoleSpawn(ROLE_MERCENARY)
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in pairs({"credits"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)