local EVENT = {}
CreateConVar("randomat_donconnons_timer", 5, FCVAR_NONE, "Time between being given donconnons")
local strip = CreateConVar("randomat_donconnons_strip", 0, FCVAR_NONE, "The event strips your other weapons")
CreateConVar("randomat_donconnons_weaponid", "weapon_ttt_donconnon_randomat", FCVAR_NONE, "Id of the weapon given")
CreateConVar("randomat_donconnons_damage", "1000", FCVAR_NONE, "Donconnon Damage", 0, 1000)
CreateConVar("randomat_donconnons_speed", "350", FCVAR_NONE, "Donconnon Speed", 0, 1000)
CreateConVar("randomat_donconnons_range", "2000", FCVAR_NONE, "Donconnon Range", 0, 10000)
CreateConVar("randomat_donconnons_scale", "0.2", FCVAR_NONE, "Donconnon Size", 0, 5)
CreateConVar("randomat_donconnons_turn", "0", FCVAR_NONE, "Donconnon Turn Speed, set to 0 to disable homing", 0, 0.001)
CreateConVar("randomat_donconnons_lockondecaytime", "15", FCVAR_NONE, "Seconds until homing stops", 0, 60)
EVENT.Title = "O Rubber Tree..."
EVENT.Description = "Donconnons for all!"
EVENT.id = "donconnons"

EVENT.Categories = {"item", "largeimpact"}

local donconModel = "models/player/Doncon/doncon.mdl"
local donconModelInstalled = util.IsValidModel(donconModel)

if donconModelInstalled then
    EVENT.Description = "Everyone's Doncon. Donconnons for all!"
    table.insert(EVENT.Categories, 1, "modelchange")
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
    if updated then
        self:StripRoleWeapons(ply)
    end

    return updated, changing_teams
end

function EVENT:Begin()
    strip = GetConVar("randomat_donconnons_strip"):GetBool()
    local new_traitors = {}

    for _, v in ipairs(self:GetAlivePlayers()) do
        local _, new_traitor = self:HandleRoleWeapons(v)

        if new_traitor then
            table.insert(new_traitors, v)
        end
    end

    SendFullStateUpdate()
    self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)

    -- Periodically gives everyone donconnons
    timer.Create("RandomatDonconnonsTimer", GetConVar("randomat_donconnons_timer"):GetInt(), 0, function()
        local weaponid = GetConVar("randomat_donconnons_weaponid"):GetString()
        local updated = false
        new_traitors = {}

        for _, ply in ipairs(self:GetAlivePlayers()) do
            if strip then
                for _, wep in ipairs(ply:GetWeapons()) do
                    local weaponclass = WEPS.GetClass(wep)

                    if weaponclass ~= weaponid then
                        ply:StripWeapon(weaponclass)
                    end
                end

                -- Reset FOV to unscope
                ply:SetFOV(0, 0.2)
            end

            if not ply:HasWeapon(weaponid) then
                ply:Give(weaponid)
            end

            -- Workaround the case where people can respawn as Zombies while this is running
            updatedPly, new_traitor = self:HandleRoleWeapons(ply)
            updated = updated or updatedPly

            if new_traitor then
                table.insert(new_traitors, ply)
            end
        end

        -- If anyone's role changed, update each client
        -- If anyone became a traitor, notify all other traitors
        if updated then
            SendFullStateUpdate()
            self:NotifyTeamChange(new_traitors, ROLE_TEAM_TRAITOR)
        end
    end)

    self:AddHook("PlayerCanPickupWeapon", function(ply, wep)
        if not strip then return end

        return IsValid(wep) and WEPS.GetClass(wep) == GetConVar("randomat_donconnons_weaponid"):GetString()
    end)

    self:AddHook("TTTCanOrderEquipment", function(ply, id, is_item)
        if not strip or not IsValid(ply) then return end

        if not is_item then
            ply:ChatPrint("You can only buy passive items during '" .. Randomat:GetEventTitle(EVENT) .. "'!\nYour purchase has been refunded.")

            return false
        end
    end)

    -- Gives everyone a doncon playermodel if installed
    if donconModelInstalled then
        local playerModelSets = {}

        local ogDoncon = {
            model = donconModel,
            playerColor = Color(19, 46, 209):ToVector(),
            skin = 0,
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 0,
                [3] = 0,
                [4] = 0,
                [5] = 0
            }
        }

        table.insert(playerModelSets, ogDoncon)

        local floatingDoncon = {
            model = donconModel,
            playerColor = Color(19, 46, 209):ToVector(),
            skin = 0,
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 1,
                [3] = 1
            }
        }

        table.insert(playerModelSets, floatingDoncon)

        local gridDoncon = {
            model = donconModel,
            playerColor = Color(197, 17, 17):ToVector(),
            skin = 1,
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 0,
                [3] = 0
            }
        }

        table.insert(playerModelSets, gridDoncon)

        local hairlessDoncon = {
            model = donconModel,
            playerColor = Color(17, 127, 45):ToVector(),
            skin = 0,
            bodygroupValues = {
                [0] = 0,
                [1] = 1,
                [2] = 0,
                [3] = 1
            }
        }

        table.insert(playerModelSets, hairlessDoncon)

        local hairlessFloatingDoncon = {
            model = donconModel,
            playerColor = Color(17, 127, 45):ToVector(),
            skin = 0,
            bodygroupValues = {
                [0] = 0,
                [1] = 1,
                [2] = 1,
                [3] = 1
            }
        }

        table.insert(playerModelSets, hairlessFloatingDoncon)

        local shirtDoncon = {
            model = donconModel,
            playerColor = Color(237, 84, 186):ToVector(),
            skin = 2,
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 0,
                [3] = 0
            }
        }

        table.insert(playerModelSets, shirtDoncon)

        local rainbowDoncon = {
            model = donconModel,
            playerColor = Color(255, 0, 0):ToVector(),
            skin = 0,
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 0,
                [3] = 0
            }
        }

        table.insert(playerModelSets, rainbowDoncon)
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

        -- Rainbow Doncon logic to change colours over time
        local rainbowPhase = 1

        self:AddHook("Think", function()
            for _, ply in ipairs(self:GetAlivePlayers()) do
                if chosenPlayermodels[ply] == rainbowDoncon then
                    local vector = ply:GetPlayerColor()

                    if rainbowPhase == 1 then
                        vector.z = vector.z + (1 / 128)

                        if vector.z + (1 / 128) > 1 then
                            vector.z = 1
                            rainbowPhase = rainbowPhase + 1
                        end
                    elseif rainbowPhase == 2 then
                        vector.x = vector.x - (1 / 128)

                        if vector.x - (1 / 128) < 0 then
                            vector.x = 0
                            rainbowPhase = rainbowPhase + 1
                        end
                    elseif rainbowPhase == 3 then
                        vector.y = vector.y + (1 / 128)

                        if vector.y + (1 / 128) > 1 then
                            vector.y = 1
                            rainbowPhase = rainbowPhase + 1
                        end
                    elseif rainbowPhase == 4 then
                        vector.z = vector.z - (1 / 128)

                        if vector.z - (1 / 128) < 0 then
                            vector.z = 0
                            rainbowPhase = rainbowPhase + 1
                        end
                    elseif rainbowPhase == 5 then
                        vector.x = vector.x + (1 / 128)

                        if vector.x + (1 / 128) > 1 then
                            vector.x = 1
                            rainbowPhase = rainbowPhase + 1
                        end
                    elseif rainbowPhase == 6 then
                        vector.y = vector.y - (1 / 128)

                        if vector.y - (1 / 128) < 0 then
                            vector.y = 0
                            rainbowPhase = 1
                        end
                    end

                    ply:SetPlayerColor(vector)
                end
            end
        end)
    end
end

function EVENT:End()
    timer.Remove("RandomatDonconnonsTimer")

    if donconModelInstalled then
        Randomat:ForceResetAllPlayermodels()
    end
end

function EVENT:Condition()
    return weapons.Get(GetConVar("randomat_donconnons_weaponid"):GetString()) ~= nil
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"timer", "damage", "speed", "range", "lockondecaytime"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)
            convar:Revert()

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    for _, v in ipairs({"scale"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)
            convar:Revert()

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end

    for _, v in ipairs({"turn"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)
            convar:Revert()

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 5
            })
        end
    end

    local checks = {}

    for _, v in ipairs({"strip"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)
            convar:Revert()

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