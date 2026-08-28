-----------------------------------
-- Secretion
--
-- Description: Enhances evasion.
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-- Notes: evasion increase.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/secretion.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.EVASION_BOOST, 25, 0, 60))

    return xi.effect.EVASION_BOOST
end

return abilityObject
