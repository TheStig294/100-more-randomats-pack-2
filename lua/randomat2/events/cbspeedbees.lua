local EVENT = {}
EVENT.Title = "Combo: Speed Bees!"
EVENT.Description = "Everything's fast + hostile bees!"
EVENT.id = "cbspeedbees"

EVENT.Categories = {"entityspawn", "eventtrigger", "largeimpact"}

local event1 = "flash"
local event2 = "bees"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)