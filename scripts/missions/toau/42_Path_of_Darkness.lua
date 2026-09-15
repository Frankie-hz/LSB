-----------------------------------
-- Path of Darkness
-- Aht Uhrgan Mission 42
-----------------------------------
-- !addmission 4 40
-- Rodin-Comidin : !pos 17.205 -5.999 51.161 50
-- blank_lamp    : !pos 206.55 -1.5 20.05 72
-- _1e1 (Door)   : !pos 23 -6 -63 50
-----------------------------------

local mission = Mission:new(xi.mission.log_id.TOAU, xi.mission.id.toau.PATH_OF_DARKNESS)

mission.reward =
{
    title       = xi.title.NAJAS_COMRADE_IN_ARMS,
    nextMission = { xi.mission.log_id.TOAU, xi.mission.id.toau.FANGS_OF_THE_LION },
}

mission.sections =
{
    {
        check = function(player, currentMission, missionStatus, vars)
            return currentMission == mission.missionId
        end,

        [xi.zone.AHT_URHGAN_WHITEGATE] =
        {
            ['Naja_Salaheem'] =
            {
                onTrigger = function(player, npc)
                    return mission:event(3148, xi.besieged.getMercenaryRank(player), 1, 0, 0, 0, 0, 0, 0, 0)
                end,
            },

            ['Rodin-Comidin'] =
            {
                onTrigger = function(player, npc)
                    if not player:hasKeyItem(xi.keyItem.NYZUL_ISLE_ROUTE) then
                        return mission:progressEvent(3142, { text_table = 0 })
                    else
                        return mission:progressEvent(3141, { text_table = 0 })
                    end
                end,
            },

            onTriggerAreaEnter =
            {
                [3] = function(player, triggerArea)
                    if player:getMissionStatus(mission.areaId) > 0 then
                        local blockedDialog = mission:getLocalVar(player, 'blockedDialog')

                        return mission:progressEvent(3143, 0, 1, 0, 0, 0, 0, blockedDialog, 0, 0)
                    end
                end,
            },

            onEventUpdate =
            {
                [3143] = function(player, csid, option, npc)
                    if option == 0 then
                        player:updateEvent(0, 1, 0, 0, 0, 0, 0, 0, 0)
                    end
                end,
            },

            onEventFinish =
            {
                [3142] = function(player, csid, option, npc)
                    npcUtil.giveKeyItem(player, xi.keyItem.NYZUL_ISLE_ROUTE)
                end,

                [3143] = function(player, csid, option, npc)
                    mission:setLocalVar(player, 'blockedDialog', 1)
                    player:setPos(23.978, -6, -64.624, 63)
                end,
            },
        },

        [xi.zone.ALZADAAL_UNDERSEA_RUINS] =
        {
            ['blank_lamp'] =
            {
                onTrigger = function(player, npc)
                    if player:getMissionStatus(mission.areaId) == 0 then
                        return mission:progressEvent(6)
                    end
                end,
            },

            onZoneIn = function(player, prevZone)
                if player:getMissionStatus(mission.areaId) == 2 then
                    return 7
                end
            end,

            onEventFinish =
            {
                [6] = function(player, csid, option, npc)
                    if option == 0 then
                        player:setMissionStatus(mission.areaId, 1)
                    end
                end,

                [7] = function(player, csid, option, npc)
                    mission:complete(player)
                end,
            },
        },
    },
}

return mission
