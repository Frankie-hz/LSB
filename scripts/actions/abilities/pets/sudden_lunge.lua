-----------------------------------
-- Sudden Lunge
-- Family: Ladybug
-- Description: Deals physical damage to a target. Additional effect: Knockback, Stun.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/sudden_lunge.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-- TODO: The mob version's onMobSkillFinalize reduces the ladybug's own HP by 5%-15% whether
--       it hits or not. The pet flow has never applied this cost; verify against retail
--       before adding it here.
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
    params.fTP            = { 1.5, 1.5, 1.5 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.IGNORE_SHADOWS

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.STUN, 1, 0, 4) -- TODO: Capture stun duration
    end

    return info.damage
end

return abilityObject
