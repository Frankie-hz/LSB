-----------------------------------
-- Area: East Ronfaure
--  Mob: Rambukk
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 152)
end

return entity
