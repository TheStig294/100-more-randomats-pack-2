-- Drawing an outline around the Tom bot when spawned
net.Receive("RandomatPalpDrawHalo", function()
    timer.Simple(0.1, function()
        chat.AddText(Color(156, 253, 156), "Player Angor has joined the game")
    end)

    -- Suppressing the "Bot01 has joined the game" message from appearing
    hook.Add("ChatText", "RandomatPalpSuppressJoinMsg", function(index, name, text, type)
        if type == "joinleave" then return true end
    end)

    timer.Simple(4, function()
        hook.Remove("ChatText", "RandomatPalpSuppressJoinMsg")
        local tom = player.GetBots()[#player.GetBots()]

        local tomTable = {tom}

        -- Adding a halo around Tom for the first round he's spawned in
        hook.Add("PreDrawHalos", "RandomatPalpHalo", function()
            if not IsValid(tom) then
                hook.Remove("PreDrawHalos", "RandomatPalpHalo")

                return
            end

            -- Don't draw a halo around Tom if he's dead
            if not tom:Alive() or tom:IsSpec() then return end
            halo.Add(tomTable, Color(0, 255, 0), 0, 0, 1, true, true)
        end)

        -- Removing the halo at the end of the round and displaying a fake leave notification in chat
        hook.Add("TTTEndRound", "RandomatPalpRemoveHalo", function()
            hook.Remove("PreDrawHalos", "RandomatPalpHalo")
            hook.Remove("TTTEndRound", "RandomatPalpRemoveHalo")

            timer.Simple(4, function()
                chat.AddText(Color(156, 253, 156), "Player Angor has left the game")
            end)
        end)
    end)
end)

net.Receive("RandomatPalpSuppressLeaveMessage", function()
    -- Suppressing the "Bot01 has left the game" message from appearing
    hook.Add("ChatText", "RandomatPalpSuppressLeaveMsg", function(index, name, text, type)
        if type == "joinleave" then return true end
    end)

    timer.Simple(4, function()
        hook.Remove("ChatText", "RandomatPalpSuppressLeaveMsg")
    end)
end)