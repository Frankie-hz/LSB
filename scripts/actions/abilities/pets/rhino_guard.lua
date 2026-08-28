-----------------------------------
-- Rhino Guard
-- Description: Enhances evasion, duration scales with TP.
-- Range: Self
-- Notes: Very sharp evasion increase.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/rhino_guard.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local duration = xi.mobskills.calculateDuration(petskill:getTP(), 180, 780)
    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.EVASION_BOOST, 25, 0, duration))

    return xi.effect.EVASION_BOOST
end

return abilityObject
