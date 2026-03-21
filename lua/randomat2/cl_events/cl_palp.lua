-- Drawing an outline around the Tom bot when spawned
net.Receive("RandomatPalpDrawHalo", function()
    timer.Simple(0.1, function()
        chat.AddText(CustomChat and Color(0, 128, 255) or Color(156, 253, 156), "Player Angor has joined the game")
    end)

    -- Suppressing the "Bot01 has joined the game" message from appearing
    hook.Add("ChatText", "RandomatPalpSuppressJoinMsg", function(index, name, text, type)
        if type == "joinleave" then return true end
    end)

    -- Support for the Custom Chat mod, which returns true in the "ChatText" hook and prevents the hook above from running
    local customChatOldConnect

    if CustomChat and CustomChat.JoinLeave then
        customChatOldConnect = CustomChat.JoinLeave.showConnect
        CustomChat.JoinLeave.showConnect = true
    end

    timer.Simple(4, function()
        if CustomChat and CustomChat.JoinLeave then
            CustomChat.JoinLeave.showConnect = customChatOldConnect
        end

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
                chat.AddText(CustomChat and Color(0, 128, 255) or Color(156, 253, 156), "Player Angor has left the game")
            end)
        end)
    end)
end)

net.Receive("RandomatPalpSuppressLeaveMessage", function()
    -- Suppressing the "Bot01 has left the game" message from appearing
    hook.Add("ChatText", "RandomatPalpSuppressLeaveMsg", function(index, name, text, type)
        if type == "joinleave" then return true end
    end)

    -- Support for the Custom Chat mod, which returns true in the "ChatText" hook and prevents the hook above from running
    local customChatOldDisconnect

    if CustomChat and CustomChat.JoinLeave then
        customChatOldDisconnect = CustomChat.JoinLeave.showDisconnect
        CustomChat.JoinLeave.showDisconnect = true
    end

    timer.Simple(4, function()
        if CustomChat and CustomChat.JoinLeave then
            CustomChat.JoinLeave.showDisconnect = customChatOldDisconnect
        end

        hook.Remove("ChatText", "RandomatPalpSuppressLeaveMsg")
    end)
end)