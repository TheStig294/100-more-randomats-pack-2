local EVENT = {}

CreateConVar("randomat_infected_time", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time players must survive in seconds", 5, 180)

EVENT.Title = "Infected"
EVENT.Description = "Innocents and respawning Zombies, survive for " .. GetConVar("randomat_infected_time"):GetInt() .. " seconds!"
EVENT.id = "infected"

-- Used in removecorpse.
local function findcorpse(v)
    for _, ent in pairs(ents.FindByClass("prop_ragdoll")) do
        if ent.uqid == v:UniqueID() and IsValid(ent) then return ent or false end
    end
end

local function removecorpse(corpse)
    CORPSE.SetFound(corpse, false)

    if string.find(corpse:GetModel(), "zm_", 6, true) then
        player.GetByUniqueID(corpse.uqid):SetNWBool("body_found", false)
        corpse:Remove()
        SendFullStateUpdate()
    elseif corpse.player_ragdoll then
        player.GetByUniqueID(corpse.uqid):SetNWBool("body_found", false)
        corpse:Remove()
        SendFullStateUpdate()
    end
end

function EVENT:Begin()
    infectedRandomat = true
    Randomat:SilentTriggerEvent("grave", self.owner)

    if GetConVar("ttt_zombie_prime_only_weapons"):GetBool() then
        initialPrimeOnlyWeapons = true
    else
        initialPrimeOnlyWeapons = false
        GetConVar("ttt_zombie_prime_only_weapons"):SetBool(true)
    end

    SetGlobalFloat("ttt_round_end", CurTime() + GetConVar("randomat_infected_time"):GetInt())
    firstInfectedPlayer = table.Random(self.GetAlivePlayers())

    --firstInfectedPlayer = Entity(1)
    for i, ply in pairs(self.GetAlivePlayers()) do
        if ply == firstInfectedPlayer then
            self:StripRoleWeapons(ply)
            Randomat:SetRole(ply, ROLE_ZOMBIE)
            ply:SetNWBool("zombie_prime", true)
            ply:Give("weapon_ttt_knife_randomat")
        else
            self:StripRoleWeapons(ply)
            Randomat:SetRole(ply, ROLE_INNOCENT)
        end
    end

    SendFullStateUpdate()

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if ply:GetRole() == ROLE_ZOMBIE then
            ply:ConCommand("ttt_spectator_mode 0")

            timer.Create("respawndelay", 5, 0, function()
                local corpse = findcorpse(ply) -- run the normal respawn code now
                ply:SpawnForRound(true)
                ply:SetHealth(100)

                if corpse then
                    removecorpse(corpse)
                end

                SendFullStateUpdate()

                if ply:Alive() then
                    timer.Remove("respawndelay")

                    return
                end
            end)
        end
    end)

    infectedCount = 0

    self:AddHook("PlayerSpawn", function(ply)
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "weapon_ttt_knife_randomat" or ent:GetClass() == "ttt_knife_proj_randomat" then
                ent:Remove()
            end
        end

        infectedCount = 0

        for i, p in pairs(self.GetAlivePlayers()) do
            if p:GetRole() == ROLE_ZOMBIE then
                infectedCount = infectedCount + 1
            end
        end

        if ply:GetNWBool("zombie_prime") and infectedCount < 2 then
            timer.Simple(1, function()
                ply:Give("weapon_ttt_knife_randomat")
            end)
        end
    end)

    self:AddHook("Think", function()
        if infectedCount == 2 then
            for _, ent in pairs(ents.GetAll()) do
                if ent:GetClass() == "weapon_ttt_knife_randomat" or ent:GetClass() == "ttt_knife_proj_randomat" then
                    ent:Remove()
                end
            end
        end
    end)

    self:AddHook("TTTCheckForWin", function()
        local nowin1 = false
        local nowin2 = false

        for i, ply in pairs(player.GetAll()) do
            if ply:GetRole() == ROLE_INNOCENT then
                nowin1 = true
            end
        end

        if GetGlobalFloat("ttt_round_end") > CurTime() then
            nowin2 = true
        end

        if nowin1 and nowin2 then return WIN_NONE end
    end)
end

function EVENT:End()
    if infectedRandomat then
        GetConVar("ttt_zombie_prime_only_weapons"):SetBool(initialPrimeOnlyWeapons)
        infectedRandomat = false
    end
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in pairs({"time"}) do
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

function EVENT:Condition()
    local isZombie = false

    if isnumber(ROLE_ZOMBIE) and ROLE_ZOMBIE ~= -1 then
        isZombie = true
    end

    return isZombie
end

Randomat:register(EVENT)