-----------------------------------
-- Area: Sauromugue Champaign [S]
--   NM: Herensugue
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMod(xi.mod.TRIPLE_ATTACK, 90) -- "Triple Attacks almost every round"
    mob:addMod(xi.mod.REGAIN, 75) -- "appears to have a high rate of Regain"
end

entity.onMobDeath = function(mob, player, optParams)
    xi.hunts.checkHunt(mob, player, 531)
end

return entity
