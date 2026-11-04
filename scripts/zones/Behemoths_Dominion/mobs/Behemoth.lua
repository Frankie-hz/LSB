-----------------------------------
-- Area: Behemoth's Dominion
--  HNM: Behemoth
-----------------------------------
mixins = { require('scripts/mixins/rage') }

mixinOptions =
{
    -- Damage is its melee against its pre-rage damage, with anything before 3 hidden by the damage floor.
    -- DEF, ACC and EVA match the default table.
    -- Capture needed
    rage =
    {
        [ 0] = { damage =  100, defp =   60, acc =  60, eva = 10 },
        [ 1] = { damage =  100, defp =  100, acc =  80, eva = 10 },
        [ 2] = { damage =  100, defp =  115, acc = 110, eva = 15 },
        [ 3] = { damage =  210, defp =  200, acc = 150, eva = 30 },
        [ 4] = { damage =  210, defp = 1700, acc = 150, eva = 30 },
        [ 5] = { damage =  260, defp = 1700, acc = 150, eva = 35 },
        [ 6] = { damage =  390, defp = 1700, acc = 150, eva = 35 },
        [ 7] = { damage =  620, defp = 1700, acc = 150, eva = 35 },
        [ 8] = { damage = 1030, defp = 1700, acc = 150, eva = 35 },
        [ 9] = { damage = 1450, defp = 1700, acc = 150, eva = 35 },
        [10] = { damage = 1950, defp = 1700, acc = 150, eva = 35 },
        [11] = { damage = 2330, defp = 1700, acc = 150, eva = 35 },
    },
}
-----------------------------------
---@type TMobEntity
local entity = {}

entity.onMobInitialize = function(mob)
    mob:setMobMod(xi.mobMod.GIL_MIN, 20000)
    mob:setMobMod(xi.mobMod.GIL_MAX, 20000)
    mob:setMobMod(xi.mobMod.MUG_GIL, 15500)
    mob:addImmunity(xi.immunity.LIGHT_SLEEP)
    mob:setMobMod(xi.mobMod.IDLE_DESPAWN, 90)
end

entity.onMobSpawn = function(mob)
    mob:setLocalVar('[rage]timer', 1800) -- 30 minutes
    mob:setMobMod(xi.mobMod.NO_MOVE, 0)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MODIFIER, 37) -- 109 total weapon damage
    mob:setMod(xi.mod.EVA, 301)
    mob:setMod(xi.mod.ATT, 211)
    mob:setMod(xi.mod.DARK_SLEEP_RES_RANK, 11)
    mob:setMod(xi.mod.STUN_RES_RANK, 10)
end

entity.onMobRoam = function(mob)
    mob:setMobMod(xi.mobMod.NO_MOVE, 0)
end

entity.onMobFight = function(mob, target)
    local drawInTable =
    {
        conditions =
        {
            target:getXPos() > -180 and target:getZPos() > 53,
            target:getXPos() > -230 and target:getZPos() < 5,
        },
        position = mob:getPos(),
        wait = 3,
    }
    for _, condition in ipairs(drawInTable.conditions) do
        if condition then
            mob:setMobMod(xi.mobMod.NO_MOVE, 1)
            utils.drawIn(target, drawInTable)
            break
        else
            mob:setMobMod(xi.mobMod.NO_MOVE, 0)
        end
    end
end

entity.onMobDeath = function(mob, player, optParams)
    if player then
        player:addTitle(xi.title.BEHEMOTHS_BANE)
    end
end

return entity
