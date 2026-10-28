-----------------------------------
-- Area: Vunkerl Inlet [S]
--   NM: Warabouc
-----------------------------------
---@type TMobEntity
local entity = {}

entity.spawnPoints =
{
    { x =  75.930, y = -40.153, z = -108.190 }
}

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 487)
end

return entity
