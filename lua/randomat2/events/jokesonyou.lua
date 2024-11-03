local EVENT = {}
EVENT.Title = "Joke's on you!"
EVENT.Description = "Killed players come back as jesters!"
EVENT.id = "jokesonyou"

EVENT.Type = {EVENT_TYPE_RESPAWN}

EVENT.Categories = {"rolechange", "deathtrigger", "largeimpact"}

CreateConVar("randomat_jokesonyou_health", 100, FCVAR_ARCHIVE, "The health that the Jesters respawn with", 1, 200)
CreateConVar("randomat_jokesonyou_include_dead", 1, FCVAR_ARCHIVE, "Whether to resurrect dead players at the start")

local function JesterfyPlayer(ply, skip_missing_corpse, pos)
    local body = ply.server_ragdoll or ply:GetRagdollEntity()
    if skip_missing_corpse and not IsValid(body) then return false end
    ply:SpawnForRound(true)
    ply:SetCredits(0)
    ply:SetRole(ROLE_JESTER)

    if pos then
        ply:SetPos(pos)
    end

    ply:SetHealth(GetConVar("randomat_jokesonyou_health"):GetInt())
    ply:SetMaxHealth(GetConVar("randomat_jokesonyou_health"):GetInt())

    if IsValid(body) then
        ply:SetEyeAngles(Angle(0, body:GetAngles().y, 0))
        body:Remove()
    end

    return true
end

function EVENT:Begin(filter_class)
    -- Update this in case the role names have been changed
    EVENT.Description = "Killed players come back as " .. Randomat:GetRolePluralString(ROLE_JESTER)
    local include_dead = not filter_class and GetConVar("randomat_jokesonyou_include_dead"):GetBool()

    if include_dead then
        local jesterfied = false

        for _, p in ipairs(self:GetDeadPlayers()) do
            jesterfied = jesterfied or JesterfyPlayer(p, true)
        end

        -- Don't update everyone if nobody actually changed
        if jesterfied then
            SendFullStateUpdate()
        end
    end

    local new_traitors = {}

    for _, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsBodyDependentRole(ply) then
            self:StripRoleWeapons(ply)
            local isTraitor = Randomat:SetToBasicRole(ply, "Traitor", true)

            if isTraitor then
                table.insert(new_traitors, ply)
            end
        end
    end

    -- Send message to the traitor team if new traitors joined
    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)
    SendFullStateUpdate()

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        local pos = victim:GetPos()

        timer.Create(victim:SteamID64() .. "RdmtJesterTimer", 0.25, 1, function()
            if not filter_class or (IsValid(killer) and killer:GetClass() == filter_class) then
                JesterfyPlayer(victim, false, pos)
                self:StripRoleWeapons(victim)
                SendFullStateUpdate()
            end
        end)
    end)
end

function EVENT:End()
    for _, v in ipairs(player.GetAll()) do
        timer.Remove(v:SteamID64() .. "RdmtJesterTimer")
    end
end

-- Checking if someone is a body dependent role and if it isn't at the start of the round, prevent the event from running
function EVENT:Condition()
    if not Randomat:CanRoleSpawn(ROLE_JESTER) then return false end
    local bodyDependentRoleExists = false

    for _, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsBodyDependentRole(ply) then
            bodyDependentRoleExists = true
            break
        end
    end

    return Randomat:GetRoundCompletePercent() < 5 or not bodyDependentRoleExists
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"health"}) do
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

    local checks = {}

    for _, v in ipairs({"include_dead"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks
end

Randomat:register(EVENT)