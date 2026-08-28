-----------------------------------
-- Swooping Frenzy
-- Family: Tulfaire
-- Description: Deals physical damage to enemies in a fan-shaped area. Additional effect: Defense Down, Magic Defense Down
-- Utsusemi/Blink absorb: Multiple shadows (FFO wiki)
-- Notes: FFO wiki lists the additional effects lasting 30s to 1m.
-- Note: No mob version exists. Values are estimates from wiki descriptions and are not
--       verified against retail jug pet data. Adjust here.
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
    params.fTP            = { 2.0, 2.0, 2.0 } -- TODO: Capture fTPs
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.SLASHING
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3 -- TODO: Capture shadowBehavior

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        -- TODO: Capture power of both effects
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.DEFENSE_DOWN, 20, 0, 60)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.MAGIC_DEF_DOWN, 20, 0, 60)
    end

    return info.damage
end

return abilityObject
