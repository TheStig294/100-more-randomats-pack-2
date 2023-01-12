local EVENT = {}
EVENT.Title = "Combo: Careful there cowboy..."
EVENT.Description = "A traitor and detective have a pistol showdown + everyone else is a jester"
EVENT.id = "cbcowboy"
EVENT.IsEnabled = false

EVENT.Categories = {"rolechange", "eventtrigger", "largeimpact"}

local event1 = "jesters"
local event2 = "pistols"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)
    Randomat:SilentTriggerEvent(event2)

    -- Give the detective enough health to survive two hits from the duelling pistol
    for _, ply in ipairs(player.GetAll()) do
        if Randomat:IsGoodDetectiveLike(ply) then
            ply:SetHealth(1000)
            break
        end
    end
end

function EVENT:Condition()
    return Randomat:CanEventRun(event1) and Randomat:CanEventRun(event2)
end

Randomat:register(EVENT)