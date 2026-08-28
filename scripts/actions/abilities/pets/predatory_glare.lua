-----------------------------------
-- Predatory Glare
-- Family: Tiger
-- Description: Stuns enemies in a fan-shaped area.
-- Type: Gaze (FFXIclopedia, flagged for verification)
-- Utsusemi/Blink absorb: Ignores shadows
-- Notes: FFO wiki: short stun duration.
-- Note: No mob version exists. Values are estimates from wiki descriptions and are not
--       verified against retail jug pet data. Adjust here.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobGazeMove(pet, target, xi.effect.STUN, 1, 0, 4)) -- TODO: Capture stun duration

    return xi.effect.STUN
end

return abilityObject
