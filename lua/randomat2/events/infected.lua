local EVENT = {}
CreateConVar("randomat_infected_timer", 90, FCVAR_NONE, "Time players must survive in seconds", 30, 180)
EVENT.Title = "Infected"
EVENT.Description = "Innocents and respawning zombies, survive for " .. GetConVar("randomat_infected_timer"):GetInt() .. " seconds!"
EVENT.id = "infected"

EVENT.Type = {EVENT_TYPE_WEAPON_OVERRIDE, EVENT_TYPE_RESPAWN, EVENT_TYPE_FORCED_DEATH}

EVENT.Categories = {"gamemode", "rolechange", "largeimpact", "deathtrigger"}

local infectedRandomat = false
local initialPrimeOnlyWeapons = true
local hasteMode = false
local hasteMinutes = 0.5
local zombieBlockWin

-- Used in removecorpse.
local function findcorpse(v)
    for _, ent in pairs(ents.FindByClass("prop_ragdoll")) do
        if ent.uqid == v:UniqueID() and IsValid(ent) then return ent or false end
    end
end

-- Removes a zombie's corpse when they respawn
local function removecorpse(corpse)
    CORPSE.SetFound(corpse, false)

    if string.find(corpse:GetModel(), "zm_", 6, true) or corpse.player_ragdoll then
        player.GetByUniqueID(corpse.uqid):SetNWBool("body_found", false)
        corpse:Remove()
    end
end

function EVENT:Begin()
    self.Description = "Innocents and respawning Zombies, survive for " .. GetConVar("randomat_infected_timer"):GetInt() .. " seconds!"
    -- Let the end function know the begin function has run
    infectedRandomat = true
    hasteMode = GetConVar("ttt_haste"):GetBool()
    hasteMinutes = GetConVar("ttt_haste_minutes_per_death"):GetFloat()

    -- Prevent the round from being blocked from ending while zombies are dead and respawning
    if ConVarExists("ttt_zombie_respawn_block_win") then
        zombieBlockWin = GetConVar("ttt_zombie_respawn_block_win"):GetBool()
        GetConVar("ttt_zombie_respawn_block_win"):SetBool(false)
    end

    -- Set the round length to what it is in the convar
    if hasteMode then
        GetConVar("ttt_haste"):SetBool(false)
        GetConVar("ttt_haste_minutes_per_death"):SetFloat(0)
        SetGlobalFloat("ttt_haste_end", CurTime() + GetConVar("randomat_infected_timer"):GetInt())
        SetGlobalFloat("ttt_round_end", CurTime() + GetConVar("randomat_infected_timer"):GetInt())
    else
        SetGlobalFloat("ttt_round_end", CurTime() + GetConVar("randomat_infected_timer"):GetInt())
    end

    -- Let the zombie prime use weapons other than the claws so the throwing knife can be used
    if GetConVar("ttt_zombie_prime_only_weapons"):GetBool() then
        initialPrimeOnlyWeapons = true
    else
        initialPrimeOnlyWeapons = false
        GetConVar("ttt_zombie_prime_only_weapons"):SetBool(true)
    end

    -- For all alive players,
    local alivePlys = self:GetAlivePlayers(true)
    local firstInfectedPlayer = alivePlys[1]

    for i, ply in pairs(alivePlys) do
        -- Set the chosen player to be the first zombie,
        if ply == firstInfectedPlayer then
            self:StripRoleWeapons(ply)
            Randomat:SetRole(ply, ROLE_ZOMBIE)
            -- And set them to be the zombie prime so they can be given the throwing knife
            ply:SetNWBool("zombie_prime", true)
            ply:Give("weapon_ttt_knife_randomat")
        else
            -- Else, set everyone else to be innocent
            self:StripRoleWeapons(ply)
            Randomat:SetRole(ply, ROLE_INNOCENT)
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()

    -- Respawns any zombies that die after a 5 second delay
    self:AddHook("PostPlayerDeath", function(ply)
        -- Let Custom Roles know someone is respawning as a zombie for any special role logic it needs to do
        ply:SetNWBool("IsZombifying", true)

        timer.Simple(5, function()
            local corpse = findcorpse(ply) -- run the normal respawn code now
            ply:SpawnForRound(true)
            ply:SetHealth(100)

            if corpse then
                removecorpse(corpse)
            end

            if ply:GetRole() ~= ROLE_ZOMBIE then
                Randomat:SetRole(ply, ROLE_ZOMBIE)
                SendFullStateUpdate()
            end

            ply:SetNWBool("IsZombifying", false)
        end)
    end)

    local infectedCount = 0

    -- Whenever a player spawns,
    self:AddHook("PlayerSpawn", function(ply)
        -- Remove the knife if it was thorwn on the ground or picked up by a player,
        for _, ent in pairs(ents.GetAll()) do
            if ent:GetClass() == "weapon_ttt_knife_randomat" or ent:GetClass() == "ttt_knife_proj_randomat" then
                ent:Remove()
            end
        end

        infectedCount = 0

        -- Count the number of zombies,
        for i, p in pairs(self:GetAlivePlayers()) do
            if p:GetRole() == ROLE_ZOMBIE then
                infectedCount = infectedCount + 1
            end
        end

        -- And if only the zombie prime is alive, give them the throwing knife again
        if ply:GetNWBool("zombie_prime") and infectedCount < 2 then
            timer.Simple(1, function()
                ply:Give("weapon_ttt_knife_randomat")
            end)
        end
    end)

    -- Remove the throwing knife from everyone once there are 2 zombies
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

        -- If there is at least one innocent alive,
        for i, ply in pairs(player.GetAll()) do
            if ply:GetRole() == ROLE_INNOCENT and ply:Alive() and not ply:IsSpec() then
                nowin1 = true
            end
        end

        -- Or the round time hasn't run out yet,
        if GetGlobalFloat("ttt_round_end") > CurTime() then
            nowin2 = true
        end

        -- Prevent the round from ending
        if nowin1 and nowin2 then return WIN_NONE end
    end)
end

function EVENT:End()
    -- If the begin function has run, set the zombie prime weapons setting to what it was,
    if infectedRandomat then
        GetConVar("ttt_zombie_prime_only_weapons"):SetBool(initialPrimeOnlyWeapons)

        if hasteMode then
            GetConVar("ttt_haste"):SetBool(true)
            GetConVar("ttt_haste_minutes_per_death"):SetFloat(hasteMinutes)
        end

        if zombieBlockWin ~= nil then
            GetConVar("ttt_zombie_respawn_block_win"):SetBool(zombieBlockWin)
        end

        -- And prevent the end function from being run until this randomat triggers again
        infectedRandomat = false
    end
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in pairs({"timer"}) do
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

-- Check if the zombie exists
function EVENT:Condition()
    return Randomat:CanRoleSpawn(ROLE_ZOMBIE)
end

Randomat:register(EVENT)