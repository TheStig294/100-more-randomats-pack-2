net.Receive("HwapoonRandomatPlaySound", function()
    local hwapoonSound = net.ReadString()
    surface.PlaySound(hwapoonSound)
end)