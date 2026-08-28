-----------------------------------
-- Sweeping Gouge
-- Family: Raaz
-- Description: Delivers a twofold attack. Additional effect: Defense Down. Duration of effect varies with TP.
-- Notes: FFO wiki lists the mob version as -20% defense; BLU spell version is fTP 1.75, 2 hits,
--        90s base duration scaling to 135s at 3000 TP.
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
    params.numHits        = 2
    params.fTP            = { 1.75, 1.75, 1.75 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_2 -- TODO: Capture shadowBehavior

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        local duration = xi.mobskills.calculateDuration(petskill:getTP(), 90, 135)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.DEFENSE_DOWN, 20, 0, duration)
    end

    return info.damage
end

return abilityObject
