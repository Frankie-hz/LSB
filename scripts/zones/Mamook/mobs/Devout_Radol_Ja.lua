-----------------------------------
-- Area: Mamook
--   NM: Devout Radol Ja
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDespawn = function(mob)
    xi.mob.updateNMSpawnPoint(mob)
end

return entity
