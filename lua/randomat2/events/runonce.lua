local EVENT = {}
EVENT.Title = "You can only run once"
EVENT.Description = "Anyone who presses the sprint key more than once, dies!"
EVENT.id = "runonce"

EVENT.Categories = {"largeimpact"}

util.AddNetworkString("RunOnceRandomatBegin")
util.AddNetworkString("RunOnceRandomatKill")
util.AddNetworkString("RunOnceRandomatEnd")

function EVENT:Begin()
    net.Start("RunOnceRandomatBegin")
    net.Broadcast()

    net.Receive("RunOnceRandomatKill", function(len, ply)
        if not ply:Alive() or ply:IsSpec() then return end
        ply:Kill()
        self:SmallNotify(ply:Nick() .. " ran more than once!")
    end)
end

function EVENT:End()
    net.Start("RunOnceRandomatEnd")
    net.Broadcast()
end

-- Only run if sprinting is enabled
function EVENT:Condition()
    return ConVarExists("ttt_sprint_enabled") and GetConVar("ttt_sprint_enabled"):GetBool()
end

Randomat:register(EVENT)