-----------------------------------
-- Queasyshroom
-- Family: Funguar
-- Description: Deals physical damage to a single target. Additional Effect: Poison
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/queasyshroom.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    local pet = player:getPet()
    if pet == nil or pet:getAnimationSub() ~= 0 then
        return xi.msg.basic.PET_CANNOT_DO_ACTION, 0 -- TODO: verify exact message in packet.
    end

    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage     = pet:getWeaponDmg()
    params.numHits        = 1
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.PIERCING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.canCrit        = true
    params.criticalChance = { 0.10, 0.20, 0.25 } -- TODO: Capture crit rate

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        local power = pet:getMainLvl() / 10 + 1
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.POISON, power, 3, 60)
    end

    petskill:setFinalAnimationSub(1)

    return info.damage
end

return abilityObject
