local EVENT = {}
EVENT.Title = "Pack-a-Punch for all!"
EVENT.Description = "Upgrades the weapon you're holding"
EVENT.id = "papupgrade"

EVENT.Categories = {"largeimpact", "item"}

function EVENT:Begin()
    for _, ply in pairs(self:GetAlivePlayers()) do
        TTTPAP:OrderPAP(ply)
    end
end

-- Check the Pack-a-Punch item is installed
function EVENT:Condition()
    return TTTPAP and TTTPAP.OrderPAP
end

Randomat:register(EVENT)