-----------------------------------
-- Infected Leech
-- Family: Mosquito
-- Description: Drains HP from enemies in a fan-shaped area. Additional effect: Plague
-- Utsusemi/Blink absorb: Ignores shadows (FFO wiki)
-- Notes: FFO wiki: when used by a jug pet the drain is a fixed 819 and does not scale with magic attack.
-- Note: No mob version exists. Values are estimates from wiki descriptions and are not
--       verified against retail jug pet data. Adjust here.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local drain = 819

    petskill:setMsg(xi.mobskills.mobDrainMove(pet, target, xi.mobskills.drainType.HP, drain, xi.attackType.MAGICAL, xi.damageType.DARK))

    xi.mobskills.mobStatusEffectMove(pet, target, xi.effect.PLAGUE, 5, 3, 60) -- TODO: Capture power/duration

    return drain
end

return abilityObject
