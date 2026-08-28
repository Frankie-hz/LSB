-----------------------------------
-- Gloeosuccus
-- Enfeebling
-- Description: Slows down a single target.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/gloeosuccus.lua)
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
        [1] = { effectId = xi.effect.SLOW, power = 1250, duration = 180, tier = 1 },
    }

    return xi.combat.action.executeMobskillStatusEffect(pet, target, petskill, effectTable, {})
end

return abilityObject
