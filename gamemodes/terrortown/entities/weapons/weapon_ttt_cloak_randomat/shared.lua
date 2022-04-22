AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Invisibility Cloak"
    SWEP.Slot = 7
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.HoldType = "knife"
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP
SWEP.AutoSpawnable = false
SWEP.ViewModelFOV = 67
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.NoSights = true
SWEP.AllowDrop = false
SWEP.InitialEmitSound = true

function SWEP:PrimaryAttack()
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    if not IsPlayer(owner) then return end
    owner:GetViewModel():SendViewModelMatchingSequence(12)
    owner:SetColor(Color(255, 255, 255, 10))
    owner:SetMaterial("sprites/heatwave")
    owner:SetNWBool("RdmtInvisible", true)

    if self.InitialEmitSound then
        self:EmitSound("horror/kikikimamama.mp3", 0)
        self.InitialEmitSound = false
    end

    timer.Create("InvisibilityCloakWhisperSoundCooldown" .. owner:SteamID64(), 2, 1, function()
        if IsValid(self) then
            self.InitialEmitSound = true
        else
            timer.Remove("InvisibilityCloakWhisperSoundCooldown" .. owner:SteamID64())
        end
    end)

    timer.Create("InvisibilityCloakWhisperSound" .. owner:SteamID64(), 10, 0, function()
        if IsValid(self) then
            self:EmitSound("horror/kikikimamama.mp3", 0)
        else
            timer.Remove("InvisibilityCloakWhisperSound" .. owner:SteamID64())
        end
    end)
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if not IsPlayer(owner) then return end
    owner:SetColor(Color(255, 255, 255, 255))
    owner:SetMaterial("models/glass")
    owner:SetNWBool("RdmtInvisible", false)
    timer.Remove("InvisibilityCloakWhisperSound" .. owner:SteamID64())

    return true
end

function SWEP:PreDrop()
    self:Holster()
end

function SWEP:OnDrop()
    self:Remove()
end

function SWEP:ShouldDropOnDie()
    return false
end