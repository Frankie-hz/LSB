-----------------------------------
-- Purulent Ooze
-- Family: Slugs
-- Description: Deals Water damage in a fan-shaped area of effect. Additional Effect: Bio, Max HP Down
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/purulent_ooze.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getMainLvl() + 2
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

         -- TODO: Capture durations
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.BIO, 12, 3, 120, 0, 10)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.MAX_HP_DOWN, 10, 0, 120)
    end

    return info.damage
end

return abilityObject
