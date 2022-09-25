local EVENT = {}
EVENT.Title = "Combo: I am speed."
EVENT.Description = "Quake pro + Everything's fast!"
EVENT.id = "cbspeed"

EVENT.Categories = {"eventtrigger", "largeimpact"}

local event1 = "fov"
local event2 = "flash"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)