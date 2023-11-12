local EVENT = {}

CreateConVar("randomat_paranoia_spectator_charge_time", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Seconds until a spectator can play a sound again", 10, 120)

CreateConVar("randomat_paranoia_spectator_sound_cooldown", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Seconds until someone can hear a spectator sound again", 10, 120)

EVENT.Title = "Paranoia"
EVENT.Description = "Lets spectators play horror sounds on living players"
EVENT.id = "paranoia"
EVENT.StartSecret = true

EVENT.Type = {EVENT_TYPE_SPECTATOR_UI}

EVENT.Categories = {"spectator", "smallimpact"}

util.AddNetworkString("randomat_paranoia_begin")
util.AddNetworkString("randomat_paranoia_spectator_sound")
util.AddNetworkString("randomat_paranoia_end")

local spectatorSounds = {"horror/spectator_sounds/box_laugh.mp3", "horror/spectator_sounds/box_richtofen_laugh.mp3", "horror/spectator_sounds/flowey_laugh.mp3", "horror/spectator_sounds/gowlermusic_horror_sounds1.mp3", "horror/spectator_sounds/gowlermusic_horror_sounds2.mp3", "horror/spectator_sounds/inspectorj_hand_bells_reverse.mp3", "horror/spectator_sounds/inspectorj_horror_violin.mp3", "horror/spectator_sounds/moon_laugh.mp3", "horror/spectator_sounds/onderwish_scream.mp3", "horror/spectator_sounds/omega_flowey_laugh.mp3"}

local function SpectatorMessage(ply)
    ply:PrintMessage(HUD_PRINTCENTER, "Right-click to cycle through players")
    ply:PrintMessage(HUD_PRINTTALK, "Right-click to cycle through players")

    timer.Simple(2, function()
        ply:PrintMessage(HUD_PRINTCENTER, "Right-click to cycle through players")
    end)

    timer.Simple(4, function()
        ply:PrintMessage(HUD_PRINTCENTER, "Press 'R' to go into first-person view")
        ply:PrintMessage(HUD_PRINTTALK, "Press 'R' to go into first-person view")
    end)

    timer.Simple(6, function()
        ply:PrintMessage(HUD_PRINTCENTER, "Press 'R' to go into first-person view")
    end)

    timer.Simple(8, function()
        ply:PrintMessage(HUD_PRINTCENTER, "Press 'SPACE' to play a sound...")
        ply:PrintMessage(HUD_PRINTTALK, "Press 'SPACE' to play a sound...")
    end)

    timer.Simple(10, function()
        ply:PrintMessage(HUD_PRINTCENTER, "Press 'SPACE' to play a sound...")
    end)
end

function EVENT:Begin()
    for _, ply in ipairs(player.GetAll()) do
        -- Preparing variables for the spectator sounds
        ply:SetNWInt("ParanoiaRandomatSpectatorPower", 0)
        ply:SetNWBool("ParanoiaRandomatSpectatorCooldown", false)

        -- Gives spectators artificial flashlights and draws the spectator UI on their screen
        if not ply:Alive() or ply:IsSpec() then
            net.Start("randomat_paranoia_begin")
            net.Send(ply)
            SpectatorMessage(ply)
        end

        -- Adding all sounds to the initial pool spectator sound so players don't hear the same sound more than once
        -- Until all sounds have been heard before
        ply.remainingSpectatorSounds = {}
        table.Add(ply.remainingSpectatorSounds, spectatorSounds)
    end

    -- Adds the spectator UI 
    self:AddHook("PostPlayerDeath", function(ply)
        net.Start("randomat_paranoia_begin")
        net.Send(ply)

        timer.Simple(2, function()
            SpectatorMessage(ply)
        end)
    end)

    -- Removes the spectator UI 
    self:AddHook("PlayerSpawn", function(ply)
        net.Start("randomat_paranoia_end")
        net.Send(ply)
    end)

    -- Plays a random paranoia sound when a spectator presses the jump key
    self:AddHook("KeyPress", function(ply, key)
        if key == IN_JUMP and ply:GetNWInt("ParanoiaRandomatSpectatorPower", 0) == 100 then
            local target = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil

            if IsPlayer(target) and not target:GetNWBool("ParanoiaRandomatSpectatorCooldown") then
                -- Reset the player's power
                ply:SetNWInt("ParanoiaRandomatSpectatorPower", 0)
                -- Players can only hear sounds on a cooldown
                target:SetNWBool("ParanoiaRandomatSpectatorCooldown", true)

                timer.Simple(GetConVar("randomat_paranoia_spectator_sound_cooldown"):GetInt(), function()
                    target:SetNWBool("ParanoiaRandomatSpectatorCooldown", false)
                end)

                -- Sound plays for the spectator and target player
                local randomSound = target.remainingSpectatorSounds[math.random(#target.remainingSpectatorSounds)]
                table.RemoveByValue(target.remainingSpectatorSounds, randomSound)

                -- Resets the choosable sounds if all have been played before for that player
                if table.IsEmpty(target.remainingSpectatorSounds) then
                    table.Add(target.remainingSpectatorSounds, spectatorSounds)
                end

                local soundPlayers = {target, ply}

                net.Start("randomat_paranoia_spectator_sound")
                net.WriteString(randomSound)
                net.Send(soundPlayers)
            elseif IsPlayer(target) and target:GetNWBool("ParanoiaRandomatSpectatorCooldown") then
                ply:PrintMessage(HUD_PRINTCENTER, "This player's been spooked too recently...")
            end
        end
    end)

    -- Updates the spectator charge bar
    local tick = GetConVar("randomat_paranoia_spectator_charge_time"):GetInt() / 100

    timer.Create("ParanoiaRandomatPowerTimer", tick, 0, function()
        for _, ply in ipairs(self:GetDeadPlayers()) do
            local power = ply:GetNWInt("ParanoiaRandomatSpectatorPower", 0)

            if power < 100 then
                ply:SetNWInt("ParanoiaRandomatSpectatorPower", power + 1)
            end
        end
    end)
end

function EVENT:End()
    -- Playing ending sound if music was enabled
    net.Start("randomat_paranoia_end")
    net.Broadcast()

    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWInt("ParanoiaRandomatSpectatorPower", 0)
    end
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"spectator_charge_time", "spectator_sound_cooldown"}) do
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

    return sliders
end

Randomat:register(EVENT)