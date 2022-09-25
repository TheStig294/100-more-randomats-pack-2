local EVENT = {}
EVENT.Title = "Combo: Weird roles"
EVENT.Description = "Traitors are bees + Someone's a \"Mud Scientist\""
EVENT.id = "cbweirdroles"

EVENT.Categories = {"rolechange", "eventtrigger", "largeimpact"}

local event1 = "mudscientist"
local event2 = "beeswin"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)