--[[
Mobs that rage after a set amount of time in combat. Once the timer is up, stats rise in steps once a minute,
counted from when the mob engaged. Everything resets if the mob disengages.

localVar      default  description
--------      -------  -----------
[rage]timer   1200     seconds into combat at which the mob rages. Set onMobSpawn.

Steps come from a table of minutes since the timer, so 0 lands when it runs out. Each row holds the totals from
that minute on, not increments, and the last row is the cap. A stat left out of a row keeps its previous total.
    damage : percent of the mob's base damage multiplier (100 is unchanged)
    defp   : percent DEF
    acc    : flat ACC
    eva    : percent EVA

A mob can replace the whole table by setting mixinOptions in its script:

mixinOptions =
{
    rage =
    {
        [0] = { damage = 150, defp = 25, acc = 50, eva = 10 },
        [1] = { damage = 200, defp = 50, acc = 75, eva = 15 },
    },
}

Elemental resistance ranks are not in the table. All of them gain 1 per minute from the timer on, up to 11.

https://ffxiclopedia.fandom.com/wiki/Rage
--]]

require('scripts/globals/mixins')

g_mixins = g_mixins or {}

local maxResistanceRank = 11

local scheduleMods =
{
    defp = xi.mod.DEFP,
    acc  = xi.mod.ACC,
    eva  = xi.mod.EVA_PERCENT,
}

-- Damage up to 5 is Roc's melee against its pre-rage damage, then Behemoth's growth since Roc's data ends there.
-- DEF is fit from player hits on Roc at a constant ATT. Normal hits read 0 from 4 while crits still land.
-- Roc's DEF also rose in the 4 minutes before its timer. Those steps are left out on purpose.
-- ACC, EVA and damage past 5 are guesses.
-- Capture needed
local defaultSchedule =
{
    [ 0] = { damage =  180, defp =   60, acc =  60, eva = 10 },
    [ 1] = { damage =  210, defp =  100, acc =  80, eva = 10 },
    [ 2] = { damage =  220, defp =  115, acc = 110, eva = 15 },
    [ 3] = { damage =  340, defp =  200, acc = 150, eva = 30 },
    [ 4] = { damage =  620, defp = 1700, acc = 150, eva = 30 },
    [ 5] = { damage =  820, defp = 1700, acc = 150, eva = 35 },
    [ 6] = { damage = 1030, defp = 1700, acc = 150, eva = 35 },
    [ 7] = { damage = 1450, defp = 1700, acc = 150, eva = 35 },
    [ 8] = { damage = 1950, defp = 1700, acc = 150, eva = 35 },
    [ 9] = { damage = 2330, defp = 1700, acc = 150, eva = 35 },
    [10] = { damage = 2330, defp = 1700, acc = 150, eva = 35 },
    [11] = { damage = 2330, defp = 1700, acc = 150, eva = 35 },
}

local function setModTotal(mob, modifier, total)
    local varName = '[rage]mod_' .. modifier

    mob:addMod(modifier, total - mob:getLocalVar(varName))
    mob:setLocalVar(varName, total)
end

local function raiseResistanceRanks(mob)
    for element = xi.element.FIRE, xi.element.DARK do
        local rankMod = xi.data.element.getElementalResistanceRankModifier(element)

        if mob:getMod(rankMod) < maxResistanceRank then
            setModTotal(mob, rankMod, mob:getLocalVar('[rage]mod_' .. rankMod) + 1)
        end
    end
end

local function applyScheduleRow(mob, row)
    if row.damage then
        local baseMultiplier = mob:getLocalVar('[rage]baseMultiplier')

        -- 0 means the mob uses its pool multiplier, which Lua can't read.
        if baseMultiplier == 0 then
            baseMultiplier = 100
        end

        mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, math.floor(baseMultiplier * row.damage / 100))
        mob:setLocalVar('[rage]damageRaised', 1)
    end

    for stat, modifier in pairs(scheduleMods) do
        if row[stat] then
            setModTotal(mob, modifier, row[stat])
        end
    end
end

g_mixins.rage = function(rageMob, options)
    local schedule = options and options.rage or defaultSchedule

    rageMob:addListener('PRESPAWN', 'RAGE_SPAWN', function(mob)
        mob:setLocalVar('[rage]timer', 1200) -- 20 minutes
    end)

    rageMob:addListener('ENGAGE', 'RAGE_ENGAGE', function(mob)
        mob:setLocalVar('[rage]baseMultiplier', mob:getMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER))
    end)

    rageMob:addListener('COMBAT_TICK', 'RAGE_CTICK', function(mob)
        local battleMinute = math.floor(mob:getBattleTime() / 60)
        local lastMinute   = mob:getLocalVar('[rage]minute')

        -- Early return: steps only land once a minute.
        if battleMinute <= lastMinute then
            return
        end

        mob:setLocalVar('[rage]minute', battleMinute)

        local timerMinute = math.floor(mob:getLocalVar('[rage]timer') / 60)

        for step = math.max(lastMinute + 1 - timerMinute, 0), battleMinute - timerMinute do
            if schedule[step] then
                applyScheduleRow(mob, schedule[step])
            end

            raiseResistanceRanks(mob)
        end
    end)

    -- Todo: should happen when mob begins to regen while unclaimed. If 1st healing tick hasn't happened, retail mob is stil raged.
    rageMob:addListener('DISENGAGE', 'RAGE_DISENGAGE', function(mob)
        mob:setLocalVar('[rage]minute', 0)

        if mob:getLocalVar('[rage]damageRaised') == 1 then
            mob:setLocalVar('[rage]damageRaised', 0)
            mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, mob:getLocalVar('[rage]baseMultiplier'))
        end

        for _, modifier in pairs(scheduleMods) do
            setModTotal(mob, modifier, 0)
        end

        for element = xi.element.FIRE, xi.element.DARK do
            setModTotal(mob, xi.data.element.getElementalResistanceRankModifier(element), 0)
        end
    end)
end

return g_mixins.rage
