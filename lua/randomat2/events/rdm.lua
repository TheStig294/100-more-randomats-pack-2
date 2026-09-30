local EVENT = {}
EVENT.Title = "Random Deathmatch"
EVENT.Description = "Infinite free kill guns only!"
EVENT.id = "rdm"

EVENT.Categories = {"item", "biased_innocent", "biased", "largeimpact"}

local stripCvar = CreateConVar("randomat_rdm_strip", 1, FCVAR_NONE, "The event strips your other weapons")
local weaponidCvar = CreateConVar("randomat_rdm_weaponid", "weapon_rp_railgun", FCVAR_NONE, "Id of the weapon given")
local strip = stripCvar:GetBool()

if strip then
    EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
    table.insert(EVENT.Categories, "rolechange")
end

function EVENT:Begin()
    strip = stripCvar:GetBool()
    local _, _, new_traitors = Randomat:BalanceTeams()
    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    -- Continually gives everyone Free Kill Guns
    self:AddHook("PlayerPostThink", function(ply)
        if not ply:Alive() or ply:IsSpec() then return end
        local activeWeapon = ply:GetActiveWeapon()

        if #ply:GetWeapons() ~= 1 or (IsValid(activeWeapon) and activeWeapon:GetClass() ~= weaponidCvar:GetString()) then
            if strip then
                ply:StripWeapons()
                ply:SetFOV(0, 0.2)
            end

            local givenFKG = ply:Give(weaponidCvar:GetString())

            if givenFKG then
                givenFKG.AllowDrop = false
            end
        end

        if IsValid(activeWeapon) and activeWeapon:GetClass() == weaponidCvar:GetString() then
            activeWeapon:SetClip1(activeWeapon.Primary.ClipSize)
        end
    end)

    -- Only allows players to pick up Free Kill Guns
    self:AddHook("PlayerCanPickupWeapon", function(_, wep)
        if not strip then return end

        return IsValid(wep) and WEPS.GetClass(wep) == weaponidCvar:GetString()
    end)

    -- Prevents players from buying non-passive items
    self:AddHook("TTTCanOrderEquipment", function(ply, _, is_item)
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

    for _, ent in ipairs(ents.FindByClass(weaponidCvar:GetString())) do
        ent:Remove()
    end

    if strip then
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

    return {}, checks, textboxes
end

Randomat:register(EVENT)