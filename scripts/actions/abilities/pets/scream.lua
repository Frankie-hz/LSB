-----------------------------------
-- Scream
-- 15' Reduces MND of players in area of effect.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/scream.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.MND_DOWN, 10, 3, 180))

    return xi.effect.MND_DOWN
end

return abilityObject
