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

    local function leadersInTable(player)
        local leaders = 0
        local found   = false
        for _, packet in pairs(player.packets:getIncoming()) do
            if packet.type == 0x0C8 then
                found   = true
                leaders = 0
                for slot = 0, 19 do
                    local offset = 0x08 + slot * 0x0C
                    if readU32(packet.data, offset) ~= 0 and bit.band(packet.data[offset + 0x06], 0x04) ~= 0 then
                        leaders = leaders + 1
                    end
                end
            end
        end

        assert(found, 'expected a party table packet')
        return leaders
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

    it('restores a leader when a party is left without one', function()
        local first  = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })
        local second = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })
        local third  = xi.test.world:spawnPlayer({ zone = xi.zone.WEST_RONFAURE })

        formParty(first, second, third)
        xi.test.world:tick()

        for _, player in ipairs({ first, second, third }) do
            player.packets:clear()
        end

        xi.test.world:removePartyLeaderFromOtherProcess(second)
        xi.test.world:tick()

        local leader = second:getPartyLeader()
        assert(leader, 'the party should have a leader again')
        assert(leader:getID() == first:getID(), 'the oldest member should take the lead')
        assert(leadersInTable(second) == 1, 'the party table should mark one leader')
        assert(third:getPartyLeader():getID() == first:getID(), 'every member should agree on the leader')
    end)
end)
