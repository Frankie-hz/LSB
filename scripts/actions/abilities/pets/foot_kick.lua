-----------------------------------
-- Foot Kick
-- Family: Rabbit
-- Description: Deals critical damage to a single target.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/foot_kick.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage      = pet:getWeaponDmg()
    params.numHits         = 1
    params.fTP             = { 1.0, 1.0, 1.0 }
    params.attackType      = xi.attackType.PHYSICAL
    params.damageType      = xi.damageType.SLASHING
    params.shadowBehavior  = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.canCrit         = true
    params.criticalChance  = { 1.0, 1.0, 1.0 }

    if pet:getMainLvl() >= 50 then
        params.fTP = { 2, 2, 2 }
    end

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end

return abilityObject
