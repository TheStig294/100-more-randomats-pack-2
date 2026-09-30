local EVENT = {}
EVENT.Title = "GET NO SCOPED!!!"
EVENT.Description = "Spin around to shoot!"
EVENT.id = "mlg"

EVENT.Type = {EVENT_TYPE_WEAPON_OVERRIDE}

EVENT.Categories = {"item", "rolechange", "largeimpact"}

local stripCvar = CreateConVar("randomat_mlg_strip", 1, FCVAR_NONE, "The event strips your other weapons", 0, 1)
local weaponidCvar = CreateConVar("randomat_mlg_weaponid", "ttt_no_scope_awp", FCVAR_NONE, "Id of the weapon given")
util.AddNetworkString("RandomatMLGGunEffects")

function EVENT:Begin()
    -- Convert all bad guys to traitors so we don't have to worry about fighting with special weapon replacement logic
    local _, _, new_traitors = Randomat:BalanceTeams()
    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    -- Continually gives everyone AWPs
    self:AddHook("PlayerPostThink", function(ply)
        if not ply:Alive() or ply:IsSpec() then return end
        local activeWeapon = ply:GetActiveWeapon()

        if #ply:GetWeapons() ~= 1 or (IsValid(activeWeapon) and activeWeapon:GetClass() ~= weaponidCvar:GetString()) then
            if stripCvar:GetBool() then
                ply:StripWeapons()
                ply:SetFOV(0, 0.2)
            end

            local givenAWP = ply:Give(weaponidCvar:GetString())

            if givenAWP then
                givenAWP.AllowDrop = false
                givenAWP.airhornNoise = false
                givenAWP.chargeSound = "mlg/silence.mp3"
                givenAWP.chargeDownSound = "mlg/silence.mp3"
                givenAWP.ahSound = "mlg/silence.mp3"
            end
        end

        if IsValid(activeWeapon) and activeWeapon:GetClass() == weaponidCvar:GetString() then
            activeWeapon:SetClip1(activeWeapon.Primary.ClipSize)
        end
    end)

    -- Removes the hook that plays the normal airhorn sound from the MLG AWP, we want to play our own sounds below
    hook.Remove("DoPlayerDeath", "airhornTest")

    -- Players hear a random MLG-themed sound on killing someone
    self:AddHook("DoPlayerDeath", function(ply, attacker)
        if not IsValid(attacker) or not attacker:IsPlayer() then return end
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
    self:AddHook("PlayerCanPickupWeapon", function(_, wep)
        if not stripCvar:GetBool() then return end

        return IsValid(wep) and WEPS.GetClass(wep) == weaponidCvar:GetString()
    end)

    -- Prevents players from buying non-passive items
    self:AddHook("TTTCanOrderEquipment", function(ply, _, is_item)
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

    for _, ent in ipairs(ents.FindByClass(weaponidCvar:GetString())) do
        ent:Remove()
    end

    if stripCvar:GetBool() then
        for _, ply in player.Iterator() do
            if not ply:Alive() or ply:IsSpec() then continue end
            ply:Give("weapon_zm_improvised")
            ply:Give("weapon_zm_carry")
            ply:Give("weapon_ttt_unarmed")
        end
    end
end

function EVENT:Condition()
    -- Do not trigger passive item only events when there is a Faker
    for _, ply in player.Iterator() do
        if ply.IsFaker and ply:IsFaker() then return false end
    end

    return weapons.Get(weaponidCvar:GetString()) ~= nil
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