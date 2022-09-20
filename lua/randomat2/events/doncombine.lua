local EVENT = {}
EVENT.Title = "There's a Doncon inside us all..."
EVENT.Description = "A doncombine spawns where people die"
EVENT.id = "doncombine"

EVENT.Categories = {"biased_traitor", "biased", "entityspawn", "deathtrigger", "largeimpact"}

function EVENT:Begin()
    self:AddHook("PostPlayerDeath", function(ply)
        if not IsPlayer(ply) then return end
        local pos = ply:GetPos()
        local wep = ents.Create("weapon_doncombinesummoner")
        local tracedata = {}
        tracedata.pos = pos
        place_doncom(tracedata, wep)
    end)
end

function EVENT:Condition()
    return weapons.Get("weapon_doncombinesummoner") ~= nil and isfunction(place_doncom)
end

Randomat:register(EVENT)