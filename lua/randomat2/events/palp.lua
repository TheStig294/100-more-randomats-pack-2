local EVENT = {}
EVENT.Title = "Somehow, Palpatine Returned!"
EVENT.Description = "'Tom' has joined the game!"
EVENT.id = "palp"

EVENT.Categories = {"fun", "smallimpact"}

util.AddNetworkString("RandomatPalpDrawHalo")
local palpModel = "models/player/emperor_palpatine.mdl"
local tom

function EVENT:Begin()
    -- Plays a clip of Tom
    BroadcastLua("surface.PlaySound(\"palp/spawn1.mp3\")")
    -- Spawns a bot with a "Palpatine" playermodel, if installed, and sets them to the Old Man role if possible
    net.Start("RandomatPalpDrawHalo")
    net.Broadcast()

    timer.Simple(0.5, function()
        RunConsoleCommand("bot")
    end)

    timer.Simple(2, function()
        -- Get the last bot, which will be the one we just spawned
        tom = player.GetBots()[#player.GetBots()]
        tom:Spawn()

        if util.IsValidModel("models/player/emperor_palpatine.mdl") then
            tom:SetModel("models/player/emperor_palpatine.mdl")
        end

        tom:SetRole(ROLE_OLDMAN or ROLE_INNOCENT)
        tom:SetHealth(100)
        tom:SetMaxHealth(100)
        tom:SetNWString("PlayerName", "Angor")
        SendFullStateUpdate()

        -- Whenever tom-bot takes damage, dies, etc. he makes a sound
        self:AddHook("EntityTakeDamage", function(dmgEnt, dmg)
            if not IsPlayer(tom) or not IsPlayer(dmgEnt) then return end

            if dmgEnt ~= tom then
                -- If a player is somehow damaged by tom, then both the player and tom make a sound
                if IsValid(dmg:GetAttacker()) and dmg:GetAttacker() == tom then
                    timer.Create("RandomatPalpKillCooldown", 0.5, 1, function()
                        tom:EmitSound("palp/kill1.mp3")
                        dmgEnt:EmitSound("palp/kill1.mp3")
                    end)
                end

                return
            end

            timer.Create("RandomatPalpHurtCooldown", 0.5, 1, function()
                local randomNum = math.random(1, 12)
                tom:EmitSound("palp/hurt" .. randomNum .. ".mp3")
                tom:EmitSound("palp/hurt" .. randomNum .. ".mp3")
            end)
        end)

        -- Tom is killed
        self:AddHook("PostPlayerDeath", function(dmgEnt)
            if not IsPlayer(tom) or not IsPlayer(dmgEnt) then return end
            if dmgEnt ~= tom then return end

            timer.Create("AHTomDeathCooldown", 0.5, 1, function()
                local randomNum = math.random(1, 5)
                tom:EmitSound("palp/death" .. randomNum .. ".mp3")
                tom:EmitSound("palp/death" .. randomNum .. ".mp3")
            end)
        end)

        -- Tom is near another player
        timer.Create("RandomatPalpTouchPlayer", 2, 0, function()
            if not IsValid(tom) then
                timer.Remove("RandomatPalpTouchPlayer")

                return
            end

            local foundEnts = ents.FindInSphere(tom:GetPos(), 50)

            for _, foundEnt in ipairs(foundEnts) do
                if IsPlayer(foundEnt) and foundEnt ~= tom then
                    -- If the close entity is wearing the sharky playermodel, play special sounds once
                    if foundEnt:GetModel() == "models/bradyjharty/yogscast/sharky.mdl" then
                        if not tom.PlayedBen1 then
                            tom:EmitSound("palp/ben1.mp3")
                            tom:EmitSound("palp/ben1.mp3")
                            tom.PlayedBen1 = true

                            return
                        elseif not tom.PlayedBen2 then
                            tom:EmitSound("palp/ben2.mp3")
                            tom:EmitSound("palp/ben2.mp3")
                            tom.PlayedBen2 = true

                            return
                        end
                    end

                    local randomNum = math.random(1, 10)
                    tom:EmitSound("palp/bump" .. randomNum .. ".mp3")
                    tom:EmitSound("palp/bump" .. randomNum .. ".mp3")

                    return
                end
            end
        end)
    end)
end

function EVENT:End()
    if IsValid(tom) then
        tom:Kick()
    end
end

-- Prevent this event from running if the server is full, as the bot cannot spawn
-- And check the Palpatine model is installed!
function EVENT:Condition()
    return util.IsValidModel(palpModel) and player.GetCount() ~= game.MaxPlayers()
end

Randomat:register(EVENT)