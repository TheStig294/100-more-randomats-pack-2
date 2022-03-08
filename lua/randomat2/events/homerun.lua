local EVENT = {}

CreateConVar("randomat_homerun_strip", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")

CreateConVar("randomat_homerun_weaponid", "weapon_ttt_homebat", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")

EVENT.Title = "Home Run!"
EVENT.Description = "Homerun bats only!"
EVENT.id = "homerun"

EVENT.Categories = {"item", "biased_innocent", "biased", "largeimpact"}

if GetConVar("randomat_homerun_strip"):GetBool() then
    EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
end

function EVENT:HandleRoleWeapons(ply)
    local updated = false

    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    if (Randomat:IsTraitorTeam(ply) and ply:GetRole() ~= ROLE_TRAITOR) or Randomat:IsMonsterTeam(ply) or Randomat:IsIndependentTeam(ply) then
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

    return updated
end

function EVENT:Begin()
    -- Removing role weapons and changing problematic roles to basic ones
    for _, ply in ipairs(self:GetAlivePlayers()) do
        self:HandleRoleWeapons(ply)
    end

    SendFullStateUpdate()

    timer.Create("HomerunRoleChangeTimer", 1, 0, function()
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

    self:AddHook("Think", function()
        for i, ply in pairs(self:GetAlivePlayers()) do
            local activeWeapon = ply:GetActiveWeapon()

            if #ply:GetWeapons() ~= 1 or (IsValid(activeWeapon) and activeWeapon:GetClass() ~= GetConVar("randomat_homerun_weaponid"):GetString()) then
                if GetConVar("randomat_homerun_strip"):GetBool() then
                    ply:StripWeapons()
                    ply:SetFOV(0, 0.2)
                end

                local givenBat = ply:Give(GetConVar("randomat_homerun_weaponid"):GetString())

                if givenBat then
                    givenBat.AllowDrop = false
                end
            end

            if IsValid(activeWeapon) and activeWeapon:GetClass() == GetConVar("randomat_homerun_weaponid"):GetString() then
                activeWeapon:SetClip1(activeWeapon.Primary.ClipSize)
            end
        end
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not GetConVar("randomat_homerun_strip"):GetBool() then return end

        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_homerun_weaponid"):GetString()
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not IsValid(ply) then return end

        if not is_item then
            ply:PrintMessage(HUD_PRINTCENTER, "Passive items only!")
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'\nYour purchase has been refunded.")

            return false
        end
    end)
end

function EVENT:End()
    timer.Remove("HomerunRoleChangeTimer")

    for i, ent in ipairs(ents.FindByClass(GetConVar("randomat_homerun_weaponid"):GetString())) do
        ent:Remove()
    end

    if GetConVar("randomat_homerun_strip"):GetBool() then
        for i, ply in ipairs(self:GetAlivePlayers()) do
            ply:Give("weapon_zm_improvised")
            ply:Give("weapon_zm_carry")
            ply:Give("weapon_ttt_unarmed")
        end
    end
end

function EVENT:Condition()
    return weapons.Get(GetConVar("randomat_homerun_weaponid"):GetString()) ~= nil
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

    return sliders, checks, textboxes
end

Randomat:register(EVENT)