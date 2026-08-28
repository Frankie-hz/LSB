-----------------------------------
-- Sand Pit
-- Single target bind
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/sand_pit.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
--       The mob version's Feeler Antlion NM spawn mechanics do not apply to pets.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.BIND, 1, 0, 60))

    return xi.effect.BIND
end

return abilityObject
