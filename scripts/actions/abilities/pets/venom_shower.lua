-----------------------------------
-- Venom Shower
-- Family: Crab (Porter Crab)
-- Description: Deals Water damage to enemies around the pet. Additional effect: Poison, Defense Down
-- Utsusemi/Blink absorb: Wipes shadows (FFO wiki)
-- Notes: FFO/FFXIclopedia list the Poison at 40 HP/tick for up to 1 minute. The uncurable
--        poison is specific to the NM users and is not reproduced here.
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
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, 40, 3, 60)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.DEFENSE_DOWN, 20, 0, 60) -- TODO: Capture power/duration
    end

    return info.damage
end

return abilityObject
