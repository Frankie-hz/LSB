-----------------------------------
-- Geist Wall
-- Description: Dispels one effects from targets in an area of effect.
-- Type: Enfeebling
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: 10' radial
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/geist_wall.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local dispel = target:dispelStatusEffect()

    if dispel == xi.effect.NONE then
        -- no effect
        petskill:setMsg(xi.msg.basic.SKILL_NO_EFFECT) -- no effect
    else
        petskill:setMsg(xi.msg.basic.SKILL_ERASE)
    end

    return dispel
end

return abilityObject
