-----------------------------------
-- Tegmina Buffet
-- Family: Chapuli
-- Description: Delivers a threefold attack to enemies around the pet. Additional effect: Choke
-- Utsusemi/Blink absorb: 1-3 shadows (FFXIclopedia)
-- Notes: FFO wiki lists Choke at -32 HP/3s for a few tens of seconds.
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
    params.numHits        = 3
    params.fTP            = { 1.0, 1.0, 1.0 } -- TODO: Capture fTPs
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_3

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.CHOKE, 32, 3, 30)
    end

    return info.damage
end

return abilityObject
