local EVENT = {}
EVENT.Title = "RELEASE THE PLANES!"
EVENT.Description = "Forces everyone to throw a plane!"
EVENT.id = "planes"

EVENT.Categories = {"entityspawn", "largeimpact"}

local capCvar = CreateConVar("randomat_planes_cap", 12, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Maximum number of planes spawned", 0, 20)

local delayCvar = CreateConVar("randomat_planes_delay", 3, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Delay before planes are spawned", 0.1, 5.0)

function EVENT:Begin()
    local cap = capCvar:GetInt()
    local count = 0

    timer.Create("RandomatPlanesDelay", delayCvar:GetFloat(), 1, function()
        -- Spawn as many planes as there are alive players
        for _, ply in ipairs(self:GetAlivePlayers()) do
            local plane = ents.Create("ttt_paper_plane_proj")
            local vsrc = ply:GetShootPos()
            local vang = ply:GetAimVector()
            local vvel = ply:GetVelocity()
            local vthrow = vvel + vang * 250
            plane:SetPos(vsrc + vang * 50)
            plane:SetAngles(ply:GetAimVector():Angle() + Angle(0, 180, 0))
            plane:Spawn()
            plane:SetThrower(ply)
            local phys = plane:GetPhysicsObject()

            if IsValid(phys) then
                phys:SetVelocity(vthrow)
                phys:SetMass(200)
            end

            count = count + 1
            if count >= cap then break end
        end
    end)
end

function EVENT:End()
    timer.Remove("RandomatPlanesDelay")
end

function EVENT:Condition()
    return weapons.Get("weapon_ttt_paper_plane") ~= nil
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in pairs({"cap", "delay"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = v == "delay" and 1 or 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)