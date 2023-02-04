local EVENT = {}
EVENT.Title = "Combo: Sharkies and Palp!"
EVENT.Description = "Everyone is sharky + spawns in palp!"
EVENT.id = "cbsharkypalp"

EVENT.Categories = {"eventtrigger", "moderateimpact"}

local event1 = "bleghsound"
local event2 = "palp"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)

    timer.Simple(4, function()
        local tom = GetGlobalEntity("RandomatTomBot")

        if IsValid(tom) and util.IsValidModel("models/player/emperor_palpatine.mdl") then
            Randomat:ForceSetPlayermodel(tom, "models/player/emperor_palpatine.mdl")
        end
    end)
end

function EVENT:Condition()
    return util.IsValidModel("models/bradyjharty/yogscast/sharky.mdl") and Randomat:CanEventRun(event1, true) and Randomat:CanEventRun(event2, true)
end

Randomat:register(EVENT)