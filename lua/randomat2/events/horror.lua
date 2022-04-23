local EVENT = {}
EVENT.Title = "Friday the 13th"
EVENT.AltTitle = "Horror"
EVENT.ExtDescription = "Makes someone a killer and everyone else innocent. Adds horror-themed visuals and sounds."
EVENT.id = "horror"

EVENT.Type = {EVENT_TYPE_MUSIC, EVENT_TYPE_SPECTATOR_UI}

EVENT.Categories = {"spectator", "rolechange", "largeimpact"}

util.AddNetworkString("randomat_horror")
util.AddNetworkString("randomat_horror_end")
util.AddNetworkString("randomat_horror_spectator")
util.AddNetworkString("randomat_horror_respawn")
util.AddNetworkString("randomat_horror_spectator_sound")

local musicConvar = CreateConVar("randomat_horror_music", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Play music during this randomat", 0, 1)

CreateConVar("randomat_horror_spectator_charge_time", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many seconds it takes to charge playing a sound as a spectator", 10, 120)

CreateConVar("randomat_horror_spectator_sound_cooldown", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many seconds it takes until someone can hear a spectator sound again", 10, 120)

local killerCrowbar = true

local spectatorSounds = {"horror/spectator_sounds/box_laugh.mp3", "horror/spectator_sounds/box_richtofen_laugh.mp3", "horror/spectator_sounds/flowey_laugh.mp3", "horror/spectator_sounds/gowlermusic_sudden_sound.mp3", "horror/spectator_sounds/inspectorj_hand_bells_reverse.mp3", "horror/spectator_sounds/inspectorj_horror_violin.mp3", "horror/spectator_sounds/minecraft_cave_sound_1.mp3", "horror/spectator_sounds/minecraft_cave_sound_2.mp3", "horror/spectator_sounds/moon_laugh.mp3", "horror/spectator_sounds/onderwish_scream.mp3"}

local function SpectatorMessage(ply)
    ply:PrintMessage(HUD_PRINTCENTER, "Right-click to cycle through living players")

    timer.Simple(2, function()
        ply:PrintMessage(HUD_PRINTCENTER, "Right-click to cycle through living players")
    end)

    timer.Simple(4, function()
        ply:PrintMessage(HUD_PRINTCENTER, "Press 'R' to go to first person view")
    end)

    timer.Simple(6, function()
        ply:PrintMessage(HUD_PRINTCENTER, "Press 'R' to go to first person view")
    end)
end

function EVENT:Begin()
    horrorRandomat = true
    -- Turns off the killer crowbar, target icons and player highlights for the killer
    killerCrowbar = GetConVar("ttt_killer_crowbar_enabled"):GetBool()
    GetConVar("ttt_killer_crowbar_enabled"):SetBool(false)
    -- Picks who is the killer
    local alivePlayers = self:GetAlivePlayers(true)
    local killer = alivePlayers[1]
    local killerID = killer:SteamID64()
    -- Draws screen effects to hinder each player's view and plays music if enabled
    engine.LightStyle(0, "a")
    net.Start("randomat_horror")
    net.WriteBool(musicConvar:GetBool())
    net.WriteString(killerID)
    net.Broadcast()

    -- Disable round end sounds and 'Ending Flair' event so ending music can play
    if musicConvar:GetBool() then
        DisableRoundEndSounds()
    end

    -- Removes all role and shop weapons
    for _, ent in ipairs(ents.GetAll()) do
        if ent.Kind and ent.Kind >= WEAPON_EQUIP1 then
            ent:Remove()
        end
    end

    for _, ply in ipairs(alivePlayers) do
        -- Turns everyone's flashlight on
        ply:Flashlight(true)
        -- Reset FOV to unscope
        ply:SetFOV(0, 0.2)
        -- Role weapons were stripped earlier, but just in case there are some that don't use WEAPON_ROLE...
        self:StripRoleWeapons(ply)

        -- Gives the killer extra health, an invisibility cloak, and shows hints in the centre of the screen
        if ply == killer then
            Randomat:SetRole(ply, ROLE_KILLER)
            killer = ply
            ply:SetHealth(200)
            ply:SetMaxHealth(100)
            ply:SetCredits(1)
            ply:Give("weapon_ttt_cloak_randomat")

            timer.Simple(2, function()
                ply:PrintMessage(HUD_PRINTCENTER, "You deal less damage with guns")
                ply:PrintMessage(HUD_PRINTTALK, "You deal less damage with guns")
            end)

            timer.Simple(4, function()
                ply:PrintMessage(HUD_PRINTCENTER, "Use your knife and shadow cloak...")
                ply:PrintMessage(HUD_PRINTTALK, "Use your knife and shadow cloak...")
            end)

            timer.Simple(6, function()
                ply:PrintMessage(HUD_PRINTCENTER, "Kill all others to win!")
                ply:PrintMessage(HUD_PRINTTALK, "Kill all others to win!")
            end)
        else
            Randomat:SetRole(ply, ROLE_INNOCENT)
            ply:SetCredits(0)

            timer.Simple(5, function()
                if ply:Alive() and not ply:IsSpec() then
                    ply:PrintMessage(HUD_PRINTCENTER, "When you hear that sound...")
                    ply:PrintMessage(HUD_PRINTTALK, "When you hear that sound...")
                end
            end)

            timer.Simple(7, function()
                if ply:Alive() and not ply:IsSpec() then
                    ply:PrintMessage(HUD_PRINTCENTER, "The killer is a shadow...")
                    ply:PrintMessage(HUD_PRINTTALK, "The killer is shadow...")
                end
            end)
        end
    end

    SendFullStateUpdate()

    -- Puts halos around living players for spectators to make them easier to see
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNWInt("HorrorRandomatSpectatorPower", 0)
        ply:SetNWBool("HorrorRandomatSpectatorCooldown", false)

        if not ply:Alive() or ply:IsSpec() then
            net.Start("randomat_horror_spectator")
            net.Send(ply)
            SpectatorMessage(ply)
        end

        -- Adding all sounds to the initial pool spectator sound so players don't hear the same sound more than once
        -- Until all sounds have been heard before
        ply.remainingSpectatorSounds = {}
        table.Add(ply.remainingSpectatorSounds, spectatorSounds)
    end

    -- Removes screen effects and add halos around players for spectators
    self:AddHook("PostPlayerDeath", function(ply)
        net.Start("randomat_horror_spectator")
        net.Send(ply)
        SpectatorMessage(ply)
    end)

    -- Re-adds screen effects and removes player halos for players that respawn
    self:AddHook("PlayerSpawn", function(ply)
        net.Start("randomat_horror_respawn")
        net.Send(ply)
    end)

    -- Plays a random horror sound when a spectator presses the jump key
    self:AddHook("KeyPress", function(ply, key)
        if key == IN_JUMP and ply:GetNWInt("HorrorRandomatSpectatorPower", 0) == 100 then
            local target = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil

            if IsPlayer(target) and not target:GetNWBool("HorrorRandomatSpectatorCooldown") then
                -- Reset the player's power
                ply:SetNWInt("HorrorRandomatSpectatorPower", 0)
                -- Players can only hear sounds on a cooldown
                target:SetNWBool("HorrorRandomatSpectatorCooldown", true)

                timer.Simple(GetConVar("randomat_horror_spectator_sound_cooldown"):GetInt(), function()
                    target:SetNWBool("HorrorRandomatSpectatorCooldown", false)
                end)

                -- Sound plays for the spectator and target player
                local randomSound = table.Random(target.remainingSpectatorSounds)
                table.RemoveByValue(target.remainingSpectatorSounds, randomSound)

                -- Resets the choosable sounds if all have been played before for that player
                if table.IsEmpty(target.remainingSpectatorSounds) then
                    table.Add(target.remainingSpectatorSounds, spectatorSounds)
                end

                local soundPlayers = {target, ply}

                net.Start("randomat_horror_spectator_sound")
                net.WriteString(randomSound)
                net.Send(soundPlayers)
            end
        end
    end)

    -- Updates the spectator charge bar
    local tick = GetConVar("randomat_horror_spectator_charge_time"):GetInt() / 100

    timer.Create("HorrorRandomatPowerTimer", tick, 0, function()
        for _, ply in ipairs(self:GetDeadPlayers()) do
            local power = ply:GetNWInt("HorrorRandomatPower", 0)

            if power < 100 then
                ply:SetNWInt("HorrorRandomatPower", power + 1)
            end
        end
    end)
end

function EVENT:End()
    -- Checking if the randomat has run before trying to end the event, else causes an error
    if horrorRandomat then
        horrorRandomat = false
        -- Resetting the killer crowbar convar to what is was before the event triggered
        GetConVar("ttt_killer_crowbar_enabled"):SetBool(killerCrowbar)
        -- Playing ending sound if music was enabled
        net.Start("randomat_horror_end")
        net.Broadcast()

        -- Resets map lighting and turns everyone's flashlight off
        timer.Simple(5, function()
            engine.LightStyle(0, "m")

            for _, ply in ipairs(self:GetAlivePlayers()) do
                ply:Flashlight(false)
            end
        end)
    end
end

-- This event can only run if the "killer" role exists
function EVENT:Condition()
    return ConVarExists("ttt_killer_enabled")
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

    local checkboxes = {}

    for _, v in pairs({"music"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(checkboxes, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    return sliders, checkboxes
end

Randomat:register(EVENT)