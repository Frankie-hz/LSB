-----------------------------------
-- Silence Gas
-- Family: Funguar
-- Description: Deals Dark Breath damage to targets in front of mob. Additional Effect: Silence
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/silence_gas.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.percentMultipier = 0.25
    params.damageCap        = 800 -- TODO: Capture cap
    params.bonusDamage      = 0
    params.mAccuracyBonus   = { 0, 0, 0 }
    params.resistStat       = xi.mod.INT
    params.element          = xi.element.DARK
    params.attackType       = xi.attackType.BREATH
    params.damageType       = xi.damageType.DARK
    params.shadowBehavior   = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobBreathMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        -- TODO: Jugpet Differences
        local duration = math.randomInt(15, 60)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.SILENCE, 1, 0, duration)
    end

    return info.damage
end

return abilityObject
