local EVENT = {}
CreateConVar("randomat_beebarrels_count", 3, FCVAR_NONE, "Number of bee barrels spawned per person", 1, 5)
CreateConVar("randomat_beebarrels_range", 100, FCVAR_NONE, "Distance bee barrels spawn from the player", 50, 200)
CreateConVar("randomat_beebarrels_timer", 60, FCVAR_NONE, "Time between bee barrel spawns", 10, 120)
EVENT.Title = "NOT THE BEE BARRELS!"
EVENT.Description = "Spawns bee barrels around every player repeatedly until the event ends"
EVENT.id = "beebarrels"

EVENT.Categories = {"entityspawn", "moderateimpact"}

local function BeebarrelDamage(target, dmginfo)
    if target:GetClass() == "prop_physics" then
        local model = target:GetModel()

        if model == "models/bee_drum/beedrum001_explosive.mdl" and dmginfo:GetDamage() >= 1 then
            local pos = target:GetPos()

            timer.Create("barrelbeesspawn", 0.1, 3, function()
                local spos = pos + Vector(math.random(-50, 50), math.random(-50, 50), math.random(0, 100))
                local headBee = ents.Create("npc_manhack")
                headBee:SetPos(spos)
                headBee:Spawn()
                headBee:Activate()
                headBee:SetNPCState(NPC_STATE_ALERT)
                local bee = ents.Create("prop_dynamic")
                bee:SetModel("models/lucian/props/stupid_bee.mdl")
                bee:SetPos(spos)
                bee:SetParent(headBee)
                headBee:SetNoDraw(true)
                headBee:SetHealth(10)
            end)
        end
    end
end

local function SpawnBeeBarrel(pos, range, min_range, ignore_negative)
    local ent = ents.Create("prop_physics")
    if not IsValid(ent) then return end

    if not min_range then
        min_range = range
    end

    local x = math.random(min_range, range)
    local y = math.random(min_range, range)

    if not ignore_negative then
        if math.random(0, 1) == 1 then
            x = -x
        end

        if math.random(0, 1) == 1 then
            y = -y
        end
    end

    ent:SetModel("models/bee_drum/beedrum001_explosive.mdl")
    ent:SetPos(pos + Vector(x, y, math.random(5, range)))
    ent:Spawn()
    local phys = ent:GetPhysicsObject()

    if not IsValid(phys) then
        ent:Remove()

        return
    end
end

local function TriggerBeeBarrels()
    local plys = {}
    hook.Add("EntityTakeDamage", "BeebarrelDamage", BeebarrelDamage)

    for k, ply in ipairs(player.GetAll()) do
        if not ply:IsSpec() then
            plys[k] = ply
        end
    end

    local range = GetConVar("randomat_beebarrels_range"):GetInt()

    for _, ply in pairs(plys) do
        if ply:Alive() and not ply:IsSpec() then
            for _ = 1, GetConVar("randomat_beebarrels_count"):GetInt() do
                SpawnBeeBarrel(ply:GetPos(), range)
            end
        end
    end
end

function EVENT:Begin()
    TriggerBeeBarrels()
    timer.Create("RdmtBeeBarrelSpawnTimer", GetConVar("randomat_beebarrels_timer"):GetInt(), 0, TriggerBeeBarrels)
end

function EVENT:End()
    timer.Remove("RdmtBeeBarrelSpawnTimer")
    hook.Remove("EntityTakeDamage", "BeebarrelDamage")
end

function EVENT:Condition()
    return util.IsValidModel("models/lucian/props/stupid_bee.mdl")
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"count", "range", "timer"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)