-----------------------------------
-- Rhinowrecker
-- Family: Beetle
-- Description: Powerful physical attack to enemies in a cone. Additional Effect: Defense Down, Knockback
-- Range: Cone originating from caster.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/rhinowrecker.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 3.0, 3.0, 3.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3 -- TODO: Capture shadowBehavior

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        -- TODO: Mob version notes DEF Down power is NM specific. Needs jug pet captures.
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.DEFENSE_DOWN, 25, 0, 180)
    end

    return info.damage
end

return abilityObject
