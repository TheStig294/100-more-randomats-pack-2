net.Receive("YayRandomatActivate", function()
    for i, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:IsSpec() then
            ply:Celebrate(nil, true)
        end
    end

    LocalPlayer():Celebrate("clown.wav", false)
end)