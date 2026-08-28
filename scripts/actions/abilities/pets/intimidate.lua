-----------------------------------
-- Intimidate
-- Inflicts slow on targets in a fan-shaped area of effect.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/intimidate.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobGazeMove(pet, target, xi.effect.SLOW, 1250, 0, 120))

    return xi.effect.SLOW
end

return abilityObject
