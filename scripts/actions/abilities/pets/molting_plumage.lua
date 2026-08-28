-----------------------------------
-- Molting Plumage
-- Family: Tulfaire
-- Description: Deals Wind damage to enemies in a fan-shaped area. Additional effect: Dispel, Knockback
-- Notes: FFO wiki lists the mob version as damage + knockback + dispel. The BLU spell version
--        is Wind magical with fTP 4.0 and no dispel; the element is assumed shared.
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
    params.fTP            = { 3.0, 3.0, 3.0 } -- TODO: Capture fTPs
    params.element        = xi.element.WIND
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WIND
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS -- TODO: Capture shadowBehavior

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        target:dispelStatusEffect()
    end

    return info.damage
end

return abilityObject
