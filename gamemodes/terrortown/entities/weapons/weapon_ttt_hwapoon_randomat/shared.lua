AddCSLuaFile()
SWEP.Base = "ttt_m9k_harpoon"
SWEP.PrintName = "Hwapoon!"
SWEP.PlayedSound = false
SWEP.Kind = 340
SWEP.Slot = 6

if SERVER then
    util.AddNetworkString("RandomatHwapoonSound")
end

if CLIENT then
    net.Receive("RandomatHwapoonSound", function()
        local hwapoonSound = net.ReadString()
        surface.PlaySound(hwapoonSound)
    end)
end

function SWEP:PrimaryAttack()
    if SERVER and not self.PlayedSound then
        self.PlayedSound = true
        local hwapoonSound = "hwapoon/hwapoon" .. math.random(1, 4) .. ".mp3"
        net.Start("RandomatHwapoonSound")
        net.WriteString(hwapoonSound)
        net.Broadcast()
    end

    self.BaseClass.PrimaryAttack(self)

    if SERVER then
        self:Remove()
    end
end