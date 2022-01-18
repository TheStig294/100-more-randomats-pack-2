local playSound = true

net.Receive("YayRandomatActivate", function()
    for i, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:IsSpec() then
            ply:Celebrate(nil, true)
        end
    end

    -- Prevent the sound overlapping for multiple kills to prevent it being too loud
    if playSound then
        LocalPlayer():Celebrate("clown.wav", false)
        playSound = false

        timer.Simple(1, function()
            playSound = true
        end)
    end
end)