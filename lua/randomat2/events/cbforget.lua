local EVENT = {}
EVENT.Title = "Combo: Don't forget!"
EVENT.Description = "You can only jump once + Players explode on death"
EVENT.id = "cbforget"

EVENT.Categories = {"deathtrigger", "eventtrigger", "largeimpact"}

local event1 = "jump"
local event2 = "mayhem"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)