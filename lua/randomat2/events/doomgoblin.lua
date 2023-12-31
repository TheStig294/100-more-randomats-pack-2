local EVENT = {}
EVENT.Title = "Doom Goblin"
EVENT.Description = "Spawns a loot goblin, they can trigger bad randomats until killed!"
EVENT.id = "doomgoblin"

EVENT.Categories = {"rolechange", "fun", "largeimpact"}

local function TriggerChoose(goblin)
    if not IsValid(goblin) or not goblin:IsLootGoblin() or not goblin:Alive() or goblin:IsSpec() then return end
end

function EVENT:Begin()
    local goblin
    local jester
    local alivePlys = self:GetAlivePlayers(true)

    -- First, search for an existing loot goblin, or a jester
    for _, ply in ipairs(alivePlys) do
        if ply:IsLootGoblin() then
            goblin = ply
            break
        elseif ply:IsJester() then
            jester = ply
            break
        end
    end

    -- If no jester or loot goblin is found, choose a random player
    -- (Player table was shuffled by the "true" argument passed to self:GetAlivePlayers())
    if not IsValid(goblin) then
        goblin = jester or alivePlys[1]
        Randomat:SetRole(goblin, ROLE_LOOTGOBLIN)
    end

    -- Now that we have our goblin, trigger the "Choose an event!" randomat on them on a timer
    timer.Create("DoomGoblinInitialTrigger", 5, 1, function()
        TriggerChoose(goblin)

        timer.Create("DoomGoblinRandomat", 30, 0, function()
            TriggerChoose(goblin)
        end)
    end)
end

function EVENT:End()
    timer.Remove("DoomGoblinInitialTrigger")
    timer.Remove("DoomGoblinRandomat")
end

function EVENT:Condition()
    return ConVarExists("ttt_lootgoblin_enabled")
end
-- Randomat:register(EVENT)