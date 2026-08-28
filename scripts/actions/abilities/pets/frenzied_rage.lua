-----------------------------------
-- Frenzied Rage
--
-- Description: Attack Boost
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-- Notes: 20% Attack Boost.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/frenzied_rage.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local power = 20
    local duration = 120

    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.ATTACK_BOOST, power, 0, duration))
    return xi.effect.ATTACK_BOOST
end

return abilityObject
