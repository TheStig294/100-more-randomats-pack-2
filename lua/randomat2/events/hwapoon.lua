local EVENT = {}
EVENT.Title = "Hwapoon!"
EVENT.Description = "Everyone gets a 'hwapoon!'"
EVENT.id = "hwapoon"

EVENT.Categories = {"item", "largeimpact"}

local lewisModel = "models/bradyjharty/yogscast/lewis.mdl"
util.AddNetworkString("HwapoonRandomatPlaySound")

function EVENT:Begin()
    local alivePlayers = self:GetAlivePlayers()

    if weapons.Get("ttt_m9k_harpoon") then
        for _, ply in ipairs(alivePlayers) do
            ply:Give("ttt_m9k_harpoon")
        end
    elseif weapons.Get("weapon_ttt_hwapoon") then
        for _, ply in ipairs(alivePlayers) do
            ply:Give("weapon_ttt_hwapoon")
        end
    end

    self:AddHook("PlayerButtonDown", function(ply, button)
        if not IsFirstTimePredicted() then return end

        if button == MOUSE_LEFT and IsValid(ply:GetActiveWeapon()) and (ply:GetActiveWeapon():GetClass() == "ttt_m9k_harpoon" or ply:GetActiveWeapon():GetClass() == "weapon_ttt_hwapoon") then
            local hwapoonSound = "hwapoon/hwapoon" .. math.random(1, 4) .. ".mp3"
            net.Start("HwapoonRandomatPlaySound")
            net.WriteString(hwapoonSound)
            net.Broadcast()
        end
    end)

    -- If the yogs lewis playermodel is installed, do a bit more...
    if util.IsValidModel(lewisModel) then
        -- Change the description
        self.Description = "Everyone gets a 'hwapoon', a big grin, and long flowing hair..."
        -- Special models that aren't just the yogs lewis model with a random colour
        local playerModelSets = {}

        playerModelSets.lewisRed = {
            model = lewisModel,
            skin = 1,
            playerColor = Color(255, 0, 0):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0
            }
        }

        playerModelSets.lewisBlue = {
            model = lewisModel,
            skin = 1,
            playerColor = Color(0, 0, 255):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0
            }
        }

        playerModelSets.lewisPink = {
            model = lewisModel,
            skin = 1,
            playerColor = Color(255, 0, 255):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0
            }
        }

        playerModelSets.lewisWhite = {
            model = lewisModel,
            skin = 0,
            playerColor = Color(255, 255, 255):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0
            }
        }

        playerModelSets.beeLewis = {
            model = lewisModel,
            skin = 0,
            playerColor = Color(255, 229, 0):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 1
            }
        }

        playerModelSets.dressLewis = {
            model = lewisModel,
            skin = 0,
            playerColor = Color(0, 88, 0):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 2
            }
        }

        playerModelSets.rainbowLewis = {
            model = lewisModel,
            skin = 1,
            playerColor = Color(255, 0, 0):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0
            }
        }

        if util.IsValidModel("models/player/Yahtzee.mdl") then
            playerModelSets.ogLewisModel = {
                model = "models/player/Yahtzee.mdl",
                skin = 10,
                playerColor = Color(255, 255, 255):ToVector(),
                bodygroupValues = {
                    [0] = 0,
                    [1] = 3,
                    [2] = 2
                }
            }
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

            local modelData = table.Random(remainingPlayermodels)
            ForceSetPlayermodel(ply, modelData)
            -- Remove the selected model from the pool
            table.RemoveByValue(remainingPlayermodels, modelData)
            -- Keep track of who got what model so it can be set when they respawn
            chosenPlayermodels[ply] = modelData
        end

        self:AddHook("PlayerSpawn", function(ply)
            -- If they weren't in the round when the event triggered, set their chosen model to a random one
            if not chosenPlayermodels[ply] then
                chosenPlayermodels[ply] = table.Random(playerModelSets)
            end

            -- Sets someone's playermodel again when respawning
            timer.Simple(1, function()
                ForceSetPlayermodel(ply, chosenPlayermodels[ply])
            end)
        end)

        -- Rainbow Lewis logic to change colours over time
        local rainbowPhase = 1

        self:AddHook("Think", function()
            for _, ply in ipairs(self:GetAlivePlayers()) do
                if chosenPlayermodels[ply] == playerModelSets.rainbowLewis then
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
    ForceResetAllPlayermodels()
end

function EVENT:Condition()
    return weapons.Get("ttt_m9k_harpoon") or weapons.Get("weapon_ttt_hwapoon")
end

Randomat:register(EVENT)