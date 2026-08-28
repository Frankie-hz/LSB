-----------------------------------
-- Sickle Slash
-- Family: Spider
-- Description: Deals critical damage. Attack multiplier varies with TP.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/sickle_slash.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage       = pet:getWeaponDmg()
    params.numHits          = 1
    params.fTP              = { 2.0, 2.0, 2.0 }
    params.attackType       = xi.attackType.PHYSICAL
    params.damageType       = xi.damageType.BLUNT
    params.shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.attackMultiplier = { 0.5, 1.5, 2.5 }
    params.canCrit          = true
    params.criticalChance   = { 1.0, 1.0, 1.0 }

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end

return abilityObject
