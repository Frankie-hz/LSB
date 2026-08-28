-----------------------------------
-- Dream Flower
-- 15' AoE sleep
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/dream_flower.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.SLEEP_I, 1, 0, math.randomInt(15, 60)))

    return xi.effect.SLEEP_I
end

return abilityObject
