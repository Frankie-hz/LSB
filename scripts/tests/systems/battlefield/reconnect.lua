-----------------------------------
-- Battlefield reconnect
-- Retail plays the win cutscene, which moves the player out, and clears the Battlefield and
-- level cap effects once the client reports that cutscene finished. A player whose connection
-- drops keeps their place in the battlefield while the rest of the party is still inside, and
-- must still leave the same way when they come back.
-----------------------------------
local entryEventId = 32000
local winEventId   = 32001
local entryNpc     = 'BC_Entrance'

local function spawnHorlaisPlayer()
    return xi.test.world:spawnPlayer({ zone = xi.zone.HORLAIS_PEAK })
end

local function enterShootingFish(player)
    player:addItem(xi.item.CLOUDY_ORB)
    player.bcnm:enter(entryNpc, xi.battlefield.id.SHOOTING_FISH, { xi.item.CLOUDY_ORB })
end

local function joinShootingFish(member)
    local option = bit.lshift(xi.battlefield.contents[xi.battlefield.id.SHOOTING_FISH].index, 4) + 1
    member.entities:gotoAndTrigger(entryNpc, { eventId = entryEventId, updates = { option } })
    assert(member:getBattlefield(), 'party member did not join the battlefield')
end

local function formParty(leader, member)
    leader.actions:inviteToParty(member)
    member.actions:acceptPartyInvite()
end

local function killMobsAndShowCrate(player)
    player.bcnm:killMobs()

    local crate = GetNPCByID(player:getBattlefield():getArmouryCrate())
    assert(crate, 'no armoury crate appeared after the last mob died')

    return crate
end

local function openArmouryCrate(player)
    local battlefield = player:getBattlefield()
    player.entities:gotoAndTrigger(killMobsAndShowCrate(player))
    assert(battlefield:getStatus() == xi.battlefield.status.WON, 'opening the crate did not win the battlefield')
end

local function tickSeconds(seconds)
    for _ = 1, seconds do
        xi.test.world:skipTime(1)
        xi.test.world:tick()
    end
end

-- The win cutscene starts on its own a few seconds after the crate
local function waitForWinCutscene(player)
    tickSeconds(6)
    assert(player:isInEvent(), 'the win cutscene did not start')
end

-- A dropped session takes its event with it, then the client zones back in at its last position
local function dropConnection(player)
    if player:isInEvent() then
        player:release()
    end

    player:gotoZone(player:getZoneID())
end

local function assertOutOfBattlefield(player)
    assert(not player:getBattlefield(), 'player is still inside the battlefield')
    assert(not player:hasStatusEffect(xi.effect.BATTLEFIELD), 'player still holds the Battlefield effect')
    assert(not player:hasStatusEffect(xi.effect.LEVEL_RESTRICTION), 'player is still level capped')
end

-- An empty battlefield is destroyed on the handler pass after a 10 second grace
local function leaveBattlefields(players)
    for _, player in ipairs(players) do
        if player:isInEvent() then
            player:release()
        end

        if player:getBattlefield() then
            player:leaveBattlefield(xi.battlefield.leaveCode.EXIT)
        end
    end

    for _ = 1, 3 do
        xi.test.world:skipTime(11)
        xi.test.world:tick()
    end
end

describe('Battlefield reconnect', function()
    local players

    before_each(function()
        players = {}
    end)

    after_each(function()
        leaveBattlefields(players)
    end)

    it('replays the win cutscene for a player whose connection dropped during it', function()
        local player = spawnHorlaisPlayer()
        table.insert(players, player)
        enterShootingFish(player)
        openArmouryCrate(player)
        waitForWinCutscene(player)

        dropConnection(player)
        assert(player:getBattlefield(), 'the returning player was not put back into the finished battlefield')

        tickSeconds(6)
        player.events:expect({ eventId = winEventId, finishOption = 0 })

        tickSeconds(11)
        assertOutOfBattlefield(player)
    end)

    it('keeps out a player whose connection dropped after the win cutscene moved them out', function()
        local player = spawnHorlaisPlayer()
        table.insert(players, player)
        enterShootingFish(player)
        openArmouryCrate(player)
        waitForWinCutscene(player)
        player.events:finish(winEventId, 0)

        dropConnection(player)
        assert(not player:getBattlefield(), 'player was put back inside the arena after leaving it')

        tickSeconds(11)
        player.events:expectNotInEvent()
        assertOutOfBattlefield(player)
    end)

    it('shows the win cutscene once to a player who stays connected and then clears their effects', function()
        local player = spawnHorlaisPlayer()
        table.insert(players, player)
        enterShootingFish(player)
        openArmouryCrate(player)
        waitForWinCutscene(player)
        player.events:finish(winEventId, 0)

        tickSeconds(11)
        player.events:expectNotInEvent()
        assertOutOfBattlefield(player)
    end)

    it('puts a party leader whose connection dropped back into the fight the party is still in', function()
        local leader = spawnHorlaisPlayer()
        local member = spawnHorlaisPlayer()
        table.insert(players, leader)
        table.insert(players, member)
        formParty(leader, member)
        enterShootingFish(leader)
        joinShootingFish(member)

        dropConnection(leader)
        assert(leader:getBattlefield(), 'the returning leader was not put back into the battlefield')
        assert(leader:hasEnteredBattlefield(), 'the returning leader should be inside the arena')

        tickSeconds(6)
        leader.events:expectNotInEvent()
        assert(leader:hasStatusEffect(xi.effect.BATTLEFIELD), 'the returning leader lost clearance')
    end)

    it('lets a leader whose connection dropped open the crate the party left for them', function()
        local leader = spawnHorlaisPlayer()
        local member = spawnHorlaisPlayer()
        table.insert(players, leader)
        table.insert(players, member)
        formParty(leader, member)
        enterShootingFish(leader)
        joinShootingFish(member)
        local crate = killMobsAndShowCrate(leader)

        dropConnection(leader)
        leader.entities:gotoAndTrigger(crate)
        assert(leader:getBattlefield():getStatus() == xi.battlefield.status.WON, 'the returning leader could not open the crate')

        waitForWinCutscene(leader)
        leader.events:finish(winEventId, 0)
        member.events:finish(winEventId, 0)

        tickSeconds(11)
        assertOutOfBattlefield(leader)
        assertOutOfBattlefield(member)
    end)

    -- Retail keeps a crashed player in the fight until the session times out, which outlasts the battlefield cleanup
    it('shows a member who crashed before the crate the win cutscene when they come back after cleanup', function()
        local leader = spawnHorlaisPlayer()
        local member = spawnHorlaisPlayer()
        table.insert(players, leader)
        table.insert(players, member)
        formParty(leader, member)
        enterShootingFish(leader)
        joinShootingFish(member)

        openArmouryCrate(leader)
        waitForWinCutscene(member)
        leader.events:finish(winEventId, 0)

        tickSeconds(11)
        assert(not leader:getBattlefield(), 'the battlefield should be gone once its grace ran out')
        assertOutOfBattlefield(leader)

        dropConnection(member)
        tickSeconds(6)
        member.events:expect({ eventId = winEventId, finishOption = 0 })
        assert(member:getLocalVar('battlefieldWin') == xi.battlefield.id.SHOOTING_FISH, 'the replayed cutscene did not credit the win')
        assertOutOfBattlefield(member)
    end)

    it('shows a solo player who crashed after the crate the win cutscene when they come back after cleanup', function()
        local player = spawnHorlaisPlayer()
        local bystander = spawnHorlaisPlayer()
        table.insert(players, player)
        table.insert(players, bystander)
        enterShootingFish(player)
        openArmouryCrate(player)
        waitForWinCutscene(player)

        tickSeconds(11)
        assert(not player:getBattlefield(), 'the battlefield should be gone once its grace ran out')

        dropConnection(player)
        tickSeconds(6)
        player.events:expect({ eventId = winEventId, finishOption = 0 })
        assertOutOfBattlefield(player)
    end)
end)
