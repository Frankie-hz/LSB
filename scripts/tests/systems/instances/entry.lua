-----------------------------------
-- Instance entry
-- The entrance event asks the server to register the party and waits for one of two answers:
-- a 0x0BF registration result, or the eighth parameter of an event update reply (Nyzul).
-----------------------------------
local registrationPacket = 0x0BF
local pendingNumPacket   = 0x05C

local blackCoffin    = xi.instance.entries[6000]
local pathOfDarkness = xi.instance.entries[7700]
local cutterEvent    = blackCoffin.entryEvent[1]
local nyzulEvent     = pathOfDarkness.entryEvent[1]
local nyzulZoneName  = pathOfDarkness.entryEvent[6]
local nyzulCodes     = xi.instance.pollCode[xi.instance.protocol.POLL_NYZUL]

local function readU16(data, offset)
    return data[offset] + data[offset + 1] * 256
end

local function readI32(data, offset)
    local value = data[offset] + data[offset + 1] * 256 + data[offset + 2] * 65536 + data[offset + 3] * 16777216
    if value >= 2147483648 then
        value = value - 4294967296
    end

    return value
end

-- Every 0x0BF result the server queued for the player
local function registrationResults(player)
    local results = {}
    for _, packet in ipairs(player.packets:getIncoming()) do
        if packet.type == registrationPacket then
            table.insert(results, readU16(packet.data, 6))
        end
    end

    return results
end

-- Parameters of the last event update reply, nil when none was sent
local function pendingParams(player)
    local params
    for _, packet in ipairs(player.packets:getIncoming()) do
        if packet.type == pendingNumPacket then
            params = {}
            for i = 0, 7 do
                params[i] = readI32(packet.data, 4 + i * 4)
            end
        end
    end

    return params
end

local function request(player, csid, option)
    player.packets:clear()
    player.events:update(csid, option)
end

-- Option the client builds: menu choice in bits 18-21, Nyzul poll state in bits 22-25
local function menuOption(menuIndex, pollState)
    return bit.bor(bit.lshift(menuIndex, 18), bit.lshift(pollState or 0, 22))
end

local function spawnBlackCoffinCandidate()
    local player = xi.test.world:spawnPlayer({ zone = xi.zone.ARRAPAGO_REEF })
    player:addMission(xi.mission.log_id.TOAU, xi.mission.id.toau.THE_BLACK_COFFIN)
    player:addKeyItem(xi.keyItem.EPHRAMADIAN_GOLD_COIN)

    return player
end

local function spawnPathOfDarknessCandidate()
    local player = xi.test.world:spawnPlayer({ zone = xi.zone.ALZADAAL_UNDERSEA_RUINS })
    player:addMission(xi.mission.log_id.TOAU, xi.mission.id.toau.PATH_OF_DARKNESS)
    player:setMissionStatus(xi.mission.log_id.TOAU, 1)
    player:addKeyItem(xi.keyItem.NYZUL_ISLE_ROUTE)

    return player
end

local function formParty(leader, member)
    leader.actions:inviteToParty(member)
    member.actions:acceptPartyInvite()
end

local function failInstances(players)
    for _, player in ipairs(players) do
        local instance = player:getInstance()
        if instance then
            instance:fail()
        end
    end

    xi.test.world:tick(xi.tick.TIME)
end

describe('Instance entry with a registration result', function()
    local players

    before_each(function()
        players = {}
    end)

    after_each(function()
        failInstances(players)
    end)

    it('accepts the registrant once the instance has loaded', function()
        local player = spawnBlackCoffinCandidate()
        table.insert(players, player)

        player.entities:gotoAndTrigger('Cutter')
        request(player, cutterEvent, menuOption(blackCoffin.menuIndex))
        assert(#registrationResults(player) == 0, 'nothing may be answered before the instance exists')

        xi.test.world:tick(xi.tick.TIME)

        local results = registrationResults(player)
        assert(#results == 1 and results[1] == xi.instance.registration.ACCEPTED,
            'expected one accepted registration, got ' .. #results)
        assert(player:getInstance(), 'the registrant should be attached to the new instance')

        player.events:finish(cutterEvent, blackCoffin.confirm[2])
        xi.test.world:tick()
        player.assert:inZone(xi.zone.THE_ASHU_TALIF)
        assert(player:getInstance(), 'the registrant should be inside the instance')
    end)

    it('brings the party members standing with the registrant', function()
        local leader = spawnBlackCoffinCandidate()
        local member = spawnBlackCoffinCandidate()
        table.insert(players, leader)
        table.insert(players, member)
        formParty(leader, member)

        leader.entities:gotoAndTrigger('Cutter')
        request(leader, cutterEvent, menuOption(blackCoffin.menuIndex))
        xi.test.world:tick(xi.tick.TIME)

        assert(registrationResults(leader)[1] == xi.instance.registration.ACCEPTED, 'the registrant should be accepted')
        assert(member:isInEvent(), 'the member should be watching the transport event')
        assert(member:getInstance(), 'the member should be registered to the instance')

        leader.events:finish(cutterEvent, blackCoffin.confirm[2])
        xi.test.world:tick()
        leader.assert:inZone(xi.zone.THE_ASHU_TALIF)
        member.assert:inZone(xi.zone.THE_ASHU_TALIF)
        assert(member:getInstance() == leader:getInstance(), 'the member should share the instance')
    end)

    it('denies the registrant when a member lacks the requirements', function()
        local leader = spawnBlackCoffinCandidate()
        local member = xi.test.world:spawnPlayer({ zone = xi.zone.ARRAPAGO_REEF })
        table.insert(players, leader)
        table.insert(players, member)
        formParty(leader, member)

        leader.entities:gotoAndTrigger('Cutter')
        request(leader, cutterEvent, menuOption(blackCoffin.menuIndex))

        local results = registrationResults(leader)
        assert(#results == 1 and results[1] == xi.instance.registration.DENIED, 'the registration should be denied at once')

        xi.test.world:tick(xi.tick.TIME)
        assert(not leader:getInstance(), 'no instance may be created for a denied request')

        leader.events:finish(cutterEvent, xi.instance.registration.DENIED)
        xi.test.world:tick()
        leader.assert:inZone(xi.zone.ARRAPAGO_REEF)
    end)

    it('denies an objective the entrance did not offer', function()
        local player = spawnBlackCoffinCandidate()
        table.insert(players, player)

        player.entities:gotoAndTrigger('Cutter')
        request(player, cutterEvent, menuOption(blackCoffin.menuIndex + 1))

        local results = registrationResults(player)
        assert(#results == 1 and results[1] == xi.instance.registration.DENIED, 'another mission must be refused')

        xi.test.world:tick(xi.tick.TIME)
        assert(not player:getInstance(), 'no instance may be created for the refused mission')
    end)
end)

describe('Instance entry with the Nyzul poll', function()
    local players

    before_each(function()
        players = {}
    end)

    after_each(function()
        failInstances(players)
    end)

    it('registers the request, then reports ready once the instance has loaded', function()
        local player = spawnPathOfDarknessCandidate()
        table.insert(players, player)

        player.entities:gotoAndTrigger('_20m')

        request(player, nyzulEvent, menuOption(pathOfDarkness.menuIndex, 0))
        local reply = pendingParams(player)
        assert(reply and reply[7] == nyzulCodes.REGISTERED, 'the request should be registered')
        assert(reply[4] == nyzulZoneName, 'the reply must keep the zone name parameter')

        xi.test.world:tick(xi.tick.TIME)
        assert(player:getInstance(), 'the instance should have loaded')

        request(player, nyzulEvent, menuOption(pathOfDarkness.menuIndex, 1))
        reply = pendingParams(player)
        assert(reply and reply[7] == nyzulCodes.READY, 'the poll should be answered with ready')
        assert(reply[0] == pathOfDarkness.entryEvent[2] and reply[4] == nyzulZoneName, 'the ready reply must echo the start parameters')

        player.events:finish(nyzulEvent, pathOfDarkness.confirm[2])
        xi.test.world:tick()
        player.assert:inZone(xi.zone.NYZUL_ISLE)
        assert(player:getInstance(), 'the registrant should be inside the instance')
    end)

    it('answers a poll that arrived before the instance loaded', function()
        local player = spawnPathOfDarknessCandidate()
        table.insert(players, player)

        player.entities:gotoAndTrigger('_20m')
        request(player, nyzulEvent, menuOption(pathOfDarkness.menuIndex, 0))

        request(player, nyzulEvent, menuOption(pathOfDarkness.menuIndex, 1))
        assert(not pendingParams(player), 'the poll must wait for the instance')

        xi.test.world:tick(xi.tick.TIME)

        local reply = pendingParams(player)
        assert(reply and reply[7] == nyzulCodes.READY, 'the waiting poll should be answered once loaded')
    end)

    it('cancels the poll when a member lacks the requirements', function()
        local leader = spawnPathOfDarknessCandidate()
        local member = xi.test.world:spawnPlayer({ zone = xi.zone.ALZADAAL_UNDERSEA_RUINS })
        table.insert(players, leader)
        table.insert(players, member)
        formParty(leader, member)

        leader.entities:gotoAndTrigger('_20m')
        request(leader, nyzulEvent, menuOption(pathOfDarkness.menuIndex, 0))

        local reply = pendingParams(leader)
        assert(reply and reply[7] == nyzulCodes.CANCEL, 'the request should be cancelled')

        xi.test.world:tick(xi.tick.TIME)
        assert(not leader:getInstance(), 'no instance may be created for a cancelled request')
    end)
end)
