local EVENT = {}
EVENT.Title = "Drink up!"
EVENT.Description = "Everyone gets a random COD Zombies perk bottle"
EVENT.id = "drinkup"

EVENT.Categories = {"item", "smallimpact"}

local hagenPerks = false
local hoffPerks = false

function EVENT:Begin()
    if hagenPerks then
        local perks = {EQUIP_DOUBLETAP, EQUIP_JUGGERNOG, EQUIP_PHD, EQUIP_SPEEDCOLA, EQUIP_STAMINUP}

        for _, ply in pairs(self:GetAlivePlayers()) do
            local perk = perks[math.random(1, #perks)]
            ply:GiveEquipmentItem(tonumber(perk))
            Randomat:CallShopHooks(true, perk, ply)
        end
    elseif hoffPerks then
        local perks = {"zombies_perk_doubletap", "zombies_perk_juggernog", "zombies_perk_phdflopper", "zombies_perk_staminup", "zombies_perk_vultureaid"}

        for _, ply in ipairs(self:GetAlivePlayers()) do
            local perk = perks[math.random(1, #perks)]
            ply:Give(perk)
            ply:SelectWeapon(perk)
            Randomat:CallShopHooks(false, perk, ply)
        end
    end
end

function EVENT:Condition()
    if EQUIP_DOUBLETAP and EQUIP_JUGGERNOG and EQUIP_PHD and EQUIP_SPEEDCOLA and EQUIP_STAMINUP then
        hagenPerks = true
    end

    if weapons.Get("zombies_perk_base") ~= nil then
        hoffPerks = true
    end

    return hagenPerks or hoffPerks
end

Randomat:register(EVENT)