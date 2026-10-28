-----------------------------------
-- Area: East Ronfaure [S]
--   NM: Melusine
-----------------------------------
---@type TMobEntity
local entity = {}

entity.spawnPoints =
{
    { x =  794.000, y = -59.000, z =  510.000 }
}

entity.onMobInitialize = function(mob)
    xi.mob.updateNMSpawnPoint(mob)
end

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 482)
end

entity.onMobDespawn = function(mob)
    xi.mob.updateNMSpawnPoint(mob)
end

return entity
