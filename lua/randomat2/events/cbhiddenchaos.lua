local EVENT = {}
EVENT.Title = "Combo: Hidden Chaos"
EVENT.Description = "A randomat triggers every 30 seconds + Randomat alerts are hidden!"
EVENT.id = "cbhiddenchaos"

EVENT.Categories = {"eventtrigger", "largeimpact"}

local event1 = "secret"
local event2 = "intensifies"

function EVENT:Begin()
    timer.Simple(0.1, function()
        Randomat:SilentTriggerEvent(event1)
        Randomat:SilentTriggerEvent(event2)
    end)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)