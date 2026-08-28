-----------------------------------
-- Corrosive Ooze
-- Family: Slugs
-- Description: Deals Water damage to an enemy. Additional Effect: Attack Down, Defense Down
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/corrosive_ooze.lua)
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
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.ATTACK_DOWN, 33, 0, 120)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.DEFENSE_DOWN, 33, 0, 120)
    end

    return info.damage
end

return abilityObject
