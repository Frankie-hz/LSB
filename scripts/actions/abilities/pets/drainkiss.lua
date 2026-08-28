-----------------------------------
-- Drainkiss
-- Family: Leeches
-- Deals Dark damage to a single target. Additional Effect: HP Drain
-- Notes: If used against undead, it will simply do damage and not drain HP.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/drainkiss.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local params = {}

    params.baseDamage         = pet:getMainLvl() + 2
    params.fTP                = { 1.00, 1.25, 1.50 }
    params.element            = xi.element.NONE
    params.attackType         = xi.attackType.MAGICAL
    params.damageType         = xi.damageType.NONE
    params.shadowBehavior     = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    params.skipMagicBonusDiff = true

    local info = xi.mobskills.mobMagicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        petskill:setMsg(xi.mobskills.mobDrainMove(pet, target, xi.mobskills.drainType.HP, info.damage))
    end

    return info.damage
end

return abilityObject
