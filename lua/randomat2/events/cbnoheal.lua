local EVENT = {}
EVENT.Title = "Combo: Clock's ticking..."
EVENT.Description = "No healing + lose health over time"
EVENT.id = "cbnoheal"

EVENT.Categories = {"eventtrigger", "largeimpact"}

local event1 = "feelingill"
local event2 = "noheal"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)