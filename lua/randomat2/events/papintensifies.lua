local EVENT = {}

local timerCvar = CreateConVar("randomat_papintensifies_time", 30, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds between upgrading weapons", 10, 180)

EVENT.Title = "Pack-a-Punch Intensifies"
EVENT.Description = "Upgrades everyone's held weapon every " .. timerCvar:GetInt() .. " seconds!"
EVENT.id = "papintensifies"

EVENT.Categories = {"largeimpact", "item"}

function EVENT:Begin()
    self.Description = "Upgrades everyone's held weapon every " .. timerCvar:GetInt() .. " seconds!"

    timer.Create("PackAPunchIntensifiesRandomatTimer", timerCvar:GetInt(), 0, function()
        self:SmallNotify("Upgrade time!")

        for _, ply in pairs(self:GetAlivePlayers()) do
            TTTPAP:OrderPAP(ply)
        end
    end)
end

function EVENT:End()
    timer.Remove("PackAPunchIntensifiesRandomatTimer")
end

-- Check the Pack-a-Punch item is installed
function EVENT:Condition()
    return TTTPAP and TTTPAP.OrderPAP
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"time"}) do
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