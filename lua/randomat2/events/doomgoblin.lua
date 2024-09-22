local EVENT = {}
EVENT.Title = "Doom Goblin"
EVENT.Description = "Spawns a loot goblin who can trigger bad randomats until killed!"
EVENT.id = "doomgoblin"

EVENT.Categories = {"rolechange", "fun", "largeimpact"}

local badRandomats = {"butter", "cantstop", "downunder", "fogofwar", "fov", "looseclips", "opposite", "ragdoll", "wasteful", "crabwalk", "doomed", "elevator", "friction", "hud", "make", "runonce", "thirdperson"}

local function TriggerChoose(goblin)
    if IsValid(goblin) and goblin:IsLootGoblin() and goblin:Alive() and not goblin:IsSpec() then
        local atLeastOneCanTrigger = false

        for _, e in ipairs(badRandomats) do
            if Randomat:CanEventRun(e) then
                atLeastOneCanTrigger = true
                break
            end
        end

        if atLeastOneCanTrigger then
            Randomat:SilentTriggerEvent("choose", goblin, false, false, nil, nil, badRandomats)
        end
    end
end

function EVENT:Begin()
    local goblin
    local alivePlys = self:GetAlivePlayers(true)

    -- First, search for an existing loot goblin, or a jester
    for _, ply in ipairs(alivePlys) do
        if ply:IsLootGoblin() then
            goblin = ply
            break
        end
    end

    if not IsValid(goblin) then
        for _, ply in ipairs(alivePlys) do
            if ply:IsJesterTeam() then
                goblin = ply
                break
            end
        end

        -- If no jester or loot goblin is found, choose a random player
        -- (Player table was shuffled by the "true" argument passed to self:GetAlivePlayers())
        if not IsValid(goblin) then
            goblin = alivePlys[1]
        end

        Randomat:SetRole(goblin, ROLE_LOOTGOBLIN)
        SendFullStateUpdate()
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
    return Randomat:CanRoleSpawn(ROLE_LOOTGOBLIN) and Randomat:CanEventRun("choose")
end

Randomat:register(EVENT)