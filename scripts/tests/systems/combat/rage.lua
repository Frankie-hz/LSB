describe('Rage', function()
    local timerMinutes = 5
    local rankMods     =
    {
        xi.mod.FIRE_RES_RANK,
        xi.mod.ICE_RES_RANK,
        xi.mod.WIND_RES_RANK,
        xi.mod.EARTH_RES_RANK,
        xi.mod.THUNDER_RES_RANK,
        xi.mod.WATER_RES_RANK,
        xi.mod.LIGHT_RES_RANK,
        xi.mod.DARK_RES_RANK,
    }

    ---@type CClientEntityPair
    local player

    ---@type CTestEntity
    local mob

    local function engageMob(zoneId, mobName)
        player = xi.test.world:spawnPlayer({ zone = zoneId, job = xi.job.WAR, level = 99 })
        player:setUnkillable(true)

        mob = player.entities:moveTo(mobName)
        mob:respawn()
        mob:setAutoAttackEnabled(false)
        mob:setMagicCastingEnabled(false)
        mob:setMobAbilityEnabled(false)
        mob:setLocalVar('[rage]timer', timerMinutes * 60)
        mob:addEnmity(player, 100, 100)
        xi.test.world:skipTime(1)
        xi.test.world:tickEntity(mob)

        assert(mob:isEngaged(), 'mob did not engage')
    end

    local function advanceMinutes(minutes)
        for _ = 1, minutes do
            xi.test.world:skipTime(60)
            xi.test.world:tickEntity(mob)
        end
    end

    after_each(function()
        mob:setAutoAttackEnabled(true)
        mob:setMagicCastingEnabled(true)
        mob:setMobAbilityEnabled(true)
        mob:despawn()
    end)

    describe('with the default schedule', function()
        before_each(function()
            engageMob(xi.zone.SAUROMUGUE_CHAMPAIGN, 'Roc')
        end)

        it('changes nothing before the timer', function()
            local defBefore        = mob:getMod(xi.mod.DEFP)
            local accBefore        = mob:getMod(xi.mod.ACC)
            local multiplierBefore = mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER)
            local rankBefore       = mob:getMod(xi.mod.FIRE_RES_RANK)

            advanceMinutes(timerMinutes - 1)

            mob.assert:hasModifier(xi.mod.DEFP, defBefore)
            mob.assert:hasModifier(xi.mod.ACC, accBefore)
            mob.assert:hasModifier(xi.mod.FIRE_RES_RANK, rankBefore)
            assert(mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER) == multiplierBefore, 'damage rose before the timer')
        end)

        it('raises its stats at the timer and keeps ramping damage', function()
            local defBefore        = mob:getMod(xi.mod.DEFP)
            local accBefore        = mob:getMod(xi.mod.ACC)
            local multiplierBefore = mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER)

            advanceMinutes(timerMinutes)

            local multiplierAtTimer = mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER)

            assert(mob:getMod(xi.mod.DEFP) > defBefore, 'DEF did not rise at the timer')
            assert(mob:getMod(xi.mod.ACC) > accBefore, 'ACC did not rise at the timer')
            assert(multiplierAtTimer > multiplierBefore, 'damage did not rise at the timer')

            advanceMinutes(1)

            assert(mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER) > multiplierAtTimer, 'damage stopped ramping')
        end)

        it('raises every resistance rank by 1 per minute from the timer', function()
            for _, rankMod in ipairs(rankMods) do
                mob:setMod(rankMod, 0)
            end

            advanceMinutes(timerMinutes + 2)

            for _, rankMod in ipairs(rankMods) do
                mob.assert:hasModifier(rankMod, 3)
            end
        end)

        it('holds the last row once the table runs out', function()
            advanceMinutes(timerMinutes + 11)

            local multiplierAtCap = mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER)
            local defAtCap        = mob:getMod(xi.mod.DEFP)

            advanceMinutes(2)

            assert(mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER) == multiplierAtCap, 'damage rose past the last row')
            mob.assert:hasModifier(xi.mod.DEFP, defAtCap)
        end)

        it('stops raising a resistance rank at 11', function()
            mob:setMod(xi.mod.FIRE_RES_RANK, 10)

            advanceMinutes(timerMinutes + 2)

            mob.assert:hasModifier(xi.mod.FIRE_RES_RANK, 11)
        end)

        it('removes everything on disengage', function()
            local defBefore        = mob:getMod(xi.mod.DEFP)
            local accBefore        = mob:getMod(xi.mod.ACC)
            local evaBefore        = mob:getMod(xi.mod.EVA_PERCENT)
            local multiplierBefore = mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER)
            local rankBefore       = mob:getMod(xi.mod.FIRE_RES_RANK)

            advanceMinutes(timerMinutes + 2)
            mob:disengage()
            xi.test.world:tickEntity(mob)

            mob.assert:hasModifier(xi.mod.DEFP, defBefore)
            mob.assert:hasModifier(xi.mod.ACC, accBefore)
            mob.assert:hasModifier(xi.mod.EVA_PERCENT, evaBefore)
            mob.assert:hasModifier(xi.mod.FIRE_RES_RANK, rankBefore)
            assert(mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER) == multiplierBefore, 'damage was not restored')
        end)
    end)
end)
