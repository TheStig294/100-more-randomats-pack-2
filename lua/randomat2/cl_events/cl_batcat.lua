local bats = {}

net.Receive("BatCatRandomatSetBatModel", function()
    local batOwner = net.ReadEntity()
    -- Don't add a bat to yourself, since looking down makes it hard to see
    if LocalPlayer() == batOwner then return end
    local addBat = net.ReadBool()

    if addBat then
        if IsValid(batOwner) then
            batOwner:SetNoDraw(true)
            local bat = ClientsideModel("models/weapons/gamefreak/w_nessbat.mdl")
            local pos = batOwner:GetPos()
            pos.z = pos.z + 20
            bat:SetPos(pos)
            bat:SetAngles(Angle(90, 0, 0))
            bat:SetParent(batOwner)
            bat:Spawn()
            bat:PhysWake()
            bats[batOwner] = bat
        end

        hook.Add("TTTPrepareRound", "BatCatRandomatReset", function()
            for _, ply in ipairs(player.GetAll()) do
                ply:SetNoDraw(false)
            end

            for _, bat in pairs(bats) do
                if IsValid(bat) then
                    bat:Remove()
                end
            end

            hook.Remove("TTTPrepareRound", "BatCatRandomatReset")
        end)
    else
        -- If we're not adding a bat, we're removing it from a player instead
        bats[batOwner]:Remove()
        bats[batOwner] = nil
    end
end)