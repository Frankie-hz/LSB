-----------------------------------
-- Fantod
-- Family: Hippogryph
-- Description: Gives special boost ability
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/fantod.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local subPower = 1 -- Special formula for boost increasing base damage

    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.BOOST, 400, 0, 180, nil, subPower))

    return xi.effect.BOOST
end

return abilityObject
