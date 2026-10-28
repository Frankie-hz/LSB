-----------------------------------
-- Area: West Sarutabaruta [S]
--   NM: Tiffenotte
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 520)
end

return entity
