-----------------------------------
-- Hoof Volley
-- Family: Hippogryph
-- Description: Deals critical damage to a single target. Additional Effect: Hate Reset, Knockback
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/hoof_volley.lua)
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
    params.fTP            = { 4.0, 4.0, 4.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        -- TODO: Capture hate reset type (Enmity wipe vs enmity turned off)
        -- See Antica petskill "Sand Trap" for reference
        pet:resetEnmity(target)
    end

    return info.damage
end

return abilityObject
