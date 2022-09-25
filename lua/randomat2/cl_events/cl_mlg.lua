net.Receive("RandomatMLGGunEffects", function()
    local frame = vgui.Create("DFrame")
    local xSize = ScrW() / 2
    local ySize = ScrH() / 2
    local pos1 = ScrW() / 4
    local pos2 = ScrH() / 4
    frame:SetPos(pos1, pos2)
    frame:SetSize(xSize, ySize)
    frame:ShowCloseButton(false)
    frame:SetTitle("")
    frame.Paint = function(self, w, h) end
    local image = vgui.Create("DImage", frame)
    image:SetImage("vgui/ttt/mlg/mlg" .. math.random(1, 6) .. ".jpg")
    image:SetPos(0, 0)
    image:SetSize(xSize, ySize)

    timer.Create("RandomatMLGShakeTimer", 0.1, 30, function()
        local shakeSize = 20
        if not IsValid(frame) then return end
        frame:SetPos(pos1 + math.random(-shakeSize, shakeSize), pos2 + math.random(-shakeSize, shakeSize))
    end)

    timer.Simple(3, function()
        timer.Remove("RandomatMLGShakeTimer")
        frame:Close()
    end)
end)