local EVENT = {}
EVENT.Title = ""
EVENT.id = "yogsmurder"
EVENT.AltTitle = "Murder (Yogscast intro)"
EVENT.ExtDescription = "Displays the old Yogscast Gmod Murder intro, and turns the game into Murder!"

EVENT.Categories = {"gamemode", "eventtrigger", "largeimpact"}

util.AddNetworkString("YogsMurderRandomat")
util.AddNetworkString("YogsMurderRandomatEnd")
-- Declares this randomat a 'Weapon Override' randomat, meaning it cannot trigger if another Weapon Override randomat has triggered in the round
EVENT.Type = EVENT_TYPE_WEAPON_OVERRIDE

function EVENT:Begin()
    -- After 1 second, start the special popup and sound for all players
    timer.Simple(1, function()
        net.Start("YogsMurderRandomat")
        net.Broadcast()

        for i, ply in pairs(self:GetPlayers()) do
            ply:EmitSound(Sound("yogsmurder/murder.mp3"))
        end
    end)

    -- After 5 seconds, remove the popup
    timer.Simple(5, function()
        net.Start("YogsMurderRandomatEnd")
        net.Broadcast()

        -- Trigger the murder randomat
        Randomat:SilentTriggerEvent("murder", self.owner)
    end)
end

function EVENT:Condition()
    -- Only triggers if the 'Murder' randomat can
    return Randomat.Events["murder"] ~= nil and Randomat.Events["murder"]:Condition()
end

Randomat:register(EVENT)
