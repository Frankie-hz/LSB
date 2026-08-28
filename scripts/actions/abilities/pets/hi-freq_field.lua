-----------------------------------
-- Hi-Freq Field
-- Description: Lowers the evasion of enemies in a fan-shaped area of effect.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/hi-freq_field.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.EVASION_DOWN, 40, 0, 180))

    return xi.effect.EVASION_DOWN
end

return abilityObject
