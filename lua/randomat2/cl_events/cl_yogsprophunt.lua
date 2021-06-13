net.Receive("YogsPropHuntRandomat", function()
	yogsprophuntpopup = vgui.Create("DFrame")
	local xSize = 712
	local ySize = 178
    local pos1 = (ScrW()-xSize)/2
    local pos2 = (ScrH()-ySize)/2
    yogsprophuntpopup:SetPos(pos1,pos2)
    yogsprophuntpopup:SetSize(xSize,ySize)
    yogsprophuntpopup:ShowCloseButton(false)
    yogsprophuntpopup:MakePopup()
	yogsprophuntpopup.Paint = function(self, w, h) end
	
	local image = vgui.Create("DImage", yogsprophuntpopup)
    image:SetImage("materials/vgui/ttt/yogsprophunt/yogsprophunt.png")
    image:SetPos(0,0)
    image:SetSize(xSize,ySize)   
end)

net.Receive("YogsPropHuntRandomatEnd", function()
	yogsprophuntpopup:Close()
end)