-- Weapon given to the 'Mud Scientist' during the 'What's the Mud Scientist?' randomat
AddCSLuaFile()
SWEP.Base = "weapon_tttbase"
SWEP.PrintName = "Mud Analysis Device"
SWEP.Category = WEAPON_CATEGORY_ROLE
SWEP.Kind = WEAPON_ROLE
SWEP.Slot = 8
local IDLE = 0
local BUSY = 1
local zap = Sound("ambient/energy/zap7.wav")
local beep = Sound("buttons/button17.wav")
local hum = Sound("items/nvg_on.wav")
SWEP.State = IDLE
SWEP.BeginTime = CurTime()
SWEP.ScannedEnts = {}

function SWEP:Initialize()
    self.ScannedEnts = {}

    return self.BaseClass.Initialize(self)
end

function SWEP:PrimaryAttack()
    if self.State ~= IDLE then return end
    local owner = self:GetOwner()
    local tr = owner:GetEyeTrace(MASK_SHOT_HULL)
    local pos = owner:GetPos()

    if tr.HitPos:Distance(pos) > 64 then
        owner:PrintMessage(HUD_PRINTCENTER, "ERROR: OBJECT TOO FAR AWAY")

        return
    end

    local ent = tr.Entity

    if self.ScannedEnts[ent] then
        owner:PrintMessage(HUD_PRINTCENTER, "Already scanned! Where's someone, a prop, weapon or ammo box?")

        return
    end

    if ent:IsWorld() or IsValid(ent) then
        owner:EmitSound(zap, 75, math.random(98, 102), 0.25)
        self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
        if not IsFirstTimePredicted() then return end
        self:StartScan(ent)
    end
end

function SWEP:StartScan(ent)
    local name = "SOMETHING"
    local class = ent:GetClass()
    local owner = self:GetOwner()

    if ent == game.GetWorld() then
        name = "WORLD"
    elseif IsPlayer(ent) then
        name = ent:Nick()
    elseif string.StartWith(class, "weapon_") then
        name = "WEAPON"
    elseif string.StartWith(class, "prop_") then
        name = "PROP"
    else
        name = "..."
    end

    self.State = BUSY
    self.BeginTime = CurTime()
    self.Target = ent
    owner:EmitSound(hum, 75, math.random(98, 102), 0.5)
    owner:PrintMessage(HUD_PRINTCENTER, "ANALYSING " .. string.upper(name))

    timer.Simple(1.5, function()
        if self.State ~= BUSY then return end
        owner:PrintMessage(HUD_PRINTCENTER, "ANALYSING " .. string.upper(name))
    end)
end

function SWEP:Think()
    if self.State == BUSY then
        if self.BeginTime + 4 <= CurTime() then
            self:ShowMessage()
        elseif not self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():GetEyeTrace(MASK_SHOT_HULL).Entity ~= self.Target then
            local owner = self:GetOwner()
            owner:PrintMessage(HUD_PRINTCENTER, "ABORTED")
            owner:EmitSound(zap, 75, math.random(98, 102), 0.25)
            self.State = IDLE
        end
    end
end

local messages = {"Hmmm... yes, this mud here is made out of mud.", "Ah, mud. Finally.", "Could it be? The mud my research was leading to?", "I need more time! This mud won't analyse itself!", "Yes, this mud will make a great discovery!", "No mud, no matter. Research must continue!", "Wait until researchers see this mud!", "Yes, this mud will change the world!", "...in this world nothing can be said to be certain, except mud and science", "Ah, what a fine mud sample!", "The mud must flow...", "I an one with the mud, the mud is with me...", "Ah, this sample will progress science!", "This mud will be seen by a great many people of science!", "The research must go on!", "So much mud, so little time...", "Careful! This is a delicate mud sample!", "This mud is forwarding a great scientific endeavour!"}

function SWEP:ShowMessage()
    if not IsFirstTimePredicted() then return end
    if self.State == IDLE then return end
    local owner = self:GetOwner()

    if not self.ScannedEnts[self.Target] then
        sound.Play(beep, owner:GetPos(), 75, 100, 0.5)
        self.ScannedEnts[self.Target] = true
    end

    timer.Create("MudScientistScanMessageCooldown", 0.1, 1, function()
        local message = messages[math.random(#messages)]
        owner:PrintMessage(HUD_PRINTCENTER, message)
        owner:PrintMessage(HUD_PRINTTALK, message)
        owner:PrintMessage(HUD_PRINTTALK, "No. of unique scanned objects: " .. table.Count(self.ScannedEnts))

        timer.Simple(1.5, function()
            owner:PrintMessage(HUD_PRINTCENTER, message)
        end)
    end)

    self.State = IDLE
end