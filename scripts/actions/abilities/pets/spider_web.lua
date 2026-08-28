-----------------------------------
-- Spider Web
-- Family: Spider
-- Description: Entangles all targets in an area of effect.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/spider_web.lua)
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
        [1] = { effectId = xi.effect.SLOW, power = 3000, duration = 90, tier = 8 },
    }

    return xi.combat.action.executeMobskillStatusEffect(pet, target, petskill, effectTable, {})
end

return abilityObject
