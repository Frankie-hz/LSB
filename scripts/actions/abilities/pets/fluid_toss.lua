-----------------------------------
-- Fluid Toss
-- Family: Slime (Clot)
-- Description: Lobs a ball of liquid at a single target.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/fluid_toss.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    -- TODO: Physical or Ranged PDIF?
    params.baseDamage       = pet:getWeaponDmg()
    params.numHits          = 1
    params.fTP              = { 1.5, 1.5, 1.5 }
    params.attackType       = xi.attackType.PHYSICAL
    params.damageType       = xi.damageType.SLASHING
    params.shadowBehavior   = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.attackMultiplier = { 2.0, 2.0, 2.0 }
    params.canCrit          = true
    params.criticalChance   = { 0.10, 0.20, 0.25 } -- TODO: Capture crit rate

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end

return abilityObject
