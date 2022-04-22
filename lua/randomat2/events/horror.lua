local EVENT = {}
EVENT.Title = "Ki Ki Ki Ma Ma Ma"
EVENT.AltTitle = "Horror"
EVENT.ExtDescription = "Makes someone a killer and everyone else innocent. Adds horror-themed visuals and sounds."
EVENT.id = "horror"
EVENT.Type = EVENT_TYPE_MUSIC

EVENT.Categories = {"rolechange", "largeimpact"}

util.AddNetworkString("randomat_horror")
util.AddNetworkString("randomat_horror_end")

local musicConvar = CreateConVar("randomat_horror_music", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Play music during this randomat", 0, 1)

function EVENT:Begin()
    horrorRandomat = true
    engine.LightStyle(0, "a")
    -- Apply black-and-white filter and play music, if enabled
    local killerID = table.Random(self:GetAlivePlayers()):SteamID64()
    net.Start("randomat_horror")
    net.WriteBool(musicConvar:GetBool())
    net.WriteString(killerID)
    net.Broadcast()

    -- Disable round end sounds and 'Ending Flair' event so ending music can play
    if musicConvar:GetBool() then
        DisableRoundEndSounds()
    end

    -- Forces everyone's flashlight on
    for _, ply in ipairs(self:GetAlivePlayers()) do
        ply:Flashlight(true)
    end

    self:AddHook("PlayerSwitchFlashlight", function() return false end)
end

function EVENT:End()
    -- Checking if the randomat has run before trying to remove the greyscale effect, else causes an error
    if horrorRandomat then
        horrorRandomat = false
        engine.LightStyle(0, "m")
        net.Start("randomat_horror_end")
        net.Broadcast()

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