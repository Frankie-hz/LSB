-----------------------------------
-- Acid Mist
-- Family: Leech
-- Description: Deals Water damage to enemies within an area of effect. Additional Effect: Attack Down
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/acid_mist.lua)
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
    params.fTP            = { 1.75, 2.00, 2.25 }
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        local power    = 50
        local duration = 120
        -- TODO: Leeches in Dynamis lower attack to 1.

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.ATTACK_DOWN, power, 0, duration)
    end

    return info.damage
end

return abilityObject
