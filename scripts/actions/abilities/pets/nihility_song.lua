-----------------------------------
-- Nihility Song
-- Family: Hippogryph
-- Description: A song dispels a positive effect in an area of effect, including food.
-- Type: Enfeebling
-- Utsusemi/Blink absorb: Ignores shadows
-- Range: Radial 12.5'
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/nihility_song.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local dispel =  target:dispelStatusEffect(bit.bor(xi.effectFlag.DISPELABLE, xi.effectFlag.FOOD))

    if dispel == xi.effect.NONE then
        -- no effect
        petskill:setMsg(xi.msg.basic.SKILL_NO_EFFECT) -- no effect
    else
        petskill:setMsg(xi.msg.basic.SKILL_ERASE)
    end

    return dispel
end

return abilityObject
