-- Creates the prop hunt popup
net.Receive("YogsPropHuntRandomat", function()
    yogsprophuntpopup = vgui.Create("DFrame")
    local xSize = 712
    local ySize = 178
    -- Places the frame at the centre of the screen
    local pos1 = (ScrW() - xSize) / 2
    local pos2 = (ScrH() - ySize) / 2
    yogsprophuntpopup:SetPos(pos1, pos2)
    yogsprophuntpopup:SetSize(xSize, ySize)
    yogsprophuntpopup:ShowCloseButton(false)
    yogsprophuntpopup:MakePopup()
    yogsprophuntpopup.Paint = function(self, w, h) end
    -- Places the popup image in the centre of the frame
    local image = vgui.Create("DImage", yogsprophuntpopup)
    image:SetImage("materials/vgui/ttt/yogsprophunt/yogsprophunt.png")
    image:SetPos(0, 0)
    image:SetSize(xSize, ySize)
end)

-- Closes the popup once time is up
net.Receive("YogsPropHuntRandomatEnd", function()
    yogsprophuntpopup:Close()
end)