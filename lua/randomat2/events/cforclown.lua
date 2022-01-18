local EVENT = {}
EVENT.Title = "C is for Clown"
EVENT.Description = "Someone can press the buy menu button to become a clown!"
EVENT.id = "cforclown"
util.AddNetworkString("CForClownRandomatActivate")
util.AddNetworkString("CForClownRandomatEnd")
local chosenPlayer

function EVENT:Begin()
    chosenPlayer = self:GetAlivePlayers(true)[1]

    timer.Simple(1, function()
        chosenPlayer:PrintMessage(HUD_PRINTCENTER, "You have been chosen!")
        chosenPlayer:ChatPrint("YOU HAVE BEEN CHOSEN!\nPress 'C' at any point this round to become a clown.")
    end)

    net.Start("CForClownRandomatActivate")
    net.Send(chosenPlayer)

    net.Receive("CForClownRandomatActivate", function(len, ply)
        if ply == chosenPlayer then
            Randomat:SetRole(chosenPlayer, ROLE_CLOWN)
            SendFullStateUpdate()
        end
    end)
end

function EVENT:End()
    if chosenPlayer then
        net.Start("CForClownRandomatEnd")
        net.Send(chosenPlayer)
        chosenPlayer = nil
    end
end

function EVENT:Condition()
    return ConVarExists("ttt_clown_enabled") and GetConVar("ttt_clown_enabled"):GetBool()
end

Randomat:register(EVENT)