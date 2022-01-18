net.Receive("CForClownRandomatActivate", function()
    hook.Add("PlayerBindPress", "CForClownOverrideShopButton", function(ply, bind, pressed)
        if (string.find(bind, "+menu_context")) then
            ply:ChatPrint("You have turned into a clown!")
            net.Start("CForClownRandomatActivate")
            net.SendToServer()
            hook.Remove("PlayerBindPress", "CForClownOverrideShopButton")

            return true
        end
    end)
end)

net.Receive("CForClownRandomatEnd", function()
    hook.Remove("PlayerBindPress", "CForClownOverrideShopButton")
end)