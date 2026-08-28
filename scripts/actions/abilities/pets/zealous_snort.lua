-----------------------------------
-- Zealous Snort
-- Family: Raaz
-- Description: Enhances the pet with Haste, Magic Defense Boost, Counter rate up and Guard rate up.
-- Range: Self
-- Notes: FFO wiki: the counter and guard portions are internal (not dispellable), like Counterstance.
--        No standalone counter-rate effect exists yet; that part is omitted.
-- Note: No mob version exists. Values are estimates from wiki descriptions and are not
--       verified against retail jug pet data. Adjust here.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    -- TODO: Capture power and duration of every effect; add the counter rate up portion.
    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.HASTE, 1500, 0, 180))
    xi.mobskills.mobBuffMove(pet, xi.effect.MAGIC_DEF_BOOST, 25, 0, 180)
    xi.mobskills.mobBuffMove(pet, xi.effect.GUARDING_RATE_BOOST, 20, 0, 180)

    return xi.effect.HASTE
end

return abilityObject
