-----------------------------------
-- Area: Bhaflau Thickets
--   NM: Harvestman
-- !pos 398.130 -10.675 179.169 52
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ADD_EFFECT, 1)
end

entity.onAdditionalEffect = function(mob, target, damage)
    return xi.mob.onAddEffect(mob, target, damage, xi.mob.ae.POISON, { power = 100, duration = math.randomInt(6, 9) })
end

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 451)
end

return entity
