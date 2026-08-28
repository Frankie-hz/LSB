-----------------------------------
-- Leaf Dagger
-- Family: Mandragora
-- Description: Deals piercing damage to a single target. Additional Effect: Poison
-- Notes: On higher level Madragoras (Korrigans for example) the poision is 5hp/tick for about 5-6 ticks, damaging a total of 25-30 HP.
-- TODO: Should be subject to ranged penalties.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/leaf_dagger.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getRangedDmg()
    params.numHits        = 1
    params.fTP            = { 2.0, 2.0, 2.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.skipParry      = true
    params.skipGuard      = true
    params.skipBlock      = true

    local info = xi.mobskills.mobRangedMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        local power   = math.max(1, pet:getMainLvl() / 10)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, power, 3, 90)
    end

    return info.damage
end

return abilityObject
