-----------------------------------
-- Nepenthic Plunge
-- Family: Snapweed
-- Description: Deals Water damage to enemies in a fan-shaped area. Additional effect: Weight, Drown
-- Utsusemi/Blink absorb: Wipes shadows (FFO wiki)
-- Notes: FFO wiki lists Drown as "(-37, -17 HP/3sec)"; read here as -17 HP/tick with the
--        STR down derived by the effect script. Element is assumed from the sibling Nectarous Deluge.
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
    params.fTP            = { 2.5, 2.5, 2.5 } -- TODO: Capture fTPs
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.WEIGHT, 50, 0, 60) -- TODO: Capture power/duration
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.DROWN, 17, 3, 60)
    end

    return info.damage
end

return abilityObject
