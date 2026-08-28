-----------------------------------
-- ??? Needles
-- Family: Cactuar
-- Description: Shoots multiple needles at enemies within range.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/random_needles.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
--       The mob version's Cuijatender (Abyssea) damage override does not apply to pets.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage         = math.randomInt(1000, 10000) / petskill:getTotalTargets()
    params.numHits            = 1
    params.fTP                = { 1.0, 1.0, 1.0 }
    params.attackType         = xi.attackType.PHYSICAL
    params.damageType         = xi.damageType.PIERCING
    params.shadowBehavior     = xi.mobskills.shadowBehavior.WIPE_SHADOWS
    params.guaranteedFirstHit = true
    params.skipPDIF           = true

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)
    end

    return info.damage
end

return abilityObject
