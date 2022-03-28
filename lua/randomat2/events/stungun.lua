local EVENT = {}
EVENT.Title = "UNLIMITED POWEEERRRRRR!"
EVENT.Description = "Infinite stunguns for all!"
EVENT.id = "stungun"

EVENT.Categories = {"item", "largeimpact"}

function EVENT:Begin()
    for i, ply in pairs(self:GetAlivePlayers(true)) do
        ply:Give("stungun")
        Randomat:CallShopHooks(false, "stungun", ply)
    end

    hook.Add("Think", "RandomatStungunAmmo", function()
        for i, ply in pairs(self:GetAlivePlayers(true)) do
            if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "stungun" then
                ply:GetActiveWeapon():SetClip1(ply:GetActiveWeapon().Primary.ClipSize)
            end
        end
    end)
end

function EVENT:Condition()
    return weapons.Get("stungun") ~= nil
end

function EVENT:End()
    hook.Remove("Think", "RandomatStungunAmmo")
end

Randomat:register(EVENT)