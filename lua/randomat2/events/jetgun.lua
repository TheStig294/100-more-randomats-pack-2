local EVENT = {}

local strip = CreateConVar("randomat_jetgun_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons", 0, 1)

CreateConVar("randomat_jetgun_overheat_delay", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds until given a new jetgun after overheating", 1, 30)

EVENT.Title = "Suck it!"
EVENT.Description = "Jetguns for all!"
EVENT.id = "jetgun"

EVENT.Categories = {"item", "largeimpact"}

strip = strip:GetBool()

if strip then
    EVENT.Description = "Jetguns only!"
    EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
    table.insert(EVENT.Categories, "rolechange")
end

function EVENT:HandleRoleWeapons(ply)
    if not strip then return end
    local updated = false
    local changing_teams = Randomat:IsMonsterTeam(ply) or Randomat:IsIndependentTeam(ply)

    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if (Randomat:IsTraitorTeam(ply) and ply:GetRole() ~= ROLE_TRAITOR) or changing_teams then
        Randomat:SetRole(ply, ROLE_TRAITOR)
        updated = true
    elseif Randomat:IsJesterTeam(ply) then
        Randomat:SetRole(ply, ROLE_INNOCENT)
        updated = true
    end

    -- Remove role weapons from anyone on the traitor team now
    if Randomat:IsTraitorTeam(ply) then
        self:StripRoleWeapons(ply)
    end

    return updated, changing_teams
end

function EVENT:GiveJetgun(ply)
    local activeWeapon = ply:GetActiveWeapon()

    if #ply:GetWeapons() ~= 1 or (IsValid(activeWeapon) and activeWeapon:GetClass() ~= "tfa_jetgun") then
        if strip then
            ply:StripWeapons()
            ply:SetFOV(0, 0.2)
        end

        local wep = ply:Give("tfa_jetgun")

        if wep then
            wep.AllowDrop = false
        end
    end
end

function EVENT:Begin()
    strip = GetConVar("randomat_jetgun_strip"):GetBool()

    if strip then
        self.Description = "Jetguns only!"
    else
        self.Description = "Jetguns for all!"
    end

    -- Removing role weapons and changing problematic roles to basic ones
    local new_traitors = {}

    for _, v in ipairs(self:GetAlivePlayers()) do
        local _, new_traitor = self:HandleRoleWeapons(v)

        if new_traitor then
            table.insert(new_traitors, v)
        end

        self:GiveJetgun(v)
    end

    SendFullStateUpdate()
    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    timer.Create("jetgunRoleChangeTimer", 1, 0, function()
        local updated = false
        new_traitors = {}

        for _, ply in ipairs(self:GetAlivePlayers()) do
            -- Workaround the case where people can respawn as Zombies while this is running
            updatedPly, new_traitor = self:HandleRoleWeapons(ply)
            updated = updated or updatedPly

            if new_traitor then
                table.insert(new_traitors, ply)
            end
        end

        -- If anyone's role changed, send the update
        -- If anyone became a traitor, notify all other traitors
        if updated then
            SendFullStateUpdate()
            self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)
        end
    end)

    self:AddHook("PlayerDroppedWeapon", function(owner, wep)
        if not owner:Alive() or owner:IsSpec() then return end

        if wep:GetClass() == "tfa_jetgun" then
            -- If the player was forced to drop the jetgun before overheating, give them a new one
            if owner:GetAmmoCount("ammo_coolant") > 0 then
                timer.Simple(0.1, function()
                    self:GiveJetgun(owner)
                end)

                return
            end

            -- Else, give them back a jetgun after a delay
            timer.Create(owner:SteamID64() .. "RandomatGiveJetgunTimer", 1, GetConVar("randomat_jetgun_overheat_delay"):GetInt(), function()
                if not IsPlayer(owner) then
                    timer.Remove(owner:SteamID64() .. "RandomatGiveJetgunTimer")

                    return
                end

                if timer.RepsLeft(owner:SteamID64() .. "RandomatGiveJetgunTimer") == 0 then
                    self:GiveJetgun(owner)
                else
                    owner:PrintMessage(HUD_PRINTCENTER, "Overheated! New jetgun in " .. timer.RepsLeft(owner:SteamID64() .. "RandomatGiveJetgunTimer") .. " seconds...")
                end
            end)
        end
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not strip then return end

        return IsValid(wep) and WEPS.GetClass(wep) == "tfa_jetgun"
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not strip or not IsValid(ply) then return end

        if not is_item then
            ply:PrintMessage(HUD_PRINTCENTER, "Passive items only!")
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'\nYour purchase has been refunded.")

            return false
        end
    end)

    self:AddHook("PlayerSpawn", function(ply)
        timer.Simple(1, function()
            self:GiveJetgun(ply)
        end)
    end)
end

function EVENT:End()
    timer.Remove("jetgunRoleChangeTimer")

    for _, ply in ipairs(player.GetAll()) do
        timer.Remove(ply:SteamID64() .. "RandomatGiveJetgunTimer")
    end

    for i, ent in ipairs(ents.FindByClass("tfa_jetgun")) do
        ent:Remove()
    end

    if strip then
        for i, ply in ipairs(self:GetAlivePlayers()) do
            ply:Give("weapon_zm_improvised")
            ply:Give("weapon_zm_carry")
            ply:Give("weapon_ttt_unarmed")
        end
    end
end

function EVENT:Condition()
    -- Prevent this event from running while there is a phantom and phantom haunting is turned on
    if ConVarExists("ttt_phantom_killer_haunt") and GetConVar("ttt_phantom_killer_haunt"):GetBool() then
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetRole() == ROLE_PHANTOM then return false end
        end
    end

    return weapons.Get("tfa_jetgun") ~= nil and not Randomat:IsEventActive("elevator")
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"overheat_delay"}) do
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

    for _, v in ipairs({"strip"}) do
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