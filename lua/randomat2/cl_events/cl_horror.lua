local music
local cloakSounds
local horrorEnding
-- Used for expensive calls needing LocalPlayer()
local client = LocalPlayer()

local function IsPlayerValid(p)
    return IsPlayer(p) and p:Alive() and not p:IsSpec()
end

local function ApplyScreenEffects()
    -- Adds a fog effect to hide some of the props and effects on the map that aren't affected by the map lighting change
    hook.Add("SetupWorldFog", "HorrorRandomatWorldFog", function()
        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogColor(0, 0, 0)
        render.FogMaxDensity(1)

        if LocalPlayer():GetNWBool("HorrorRandomatKiller") then
            render.FogStart(300 * 1.5)
            render.FogEnd(600 * 1.5)
        else
            render.FogStart(300)
            render.FogEnd(600)
        end

        return true
    end)

    --If a map has a 3D skybox, apply a fog effect to that too
    hook.Add("SetupSkyboxFog", "HorrorRandomatSkyboxFog", function(scale)
        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogColor(0, 0, 0)
        render.FogMaxDensity(1)

        if LocalPlayer():GetNWBool("HorrorRandomatKiller") then
            render.FogStart(300 * 1.5 * scale)
            render.FogEnd(600 * 1.5 * scale)
        else
            render.FogStart(300)
            render.FogEnd(600)
        end

        return true
    end)

    -- Removes popups when players look at a killer using the invisibility cloak
    hook.Add("TTTTargetIDPlayerBlockIcon", "HorrorRandomatVisionBlockTargetIcon", function(ply, cli)
        if not IsPlayerValid(cli) or not IsPlayerValid(ply) then return end
        if ply:GetNWBool("RdmtInvisible") then return true end
    end)

    hook.Add("TTTTargetIDPlayerBlockInfo", "HorrorRandomatVisionBlockTargetInfo", function(ply, cli)
        if not IsPlayerValid(cli) or not IsPlayerValid(ply) then return end
        if ply:GetNWBool("RdmtInvisible") then return true end
    end)
end

local function RemoveHooks()
    -- Reset map lighting and stop removing the skybox if the map had one
    render.RedownloadAllLightmaps()
    hook.Remove("PreDrawSkyBox", "HorrorRemoveSkybox")
    -- Remove the fog effect
    hook.Remove("SetupWorldFog", "HorrorRandomatWorldFog")
    hook.Remove("SetupSkyboxFog", "HorrorRandomatSkyboxFog")
    -- Remove the block on seeing the player info popup
    hook.Remove("TTTTargetIDPlayerBlockIcon", "HorrorRandomatVisionBlockTargetIcon")
    hook.Remove("TTTTargetIDPlayerBlockInfo", "HorrorRandomatVisionBlockTargetInfo")
    -- Remove the spectator UI and artificial flashlight
    hook.Remove("HUDPaint", "HorrorRandomatUI")
    hook.Remove("Think", "HorrorRandomatSpectatorFlashlight")
    -- Remove modified win title if it was added
    hook.Remove("TTTScoringWinTitle", "HorrorRandomatWinTitle")

    if client.HorrorRandomatFlashlight then
        client.HorrorRandomatFlashlight:Remove()
    end

    -- Just in case
    timer.Simple(2, function()
        render.RedownloadAllLightmaps()
    end)
end

local function IsKillerWin()
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetRole() == ROLE_INNOCENT and ply:Alive() and not ply:IsSpec() then return false end
    end

    return true
end

net.Receive("randomat_horror", function()
    LANG.AddToLanguage("english", "win_horror_killer", string.upper("the " .. ROLE_STRINGS_PLURAL[ROLE_INNOCENT] .. " are dead"))
    LANG.AddToLanguage("english", "win_horror_innocent", string.upper(ROLE_STRINGS_PLURAL[ROLE_INNOCENT] .. " survive"))
    music = net.ReadBool()
    cloakSounds = net.ReadBool()
    horrorEnding = net.ReadBool()
    client = LocalPlayer()

    -- Plays a "kikikimamama" sound when the event triggers
    if cloakSounds then
        surface.PlaySound("horror/kikikimamama.mp3")
    end

    -- Updates the map lighting to be dark and removes any skybox on the map
    render.RedownloadAllLightmaps()
    hook.Add("PreDrawSkyBox", "HorrorRemoveSkybox", function() return true end)

    -- Plays music if enabled
    if music then
        for i = 1, 2 do
            surface.PlaySound("horror/deep_horrors.mp3")
        end

        timer.Create("HorrorRandomatMusicLoop", 136, 0, function()
            for i = 1, 2 do
                surface.PlaySound("horror/deep_horrors.mp3")
            end
        end)
    end

    ApplyScreenEffects()

    -- Modifies the win screen depending on if the killer or innocents win
    if horrorEnding then
        if CRVersion("1.7.3") then
            hook.Add("TTTScoringWinTitleOverride", "HorrorRandomatWinTitle", function(wintype, wintitles, title)
                local newTitle = {
                    c = COLOR_BLACK
                }

                if wintype == WIN_KILLER then
                    newTitle.txt = "win_horror_killer"
                else
                    newTitle.txt = "win_horror_innocent"
                end

                return newTitle
            end)
        else
            -- The logic for the killer win title doesn't work in this hook for Custom Roles versions earlier than 1.7.3,
            -- so this is handled the "randomat_horror_end" net function instead
            hook.Add("TTTScoringWinTitle", "HorrorRandomatWinTitle", function()
                local newTitle = {
                    c = COLOR_BLACK,
                    txt = "win_horror_innocent"
                }

                return newTitle
            end)
        end
    end
end)

net.Receive("randomat_horror_spectator", function()
    -- Draws the spectator sounds UI
    hook.Add("HUDPaint", "HorrorRandomatUI", function()
        local width, height, margin = 200, 25, 20
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - (margin / 2 + height)
        local progress = client:GetNWInt("HorrorRandomatSpectatorPower", 0)
        local progress_percentage = progress / 100

        local colors = {
            border = COLOR_WHITE,
            background = Color(17, 115, 135, 222),
            fill = Color(82, 226, 255, 255)
        }

        Randomat:PaintBar(8, x, y, width, height, colors, progress_percentage)
        draw.SimpleText("SCARE POWER", "HealthAmmo", ScrW() / 2, y, Color(0, 0, 10, 200), TEXT_ALIGN_CENTER)
        draw.SimpleText("Right-click -> R -> SPACE, to play a sound...", "TabLarge", ScrW() / 2, y - margin, COLOR_WHITE, TEXT_ALIGN_CENTER)
    end)

    -- Creates an artificial flashlight for spectators
    client.HorrorRandomatFlashlight = ProjectedTexture()
    client.HorrorRandomatFlashlight:SetTexture("effects/flashlight001")
    client.HorrorRandomatFlashlight:SetFarZ(600)
    client.HorrorRandomatFlashlight:SetFOV(70)

    hook.Add("Think", "HorrorRandomatSpectatorFlashlight", function()
        local position = client:GetPos()
        local newposition = Vector(position[1], position[2], position[3] + 40) + client:GetForward() * 20
        client.HorrorRandomatFlashlight:SetPos(newposition)
        client.HorrorRandomatFlashlight:SetAngles(client:EyeAngles())
        client.HorrorRandomatFlashlight:Update()
    end)
end)

net.Receive("randomat_horror_spectator_sound", function()
    local spectatorSound = net.ReadString()
    surface.PlaySound(spectatorSound)
end)

net.Receive("randomat_horror_respawn", function()
    ApplyScreenEffects()
    -- Remove the spectator UI and artificial flashlight
    hook.Remove("HUDPaint", "HorrorRandomatUI")
    hook.Remove("Think", "HorrorRandomatSpectatorFlashlight")

    if client.HorrorRandomatFlashlight then
        client.HorrorRandomatFlashlight:Remove()
    end
end)

surface.CreateFont("HorrorRandomatKillerWin", {
    font = "Trebuchet24",
    size = 58,
    weight = 1000
})

local function DrawKillerWin()
    local xPos = (ScrW() / 2) - 345
    local yPos = (ScrH() / 2) - 228
    local width = 691
    local height = 87

    hook.Add("DrawOverlay", "HorrorRandomatDrawKillerWin", function()
        if not IsValid(vgui.GetHoveredPanel()) then return end
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(xPos, yPos, width, height)
        surface.SetFont("HorrorRandomatKillerWin")
        surface.SetTextColor(255, 255, 255)
        surface.SetTextPos(xPos + 75, yPos + 15)
        surface.DrawText("the innocents are dead")
    end)
end

net.Receive("randomat_horror_end", function()
    if music then
        timer.Remove("HorrorRandomatMusicLoop")
        RunConsoleCommand("stopsound")
    end

    local screenEffectsRemovalDelay = 5

    -- Plays a sound and sets the delay to when the lights are turned back on in the map (and all other screen effects reset)
    -- Timed to when the sound finishes playing
    if horrorEnding then
        timer.Simple(0.1, function()
            local endingSound

            if IsKillerWin() then
                screenEffectsRemovalDelay = 10
                endingSound = "horror/moon_laugh_2.mp3"
            else
                screenEffectsRemovalDelay = 5
                endingSound = "horror/deep_horrors_scare.mp3"
            end

            for i = 1, 2 do
                surface.PlaySound(endingSound)
            end
        end)

        -- Draws the killer win text on the win screen by brute-force drawing over the win title
        -- Since the wintitle hook in Custom Roles doesn't work for the killer, before version 1.7.3
        if not CRVersion("1.7.3") and IsKillerWin() then
            DrawKillerWin()
            hook.Add("OnContextMenuOpen", "HorrorRandomatStartDrawKillerWin", DrawKillerWin)

            hook.Add("TTTBeginRound", "HorrorRandomatRemoveKillerWin", function()
                hook.Remove("OnContextMenuOpen", "HorrorRandomatStartDrawKillerWin")
                hook.Remove("DrawOverlay", "HorrorRandomatDrawKillerWin")
                hook.Remove("TTTBeginRound", "HorrorRandomatRemoveKillerWin")
            end)
        end
    end

    -- If the horror ending is off, lights are just turned on after 5 seconds
    -- There is still a delay because render.RedownloadAllLightmaps() in the RemoveHooks() function is an expensive call
    -- and we don't want to overwhelm the client at round end, and not reset the map lighting
    timer.Simple(screenEffectsRemovalDelay, RemoveHooks)
end)