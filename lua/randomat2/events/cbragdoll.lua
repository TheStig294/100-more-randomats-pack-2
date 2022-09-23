local EVENT = {}
EVENT.Title = "Combo: Weeee!"
EVENT.Description = "You ragdoll while in the air + moon gravity!"
EVENT.id = "cbragdoll"

EVENT.Categories = {"fun", "eventtrigger", "largeimpact"}

local event1 = "ragdoll"
local oldGravity

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    oldGravity = GetConVar("sv_gravity"):GetFloat()
    RunConsoleCommand("sv_gravity", "120")
end

function EVENT:End()
    if oldGravity then
        -- tostring() to prevent floating point nonsense convar changes showing up in chat for the rest of the map
        RunConsoleCommand("sv_gravity", tostring(oldGravity))
    end
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1)
end

Randomat:register(EVENT)