local EVENT = {}
EVENT.Title = "Friday the 13th"
EVENT.AltTitle = "Horror"
EVENT.ExtDescription = "Makes someone a killer and everyone else innocent. Adds horror-themed visuals and sounds."
EVENT.id = "horror"
EVENT.Type = EVENT_TYPE_MUSIC

EVENT.Categories = {"rolechange", "largeimpact"}

util.AddNetworkString("randomat_horror")
util.AddNetworkString("randomat_horror_end")
util.AddNetworkString("randomat_horror_spectator")

local musicConvar = CreateConVar("randomat_horror_music", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Play music during this randomat", 0, 1)

local killerCrowbar

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
    local killer = self:GetAlivePlayers(true)[1]
    killer = Entity(2)
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

    for _, ply in ipairs(self:GetAlivePlayers()) do
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
                ply:PrintMessage(HUD_PRINTCENTER, "Use your knife and cloaking device...")
                ply:PrintMessage(HUD_PRINTTALK, "Use your knife and cloaking device...")
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
                    ply:PrintMessage(HUD_PRINTCENTER, "The killer is invisible...")
                    ply:PrintMessage(HUD_PRINTTALK, "The killer is invisible...")
                end
            end)
        end
    end

    SendFullStateUpdate()

    -- Puts halos around living players for spectators to make them easier to see
    for _, ply in ipairs(player.GetAll()) do
        if ply:IsSpec() then
            net.Start("randomat_horror_spectator")
            net.Send(ply)
            SpectatorMessage(ply)
        end
    end

    self:AddHook("PostPlayerDeath", function(ply)
        net.Start("randomat_horror_spectator")
        net.Send(ply)
        SpectatorMessage(ply)
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

function EVENT:Condition()
    return ConVarExists("ttt_killer_enabled")
end

function EVENT:GetConVars()
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

    return {}, checkboxes
end

Randomat:register(EVENT)