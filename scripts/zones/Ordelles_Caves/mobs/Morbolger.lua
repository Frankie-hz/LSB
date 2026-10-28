-----------------------------------
-- Area: Ordelles Caves (193)
--   NM: Morbolger
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.ALWAYS_AGGRO, 1) -- "Aggros regardless of level"
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.MORBOLBANE)
    end
end

return entity
