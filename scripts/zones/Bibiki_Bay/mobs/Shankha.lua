-----------------------------------
-- Area: Bibiki Bay
--   NM: Shankha
-- Note: Wiki says Painful Whip does increasing damage after each use, but videos do not indicate this, so I've ignored it.
--       Does not retreat into its shell, and does not poison you, unlike other uragnites.
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMod(xi.mod.REGAIN, 200) -- "Seemed to have very high TP gain." (guessing 200 after watching video)
end

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 266)
end

return entity
