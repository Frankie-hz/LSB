-----------------------------------
-- Sand Blast
-- Deals Earth damage to targets in a fan-shaped area of effect. Additional effect: Blind
-- Range: 8' cone
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/sand_blast.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
--       The mob version's Feeler Antlion NM spawn mechanics do not apply to pets.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.BLINDNESS, 40, 0, 180))

    return xi.effect.BLINDNESS
end

return abilityObject
