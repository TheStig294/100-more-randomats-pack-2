local EVENT = {}
EVENT.Title = "Auto-PaP"
EVENT.Description = "All weapons are upgraded"
EVENT.id = "papauto"

EVENT.Categories = {"largeimpact", "item"}

function EVENT:Begin()
    timer.Create("AutoPaPRandomat", 1, 0, function()
        for _, SWEP in ipairs(ents.GetAll()) do
            -- Check for a valid entity, if the entity is a weapon, if the entity is a TTT weapon, and not the "holstered" weapon
            if IsValid(SWEP) and SWEP:IsWeapon() and SWEP.Kind and WEPS.GetClass(SWEP) ~= "weapon_ttt_unarmed" then
                TTTPAP:ApplyRandomUpgrade(SWEP)
            end
        end
    end)

    self:AddHook("PlayerSwitchWeapon", function(ply, oldSWEP, newSWEP)
        if IsValid(newSWEP) and newSWEP.PAPUpgrade and newSWEP.PAPUpgrade.desc then
            if not IsValid(newSWEP.LastPlayerSwitchedTo) or newSWEP.LastPlayerSwitchedTo ~= ply then
                ply:ChatPrint("PAP UPGRADE: " .. newSWEP.PAPUpgrade.desc)
            end

            newSWEP.LastPlayerSwitchedTo = ply
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