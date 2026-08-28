-----------------------------------
-- Nectarous Deluge
-- Family: Snapweed
-- Description: Deals Water damage to enemies around the pet. Additional effect: Poison
-- Utsusemi/Blink absorb: Wipes shadows (FFO wiki)
-- Notes: FFO wiki lists the mob version Poison at roughly -51 HP/3s; BLU spell version is fTP 3.0,
--        80 HP/tick for 30s.
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
    params.fTP            = { 3.0, 3.0, 3.0 }
    params.element        = xi.element.WATER
    params.attackType     = xi.attackType.MAGICAL
    params.damageType     = xi.damageType.WATER
    params.shadowBehavior = xi.mobskills.shadowBehavior.WIPE_SHADOWS

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, 51, 3, 30)
    end

    return info.damage
end

return abilityObject
