local EVENT = {}
EVENT.Title = "Combo: CoD Zombies"
EVENT.Description = "Everyone gets a CoD weapon + Some zombies to fight..."
EVENT.id = "cbzombies"

EVENT.Categories = {"entityspawn", "eventtrigger", "item", "largeimpact"}

local event1 = "mysterybox"
local event2 = "doground"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)