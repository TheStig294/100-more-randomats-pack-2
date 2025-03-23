local EVENT = {}
EVENT.Title = "Watch your step!"
EVENT.Description = "Places shark traps around the map, in 5 seconds!"
EVENT.id = "sharktrap"
EVENT.SingleUse = false

EVENT.Categories = {"entityspawn", "largeimpact"}

CreateConVar("randomat_sharktrap_chance", 20, FCVAR_NONE, "% of possible spawns replaced with shark traps", 1, 100)

function EVENT:Begin()
    timer.Create("SharkTrapRandomatTimer", 5, 1, function()
        self:SmallNotify("Shark traps!")
        -- Get every player's position so the traps aren't spawned too close to a player
        local playerPositions = {}
        local chance = GetConVar("randomat_sharktrap_chance"):GetInt() / 100

        for _, ply in ipairs(self:GetAlivePlayers()) do
            table.insert(playerPositions, ply:GetPos())
        end

        for _, ent in ipairs(ents.GetAll()) do
            local classname = ent:GetClass()
            local pos = ent:GetPos()
            local infoEnt = string.StartWith(classname, "info_")

            -- Using the positions of weapon, ammo and player spawns
            if (string.StartWith(classname, "weapon_") or string.StartWith(classname, "item_") or infoEnt) and not IsValid(ent:GetParent()) and math.random() < chance then
                local tooClose = false

                for _, plyPos in ipairs(playerPositions) do
                    -- 100 * 100 = 10,000, so any traps closer than 100 source units to the player are too close to be placed
                    if math.DistanceSqr(pos.x, pos.y, plyPos.x, plyPos.y) < 10000 then
                        tooClose = true
                        break
                    end
                end

                if not tooClose then
                    local sharkTrap = ents.Create("ttt_shark_trap")
                    sharkTrap:SetPos(pos + Vector(0, 0, 5))

                    -- Don't remove player spawn points
                    if not infoEnt then
                        ent:Remove()
                    end

                    sharkTrap:Spawn()
                end
            end
        end
    end)
end

function EVENT:End()
    timer.Remove("SharkTrapRandomatTimer")
end

function EVENT:Condition()
    return scripted_ents.Get("ttt_shark_trap")
end

function EVENT:GetConVars()
    local sliders = {}

    for _, v in pairs({"chance"}) do
        local name = "randomat_" .. self.id .. "_" .. v

        if ConVarExists(name) then
            local convar = GetConVar(name)

            table.insert(sliders, {
                cmd = v,
                dsc = convar:GetHelpText(),
                min = convar:GetMin(),
                max = convar:GetMax(),
                dcm = 0
            })
        end
    end

    return sliders
end

Randomat:register(EVENT)