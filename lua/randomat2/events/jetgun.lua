local EVENT = {}

CreateConVar("randomat_jetgun_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons", 0, 1)

CreateConVar("randomat_jetgun_timer", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds between being given a new jet gun", 0, 30)

EVENT.Title = "Suck it!"
EVENT.Description = "Jetguns only!"
EVENT.id = "jetgun"

EVENT.Categories = {"item", "largeimpact"}

if GetConVar("randomat_jetgun_strip"):GetBool() then
    EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
end

function EVENT:HandleRoleWeapons(ply)
    local updated = false

    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if (Randomat:IsTraitorTeam(ply) and ply:GetRole() ~= ROLE_TRAITOR) or Randomat:IsMonsterTeam(ply) or Randomat:IsIndependentTeam(ply) then
        Randomat:SetRole(ply, ROLE_TRAITOR)
        updated = true
    end

    -- Remove role weapons from anyone on the traitor team now
    if Randomat:IsTraitorTeam(ply) then
        self:StripRoleWeapons(ply)
    end

    return updated
end

function EVENT:GiveJetgun(ply)
    local activeWeapon = ply:GetActiveWeapon()

    if #ply:GetWeapons() ~= 1 or (IsValid(activeWeapon) and activeWeapon:GetClass() ~= "tfa_jetgun") then
        if GetConVar("randomat_jetgun_strip"):GetBool() then
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
    -- Removing role weapons and changing problematic roles to basic ones
    for _, ply in ipairs(self:GetAlivePlayers()) do
        self:HandleRoleWeapons(ply)
        self:GiveJetgun(ply)
    end

    SendFullStateUpdate()

    timer.Create("jetgunRoleChangeTimer", 1, 0, function()
        local updated = false

        for _, ply in ipairs(self:GetAlivePlayers()) do
            -- Workaround the case where people can respawn as Zombies while this is running
            updated = updated or self:HandleRoleWeapons(ply)
        end

        -- If anyone's role changed, send the update
        if updated then
            SendFullStateUpdate()
        end
    end)

    self:AddHook("PlayerDroppedWeapon", function(owner, wep)
        if wep:GetClass() == "tfa_jetgun" then
            owner:PrintMessage(HUD_PRINTCENTER, "Overheated! New gun in " .. GetConVar("randomat_jetgun_timer") .. " seconds...")
            owner:PrintMessage(HUD_PRINTTALK, "Overheated! New gun in " .. GetConVar("randomat_jetgun_timer") .. " seconds...")

            timer.Create(owner:SteamID64() .. "RandomatGiveJetgunTimer", GetConVar("randomat_jetgun_timer"):GetInt(), 1, function()
                self:GiveJetgun(owner)
            end)
        end
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not GetConVar("randomat_jetgun_strip"):GetBool() then return end

        return IsValid(wep) and WEPS.GetClass(wep) == "tfa_jetgun"
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end

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
    timer.Remove("jetgunGiveWeaponsTimer")

    for i, ent in ipairs(ents.FindByClass("tfa_jetgun")) do
        ent:Remove()
    end

    if GetConVar("randomat_jetgun_strip"):GetBool() then
        for i, ply in ipairs(self:GetAlivePlayers()) do
            ply:Give("weapon_zm_improvised")
            ply:Give("weapon_zm_carry")
            ply:Give("weapon_ttt_unarmed")
        end
    end
end

function EVENT:Condition()
    return weapons.Get("tfa_jetgun") ~= nil
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"timer"}) do
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