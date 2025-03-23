local EVENT = {}
CreateConVar("randomat_uno_time", 3, FCVAR_NONE, "How long the uno reverse card lasts", 1, 10)
EVENT.Title = "You just triggered my trap card!"
EVENT.Description = "Everyone gets an UNO reverse card"
EVENT.id = "uno"

EVENT.Categories = {"item", "smallimpact"}

function EVENT:Begin()
    unoRandomat = true
    original_uno_length = tonumber(GetConVar("ttt_uno_reverse_length"):GetFloat())
    GetConVar("ttt_uno_reverse_length"):SetFloat(GetConVar("randomat_uno_time"):GetInt())

    for i, ply in pairs(self:GetAlivePlayers()) do
        timer.Simple(0.1, function()
            ply:Give("weapon_unoreverse")
            Randomat:CallShopHooks(false, "weapon_unoreverse", ply)
        end)
    end
end

function EVENT:End()
    if unoRandomat then
        GetConVar("ttt_uno_reverse_length"):SetFloat(original_uno_length)
    end
end

function EVENT:Condition()
    return weapons.Get("weapon_unoreverse") ~= nil
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in pairs({"time"}) do
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