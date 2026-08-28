-----------------------------------
-- Rage
-- Description: The Ram goes berserk
-- Type: Enhancing
-- Range: Self
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/rage.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-- TODO: Retail jug Rage is 50% ATTP, -50% DEFP for 4 (0 TP) to 9 (3000 TP) minutes,
--       not a flat BERSERK effect.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.BERSERK, 45, 0, 120))

    return xi.effect.BERSERK
end

return abilityObject
