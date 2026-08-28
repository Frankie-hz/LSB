-----------------------------------
-- Noisome Powder
-- Reduces attack of targets in area of effect.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/noisome_powder.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.ATTACK_DOWN, 40, 0, 120))

    return xi.effect.ATTACK_DOWN
end

return abilityObject
