-----------------------------------
-- Spoil
-- Description: Lowers the strength of target.
-- Range: Melee
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/spoil.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STR_DOWN, 10, 3, 300))

    return xi.effect.STR_DOWN
end

return abilityObject
