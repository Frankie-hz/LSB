-----------------------------------
-- Area: Sauromugue Champaign
--   NM: Thunderclaw Thuban
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 274)
end

return entity
