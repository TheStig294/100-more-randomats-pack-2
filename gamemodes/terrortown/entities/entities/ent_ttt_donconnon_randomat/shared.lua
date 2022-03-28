AddCSLuaFile()
ENT.Base = "doncmk2_en"

if SERVER then
    ENT.DonconDamage = GetConVar("randomat_donconnons_damage"):GetFloat()
    ENT.DonconSpeed = GetConVar("randomat_donconnons_speed"):GetFloat()
    ENT.DonconRange = GetConVar("randomat_donconnons_range"):GetFloat()
    ENT.DonconScale = GetConVar("randomat_donconnons_scale"):GetFloat() -- Size of Doncon
    ENT.DonconTurn = GetConVar("randomat_donconnons_turn"):GetFloat() -- How fast Homing Doncon will rotate to face target. Keep very low.
    ENT.LockOnDecayTime = GetConVar("randomat_donconnons_lockondecaytime"):GetFloat() -- How much time for lock on to decay.
end