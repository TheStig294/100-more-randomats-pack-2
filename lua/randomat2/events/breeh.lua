local EVENT = {}
EVENT.Title = "It's Breeh!"
EVENT.Description = "Everyone is an adorable sheep..."
EVENT.id = "breeh"

EVENT.Categories = {"largeimpact"}

local breehModel = "models/bradyjharty/yogscast/breeh2.mdl"

function EVENT:Begin()
    -- If the yogs breeh playermodel is installed, do a bit more...
    if util.IsValidModel(breehModel) then
        local playerModelSets = {}
        local viewOffsetBreeh = Vector(0, 0, 56)
        local viewOffsetDuckedBreeh = Vector(0, 0, 28)

        playerModelSets.dolphin = {
            model = breehModel,
            viewOffset = viewOffsetBreeh,
            viewOffsetDucked = viewOffsetDuckedBreeh,
            skin = 0,
            playerColor = Color(255, 255, 255):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 0,
                [3] = 0,
                [4] = 0,
                [5] = 0,
                [6] = 0,
                [7] = 1
            }
        }

        playerModelSets.strawhat = {
            model = breehModel,
            viewOffset = viewOffsetBreeh,
            viewOffsetDucked = viewOffsetDuckedBreeh,
            skin = 0,
            playerColor = Color(255, 255, 255):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 3,
                [3] = 1,
                [4] = 3,
                [5] = 3,
                [6] = 2,
                [7] = 0
            }
        }

        playerModelSets.jacket = {
            model = breehModel,
            viewOffset = viewOffsetBreeh,
            viewOffsetDucked = viewOffsetDuckedBreeh,
            skin = 0,
            playerColor = Color(255, 255, 255):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 2,
                [3] = 5,
                [4] = 3,
                [5] = 2,
                [6] = 1,
                [7] = 0
            }
        }

        playerModelSets.dealer = {
            model = breehModel,
            viewOffset = viewOffsetBreeh,
            viewOffsetDucked = viewOffsetDuckedBreeh,
            skin = 0,
            playerColor = Color(255, 255, 255):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 1,
                [3] = 2,
                [4] = 1,
                [5] = 4,
                [6] = 3,
                [7] = 0
            }
        }

        playerModelSets.christmas = {
            model = breehModel,
            viewOffset = viewOffsetBreeh,
            viewOffsetDucked = viewOffsetDuckedBreeh,
            skin = 1,
            playerColor = Color(0, 200, 0):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 3,
                [3] = 3,
                [4] = 3,
                [5] = 5,
                [6] = 4,
                [7] = 0
            }
        }

        playerModelSets.goku = {
            model = breehModel,
            viewOffset = viewOffsetBreeh,
            viewOffsetDucked = viewOffsetDuckedBreeh,
            skin = 1,
            playerColor = Color(255, 115, 0):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 0,
                [2] = 2,
                [3] = 2,
                [4] = 1,
                [5] = 1,
                [6] = 0,
                [7] = 0
            }
        }

        playerModelSets.rainbowBreeh = {
            model = breehModel,
            viewOffset = viewOffsetBreeh,
            viewOffsetDucked = viewOffsetDuckedBreeh,
            skin = 1,
            playerColor = Color(255, 0, 0):ToVector(),
            bodygroupValues = {
                [0] = 0,
                [1] = 1,
                [2] = 1,
                [3] = 5,
                [4] = 3,
                [5] = 0,
                [6] = 0,
                [7] = 0
            }
        }

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

        -- Rainbow Breeh logic to change colours over time
        local rainbowPhase = 1

        self:AddHook("Think", function()
            for _, ply in ipairs(self:GetAlivePlayers()) do
                if chosenPlayermodels[ply] == playerModelSets.rainbowBreeh then
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
    return util.IsValidModel(breehModel)
end

Randomat:register(EVENT)