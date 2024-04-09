local EVENT = {}
EVENT.Title = "Bat with a cat!"
EVENT.Description = "Everyone's a bat, with a cat!"
EVENT.id = "batcat"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE

EVENT.Categories = {"modelchange", "item", "largeimpact"}

local batModel = "models/weapons/gamefreak/w_nessbat.mdl"

local catSWEPs = {"weapon_catgun", "weapon_valenok", "weapon_cat"}

local bats = {}

-- Changes a player into a bat...
local function SetBatModel(ent)
    ent:SetNoDraw(true)
    local bat = ents.Create("prop_dynamic")
    bat:SetModel(batModel)
    local pos = ent:GetPos()
    pos.z = pos.z + 20
    bat:SetPos(pos)
    bat:SetAngles(Angle(90, 0, 0))
    bat:SetParent(ent)
    bat:Spawn()
    bat:PhysWake()
    bats[ent] = bat
end

function EVENT:Begin()
    -- Find which cat item is installed
    local catClass = nil
    local catKind = nil

    for _, class in ipairs(catSWEPs) do
        local SWEP = weapons.Get(class)

        if SWEP then
            catClass = class
            catKind = SWEP.Kind
            break
        end
    end

    bats = {}

    -- Sets everyone's model to a bat
    for _, ply in ipairs(self:GetAlivePlayers()) do
        SetBatModel(ply)
    end

    -- Sets a player's model to a bat if they respawn
    self:AddHook("PlayerSpawn", function(ply)
        timer.Simple(1, function()
            SetBatModel(ply)
        end)
    end)

    -- Set corpses to a bat model
    self:AddHook("TTTOnCorpseCreated", function(corpse)
        SetBatModel(corpse)
    end)

    -- Remove parented bat models when players die
    self:AddHook("PostPlayerDeath", function(ply)
        if IsValid(bats[ply]) then
            bats[ply]:Remove()
        end

        bats[ply] = nil
    end)

    -- If the installed weapon is the cat gun, force everyone to use it and give it infinite ammo!
    if catClass == "weapon_catgun" then
        self.Description = "Everyone's a bat, with only a cat!"

        -- Remove all floor weapons
        for _, ent in pairs(ents.GetAll()) do
            if ent.AutoSpawnable then
                ent:Remove()
            end
        end

        -- Give everyone an undroppable catgun
        timer.Simple(0.1, function()
            for i, ply in pairs(self:GetAlivePlayers()) do
                for _, wep in pairs(ply:GetWeapons()) do
                    if wep.Kind == WEAPON_HEAVY then
                        ply:StripWeapon(wep:GetClass())
                    end
                end

                -- Reset FOV to unscope weapons if they were possibly scoped in
                ply:SetFOV(0, 0.2)
                local catgun = ply:Give("weapon_catgun")
                catgun.AllowDrop = false
                ply:SelectWeapon("weapon_catgun")
            end
        end)

        -- Give the catgun infinite ammo
        timer.Simple(1, function()
            self:AddHook("Think", function()
                for _, v in pairs(self:GetAlivePlayers()) do
                    if IsValid(v:GetActiveWeapon()) and v:GetActiveWeapon():GetClass() == "weapon_catgun" then
                        v:GetActiveWeapon():SetClip1(v:GetActiveWeapon().Primary.ClipSize)
                    end
                end
            end)
        end)
    else
        -- Otherwise for the other cat SWEPs, just force-give the item and make everyone hold it
        timer.Simple(0.1, function()
            for i, ply in pairs(self:GetAlivePlayers()) do
                for _, wep in pairs(ply:GetWeapons()) do
                    if wep.Kind == catKind then
                        ply:StripWeapon(wep:GetClass())
                    end
                end

                -- Reset FOV to unscope weapons if they were possibly scoped in
                ply:SetFOV(0, 0.2)
                local cat = ply:Give(catClass)
                cat.AllowDrop = false
                ply:SelectWeapon(catClass)
            end
        end)
    end
end

-- Undo changing everyone to bats if the bat model exists
function EVENT:End()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetNoDraw(false)
    end

    for _, bat in pairs(bats) do
        if IsValid(bat) then
            bat:Remove()
        end
    end
end

-- Only run if a cat SWEP exists
function EVENT:Condition()
    local isCat = false

    for _, class in ipairs(catSWEPs) do
        local SWEP = weapons.Get(class)

        if SWEP then
            -- Check "Oscar the cat" is actually a TTT weapon,
            -- i.e. the joke weapons pack mod is installed and not just the base SWEP
            if class == "weapon_valenok" and not SWEP.Kind then continue end
            isCat = true
            break
        end
    end

    return isCat and util.IsValidModel(batModel)
end

Randomat:register(EVENT)