describe('Party with one player left', function()
    ---@type CClientEntityPair
    local leader
    ---@type CClientEntityPair
    local member

    before_each(function()
        leader = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })
        member = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })
        member:setPos(leader:getXPos(), leader:getYPos(), leader:getZPos())

        leader.actions:inviteToParty(member)
        member.actions:acceptPartyInvite()
        assert(leader:getPartySize() == 2, 'party was not formed')
    end)

    it('keeps the leader in charge when the member leaves', function()
        member.actions:leaveParty()
        xi.test.world:skipTime(1)

        local partyLeader = leader:getPartyLeader()
        assert(partyLeader and partyLeader:getID() == leader:getID(), 'party broke up when the member left')
        assert(not member:getPartyLeader(), 'member is still in the party')
    end)

    it('passes leader to the remaining member when the leader leaves', function()
        leader.actions:leaveParty()
        xi.test.world:skipTime(1)

        local partyLeader = member:getPartyLeader()
        assert(partyLeader and partyLeader:getID() == member:getID(), 'party broke up when the leader left')
        assert(not leader:getPartyLeader(), 'old leader is still in the party')
    end)

    it('gives the pooled loot to the remaining player', function()
        leader:addTreasure(xi.item.RABBIT_HIDE)
        member.actions:leaveParty()
        xi.test.world:skipTime(1)

        local pool = leader:getTreasurePool()
        assert(pool, 'leader has no treasure pool')
        pool:flush()

        leader.assert:hasItem(xi.item.RABBIT_HIDE)
    end)

    it('keeps the party when the last player releases their trusts', function()
        member.actions:leaveParty()
        xi.test.world:skipTime(1)

        leader:spawnTrust(xi.magic.spell.SHANTOTTO)
        xi.test.world:skipTime(1)
        leader:clearTrusts()
        xi.test.world:skipTime(1)

        local partyLeader = leader:getPartyLeader()
        assert(partyLeader and partyLeader:getID() == leader:getID(), 'party formed before the trust was disbanded')
    end)
end)

describe('Trust party', function()
    it('disbands when the last trust is released', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })
        player:spawnTrust(xi.magic.spell.SHANTOTTO)
        xi.test.world:skipTime(1)
        assert(player:getPartyLeader(), 'trust did not form a party')

        player:clearTrusts()
        xi.test.world:skipTime(1)

        assert(not player:getPartyLeader(), 'party outlived its last trust')
    end)
end)
