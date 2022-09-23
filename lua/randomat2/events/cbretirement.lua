local EVENT = {}
EVENT.Title = "Combo: Retirement fund"
EVENT.Description = "Get anything you buy on the next round + infinite credits for all!"
EVENT.id = "cbretirement"

EVENT.Categories = {"largeimpact", "item", "eventtrigger"}

local event1 = "credits"
local event2 = "future"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)