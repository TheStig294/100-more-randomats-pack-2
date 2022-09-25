local EVENT = {}
EVENT.Title = "There's a little Doncon inside us all..."
EVENT.Description = "A baby doncombine spawns where people die"
EVENT.id = "doncombine"

EVENT.Categories = {"biased_traitor", "biased", "entityspawn", "deathtrigger", "largeimpact"}

util.AddNetworkString("DoncombineRandomatBegin")
util.AddNetworkString("DoncombineRandomatEnd")

function EVENT:Begin()
    -- Spawn doncombine on player dying
    self:AddHook("PostPlayerDeath", function(ply)
        if not IsPlayer(ply) then return end
        local pos = ply:GetPos()
        local wep = ents.Create("weapon_doncombinesummoner")
        local tracedata = {}
        tracedata.pos = pos
        -- Function from the doncombine weapon itself
        place_doncom(tracedata, wep)

        timer.Simple(0, function()
            for _, ent in ipairs(ents.FindByClass("npc_hunter")) do
                ent:SetModelScale(0.25, 0.000001)
                ent:SetHealth(100)
            end
        end)
    end)

    -- Fix doncombines going back to normal size after dying
    net.Start("DoncombineRandomatBegin")
    net.Broadcast()

    -- Halves the usual damage from the baby doncombine
    self:AddHook("ScalePlayerDamage", function(ply, hitgroup, dmg)
        local attacker = dmg:GetAttacker()
        if not IsValid(attacker) or attacker:GetClass() ~= "npc_hunter" then return end
        dmg:ScaleDamage(0.5)
    end)
end

function EVENT:End()
    net.Start("DoncombineRandomatEnd")
    net.Broadcast()
end

function EVENT:Condition()
    return weapons.Get("weapon_doncombinesummoner") ~= nil and isfunction(place_doncom)
end

Randomat:register(EVENT)