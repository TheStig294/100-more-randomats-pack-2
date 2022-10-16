local EVENT = {}
EVENT.Title = "MEDIC!"
EVENT.Description = "Everyone is a paramedic, hypnotist, or mad scientist!"
EVENT.id = "medic"

EVENT.Categories = {"rolechange", "largeimpact"}

local function RoleMessage(ply, message)
    ply:PrintMessage(HUD_PRINTCENTER, message)
    ply:PrintMessage(HUD_PRINTTALK, message)

    timer.Create("MedicRandomatMessageTimer" .. ply:EntIndex(), 2, 2, function()
        ply:PrintMessage(HUD_PRINTCENTER, message)
    end)
end

function EVENT:Begin()
    local alivePlys = self:GetAlivePlayers(true)
    local madScientistChosen = false

    for _, ply in ipairs(alivePlys) do
        local message
        self:StripRoleWeapons(ply)

        if not madScientistChosen and not Randomat:IsTraitorTeam(ply) then
            Randomat:SetRole(ply, ROLE_MADSCIENTIST)
            message = "Mad Scientist! Reviving someone with your defib turns them into a zombie!"
            ply:Give("weapon_mad_zombificator")
            madScientistChosen = true
        elseif Randomat:IsTraitorTeam(ply) then
            Randomat:SetRole(ply, ROLE_HYPNOTIST)
            message = "Hypnotist! Reviving someone with your defib turns them into a traitor!"
            ply:Give("weapon_hyp_brainwash")
        else
            Randomat:SetRole(ply, ROLE_PARAMEDIC)
            message = "Paramedic! Revive someone with your defib... if you think they're innocent!"
            ply:Give("weapon_med_defib")
        end

        timer.Simple(5, function()
            RoleMessage(ply, message)
        end)
    end

    SendFullStateUpdate()
end

function EVENT:Condition()
    return ConVarExists("ttt_hypnotist_enabled") and ConVarExists("ttt_paramedic_enabled") and ConVarExists("ttt_madscientist_enabled")
end

Randomat:register(EVENT)