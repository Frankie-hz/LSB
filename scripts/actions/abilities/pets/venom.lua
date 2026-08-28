-----------------------------------
-- Venom
-- Family: Fly
-- Description: Deals Water damage in a fan shaped area. Additional Effect: Poison
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/venom.lua)
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
    params.fTP            = { 1.50, 1.50, 1.50 }
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        -- TODO: Jugpet differences

        -- TODO: Dynamis - Nightmare Fly

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, 1, 3, 60) -- TODO: Capture duration
    end

    return info.damage
end

return abilityObject
