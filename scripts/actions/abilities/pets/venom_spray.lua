-----------------------------------
-- Venom Spray
-- Family: Antlions
-- Description: Poisons enemies in a frontal cone.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/venom_spray.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
--       The mob version's NM power (25) does not apply to pets.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, 15, 3, 120))

    return xi.effect.POISON
end

return abilityObject
