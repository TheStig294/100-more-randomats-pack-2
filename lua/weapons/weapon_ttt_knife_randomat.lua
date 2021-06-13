AddCSLuaFile()

SWEP.HoldType               = "knife"

if CLIENT then
   SWEP.PrintName           = "Throwing Knife"
   SWEP.Slot                = 6

   SWEP.ViewModelFlip       = false
   SWEP.ViewModelFOV        = 54
   SWEP.DrawCrosshair       = false

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "knife_desc"
   };

   SWEP.Icon                = "vgui/ttt/icon_knife"
   SWEP.IconLetter          = "j"
end

SWEP.Base                   = "weapon_tttbase"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel             = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage         = 50
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 1.1
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.Delay        = 1.4

SWEP.Kind                   = WEAPON_EQUIP
SWEP.WeaponID               = AMMO_KNIFE

SWEP.IsSilent               = true

-- Pull out faster than standard guns
SWEP.DeploySpeed            = 2

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )


   self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )

   if SERVER then
      local ply = self:GetOwner()
      if not IsValid(ply) then return end

      ply:SetAnimation( PLAYER_ATTACK1 )

      local ang = ply:EyeAngles()

      if ang.p < 90 then
         ang.p = -10 + ang.p * ((90 + 10) / 90)
      else
         ang.p = 360 - ang.p
         ang.p = -10 + ang.p * -((90 + 10) / 90)
      end

      local vel = math.Clamp((90 - ang.p) * 5.5, 550, 800)

      local vfw = ang:Forward()
      local vrt = ang:Right()

      local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())

      src = src + (vfw * 1) + (vrt * 3)

      local thr = vfw * vel + ply:GetVelocity()

      local knife_ang = Angle(-28,0,0) + ang
      knife_ang:RotateAroundAxis(knife_ang:Right(), -90)

      local knife = ents.Create("ttt_knife_proj_randomat")
      if not IsValid(knife) then return end
      knife:SetPos(src)
      knife:SetAngles(knife_ang)

      knife:Spawn()

      knife.Damage = self.Primary.Damage

      knife:SetOwner(ply)

      local phys = knife:GetPhysicsObject()
      if IsValid(phys) then
         phys:SetVelocity(thr)
         phys:AddAngleVelocity(Vector(0, 1500, 0))
         phys:Wake()
      end

      self:Remove()
   end
end

function SWEP:Equip()
   self.Weapon:SetNextPrimaryFire( CurTime() + (self.Primary.Delay * 1.5) )
   self.Weapon:SetNextSecondaryFire( CurTime() + (self.Secondary.Delay * 1.5) )
end

function SWEP:PreDrop()
   -- for consistency, dropped knife should not have DNA/prints
   self.fingerprints = {}
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self:GetOwner()) and self:GetOwner() == LocalPlayer() and self:GetOwner():Alive() then
      RunConsoleCommand("lastinv")
   end
end

if CLIENT then
   local T = LANG.GetTranslation
   function SWEP:DrawHUD()
      local tr = self:GetOwner():GetEyeTrace(MASK_SHOT)

      if tr.HitNonWorld and IsValid(tr.Entity) and tr.Entity:IsPlayer()
         and tr.Entity:Health() < (self.Primary.Damage + 10) then

         local x = ScrW() / 2.0
         local y = ScrH() / 2.0

         surface.SetDrawColor(255, 0, 0, 255)

         local outer = 20
         local inner = 10
         surface.DrawLine(x - outer, y - outer, x - inner, y - inner)
         surface.DrawLine(x + outer, y + outer, x + inner, y + inner)

         surface.DrawLine(x - outer, y + outer, x - inner, y + inner)
         surface.DrawLine(x + outer, y - outer, x + inner, y - inner)

         draw.SimpleText(T("knife_instant"), "TabLarge", x, y - 30, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
      end

      return self.BaseClass.DrawHUD(self)
   end
end