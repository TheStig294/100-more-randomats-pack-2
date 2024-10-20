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

    -- Convert all zombie-like roles to innocents so we don't have to worry about fighting with special weapon replacement logic
    if Randomat:IsMeleeDamageRole(ply) then
        Randomat:SetRole(ply, ROLE_INNOCENT)
        ply:ChatPrint("Your role was incompatible with the \"" .. self.Title .. "\" randomat as was changed")
        self:StripRoleWeapons(ply)

        return true
    end
end

function EVENT:GiveJetgun(ply)
    for _, wep in ipairs(ply:GetWeapons()) do
        local class = WEPS.GetClass(wep)

        if class ~= "tfa_jetgun" and class ~= "weapon_ttt_unarmed" then
            wep:Remove()
        end
    end

    ply:Give("weapon_ttt_unarmed")
    ply:Give("tfa_jetgun").AllowDrop = false

    timer.Simple(0.1, function()
        ply:SelectWeapon("tfa_jetgun")
    end)
end

function EVENT:Begin()
    strip = GetConVar("randomat_jetgun_strip"):GetBool()

    if strip then
        self.Description = "Jetguns only!"
    else
        self.Description = "Jetguns for all!"
    end

    -- Removing role weapons and changing problematic roles to basic ones
    for _, v in ipairs(self:GetAlivePlayers()) do
        self:HandleRoleWeapons(v)
        self:GiveJetgun(v)
    end

    SendFullStateUpdate()

    timer.Create("jetgunRoleChangeTimer", 1, 0, function()
        local updated = false

        for _, ply in ipairs(self:GetAlivePlayers()) do
            -- Workaround the case where people can respawn as Zombies while this is running
            updatedPly, new_traitor = self:HandleRoleWeapons(ply)
            updated = updated or updatedPly
        end

        -- If anyone's role changed, send the update
        -- If anyone became a traitor, notify all other traitors
        if updated then
            SendFullStateUpdate()
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
        if not IsValid(wep) then return false end
        local class = WEPS.GetClass(wep)

        return class == "tfa_jetgun" or class == "weapon_ttt_unarmed"
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

    for _, ply in player.Iterator() do
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
        for _, ply in player.Iterator() do
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