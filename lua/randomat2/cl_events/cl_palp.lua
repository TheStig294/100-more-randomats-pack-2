-- Drawing an outline around the Tom bot when spawned
net.Receive("RandomatPalpDrawHalo", function()
    timer.Simple(0.1, function()
        chat.AddText(Color(156, 253, 156), "Player Angor has joined the game")
    end)

    -- Suppressing the "Bot01 has joined the game" message from appearing
    hook.Add("ChatText", "RandomatPalpSupressJoinMsg", function(index, name, text, type)
        if type == "joinleave" then return true end
    end)

    timer.Simple(4, function()
        hook.Remove("ChatText", "RandomatPalpSupressJoinMsg")
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

        -- Changing the name of the tom bot to "Angor" on the scoreboard
        hook.Add("TTTScoreboardPlayerName", "RandomatPalpScoreboard", function(ply, client, currentName)
            if not IsValid(tom) then
                hook.Remove("TTTScoreboardPlayerName", "RandomatPalpScoreboard")

                return
            end

            if ply == tom then return "Angor" end
        end)

        -- Changing the name of the tom bot to "Angor" when players look at them
        hook.Add("TTTTargetIDPlayerName", "RandomatPalpName", function(ply, client, text, clr)
            if not IsValid(tom) then
                hook.Remove("TTTTargetIDPlayerName", "RandomatPalpName")

                return
            end

            if ply == tom then return "Angor", clr end
        end)

        -- Changing the name of the tom bot to "Angor" when players look at them
        hook.Add("TTTScoringSummaryRender", "RandomatPalpNameSummary", function(ply, roleFileName, groupingRole, roleColor, nameLabel, startingRole, finalRole)
            if not IsValid(tom) then
                hook.Remove("TTTScoringSummaryRender", "RandomatPalpNameSummary")

                return
            end

            if ply == tom then return roleFileName, groupingRole, roleColor, "Angor" end
        end)

        -- Removing the halo at the end of the round and displaying a fake leave notification in chat
        hook.Add("TTTEndRound", "RandomatPalpRemoveHalo", function()
            hook.Remove("PreDrawHalos", "RandomatPalpHalo")
            hook.Remove("TTTEndRound", "RandomatPalpRemoveHalo")

            timer.Simple(0.1, function()
                chat.AddText(Color(156, 253, 156), "Player Angor has left the game")
            end)
        end)
    end)
end)