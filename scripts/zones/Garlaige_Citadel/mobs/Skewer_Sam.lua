-----------------------------------
-- Area: Garlaige Citadel (200)
--   NM: Skewer Sam
-----------------------------------
mixins = { require('scripts/mixins/families/cockatrice') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1)
end

entity.onMobMobskillChoose = function(mob, target, skillId)
    return xi.mix.cockatrice.onMobMobskillChoose(mob, target)
end

entity.onMobWeaponSkill = function(mob, target, skill)
    return xi.mix.cockatrice.onMobWeaponSkill(mob, target, skill)
end

return entity
