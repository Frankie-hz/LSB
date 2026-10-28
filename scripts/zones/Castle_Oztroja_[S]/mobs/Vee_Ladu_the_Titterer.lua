-----------------------------------
-- Area: Castle Oztroja [S]
--   NM: Vee Ladu the Titterer
-- TODO: summons up to four low-HP copies of itself when it casts utsusemi: ni
-----------------------------------
mixins = { require('scripts/mixins/job_special') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.spawnPoints =
{
    { x = -57.602, y = -0.823, z = -58.060 }
}

entity.onMobInitialize = function(mob)
    xi.mob.updateNMSpawnPoint(mob)
end

entity.onMobDespawn = function(mob)
    xi.mob.updateNMSpawnPoint(mob)
end

return entity
