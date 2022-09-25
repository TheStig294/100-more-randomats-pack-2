net.Receive("RunOnceRandomatBegin", function()
    local sprintCount = 0

    hook.Add("PlayerBindPress", "RandomatRunOnceBind", function(ply, bind, pressed, code)
        if not ply:Alive() or ply:IsSpec() then return end

        if bind == "+speed" then
            sprintCount = sprintCount + 1

            if sprintCount > 1 then
                net.Start("RunOnceRandomatKill")
                net.SendToServer()
                chat.AddText("Oops! You ran more than once!")
            end
        end
    end)
end)

net.Receive("RunOnceRandomatEnd", function()
    hook.Remove("PlayerBindPress", "RandomatRunOnceBind")
end)