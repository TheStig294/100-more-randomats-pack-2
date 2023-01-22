local EVENT = {}
EVENT.Title = ""
EVENT.AltTitle = "The killers are coming..."
EVENT.ExtDescription = "Killers vs. Innocents! Adds horror-themed visuals and sounds."
EVENT.id = "horror"

EVENT.Type = {EVENT_TYPE_MUSIC, EVENT_TYPE_SPECTATOR_UI}

EVENT.Categories = {"spectator", "rolechange", "largeimpact"}

util.AddNetworkString("randomat_horror")
util.AddNetworkString("randomat_horror_end")
util.AddNetworkString("randomat_horror_spectator")
util.AddNetworkString("randomat_horror_respawn")
util.AddNetworkString("randomat_horror_spectator_sound")

local musicConvar = CreateConVar("randomat_horror_music", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Play music during this randomat", 0, 1)

CreateConVar("randomat_horror_ending", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Win screen plays a horror sound and ending title is changed", 0, 1)

CreateConVar("randomat_horror_spectator_sounds", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Spectators can play horror sounds", 0, 1)

CreateConVar("randomat_horror_cloak_sounds", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Sounds play as the killer is cloaked/uncloaks", 0, 1)

CreateConVar("randomat_horror_spectator_charge_time", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Seconds until a spectator can play a sound again", 10, 120)

CreateConVar("randomat_horror_spectator_sound_cooldown", 30, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Seconds until someone can hear a spectator sound again", 10, 120)

CreateConVar("randomat_horror_killer_crowbar", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Killer gets a throwable crowbar rather than a normal one", 0, 1)

CreateConVar("randomat_horror_killer_health", 200, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much health the killer starts with", 1, 500)

CreateConVar("randomat_horror_killer_credits", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Credits the killer starts with", 0, 5)

CreateConVar("randomat_horror_killer_cloak", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Killer gets a 'Shadow Cloak' item. Makes them appear as a shadow while held", 0, 1)

CreateConVar("randomat_horror_cloak_sound_timer", 10, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Seconds until the cloak sound is heard again while cloaked", 5, 60)

-- Removes the spectator category if spectator sounds are turned off
if not GetConVar("randomat_horror_spectator_sounds"):GetBool() then
    table.remove(EVENT.Categories, 1)
end

local killerCrowbar = true

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

local function SetToKiller(ply)
    Randomat:SetRole(ply, ROLE_KILLER)
    ply:SetNWBool("HorrorRandomatKiller", true)
    ply:SetHealth(GetConVar("randomat_horror_killer_health"):GetInt())
    ply:SetMaxHealth(GetConVar("randomat_horror_killer_health"):GetInt())
    ply:SetCredits(GetConVar("randomat_horror_killer_credits"):GetInt())

    if GetConVar("randomat_horror_killer_cloak"):GetBool() then
        ply:Give("weapon_ttt_cloak_randomat")
    end

    timer.Simple(5, function()
        ply:PrintMessage(HUD_PRINTCENTER, "You deal less damage with guns, kill all innocents to win!")
    end)

    timer.Simple(7, function()
        ply:PrintMessage(HUD_PRINTCENTER, "You deal less damage with guns, kill all innocents to win!")
    end)
end

function EVENT:Begin()
    horrorRandomat = true
    -- Draws screen effects to hinder each player's view and plays music if enabled
    engine.LightStyle(0, "a")
    net.Start("randomat_horror")
    net.WriteBool(musicConvar:GetBool())
    net.WriteBool(GetConVar("randomat_horror_cloak_sounds"):GetBool())
    net.WriteBool(GetConVar("randomat_horror_ending"):GetBool())
    SetGlobalBool("randomat_horror_cloak_sounds", GetConVar("randomat_horror_cloak_sounds"):GetBool())
    net.Broadcast()

    for _, ply in ipairs(player.GetAll()) do
        -- Preparing variables for the spectator sounds
        ply:SetNWInt("HorrorRandomatSpectatorPower", 0)
        ply:SetNWBool("HorrorRandomatSpectatorCooldown", false)

        -- Gives spectators artificial flashlights and draws the spectator UI on their screen
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

    -- Disable round end sounds and 'Ending Flair' event so ending music can play
    if DisableRoundEndSounds and musicConvar:GetBool() then
        DisableRoundEndSounds()
    end

    -- Turns off the killer crowbar if it isn't enabled for the event
    if not GetConVar("randomat_horror_killer_crowbar"):GetBool() then
        killerCrowbar = GetConVar("ttt_killer_crowbar_enabled"):GetBool()
        GetConVar("ttt_killer_crowbar_enabled"):SetBool(false)
    end

    -- Removes all role and shop weapons
    for _, ent in ipairs(ents.GetAll()) do
        if ent.Kind and ent.Kind >= WEAPON_EQUIP1 then
            ent:Remove()
        end
    end

    local killerCount = 0
    local alivePlayers = self:GetAlivePlayers(true)

    for _, ply in ipairs(alivePlayers) do
        -- Turns everyone's flashlight on
        ply:Flashlight(true)
        -- Reset FOV to unscope
        ply:SetFOV(0, 0.2)
        -- Role weapons were stripped earlier, but just in case there are some that don't use WEAPON_ROLE...
        self:StripRoleWeapons(ply)

        -- Turn the traitors into killers
        -- Gives the killer(s) extra health, an invisibility cloak, and shows hints in the centre of the screen
        if Randomat:IsTraitorTeam(ply) then
            SetToKiller(ply)
            killerCount = killerCount + 1
        else
            Randomat:SetRole(ply, ROLE_INNOCENT)
            ply:SetCredits(0)

            timer.Simple(5, function()
                if ply:Alive() and not ply:IsSpec() then
                    ply:PrintMessage(HUD_PRINTCENTER, "When you hear that sound...")
                end
            end)

            timer.Simple(7, function()
                if ply:Alive() and not ply:IsSpec() then
                    if killerCount > 1 then
                        ply:PrintMessage(HUD_PRINTCENTER, "A killer is a shadow...")
                    else
                        ply:PrintMessage(HUD_PRINTCENTER, "The killer is a shadow...")
                    end
                end
            end)
        end
    end

    -- If no traitors are alive, set a random player to be a killer
    if killerCount == 0 then
        SetToKiller(alivePlayers[1])
        killerCount = killerCount + 1
    end

    SendFullStateUpdate()

    -- Name of the randomat changes depending on how many killers there are
    if killerCount == 1 then
        self.Title = "The killer is coming..."
    else
        self.Title = "The killers are coming..."
    end

    Randomat:EventNotifySilent(self.Title)

    -- Removes screen effects and adds the spectator UI and artificial flashlights for spectators
    self:AddHook("PostPlayerDeath", function(ply)
        net.Start("randomat_horror_spectator")
        net.Send(ply)

        timer.Simple(2, function()
            SpectatorMessage(ply)
        end)
    end)

    -- Re-adds screen effects and removes the spectator UI and flashlight
    self:AddHook("PlayerSpawn", function(ply)
        net.Start("randomat_horror_respawn")
        net.Send(ply)
        ply:Flashlight(true)
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
            elseif IsPlayer(target) and target:GetNWBool("HorrorRandomatSpectatorCooldown") then
                ply:PrintMessage(HUD_PRINTCENTER, "This player's been spooked too recently...")
            end
        end
    end)

    -- Updates the spectator charge bar
    local tick = GetConVar("randomat_horror_spectator_charge_time"):GetInt() / 100

    timer.Create("HorrorRandomatPowerTimer", tick, 0, function()
        for _, ply in ipairs(self:GetDeadPlayers()) do
            local power = ply:GetNWInt("HorrorRandomatSpectatorPower", 0)

            if power < 100 then
                ply:SetNWInt("HorrorRandomatSpectatorPower", power + 1)
            end
        end
    end)
end

function EVENT:End()
    -- Checking if the randomat has run before trying to end the event, else causes an error
    if horrorRandomat then
        horrorRandomat = false
        EVENT.Title = ""

        -- Resetting the killer crowbar convar to what is was before the event triggered
        if not GetConVar("randomat_horror_killer_crowbar") then
            GetConVar("ttt_killer_crowbar_enabled"):SetBool(killerCrowbar)
        end

        -- Playing ending sound if music was enabled
        net.Start("randomat_horror_end")
        net.Broadcast()

        for _, ply in ipairs(player.GetAll()) do
            ply:SetNWBool("HorrorRandomatKiller", false)
            ply:SetNWInt("HorrorRandomatSpectatorPower", 0)
        end

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

    for _, v in ipairs({"spectator_charge_time", "spectator_sound_cooldown", "killer_health", "killer_credits", "cloak_sound_timer"}) do
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

    for _, v in pairs({"music", "ending", "spectator_sounds", "cloak_sounds", "killer_crowbar", "killer_cloak"}) do
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
