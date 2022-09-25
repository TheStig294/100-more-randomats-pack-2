local EVENT = {}
EVENT.Title = "Combo: Chaos!"
EVENT.Description = "When you buy something, everyone gets it + someone else gets a credit!"
EVENT.id = "cbchaos"

EVENT.Categories = {"largeimpact", "item", "eventtrigger"}

local event1 = "communist"
local event2 = "trickledown"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)