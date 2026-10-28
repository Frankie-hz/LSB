-----------------------------------
-- Area: Promyvion-Mea
--  Mob: Coveter
-----------------------------------
mixins = { require('scripts/mixins/families/empty_terroanima') }
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMod(xi.mod.REGAIN, 100)
end

return entity
