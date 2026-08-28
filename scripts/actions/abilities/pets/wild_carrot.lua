-----------------------------------
-- Wild Carrot
-- Description: Restores HP.
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/wild_carrot.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    petskill:setMsg(xi.msg.basic.SELF_HEAL)

    return xi.mobskills.mobHealMove(target, pet:getMaxHP() * 104 / 1024)
end

return abilityObject
