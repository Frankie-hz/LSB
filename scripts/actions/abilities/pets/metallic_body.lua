-----------------------------------
-- Metallic Body
-- Gives the effect of "Stoneskin."
-- Type: Magical
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/metallic_body.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local power = 25 -- ffxiclopedia claims its always 25 on the crabs page. Tested on wootzshell in mt zhayolm..

    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.STONESKIN, power, 0, 300))

    return xi.effect.STONESKIN
end

return abilityObject
