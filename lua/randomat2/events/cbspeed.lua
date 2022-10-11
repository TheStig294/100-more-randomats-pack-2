local EVENT = {}
EVENT.Title = "Combo: I am speed."
EVENT.Description = "Quake pro + Everything's fast!"
EVENT.id = "cbspeed"

EVENT.Categories = {"eventtrigger", "largeimpact"}

local event1 = "fov"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    local ts = game.GetTimeScale()
    game.SetTimeScale(ts + GetConVar("randomat_flash_scale"):GetInt() / 100)
end

function EVENT:End()
    game.SetTimeScale(1)
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and ConVarExists("randomat_flash_scale")
end

Randomat:register(EVENT)