local originalName
local originalNameExt
local originalNamePlural

net.Receive("MudScientistBegin", function()
    -- Re-naming the Old Man to the "Mud Scientist"
    originalName = ROLE_STRINGS[ROLE_OLDMAN]
    originalNameExt = ROLE_STRINGS_EXT[ROLE_OLDMAN]
    originalNamePlural = ROLE_STRINGS_PLURAL[ROLE_OLDMAN]
    ROLE_STRINGS[ROLE_OLDMAN] = "Mud Scientist"
    ROLE_STRINGS_EXT[ROLE_OLDMAN] = "A Mud Scientist"
    ROLE_STRINGS_PLURAL[ROLE_OLDMAN] = "Mud Scientists"
end)

net.Receive("MudScientistEnd", function()
    -- Resets the names of roles
    if originalName then
        ROLE_STRINGS[ROLE_OLDMAN] = originalName
        ROLE_STRINGS_EXT[ROLE_OLDMAN] = originalNameExt
        ROLE_STRINGS_PLURAL[ROLE_OLDMAN] = originalNamePlural
    end
end)