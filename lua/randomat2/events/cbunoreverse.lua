local EVENT = {}
EVENT.Title = "Combo: no u"
EVENT.Description = "Damage is delayed + everyone has an uno reverse!"
EVENT.id = "cbunoreverse"

EVENT.Categories = {"item", "eventtrigger", "largeimpact"}

local event1 = "delayedreaction"
local event2 = "uno"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)