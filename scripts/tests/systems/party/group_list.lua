describe('Party list packets', function()
    local function readU32(data, offset)
        return data[offset] + data[offset + 1] * 0x100 + data[offset + 2] * 0x10000 + data[offset + 3] * 0x1000000
    end

    local function memberNumbers(player)
        local numbers = {}
        for _, packet in pairs(player.packets:getIncoming()) do
            if packet.type == 0x0DD then
                numbers[readU32(packet.data, 0x04)] = packet.data[0x1A]
            end
        end

        return numbers
    end

    local function formParty(leader, ...)
        for _, member in ipairs({ ... }) do
            leader.actions:inviteToParty(member)
            member.actions:acceptPartyInvite()
        end
    end

    it('numbers each recipient 0 and the rest of their zone from 1', function()
        local leader  = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })
        local member  = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })
        local faraway = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        formParty(leader, member, faraway)
        faraway:gotoZone(xi.zone.SOUTHERN_SAN_DORIA)
        xi.test.world:tick()

        for _, player in ipairs({ leader, member, faraway }) do
            player.packets:clear()
        end

        leader:reloadParty()
        xi.test.world:tick()

        local forLeader = memberNumbers(leader)
        assert(forLeader[leader:getID()] == 0, 'the leader should see themselves as 0')
        assert(forLeader[member:getID()] == 1, 'the leader should see the member as 1')
        assert(forLeader[faraway:getID()] == 0, 'a member in another zone has no number')

        local forMember = memberNumbers(member)
        assert(forMember[member:getID()] == 0, string.format('the member should see themselves as 0, got %s', tostring(forMember[member:getID()])))
        assert(forMember[leader:getID()] == 1, 'the member should see the leader as 1')
        assert(forMember[faraway:getID()] == 0, 'a member in another zone has no number')
    end)
end)
