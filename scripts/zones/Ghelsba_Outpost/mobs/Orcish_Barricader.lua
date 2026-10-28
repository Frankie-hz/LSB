-----------------------------------
-- Area: Ghelsba Outpost (140)
--  Mob: Orcish Barricader
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 171)
end

return entity
