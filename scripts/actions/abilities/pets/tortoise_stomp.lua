-----------------------------------
-- Tortoise Stomp
-- Family: Adamantoise
-- Description: Deals physical damage. Additional Effect: Defense Down
-- Note: AoE type may vary depending on NM
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/tortoise_stomp.lua)
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
    params.fTP            = { 1.0, 1.0, 1.0 }
    params.attackType     = xi.attackType.PHYSICAL
    params.damageType     = xi.damageType.BLUNT
    params.shadowBehavior = xi.mobskills.shadowBehavior.NUMSHADOWS_1
    -- Note: ShadowBehavior may vary depending on AoE Type(May vary between NMs)

    local info = xi.mobskills.mobPhysicalMove(pet, target, petskill, action, params)

    if xi.mobskills.processDamage(pet, target, petskill, action, info) then
        target:takeDamage(info.damage, pet, info.attackType, info.damageType)

        -- TODO: Random, resisted, or scales with TP?
        local duration = math.randomInt(120, 180)
        xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.DEFENSE_DOWN, 25, 0, duration)
    end

    return info.damage
end

return abilityObject
