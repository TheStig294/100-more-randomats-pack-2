AddCSLuaFile()

if SERVER then
    util.AddNetworkString("randomat_invisibility_cloak_uncloak")
end

if CLIENT then
    SWEP.PrintName = "Shadow Cloak"
    SWEP.Slot = 7
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
    -- Plays the jumpscare sound if someone is looking at the killer as they uncloak
    LocalPlayer().SeenKiller = false

    net.Receive("randomat_invisibility_cloak_uncloak", function()
        if LocalPlayer().GetEyeTrace then
            local ent = LocalPlayer():GetEyeTrace().Entity

            if IsPlayer(ent) and ent:IsKiller() and not LocalPlayer().SeenKiller then
                surface.PlaySound("horror/deep_horrors_scare.mp3")
                LocalPlayer().SeenKiller = true
            end
        end
    end)
end

SWEP.HoldType = "knife"
SWEP.Base = "weapon_tttbase"
SWEP.Kind = WEAPON_EQUIP
SWEP.AutoSpawnable = false
SWEP.ViewModelFOV = 67
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = nil
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.NoSights = true
SWEP.AllowDrop = false
SWEP.InitialEmitSound = true
SWEP.FirstCloakMessage = true

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
    owner:DrawShadow(false)
    Randomat:SetPlayerInvisible(owner)

    if SERVER then
        if self.InitialEmitSound then
            self:EmitSound("horror/kikikimamama.mp3", 0)
            self.InitialEmitSound = false
        end

        -- Displays hints on using the invisibility cloak when first brought out
        if self.FirstCloakMessage then
            owner:PrintMessage(HUD_PRINTCENTER, "You appear as a shadow, stay in the dark!")

            timer.Simple(1, function()
                owner:PrintMessage(HUD_PRINTCENTER, "You appear as a shadow, stay in the dark!")
            end)

            timer.Simple(3, function()
                owner:PrintMessage(HUD_PRINTCENTER, "Your flashlight is barely visible to others")
            end)

            timer.Simple(4, function()
                owner:PrintMessage(HUD_PRINTCENTER, "Your flashlight is barely visible to others")
            end)

            self.FirstCloakMessage = false
        end

        -- Prevents spamming the whisper sound for everyone repeatedly 
        timer.Create("InvisibilityCloakWhisperSoundCooldown" .. owner:SteamID64(), 2, 1, function()
            if IsValid(self) then
                self.InitialEmitSound = true
            else
                timer.Remove("InvisibilityCloakWhisperSoundCooldown" .. owner:SteamID64())
            end
        end)

        -- Repeatedly plays the whispering sound while the killer is invisible, to alert everyone else
        timer.Create("InvisibilityCloakWhisperSound" .. owner:SteamID64(), 10, 0, function()
            if IsValid(self) then
                self:EmitSound("horror/kikikimamama.mp3", 0)
            else
                timer.Remove("InvisibilityCloakWhisperSound" .. owner:SteamID64())
            end
        end)
    end
end

function SWEP:Holster()
    local owner = self:GetOwner()
    if not IsPlayer(owner) then return end
    owner:DrawShadow(true)
    Randomat:SetPlayerVisible(owner)

    if SERVER then
        timer.Remove("InvisibilityCloakWhisperSound" .. owner:SteamID64())
        -- Plays a jumpscare sound if someone is looking directly at someone uncloaking
        net.Start("randomat_invisibility_cloak_uncloak")
        net.Broadcast()
    end

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

function SWEP:OnRemove()
    if CLIENT then
        LocalPlayer().SeenKiller = false
    end
end