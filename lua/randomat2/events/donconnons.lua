local EVENT = {}

CreateConVar("randomat_donconnons_timer", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Time between being given donconnons")

CreateConVar("randomat_donconnons_strip", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "The event strips your other weapons")

CreateConVar("randomat_donconnons_weaponid", "weapon_ttt_donconnon_randomat", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Id of the weapon given")

CreateConVar("randomat_donconnons_damage", "1000", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Donconnon Damage", 0, 1000)

CreateConVar("randomat_donconnons_speed", "350", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Donconnon Speed", 0, 1000)

CreateConVar("randomat_donconnons_range", "2000", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Donconnon Range", 0, 10000)

CreateConVar("randomat_donconnons_scale", "0.2", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Donconnon Size", 0, 5)

CreateConVar("randomat_donconnons_turn", "0", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Donconnon Turn Speed, set to 0 to disable homing", 0, 0.001)

CreateConVar("randomat_donconnons_lockondecaytime", "15", {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Seconds until homing stops", 0, 60)

EVENT.Title = "O Rubber Tree..."
EVENT.Description = "Donconnons for all!"
EVENT.id = "donconnons"

EVENT.Categories = {"item", "moderateimpact"}

if GetConVar("randomat_donconnons_strip"):GetBool() then
    EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
end

function EVENT:Begin()
    timer.Create("RandomatDonconnonsTimer", GetConVar("randomat_donconnons_timer"):GetInt(), 0, function()
        for i, ply in pairs(self:GetAlivePlayers(true)) do
            if table.Count(ply:GetWeapons()) ~= 1 or (table.Count(ply:GetWeapons()) == 1 and ply:GetActiveWeapon():GetClass() ~= "doncmk2_swep") then
                if GetConVar("randomat_donconnons_strip"):GetBool() then
                    ply:StripWeapons()
                    ply:SetFOV(0, 0.2)
                end

                ply:Give(GetConVar("randomat_donconnons_weaponid"):GetString())
            end
        end
    end)

    -- Jesters are immune to the donconnon, so make them innocents
    for i, ply in ipairs(self:GetAlivePlayers()) do
        if Randomat:IsJesterTeam(ply) then
            Randomat:SetRole(ply, ROLE_INNOCENT)
        end
    end
end

function EVENT:End()
    timer.Remove("RandomatDonconnonsTimer")
end

function EVENT:Condition()
    return weapons.Get(GetConVar("randomat_donconnons_weaponid"):GetString()) ~= nil
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in ipairs({"timer", "damage", "speed", "range", "lockondecaytime"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)
            convar:Revert()

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    for _, v in ipairs({"scale"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)
            convar:Revert()

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 2
            })
        end
    end

    for _, v in ipairs({"turn"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)
            convar:Revert()

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 5
            })
        end
    end

    local checks = {}

    for _, v in ipairs({"strip"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)
            convar:Revert()

            table.insert(checks, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    local textboxes = {}

    for _, v in ipairs({"weaponid"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(textboxes, {
                cmd = v,
                dsc = convar:GetHelpText()
            })
        end
    end

    return sliders, checks, textboxes
end

Randomat:register(EVENT)