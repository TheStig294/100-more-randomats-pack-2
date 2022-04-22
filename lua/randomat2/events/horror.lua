local EVENT = {}
EVENT.Title = "Friday the 13th"
EVENT.AltTitle = "Horror"
EVENT.ExtDescription = "Makes someone a killer and everyone else innocent. Adds horror-themed visuals and sounds."
EVENT.id = "horror"
EVENT.Type = EVENT_TYPE_MUSIC

EVENT.Categories = {"rolechange", "largeimpact"}

util.AddNetworkString("randomat_horror")
util.AddNetworkString("randomat_horror_end")

local musicConvar = CreateConVar("randomat_horror_music", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Play music during this randomat", 0, 1)

local killerCrowbar

function EVENT:Begin()
    horrorRandomat = true
    -- Turns off the killer crowbar, target icons and player highlights for the killer
    killerCrowbar = GetConVar("ttt_killer_crowbar_enabled"):GetBool()
    GetConVar("ttt_killer_crowbar_enabled"):SetBool(false)
    -- Picks who is the killer
    local killer = self:GetAlivePlayers(true)[1]
    killer = Entity(1)
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
            end)

            timer.Simple(4, function()
                ply:PrintMessage(HUD_PRINTCENTER, "Use your knife and cloaking device...")
            end)

            timer.Simple(6, function()
                ply:PrintMessage(HUD_PRINTCENTER, "Kill all others to win!")
            end)
        else
            Randomat:SetRole(ply, ROLE_INNOCENT)
            ply:SetCredits(0)

            timer.Simple(5, function()
                ply:PrintMessage(HUD_PRINTCENTER, "When you hear that sound...")
            end)

            timer.Simple(7, function()
                ply:PrintMessage(HUD_PRINTCENTER, "The killer is invisible...")
            end)
        end
    end

    SendFullStateUpdate()
end

function EVENT:End()
    -- Checking if the randomat has run before trying to end the event, else causes an error
    if horrorRandomat then
        horrorRandomat = false
        -- Resetting the killer crowbar convar to what is was before the event triggered
        GetConVar("ttt_killer_crowbar_enabled"):SetBool(killerCrowbar)
        -- Resets map lighting and plays ending music, if enabled
        engine.LightStyle(0, "m")
        net.Start("randomat_horror_end")
        net.Broadcast()

        -- Turns everyone's flashlight off
        for _, ply in ipairs(self:GetAlivePlayers()) do
            ply:Flashlight(false)
        end
    end
end

function EVENT:Condition()
    return ConVarExists("ttt_killer_enabled")
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"innocent_fog", "killer_fog"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 1
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