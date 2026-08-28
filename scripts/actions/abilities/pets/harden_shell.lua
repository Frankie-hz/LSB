-----------------------------------
-- Harden Shell
-- Description: Enhances defense.
-- Type: Magical (Earth)
-- Note: Values copied 1:1 from the mob version (scripts/actions/mobskills/harden_shell.lua)
--       and not yet verified against retail jug pet data. Adjust here, not in mobskills/.
--       The mob version's NM power (80) does not apply to pets.
-- TODO: The mob version's onMobSkillCheck blocks re-use while DEFENSE_BOOST is active;
--       the pet flow has never applied that guard. Verify against retail.
-----------------------------------
---@type TAbilityPet
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0
end

abilityObject.onPetAbility = function(target, pet, petskill, owner, action)
    local duration = math.randomInt(60, 180)
    local power = 33

    petskill:setMsg(xi.mobskills.mobBuffMove(pet, xi.effect.DEFENSE_BOOST, power, 0, duration))

    return xi.effect.DEFENSE_BOOST
end

return abilityObject
