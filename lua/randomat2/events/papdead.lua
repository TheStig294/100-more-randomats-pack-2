-- Credit goes to Malivil for creating the bulk of this event
-- I modified it to give out weapon upgrades rather than shop items
local EVENT = {}
util.AddNetworkString("RdmtPAPDeadBegin")
util.AddNetworkString("RdmtPAPDeadEnd")

CreateConVar("randomat_papdead_charge_time", 60, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many seconds before the dead can give an upgrade", 10, 120)

EVENT.Title = "Upgrades from the dead"
EVENT.Description = "Allows dead players to give the living a single weapon upgrade"
EVENT.id = "papdead"
EVENT.Type = EVENT_TYPE_SPECTATOR_UI

EVENT.Categories = {"spectator", "biased_innocent", "biased", "largeimpact"}

function EVENT:Begin()
    for _, p in ipairs(player.GetAll()) do
        p:SetNWInt("RdmtPAPDeadPower", 0)
        p:SetNWBool("RdmtPAPDeadSent", false)

        if not p:Alive() or p:IsSpec() then
            net.Start("RdmtPAPDeadBegin")
            net.Send(p)
        end
    end

    self:AddHook("PlayerSpawn", function(ply)
        if not IsValid(ply) then return end
        net.Start("RdmtPAPDeadEnd")
        net.Send(ply)
    end)

    self:AddHook("PlayerDeath", function(victim, entity, killer)
        if not IsValid(victim) then return end
        net.Start("RdmtPAPDeadBegin")
        net.Send(victim)
    end)

    self:AddHook("KeyPress", function(ply, key)
        if key == IN_JUMP and ply:GetNWInt("RdmtPAPDeadPower", 0) == 100 then
            local target = ply:GetObserverMode() ~= OBS_MODE_ROAMING and ply:GetObserverTarget() or nil

            -- Try to give this upgrade to the current spectator target
            if IsValid(target) and target:IsPlayer() then
                if TTTPAP:CanOrderPAP(target) then
                    ply:PrintMessage(HUD_PRINTTALK, "You upgraded " .. target:Nick() .. "'s held weapon")
                    ply:PrintMessage(HUD_PRINTCENTER, "You upgraded " .. target:Nick() .. "'s held weapon")
                    target:PrintMessage(HUD_PRINTTALK, ply:Nick() .. " upgraded your held weapon")
                    target:PrintMessage(HUD_PRINTCENTER, ply:Nick() .. " upgraded your held weapon")
                    TTTPAP:OrderPAP(target, true)
                    -- Reset the player's power
                    ply:SetNWInt("RdmtPAPDeadPower", 0)
                    ply:SetNWBool("RdmtPAPDeadSent", true)
                    -- Hide the UI
                    net.Start("RdmtPAPDeadEnd")
                    net.Send(ply)
                elseif table.IsEmpty(target:GetWeapons()) then
                    ply:PrintMessage(HUD_PRINTTALK, target:Nick() .. " has no weapons!")
                    ply:PrintMessage(HUD_PRINTCENTER, target:Nick() .. " has no weapons!")
                elseif not IsValid(target:GetActiveWeapon()) then
                    ply:PrintMessage(HUD_PRINTTALK, target:Nick() .. " isn't holding a valid weapon")
                    ply:PrintMessage(HUD_PRINTCENTER, target:Nick() .. " isn't holding a valid weapon")
                else
                    ply:PrintMessage(HUD_PRINTTALK, target:Nick() .. " can't use your upgrade")
                    ply:PrintMessage(HUD_PRINTCENTER, target:Nick() .. " can't use your upgrade")

                    return
                end
            end
        end
    end)

    local tick = GetConVar("randomat_papdead_charge_time"):GetInt() / 100

    timer.Create("RdmtPAPDeadPowerTimer", tick, 0, function()
        for _, p in ipairs(self:GetDeadPlayers()) do
            if not p:GetNWBool("RdmtPAPDeadSent", false) then
                local power = p:GetNWInt("RdmtPAPDeadPower", 0)

                if power < 100 then
                    p:SetNWInt("RdmtPAPDeadPower", power + 1)
                end
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("RdmtPAPDeadPowerTimer")
    net.Start("RdmtPAPDeadEnd")
    net.Broadcast()
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"charge_time"}) do
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