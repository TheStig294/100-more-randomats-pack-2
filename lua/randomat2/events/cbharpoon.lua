local EVENT = {}
EVENT.Title = "Combo: HARPOON BATTLE ROYALE!"
EVENT.Description = "LAST ONE STANDING WINS!"
EVENT.id = "cbharpoon"

EVENT.Categories = {"gamemode", "eventtrigger", "item", "largeimpact"}

local event1 = "harpoon"
local event2 = "battleroyale"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)