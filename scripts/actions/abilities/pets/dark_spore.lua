-----------------------------------
-- Dark Spore
-- Family: Funguar
-- Description: Unleashes a torrent of black spores in a fan-shaped area of effect, dealing Dark damage to targets. Additional Effect: Blind
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/dark_spore.lua)
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
    params.damageCap        = 600 -- TODO: Capture damage cap.
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

        local duration = 90
        -- TODO: Jugpet Differences

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.BLINDNESS, 30, 0, duration)
    end

    return info.damage
end

return abilityObject
