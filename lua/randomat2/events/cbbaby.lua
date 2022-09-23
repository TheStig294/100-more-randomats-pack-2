local EVENT = {}
EVENT.Title = "Combo: Looking ridiculous"
EVENT.Description = "Everyone has small legs + a big head!"
EVENT.id = "cbbaby"

EVENT.Categories = {"fun", "eventtrigger", "smallimpact"}

local event1 = "legday"
local event2 = "bighead"
local oldScale

function EVENT:Begin()
    oldScale = GetConVar("randomat_bighead_scale"):GetFloat()
    GetConVar("randomat_bighead_scale"):SetFloat(5.00)
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)
end

function EVENT:End()
    if oldScale then
        RunConsoleCommand("randomat_bighead_scale", oldScale)
    end
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)