describe('Instances', function()
    it('Waking the Colossus spawns Alexander', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.ALZADAAL_UNDERSEA_RUINS })

        player:createInstance(7702)
        xi.test.world:tick(xi.tick.TIME)

        local instance = player:getInstance()
        assert(instance and instance:getID() == 7702)

        for _, mob in pairs(instance:getMobs()) do
            if mob:getName() == 'Alexander_WTC' then
                return
            end
        end

        assert(false, 'Alexander_WTC not spawned')
    end)

    it('drops a registered player pointer when the instance is reaped', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.ALZADAAL_UNDERSEA_RUINS })

        player:createInstance(7702)
        xi.test.world:tick(xi.tick.TIME)

        local instance = player:getInstance()
        assert(instance, 'instance was not created')

        -- Registered from the entrance zone, never zoned in
        player:setInstance(instance)
        instance:fail()
        xi.test.world:tick(xi.tick.TIME)

        assert(player:getInstance() == nil, 'a reaped instance must not stay attached to the player')
    end)

    it('drops the pointer of a player who left the instance before it was reaped', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.ALZADAAL_UNDERSEA_RUINS })

        player:createInstance(7702)
        xi.test.world:tick(xi.tick.TIME)

        local instance = player:getInstance()
        assert(instance, 'instance was not created')

        player:setInstance(instance)
        player:setPos(0, 0, 0, 0, xi.zone.NYZUL_ISLE)
        player.assert:inZone(xi.zone.NYZUL_ISLE)
        assert(player:getInstance(), 'player should be inside the instance')

        player:setPos(0, 0, 0, 0, xi.zone.ALZADAAL_UNDERSEA_RUINS)
        player.assert:inZone(xi.zone.ALZADAAL_UNDERSEA_RUINS)
        assert(player:getInstance() == nil, 'leaving the instance zone should detach the player')

        instance:fail()
        xi.test.world:tick(xi.tick.TIME)
        assert(player:getInstance() == nil, 'player must stay detached after the reap')
    end)

    it('runs the failure hook once and ignores completion after failing', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.ALZADAAL_UNDERSEA_RUINS })

        player:createInstance(7702)
        xi.test.world:tick(xi.tick.TIME)

        local instance = player:getInstance()
        assert(instance, 'instance was not created')

        local script   = GetCachedInstanceScript(7702)
        local original = script.onInstanceFailure
        local failures = 0
        script.onInstanceFailure = function(failed)
            failures = failures + 1
            original(failed)
        end

        instance:fail()
        instance:fail()
        instance:complete()

        script.onInstanceFailure = original

        assert(failures == 1, 'onInstanceFailure should run once, ran ' .. failures)
        assert(instance:failed(), 'instance should stay failed')
        assert(not instance:completed(), 'a failed instance must not complete')

        xi.test.world:tick(xi.tick.TIME)
    end)

    it('respawns an instanced mob after its timer expires', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.ALZADAAL_UNDERSEA_RUINS })

        player:createInstance(7702)
        xi.test.world:tick(xi.tick.TIME)

        local alexander
        for _, mob in pairs(player:getInstance():getMobs()) do
            if mob:getName() == 'Alexander_WTC' then
                alexander = player.entities:get(mob)
                break
            end
        end

        assert(alexander, 'Alexander_WTC not spawned')

        alexander:setRespawnTime(300)
        alexander:despawn()
        alexander.assert.no:isSpawned()

        xi.test.world:skipTime(305)
        xi.test.world:tick(xi.tick.SPAWN)

        alexander.assert:isSpawned()
    end)
end)
