net.Receive("DoncombineRandomatBegin", function()
    hook.Add("CreateClientsideRagdoll", "DoncombineRandomatRagdollFix", function(owner, rag)
        if not IsValid(owner) or owner:GetClass() ~= "npc_hunter" then return end
        local pos = rag:GetPos()
        rag:Remove()
        -- Creates a "poof" smoke cloud when the doncombine is killed
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        util.Effect("AntlionGib", effectdata)
    end)
end)

net.Receive("DoncombineRandomatEnd", function()
    hook.Remove("CreateClientsideRagdoll", "DoncombineRandomatRagdollFix")
end)