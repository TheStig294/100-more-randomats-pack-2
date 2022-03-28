AddCSLuaFile()
SWEP.Base = "doncmk2_swep"
SWEP.PrintName = "Baby Donconnon"

if SERVER then
    SWEP.DonconDamage = GetConVar("randomat_donconnons_damage"):GetFloat()
    SWEP.DonconSpeed = GetConVar("randomat_donconnons_speed"):GetFloat()
    SWEP.DonconRange = GetConVar("randomat_donconnons_range"):GetFloat()
    SWEP.DonconScale = GetConVar("randomat_donconnons_scale"):GetFloat() -- Size of Doncon
    SWEP.DonconTurn = GetConVar("randomat_donconnons_turn"):GetFloat() -- How fast Homing Doncon will rotate to face target. Keep very low.
    SWEP.LockOnDecayTime = GetConVar("randomat_donconnons_lockondecaytime"):GetFloat() -- How much time for lock on to decay.
end

function SWEP:PrimaryAttack()
    self:EmitSound("donc_fire")
    if CLIENT then return end
    local ent = ents.Create("ent_ttt_donconnon_randomat")
    if not IsValid(ent) then return end
    ent:SetPos(self:GetOwner():EyePos() + self:GetOwner():GetAimVector() * 200)
    ent:SetAngles(self:GetOwner():EyeAngles())
    ent:SetOwner(self:GetOwner())
    ent.SWEP = self

    if self.LockOnTarget ~= "none" then
        ent.Homing = true
        ent.Target = self.LockOnTarget
    else
        ent.Homing = false
    end

    ent.DonconDamage = self.DonconDamage
    ent.DonconSpeed = self.DonconSpeed
    ent.DonconRange = self.DonconRange
    ent.DonconScale = self.DonconScale
    ent.DonconTurn = self.DonconTurn
    ent.Sound = "donc_rubber_0" .. tostring(math.random(1, 3))
    ent:Spawn()
    self:UpdateHalo("none")
    self:Remove()
end