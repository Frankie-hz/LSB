-----------------------------------
-- Bubble Shower
-- Family: Crabs
-- Description: Deals Water damage in an area of effect. Additional Effect: STR Down
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/bubble_shower.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.percentMultipier = 0.0625
    params.damageCap        = 200
    params.bonusDamage      = 0
    params.mAccuracyBonus   = { 0, 0, 0 }
    params.resistStat       = xi.mod.INT
    params.element          = xi.element.WATER
    params.attackType       = xi.attackType.BREATH
    params.damageType       = xi.damageType.WATER
    params.shadowBehavior   = xi.mobskills.shadowBehavior.IGNORE_SHADOWS
    -- TODO: Jug Pet differences

    local info = xi.mobskills.mobBreathMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        local power    = 10
        local duration = 180
        -- TODO: Dreamland Dynamis Power

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STR_DOWN, power, 9, duration)
    end

    return info.damage
end

return abilityObject
