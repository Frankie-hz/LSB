-----------------------------------
-- Choke Breath
-- Family: Hippogryph
-- Description: Deals sonic damage to enemies within a fan-shaped area originating from caster. Additional Effects: Paralysis, Silence.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/choke_breath.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = 100
    params.numHits        = 1
    params.fTP            = { 1.0, 1.0, 1.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3 -- TODO: Capture shadowBehavior

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.PARALYSIS, 25, 0, 30)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.SILENCE, 1, 0, 30)
    end

    return info.damage
end

return abilityObject
