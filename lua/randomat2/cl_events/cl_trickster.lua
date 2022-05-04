local traitorButtonTableOrig

net.Receive("TricksterRandomatBegin", function()
    traitorButtonTableOrig = table.Copy(TRAITOR_BUTTON_ROLES)

    for id, _ in pairs(ROLE_STRINGS) do
        TRAITOR_BUTTON_ROLES[tonumber(id)] = true
    end
end)

net.Receive("TricksterRandomatEnd", function()
    TRAITOR_BUTTON_ROLES = traitorButtonTableOrig
end)