local EVENT = {}
EVENT.Title = ""
EVENT.id = "yogsprophunt"
EVENT.AltTitle = "Prop Hunt (Yogscast intro)"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE
util.AddNetworkString("YogsPropHuntRandomat")
util.AddNetworkString("YogsPropHuntRandomatEnd")

function EVENT:Begin()
    Randomat:SilentTriggerEvent("prophunt", self.owner)

    timer.Simple(1, function()
        net.Start("YogsPropHuntRandomat")
        net.Broadcast()

        for i, ply in pairs(player.GetAll()) do
            ply:EmitSound(Sound("yogsprophunt/prophunt2.wav"))
        end
    end)

    timer.Simple(4.8, function()
        net.Start("YogsPropHuntRandomatEnd")
        net.Broadcast()

        for i, ply in pairs(player.GetAll()) do
            ply:ChatPrint("Press 'R' to choose a prop. \nLeft click to disguise.")
        end
    end)
end

function EVENT:Condition()
    if not ConVarExists("ttt_randomat_prophunt") then return false end
    if Randomat:CanEventRun("prophunt") then return true end

    return false
end

Randomat:register(EVENT)

hook.Add("TTTPrepareRound", "YogsPropHuntRandomatConvarCheck", function()
    if ConVarExists("ttt_randomat_prophunt") and GetConVar("ttt_randomat_yogsprophunt"):GetBool() then
        GetConVar("ttt_randomat_prophunt"):SetBool(true)
    end
end)