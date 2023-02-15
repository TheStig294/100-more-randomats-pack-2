local EVENT = {}

local strip = CreateConVar("randomat_rdm_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")

CreateConVar("randomat_rdm_weaponid", "weapon_rp_railgun", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")

EVENT.Title = "Random Deathmatch"
EVENT.Description = "Infinite free kill guns only!"
EVENT.id = "rdm"

EVENT.Categories = {"item", "biased_innocent", "biased", "largeimpact"}

strip = strip:GetBool()

if strip then
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

function EVENT:Begin()
    strip = GetConVar("randomat_rdm_strip"):GetBool()
    local new_traitors = {}

    for _, v in ipairs(self:GetAlivePlayers()) do
        local _, new_traitor = self:HandleRoleWeapons(v)

        if new_traitor then
            table.insert(new_traitors, v)
        end
    end

    SendFullStateUpdate()
    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    timer.Create("RDMRoleChangeTimer", 1, 0, function()
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

    -- Continaully gives everyone Free Kill Guns
    self:AddHook("Think", function()
        for i, ply in pairs(self:GetAlivePlayers()) do
            local activeWeapon = ply:GetActiveWeapon()

            if #ply:GetWeapons() ~= 1 or (IsValid(activeWeapon) and activeWeapon:GetClass() ~= GetConVar("randomat_rdm_weaponid"):GetString()) then
                if strip then
                    ply:StripWeapons()
                    ply:SetFOV(0, 0.2)
                end

                local givenFKG = ply:Give(GetConVar("randomat_rdm_weaponid"):GetString())

                if givenFKG then
                    givenFKG.AllowDrop = false
                end
            end

            if IsValid(activeWeapon) and activeWeapon:GetClass() == GetConVar("randomat_rdm_weaponid"):GetString() then
                activeWeapon:SetClip1(activeWeapon.Primary.ClipSize)
            end
        end
    end)

    -- Only allows players to pick up Free Kill Guns
    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not strip then return end

        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_rdm_weaponid"):GetString()
    end)

    -- Prevents players from buying non-passive items
    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not strip or not IsValid(ply) then return end

        if not is_item then
            ply:PrintMessage(HUD_PRINTCENTER, "Passive items only!")
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'\nYour purchase has been refunded.")

            return false
        end
    end)
end

function EVENT:End()
    timer.Remove("RDMRoleChangeTimer")

    for i, ent in ipairs(ents.FindByClass(GetConVar("randomat_rdm_weaponid"):GetString())) do
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
    return weapons.Get(GetConVar("randomat_rdm_weaponid"):GetString()) ~= nil
end

function EVENT:GetConVars()
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

    local textboxes = {}

    for _, v in ipairs({"weaponid"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(textboxes, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return {}, checks, textboxes
end

Randomat:register(EVENT)