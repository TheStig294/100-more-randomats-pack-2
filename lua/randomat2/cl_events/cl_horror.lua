local music

local function IsPlayerValid(p)
    return IsPlayer(p) and p:Alive() and not p:IsSpec()
end

local function ApplyScreenEffects()
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

    ApplyScreenEffects()
end)

net.Receive("randomat_horror_spectator", function()
    hook.Add("PreDrawHalos", "HorrorRandomatHalos", function()
        local alivePlys = {}

        for k, v in ipairs(player.GetAll()) do
            if v:Alive() and not v:IsSpec() then
                alivePlys[k] = v
            end
        end

        halo.Add(alivePlys, Color(255, 0, 0), 0, 0, 1, true, true)
    end)

    -- Remove the fog effect and re-add the skybox to help spectators see better
    hook.Remove("PreDrawSkyBox", "HorrorRemoveSkybox")
    hook.Remove("SetupWorldFog", "HorrorRandomatWorldFog")
    hook.Remove("SetupSkyboxFog", "HorrorRandomatSkyboxFog")
    -- Remove the block on seeing the player info popup
    hook.Remove("TTTTargetIDPlayerBlockIcon", "HorrorRandomatVisionBlockTargetIcon")
    hook.Remove("TTTTargetIDPlayerBlockInfo", "HorrorRandomatVisionBlockTargetInfo")
end)

net.Receive("randomat_horror_respawn", function()
    ApplyScreenEffects()
    -- Remove the spectator halos
    hook.Remove("PreDrawHalos", "HorrorRandomatHalos")
end)

net.Receive("randomat_horror_end", function()
    -- Plays the ending music
    if music then
        timer.Remove("HorrorRandomatMusicLoop")
        RunConsoleCommand("stopsound")

        timer.Simple(0.1, function()
            surface.PlaySound("horror/deep_horrors_scare.mp3")
        end)
    end

    timer.Simple(5, function()
        -- Reset map lighting and stop removing the skybox if the map had one
        render.RedownloadAllLightmaps()
        hook.Remove("PreDrawSkyBox", "HorrorRemoveSkybox")
        -- Remove the fog effect
        hook.Remove("SetupWorldFog", "HorrorRandomatWorldFog")
        hook.Remove("SetupSkyboxFog", "HorrorRandomatSkyboxFog")
        -- Remove the block on seeing the player info popup
        hook.Remove("TTTTargetIDPlayerBlockIcon", "HorrorRandomatVisionBlockTargetIcon")
        hook.Remove("TTTTargetIDPlayerBlockInfo", "HorrorRandomatVisionBlockTargetInfo")
        -- Remove the spectator halos
        hook.Remove("PreDrawHalos", "HorrorRandomatHalos")

        timer.Simple(2, function()
            render.RedownloadAllLightmaps()
        end)
    end)
end)