local EVENT = {}
CreateConVar("randomat_mlg_strip", 1, FCVAR_NONE, "The event strips your other weapons", 0, 1)
CreateConVar("randomat_mlg_weaponid", "ttt_no_scope_awp", FCVAR_NONE, "Id of the weapon given")
EVENT.Title = "GET NO SCOPED!!!"
EVENT.Description = "Spin around to shoot!"
EVENT.id = "mlg"

EVENT.Type = {EVENT_TYPE_WEAPON_OVERRIDE}

EVENT.Categories = {"item", "rolechange", "largeimpact"}

util.AddNetworkString("RandomatMLGGunEffects")

function EVENT:HandleRoleWeapons(ply)
    ply.MLGTripleCount = 0
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
    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    local new_traitors = {}

    for _, v in ipairs(self:GetAlivePlayers()) do
        local _, new_traitor = self:HandleRoleWeapons(v)

        if new_traitor then
            table.insert(new_traitors, v)
        end
    end

    SendFullStateUpdate()
    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)
    table.Empty(new_traitors)

    timer.Create("MlgRoleChangeTimer", 1, 0, function()
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

    -- Continaully gives everyone AWPs
    self:AddHook("Think", function()
        local updated = false

        for i, ply in pairs(self:GetAlivePlayers()) do
            local activeWeapon = ply:GetActiveWeapon()

            if #ply:GetWeapons() ~= 1 or (IsValid(activeWeapon) and activeWeapon:GetClass() ~= GetConVar("randomat_mlg_weaponid"):GetString()) then
                if GetConVar("randomat_mlg_strip"):GetBool() then
                    ply:StripWeapons()
                    ply:SetFOV(0, 0.2)
                end

                local givenAWP = ply:Give(GetConVar("randomat_mlg_weaponid"):GetString())

                if givenAWP then
                    givenAWP.AllowDrop = false
                    givenAWP.airhornNoise = false
                    givenAWP.chargeSound = "mlg/silence.mp3"
                    givenAWP.chargeDownSound = "mlg/silence.mp3"
                    givenAWP.ahSound = "mlg/silence.mp3"
                end
            end

            if IsValid(activeWeapon) and activeWeapon:GetClass() == GetConVar("randomat_mlg_weaponid"):GetString() then
                activeWeapon:SetClip1(activeWeapon.Primary.ClipSize)
            end

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
            table.Empty(new_traitors)
        end
    end)

    -- Removes the hook that plays the normal airhorn sound from the MLG AWP, we want to play our own sounds below
    hook.Remove("DoPlayerDeath", "airhornTest")

    -- Players hear a random MLG-themed sound on killing someone
    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not IsValid(attacker) then return end
        local activeWeapon = attacker:GetActiveWeapon()

        if IsValid(activeWeapon) and activeWeapon:GetClass() == "ttt_no_scope_awp" then
            local mlgSound = "mlg/mlg" .. math.random(10) .. ".mp3"

            if not attacker.MLGTripleCount then
                attacker.MLGTripleCount = 1
            elseif attacker.MLGTripleCount == 3 then
                -- Always play the "Oh baby a triple!" sound on a player's third kill
                mlgSound = "mlg/triple.mp3"
            end

            attacker.MLGTripleCount = attacker.MLGTripleCount + 1
            attacker:EmitSound(mlgSound)
            ply:EmitSound(mlgSound)

            local plys = {ply, attacker}

            net.Start("RandomatMLGGunEffects")
            net.Send(plys)
        end
    end)

    -- Only allows players to pick up AWPs
    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not GetConVar("randomat_mlg_strip"):GetBool() then return end

        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_mlg_weaponid"):GetString()
    end)

    -- Prevents players from buying non-passive items
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
    timer.Remove("MlgRoleChangeTimer")

    for i, ent in ipairs(ents.FindByClass(GetConVar("randomat_mlg_weaponid"):GetString())) do
        ent:Remove()
    end

    if GetConVar("randomat_mlg_strip"):GetBool() then
        for i, ply in ipairs(self:GetAlivePlayers()) do
            ply:Give("weapon_zm_improvised")
            ply:Give("weapon_zm_carry")
            ply:Give("weapon_ttt_unarmed")
        end
    end
end

function EVENT:Condition()
    return weapons.Get(GetConVar("randomat_mlg_weaponid"):GetString()) ~= nil
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