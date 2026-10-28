-----------------------------------
-- Area: Giddeus (145)
--   NM: Quu Xijo the Illusory
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 283)
end

return entity
