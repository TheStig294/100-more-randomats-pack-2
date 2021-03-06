local EVENT = {}
EVENT.Title = ""
EVENT.id = "yogsprophunt"
EVENT.AltTitle = "Prop Hunt (Yogscast intro)"
EVENT.ExtDescription = "Displays the old Yogscast Prop Hunt intro, and turns the game into Prop Hunt!"
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE

EVENT.Categories = {"gamemode", "eventtrigger", "largeimpact"}

util.AddNetworkString("YogsPropHuntRandomat")
util.AddNetworkString("YogsPropHuntRandomatEnd")

function EVENT:Begin()
    -- Trigger the prop hunt randomat
    Randomat:SilentTriggerEvent("prophunt", self.owner)

    -- Tell all clients to start the prop hunt popup
    timer.Simple(1, function()
        net.Start("YogsPropHuntRandomat")
        net.Broadcast()

        -- Play the prop hunt jingle for all players
        for i, ply in pairs(player.GetAll()) do
            ply:EmitSound(Sound("yogsprophunt/prophunt2.mp3"))
        end
    end)

    -- Remove the popup
    timer.Simple(4.8, function()
        net.Start("YogsPropHuntRandomatEnd")
        net.Broadcast()

        -- Print the prop disguiser controls to chat for props (living innocents)
        for i, ply in pairs(self:GetAlivePlayers()) do
            if not Randomat:IsTraitorTeam(ply) then
                ply:ChatPrint("Press 'R' to choose a prop. \nLeft click to disguise.")
            end
        end
    end)
end

function EVENT:Condition()
    -- Only triggers if the 'Prop hunt' randomat can
    return Randomat.Events["prophunt"] ~= nil and Randomat.Events["prophunt"]:Condition()
end

Randomat:register(EVENT)