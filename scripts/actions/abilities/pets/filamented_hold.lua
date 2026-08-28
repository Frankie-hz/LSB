-----------------------------------
-- Filamented Hold
-- Reduces the attack speed of enemies within a fan-shaped area originating from the caster.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/filamented_hold.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local effectTable =
    {
        [1] = { effectId = xi.effect.SLOW, power = 2500, duration = 120, tier = 8 },
    }

    return xi.combat.action.executeMobskillStatusEffect(pet, target, petskill, effectTable, {})
end

return abilityObject
