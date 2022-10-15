net.Receive("randomat_paranoia_begin", function()
    -- Draws the spectator sounds UI
    local client = LocalPlayer()

    hook.Add("HUDPaint", "ParanoiaRandomatUI", function()
        local width, height, margin = 200, 25, 20
        local x = ScrW() / 2 - width / 2
        local y = ScrH() - (margin / 2 + height)
        local progress = client:GetNWInt("ParanoiaRandomatSpectatorPower", 0)
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
end)

net.Receive("randomat_paranoia_spectator_sound", function()
    local spectatorSound = net.ReadString()
    surface.PlaySound(spectatorSound)
end)

net.Receive("randomat_paranoia_end", function()
    hook.Remove("HUDPaint", "ParanoiaRandomatUI")
end)