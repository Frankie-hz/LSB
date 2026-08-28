-----------------------------------
-- Chaotic Eye
--
-- Description: Silences an enemy.
-- Type: Magical (Wind)
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/chaotic_eye.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobGazeMove(pet, target, xi.effect.SILENCE, 1, 0, 60))

    return xi.effect.SILENCE
end

return abilityObject
