local EVENT = {}
local strip = CreateConVar("randomat_homerun_strip", 1, FCVAR_ARCHIVE, "The event strips your other weapons")
CreateConVar("randomat_homerun_weaponid", "weapon_ttt_homebat", FCVAR_ARCHIVE, "Id of the weapon given")
EVENT.Title = "Home Run!"
EVENT.Description = "Homerun bats only!"
EVENT.id = "homerun"

EVENT.Categories = {"item", "biased_innocent", "biased", "largeimpact"}

local catModel1 = "models/Luria/Night_in_the_Woods/Playermodels/Mae.mdl"
local catModel2 = "models/Luria/Night_in_the_Woods/Playermodels/Mae_Astral.mdl"
local catModelInstalled = util.IsValidModel(catModel1) and util.IsValidModel(catModel2)

if catModelInstalled then
    EVENT.Title = "Cat with a bat!"
    EVENT.Description = "Everyone's a cat, with only a bat!"
    table.insert(EVENT.Categories, "modelchange")
end

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
    strip = GetConVar("randomat_homerun_strip"):GetBool()
    local new_traitors = {}

    for _, v in ipairs(self:GetAlivePlayers()) do
        local _, new_traitor = self:HandleRoleWeapons(v)

        if new_traitor then
            table.insert(new_traitors, v)
        end
    end

    SendFullStateUpdate()
    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    timer.Create("HomerunRoleChangeTimer", 1, 0, function()
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

    -- Continaully gives everyone bats
    self:AddHook("Think", function()
        for i, ply in pairs(self:GetAlivePlayers()) do
            local activeWeapon = ply:GetActiveWeapon()

            if #ply:GetWeapons() ~= 1 or (IsValid(activeWeapon) and activeWeapon:GetClass() ~= GetConVar("randomat_homerun_weaponid"):GetString()) then
                if strip then
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

    -- Only allows players to pick up bats
    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not strip then return end

        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_homerun_weaponid"):GetString()
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

    -- Gives everyone a cat playermodel if installed
    if catModelInstalled then
        local catModelOffset = Vector(0, 0, 40)
        local catModelOffsetDucked = Vector(0, 0, 28)
        local playerModelSets = {}

        local catEyesClosed = {
            model = catModel1,
            viewOffset = catModelOffset,
            viewOffsetDucked = catModelOffsetDucked,
            bodygroupValues = {
                [0] = 0,
                [1] = 14,
                [2] = 14,
                [3] = 1,
                [4] = 1
            }
        }

        table.insert(playerModelSets, catEyesClosed)

        local catAngryEyes = {
            model = catModel1,
            viewOffset = catModelOffset,
            viewOffsetDucked = catModelOffsetDucked,
            bodygroupValues = {
                [0] = 0,
                [1] = 12,
                [2] = 12,
                [3] = 0,
                [4] = 0
            }
        }

        table.insert(playerModelSets, catAngryEyes)

        local catWeirdEyes = {
            model = catModel1,
            viewOffset = catModelOffset,
            viewOffsetDucked = catModelOffsetDucked,
            bodygroupValues = {
                [0] = 0,
                [1] = 6,
                [2] = 11,
                [3] = 4,
                [4] = 1,
                [5] = 1
            }
        }

        table.insert(playerModelSets, catWeirdEyes)

        local ogBlueCat = {
            model = catModel2,
            viewOffset = catModelOffset,
            viewOffsetDucked = catModelOffsetDucked,
            bodygroupValues = {
                [0] = 0
            }
        }

        table.insert(playerModelSets, ogBlueCat)

        local blueCatWeirdEyes = {
            model = catModel2,
            viewOffset = catModelOffset,
            viewOffsetDucked = catModelOffsetDucked,
            bodygroupValues = {
                [0] = 0,
                [1] = 10,
                [2] = 4,
                [3] = 3,
                [4] = 0,
                [5] = 1
            }
        }

        table.insert(playerModelSets, blueCatWeirdEyes)

        local blueCatClosedEyes = {
            model = catModel2,
            viewOffset = catModelOffset,
            viewOffsetDucked = catModelOffsetDucked,
            bodygroupValues = {
                [0] = 0,
                [1] = 14,
                [2] = 14,
                [3] = 3,
                [4] = 1,
                [5] = 1
            }
        }

        table.insert(playerModelSets, blueCatClosedEyes)

        -- The original meowscles playermodel can also be given, if it's installed as well
        if util.IsValidModel("models/konnie/asapgaming/meowscles.mdl") then
            local meowscles = {
                model = "models/konnie/asapgaming/meowscles.mdl"
            }

            table.insert(playerModelSets, meowscles)
        end

        -- Also a garfield playermodel can be given as well...
        if util.IsValidModel("models/player/garfield/buff_garfield.mdl") then
            local garfield = {
                model = "models/player/garfield/buff_garfield.mdl"
            }

            table.insert(playerModelSets, garfield)
        end

        -- Randomly assign unique playermodels to everyone
        local remainingPlayermodels = {}
        local chosenPlayermodels = {}
        table.Add(remainingPlayermodels, playerModelSets)

        for _, ply in ipairs(self:GetAlivePlayers()) do
            -- But if all playermodels have been used, reset the pool of playermodels
            if table.IsEmpty(remainingPlayermodels) then
                table.Add(remainingPlayermodels, playerModelSets)
            end

            local modelData = remainingPlayermodels[math.random(#remainingPlayermodels)]
            Randomat:ForceSetPlayermodel(ply, modelData)
            -- Remove the selected model from the pool
            table.RemoveByValue(remainingPlayermodels, modelData)
            -- Keep track of who got what model so it can be set when they respawn
            chosenPlayermodels[ply] = modelData
        end

        -- Sets someone's playermodel again when respawning,
        -- if they weren't in the round when the event triggered, set their chosen model to a random one
        self:AddHook("PlayerSpawn", function(ply)
            if not chosenPlayermodels[ply] then
                chosenPlayermodels[ply] = playerModelSets[math.random(#playerModelSets)]
            end

            timer.Simple(1, function()
                Randomat:ForceSetPlayermodel(ply, chosenPlayermodels[ply])
            end)
        end)
    end
end

function EVENT:End()
    timer.Remove("HomerunRoleChangeTimer")

    for i, ent in ipairs(ents.FindByClass(GetConVar("randomat_homerun_weaponid"):GetString())) do
        ent:Remove()
    end

    if strip then
        for i, ply in ipairs(self:GetAlivePlayers()) do
            ply:Give("weapon_zm_improvised")
            ply:Give("weapon_zm_carry")
            ply:Give("weapon_ttt_unarmed")
        end
    end

    if catModelInstalled then
        Randomat:ForceResetAllPlayermodels()
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

    return {}, checks, textboxes
end

Randomat:register(EVENT)