local EVENT = {}
EVENT.Title = "Combo: Hunted becomes the hunter"
EVENT.Description = "Prop hunt + killed props become hunters!"
EVENT.id = "cbprophunt"

EVENT.Categories = {"gamemode", "eventtrigger", "rolechange", "largeimpact"}

local event1 = "prophunt"
local propsRespawn

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    propsRespawn = GetConVar("randomat_prophunt_props_join_hunters"):GetBool()
    RunConsoleCommand("randomat_prophunt_props_join_hunters", "1")
end

function EVENT:End()
    if propsRespawn ~= nil and propsRespawn == false then
        RunConsoleCommand("randomat_prophunt_props_join_hunters", "0")
    end
end

-- Don't run if props joining hunters is a thing anyway with the prop hunt randomat
function EVENT:Condition()
    return Randomat:CanEventRun(event1) and ConVarExists("randomat_prophunt_props_join_hunters") and not GetConVar("randomat_prophunt_props_join_hunters"):GetBool()
end

Randomat:register(EVENT)