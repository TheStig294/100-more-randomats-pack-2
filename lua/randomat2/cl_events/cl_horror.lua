local music

net.Receive("randomat_horror", function()
    music = net.ReadBool()
    killerID = net.ReadString()
    -- Plays a "kikikimamama" sound when the event triggers
    surface.PlaySound("horror/kikikimamama.mp3")
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

    -- Adds a fog effect to hide some of the props and effects on the map that aren't affected by the map lighting change
    hook.Add("SetupWorldFog", "HorrorRandomatWorldFog", function()
        render.FogMode(MATERIAL_FOG_LINEAR)
        render.FogColor(0, 0, 0)
        render.FogMaxDensity(1)

        if LocalPlayer():SteamID64() == killerID then
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

        if LocalPlayer():SteamID64() == killerID then
            render.FogStart(300 * 1.5)
            render.FogEnd(600 * 1.5)
        else
            render.FogStart(300)
            render.FogEnd(600)
        end

        return true
    end)
end)

net.Receive("randomat_horror_end", function()
    -- Reset map lighting and stop removing the skybox if the map had one
    render.RedownloadAllLightmaps()
    hook.Remove("PreDrawSkyBox", "HorrorRemoveSkybox")

    -- Plays the ending music
    if music then
        timer.Remove("HorrorRandomatMusicLoop")
        RunConsoleCommand("stopsound")
        -- timer.Simple(0.1, function()
        --     surface.PlaySound("horror/deep_horrors_end.mp3")
        -- end)
    end

    -- Remove the fog effect
    hook.Remove("SetupWorldFog", "HorrorRandomatWorldFog")
    hook.Remove("SetupSkyboxFog", "HorrorRandomatSkyboxFog")
end)