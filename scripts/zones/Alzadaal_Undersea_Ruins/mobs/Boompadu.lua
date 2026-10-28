-----------------------------------
-- Area: Alzadaal Undersea Ruins
--   NM: Boompadu
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 476)
end

return entity
