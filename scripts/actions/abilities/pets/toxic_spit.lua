-----------------------------------
-- Toxic Spit
-- Family: Eft
-- Description: Inflicts poison on targets hit.
-- Notes: Single/AoE hit varies between individuals.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/toxic_spit.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local power    = math.floor(pet:getMainLvl() / 5 + 3) -- TODO: Capture power at different levels to verify.
    local duration = 180

    -- TODO: Jug pet: Duration scales with TP.

    xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, power, 3, duration)

    return xi.effect.POISON
end

return abilityObject
