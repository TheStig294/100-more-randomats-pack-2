local EVENT = {}
EVENT.Title = "Everything's Upgraded!"
EVENT.Description = "All weapons are automatically upgraded"
EVENT.id = "papauto"

EVENT.Categories = {"largeimpact", "item"}

function EVENT:Begin()
    timer.Create("AutoPaPRandomat", 1, 0, function()
        for _, ent in ents.Iterator() do
            -- Check for a valid entity, if the entity is a weapon, if the entity is a TTT weapon, and not the "holstered" weapon
            -- Don't try to upgrade weapons more than once, as a weapon could error from being upgraded off the ground, and block this for loop from looping though all weapons
            if IsValid(ent) and not ent.PAPAutoUpgrade and ent.Kind and ent:IsWeapon() and WEPS.GetClass(ent) ~= "weapon_ttt_unarmed" then
                ent.PAPAutoUpgrade = true
                TTTPAP:ApplyRandomUpgrade(ent)
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("AutoPaPRandomat")
end

-- Check the Pack-a-Punch item is installed
function EVENT:Condition()
    return TTTPAP and TTTPAP.ApplyRandomUpgrade
end

Randomat:register(EVENT)