local popup

-- Shows the Yogscast Murder popup for the 'Prop Hunt (Yogscast Intro)' randomat
net.Receive("YogsPropHuntRandomat", function()
    popup = vgui.Create("DFrame")
    -- Resolution of the popup image file, so the popup frame is covered by the popup itself
    local xSize = 712
    local ySize = 178
    local pos1 = (ScrW() - xSize) / 2
    local pos2 = (ScrH() - ySize) / 2
    popup:SetPos(pos1, pos2)
    popup:SetSize(xSize, ySize)
    popup:ShowCloseButton(false)
    popup:MakePopup()
    popup.Paint = function(self, w, h) end
    -- The image covers the whole frame window
    local image = vgui.Create("DImage", popup)
    image:SetImage("materials/vgui/ttt/yogsprophunt/yogsprophunt.png")
    image:SetPos(0, 0)
    image:SetSize(xSize, ySize)
end)

net.Receive("YogsPropHuntRandomatEnd", function()
    if IsValid(popup) then
        popup:Close()
        popup = nil
    end
end)