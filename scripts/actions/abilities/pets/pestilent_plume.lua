-----------------------------------
-- Pestilent Plume
-- Family: Acuex
-- Description: Deals Dark damage to enemies in a fan-shaped area. Additional effect: Plague, Blindness, Magic Defense Down
-- Utsusemi/Blink absorb: Wipes shadows (FFO wiki)
-- Notes: FFO wiki lists Magic Defense Down at -25.
-- Note: No mob version exists. Values are estimates from wiki descriptions and are not
--       verified against retail jug pet data. Adjust here.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getMainLvl() + 2
    params.fTP            = { 2.0, 2.0, 2.0 } -- TODO: Capture fTPs
    params.element        = xi.element.DARK
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.DARK
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        -- TODO: Capture power/duration of Plague and Blindness
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.PLAGUE, 5, 3, 60)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.BLINDNESS, 30, 0, 60)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.MAGIC_DEF_DOWN, 25, 0, 60)
    end

    return info.damage
end

return abilityObject
