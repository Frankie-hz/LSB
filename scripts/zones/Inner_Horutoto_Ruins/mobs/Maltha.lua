-----------------------------------
-- Area: Inner Horutoto Ruins
--   NM: Maltha
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 288)
end

return entity
