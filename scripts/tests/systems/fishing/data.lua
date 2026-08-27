describe('Fishing data tables', function()
    it('has a complete positional row behind every record', function()
        for rodId, row in pairs(xi.fishing.rodData) do
            assert(#row == 20, string.format('rodData[%u] has %u fields, expected 20', rodId, #row))
        end

        for baitId, row in pairs(xi.fishing.baitData) do
            assert(#row == 6, string.format('baitData[%u] has %u fields, expected 6', baitId, #row))
        end

        for itemId, row in pairs(xi.fishing.catchData) do
            assert(#row == 27, string.format('catchData[%u] has %u fields, expected 27', itemId, #row))
        end
    end)

    it('exposes named rod records', function()
        local ebisu = xi.fishing.rods[xi.item.EBISU_FISHING_ROD]
        assert(ebisu.fishTime == 30, 'Ebisu fishTime should be 30')
        assert(ebisu.legendaryBonusTime == 10, 'Ebisu legendaryBonusTime should be 10')
        assert(ebisu.isBreakable == false, 'Ebisu should be unbreakable')
        assert(ebisu.brokenRodId == xi.item.NONE, 'Ebisu has no broken rod item')
        assert(ebisu.isLegendary == true, 'Ebisu should be legendary')

        assert(xi.fishing.rods[xi.item.EBISU_FISHING_ROD_P1].fishTime == 40, 'Ebisu +1 fishTime should be 40')
        assert(xi.fishing.rods[xi.item.LU_SHANGS_FISHING_ROD].fishTime == 40, 'Lu Shang fishTime should be 40')
        assert(xi.fishing.rods[xi.item.LU_SHANGS_FISHING_ROD_P1].fishTime == 50, 'Lu Shang +1 fishTime should be 50')
    end)

    it('exposes named bait records', function()
        local sabiki = xi.fishing.baits[xi.item.SABIKI_RIG]
        assert(sabiki.maxHook == 3, 'Sabiki rig should hook up to 3 fish')
        assert(sabiki.isLosable == true, 'Sabiki rig should be losable')
    end)

    it('exposes named catch records', function()
        local moatCarp = xi.fishing.catches[xi.item.MOAT_CARP_1]
        assert(moatCarp.skillLevel == 11, 'Moat carp skill cap should be 11')
        assert(moatCarp.isLarge == false, 'Moat carp should be a small fish')
        assert(moatCarp.isItem == false, 'Moat carp should not be an item catch')

        local coralFragment = xi.fishing.catches[xi.item.CORAL_FRAGMENT]
        assert(coralFragment.skillLevel == 74, 'Coral fragment skill cap should be 74')
        assert(coralFragment.isItem == true, 'Coral fragment should be an item catch')

        assert(xi.fishing.catches[xi.item.COBALT_JELLYFISH].isItem == true, 'Cobalt jellyfish should be an item catch')
        assert(xi.fishing.catches[xi.item.ABAIA].isDisabled == true, 'Abaia should be disabled')
        assert(xi.fishing.catches[xi.item.GUGRUSAURUS].requiredKeyItem == xi.ki.SERPENT_RUMORS, 'Gugrusaurus should require Serpent Rumors')
    end)
end)
