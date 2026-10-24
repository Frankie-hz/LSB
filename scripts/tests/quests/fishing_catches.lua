-- Catches the quests offer through onFishingCheck, flattened the way the fishing system reads them
local function offeredCatches(player, areaId)
    local catches = {}
    for _, answer in ipairs(InteractionGlobal.onFishingCheck(player, areaId)) do
        if type(answer) == 'table' then
            for _, catchId in ipairs(answer) do
                catches[catchId] = true
            end
        else
            catches[answer] = true
        end
    end

    return catches
end

describe('Quest fishing catches', function()
    it('offers the Ripped Cap in Port Windurst until the angler holds one', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.PORT_WINDURST })
        assert(offeredCatches(player, 1)[xi.item.RIPPED_CAP], 'Ripped Cap was not offered')

        player:addItem(xi.item.RIPPED_CAP)
        assert(not offeredCatches(player, 1)[xi.item.RIPPED_CAP], 'Ripped Cap was offered to an angler holding one')
    end)

    it('offers the Hydrogauge only while Navigating the Unfriendly Seas is accepted', function()
        local player = xi.test.world:spawnPlayer({ zone = xi.zone.NASHMAU })
        assert(not offeredCatches(player, 1)[xi.item.HYDROGAUGE], 'Hydrogauge was offered before the quest')

        player:addQuest(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.NAVIGATING_THE_UNFRIENDLY_SEAS)
        assert(offeredCatches(player, 1)[xi.item.HYDROGAUGE], 'Hydrogauge was not offered during the quest')
    end)

    it('offers both fished Krakens only while Hook, Line, and Sinker is accepted', function()
        local qufimID = zones[xi.zone.QUFIM_ISLAND]
        local player  = xi.test.world:spawnPlayer({ zone = xi.zone.QUFIM_ISLAND })
        local krakens = qufimID.mob.KRAKEN_FISHED_NM

        assert(#krakens == 2, 'expected two fished Krakens in Qufim Island')
        for _, krakenId in ipairs(krakens) do
            assert(krakenId ~= qufimID.mob.KRAKEN_NM, 'the roaming Kraken was listed as a fished one')
            assert(not offeredCatches(player, 1)[krakenId], 'a Kraken was offered before the quest')
        end

        player:addQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.HOOK_LINE_AND_SINKER)
        for _, krakenId in ipairs(krakens) do
            assert(offeredCatches(player, 1)[krakenId], 'a Kraken was not offered during the quest')
        end

        player:completeQuest(xi.questLog.JEUNO, xi.quest.id.jeuno.HOOK_LINE_AND_SINKER)
        for _, krakenId in ipairs(krakens) do
            assert(not offeredCatches(player, 1)[krakenId], 'a Kraken was offered after the quest')
        end
    end)
end)
