//
// Auction House Area Fees
//
//   Era listing fees by auction house area:
//   - San d'Oria, Bastok and Windurst: flat fee, cheaper in your home nation.
//   - Jeuno, Nashmau and Tavnazian Safehold: base fee plus a percentage.
//   - Aht Urhgan Whitegate and Al Zahbi: higher base fee plus a percentage.
//   Zones not listed here keep the AH_* fee settings from settings/map.lua.
//   AH_MAX_FEE from settings/map.lua caps every area.
//
//   Core reads the fee settings while it handles the listing packet, so this
//   module points them at the seller's area right before core runs.
//

#include "map/utils/moduleutils.h"

#include "common/settings.h"
#include "data/enums/nation.h"

#include "map/entities/char_entity.h"
#include "map/packets/basic.h"
#include "packets/c2s/0x04e_auc.h"

#include <algorithm>
#include <array>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

namespace
{

// Tax rates are percentages of the listing price.
struct AuctionFees
{
    double baseFeeSingle{};
    double baseFeeStacks{};
    double taxRateSingle{};
    double taxRateStacks{};
};

struct NationAuctionHouse
{
    xi::Nation              nation;
    std::vector<xi::ZoneId> zones;
};

struct AuctionArea
{
    std::vector<xi::ZoneId> zones;
    AuctionFees             fees;
};

constexpr auto homeNationFees = AuctionFees{ .baseFeeSingle = 1, .baseFeeStacks = 5, .taxRateSingle = 0, .taxRateStacks = 0 };

constexpr auto foreignNationFees = AuctionFees{ .baseFeeSingle = 100, .baseFeeStacks = 500, .taxRateSingle = 0, .taxRateStacks = 0 };

const auto nationAuctionHouses = std::array{
    NationAuctionHouse{
        .nation = xi::Nation::Sandoria,
        .zones  = { xi::ZoneId::SouthernSanDoria, xi::ZoneId::PortSanDoria },
    },
    NationAuctionHouse{
        .nation = xi::Nation::Bastok,
        .zones  = { xi::ZoneId::BastokMines, xi::ZoneId::BastokMarkets, xi::ZoneId::PortBastok },
    },
    NationAuctionHouse{
        .nation = xi::Nation::Windurst,
        .zones  = { xi::ZoneId::WindurstWalls, xi::ZoneId::WindurstWoods },
    },
};

const auto auctionAreas = std::array{
    AuctionArea{
        .zones = {
            xi::ZoneId::RuludeGardens,
            xi::ZoneId::UpperJeuno,
            xi::ZoneId::LowerJeuno,
            xi::ZoneId::PortJeuno,
            xi::ZoneId::Nashmau,
            xi::ZoneId::TavnazianSafehold,
        },
        .fees = { .baseFeeSingle = 50, .baseFeeStacks = 200, .taxRateSingle = 1.0, .taxRateStacks = 0.5 },
    },
    AuctionArea{
        .zones = {
            xi::ZoneId::AhtUrhganWhitegate,
            xi::ZoneId::AlZahbi,
        },
        .fees = { .baseFeeSingle = 100, .baseFeeStacks = 400, .taxRateSingle = 1.0, .taxRateStacks = 0.5 },
    },
};

auto readFeeSettings() -> AuctionFees
{
    return AuctionFees{
        .baseFeeSingle = settings::get<double>("map.AH_BASE_FEE_SINGLE"),
        .baseFeeStacks = settings::get<double>("map.AH_BASE_FEE_STACKS"),
        .taxRateSingle = settings::get<double>("map.AH_TAX_RATE_SINGLE"),
        .taxRateStacks = settings::get<double>("map.AH_TAX_RATE_STACKS"),
    };
}

void applyFeeSettings(const AuctionFees& fees)
{
    const auto entries = std::array<std::pair<std::string_view, double>, 4>{ {
        { "map.AH_BASE_FEE_SINGLE", fees.baseFeeSingle },
        { "map.AH_BASE_FEE_STACKS", fees.baseFeeStacks },
        { "map.AH_TAX_RATE_SINGLE", fees.taxRateSingle },
        { "map.AH_TAX_RATE_STACKS", fees.taxRateStacks },
    } };

    for (const auto& [key, value] : entries)
    {
        // settings::set invalidates every cached setting on every thread, so only write on change
        if (settings::get<double>(key) != value)
        {
            settings::set(std::string{ key }, value);
        }
    }
}

} // namespace

class AHAreaFeesModule : public CPPModule
{
    void OnInit() override
    {
        TracyZoneScoped;

        defaultFees_ = readFeeSettings();
    }

    auto OnIncomingPacket(MapSession* session, CCharEntity* PChar, CBasicPacket& packet) -> bool override
    {
        if (packet.getType() != static_cast<uint16_t>(PacketC2S::GP_CLI_COMMAND_AUC))
        {
            return false;
        }

        // AskCommit shows the fee to the seller, LotIn charges it
        const auto command = packet.as<GP_CLI_COMMAND_AUC>()->Command;
        if (command != GP_CLI_COMMAND_AUC_COMMAND::AskCommit && command != GP_CLI_COMMAND_AUC_COMMAND::LotIn)
        {
            return false;
        }

        applyFeeSettings(feesFor(PChar->getZone(), PChar->profile.nation));

        return false;
    }

    auto feesFor(const xi::ZoneId zoneId, const xi::Nation sellerNation) const -> const AuctionFees&
    {
        const auto inZone = [zoneId](const auto& candidate)
        {
            return std::ranges::contains(candidate.zones, zoneId);
        };

        if (const auto house = std::ranges::find_if(nationAuctionHouses, inZone); house != nationAuctionHouses.end())
        {
            if (house->nation == sellerNation)
            {
                return homeNationFees;
            }

            return foreignNationFees;
        }

        if (const auto area = std::ranges::find_if(auctionAreas, inZone); area != auctionAreas.end())
        {
            return area->fees;
        }

        return defaultFees_;
    }

    AuctionFees defaultFees_{};
};

REGISTER_CPP_MODULE(AHAreaFeesModule);
