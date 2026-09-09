describe('Mob self buffs', function()
    local mob

    -- A cast only completes on a later tick, so time is advanced in steps rather than one jump.
    local function skipTimeInSteps(seconds)
        for _ = 1, seconds / 10 do
            xi.test.world:skipTime(10)
        end
    end

    local function castsBy(castSpy, caster)
        local count = 0
        for _, call in ipairs(castSpy.calls) do
            if call.args[1]:getID() == caster:getID() then
                count = count + 1
            end
        end

        return count
    end

    before_each(function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.CASTLE_OZTROJA })
        mob = player.entities:moveTo('Yagudo_Priest')

        -- Keep the yagudo around the priest from engaging and dragging it into combat.
        player:addStatusEffect(xi.effect.INVISIBLE, { duration = 3600, origin = player })
        player:addStatusEffect(xi.effect.SNEAK, { duration = 3600, origin = player })

        mob:respawn()
        mob:clearPath()
        mob:delStatusEffect(xi.effect.STONESKIN)
        mob:setSpellList(97) -- Stoneskin only
    end)

    it('casts a buff it does not have', function()
        skipTimeInSteps(60)

        assert(mob:hasStatusEffect(xi.effect.STONESKIN), 'idle mob has cast Stoneskin')
    end)

    it('does not recast a buff that is still active', function()
        local cast = spy('xi.spells.enhancing.useEnhancingSpell')

        skipTimeInSteps(180)

        assert(castsBy(cast, mob) == 1, string.format('expected 1 Stoneskin cast, got %d', castsBy(cast, mob)))
    end)

    it('does not cast a buff it already has from another source', function()
        local cast = spy('xi.spells.enhancing.useEnhancingSpell')
        mob:addStatusEffect(xi.effect.STONESKIN, { power = 100, duration = 600, origin = mob })

        skipTimeInSteps(120)

        assert(castsBy(cast, mob) == 0, string.format('expected no Stoneskin cast, got %d', castsBy(cast, mob)))
    end)

    it('casts the buff again once it wears off', function()
        local cast = spy('xi.spells.enhancing.useEnhancingSpell')

        skipTimeInSteps(60)
        mob:delStatusEffect(xi.effect.STONESKIN)
        skipTimeInSteps(90)

        assert(castsBy(cast, mob) == 2, string.format('expected 2 Stoneskin casts, got %d', castsBy(cast, mob)))
    end)
end)
