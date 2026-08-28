-----------------------------------
-- Wing Slap
-- Family: Apkallu
-- Description: Slaps around a single target four times with its wings. Additional Effect: Stun
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/wing_slap.lua)
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
    params.numHits        = 4
    params.fTP            = { 0.25, 0.25, 0.25 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_4

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STUN, 1, 0, 4) -- TODO: Capture stun duration
    end

    return info.damage
end

return abilityObject
