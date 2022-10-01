local EVENT = {}
EVENT.Title = "Combo: Hunted becomes the hunter"
EVENT.Description = "Prop hunt + killed props become hunters!"
EVENT.id = "cbprophunt"

EVENT.Categories = {"gamemode", "eventtrigger", "rolechange", "largeimpact"}

local event1 = "prophunt"

function EVENT:Begin()
    Randomat:SilentTriggerEvent(event1)

    self:AddHook("DoPlayerDeath", function(ply, attacker, dmg)
        if not Randomat:IsTraitorTeam(ply) then
            ply:SpawnForRound(true)

            timer.Simple(1, function()
                Randomat:SetRole(ply, ROLE_TRAITOR)
            end)
        end
    end)
end

-- Don't run if props joining hunters is a thing anyway with the prop hunt randomat
function EVENT:Condition()
    return Randomat:CanEventRun(event1) and ConVarExists("randomat_prophunt_props_join_hunters") and not GetConVar("randomat_prophunt_props_join_hunters"):GetBool()
end

Randomat:register(EVENT)