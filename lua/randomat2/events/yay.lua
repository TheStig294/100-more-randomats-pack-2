local EVENT = {}
EVENT.Title = "Yay!"
EVENT.Description = "There is a clown and a jester, but everyone sprays confetti when someone dies"
EVENT.id = "yay"

EVENT.Categories = {"rolechange", "deathtrigger", "largeimpact"}

util.AddNetworkString("YayRandomatActivate")

function EVENT:Begin()
    local clown = false
    local jester = false
    local alivePlys = self:GetAlivePlayers(true)

    -- If there is a clown or jester already then there is no need to turn someone into one
    for _, ply in ipairs(alivePlys) do
        if ply:GetRole() == ROLE_CLOWN then
            clown = ply
        elseif ply:GetRole() == ROLE_JESTER then
            jester = ply
        end
    end

    -- Else, turn someone into either a jester or clown
    if not clown then
        for _, ply in ipairs(alivePlys) do
            if ply:GetRole() ~= ROLE_JESTER and not Randomat:IsTraitorTeam(ply) then
                Randomat:SetRole(ply, ROLE_CLOWN)
                ply:SetCredits(GetConVar("ttt_clown_credits_starting"):GetInt())
                break
            end
        end
    end

    if not jester then
        for _, ply in ipairs(alivePlys) do
            if ply:GetRole() ~= ROLE_CLOWN and not Randomat:IsTraitorTeam(ply) then
                Randomat:SetRole(ply, ROLE_JESTER)
                break
            end
        end
    end

    -- Let the end-of-round report know roles have changed
    SendFullStateUpdate()

    -- Play the clown activate sound and confetti on everyone when someone dies
    self:AddHook("PostPlayerDeath", function()
        net.Start("YayRandomatActivate")
        net.Broadcast()
    end)
end

function EVENT:Condition()
    local nonTraitorCount = 0

    for _, ply in player.Iterator() do
        if ply:Alive() and not ply:IsSpec() and not Randomat:IsTraitorTeam(ply) then
            nonTraitorCount = nonTraitorCount + 1
        end
    end

    return cvars.Bool("ttt_clown_enabled", false) and cvars.Bool("ttt_jester_enabled", false) and nonTraitorCount >= 3
end

Randomat:register(EVENT)