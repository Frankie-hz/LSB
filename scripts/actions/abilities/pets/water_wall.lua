-----------------------------------
-- Water Wall
-- Enhances defense.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/water_wall.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.DEFENSE_BOOST, 100, 0, 90)) -- The duration of this ability may vary all the way to 9 minutes with a HEAVY weight towards 90 seconds.

    return xi.effect.DEFENSE_BOOST
end

return abilityObject
