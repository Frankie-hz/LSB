/*
===========================================================================

  Copyright (c) 2026 LandSandBoat Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "map/data/datasets/zones/nodes/dataset.h"
#include "map/data/loader.h"

#include <catch2/catch_test_macros.hpp>

#include <algorithm>
#include <stdexcept>

namespace
{

using NodesDataset = xi::data::datasets::zones::nodes::Dataset;

constexpr auto kTriangle = R"(
nodes:

  4:  {at: [-10.00, -40.00, 20.00], radius: 5.00, source: extracted, links: [7, 12]}
  7:  {at: [5.00, -40.50, 22.00], radius: 0.00, source: recorded, links: [4, 12]}
  12: {at: [-2.00, -41.00, 35.00], radius: 3.25, source: navmesh, links: [4, 7]}
)";

} // namespace

TEST_CASE("nodes: each node keeps its position, radius, source and links", "[data][nodes]")
{
    const auto records = NodesDataset::decode(kTriangle);

    REQUIRE(records.size() == 3);

    const auto& first = records.front();
    REQUIRE(first.Id == 4);
    REQUIRE(first.At[0] == -10.0f);
    REQUIRE(first.At[1] == -40.0f);
    REQUIRE(first.At[2] == 20.0f);
    REQUIRE(first.Radius == 5.0f);
    REQUIRE(first.Source == xi::data::PathNodeSource::Extracted);
    REQUIRE(first.Links == std::vector<uint32>{ 7, 12 });

    REQUIRE(records[1].Radius == 0.0f);
    REQUIRE(records[1].Source == xi::data::PathNodeSource::Recorded);
    REQUIRE(records[2].Source == xi::data::PathNodeSource::Navmesh);
}

TEST_CASE("nodes: a position that is not x, y, z is rejected", "[data][nodes]")
{
    constexpr auto flat = R"(
nodes:
  1: {at: [0.0, 0.0], radius: 1.0, source: extracted, links: []}
)";

    REQUIRE_THROWS_AS(NodesDataset::decode(flat), std::runtime_error);
}

TEST_CASE("nodes: a negative radius is rejected", "[data][nodes]")
{
    constexpr auto negative = R"(
nodes:
  1: {at: [0.0, 0.0, 0.0], radius: -1.0, source: extracted, links: []}
)";

    REQUIRE_THROWS_AS(NodesDataset::decode(negative), std::runtime_error);
}

TEST_CASE("nodes: an unknown source is rejected", "[data][nodes]")
{
    constexpr auto guessed = R"(
nodes:
  1: {at: [0.0, 0.0, 0.0], radius: 1.0, source: guessed, links: []}
)";

    REQUIRE_THROWS_AS(NodesDataset::decode(guessed), std::runtime_error);
}

TEST_CASE("nodes: a link to a missing node is rejected", "[data][nodes]")
{
    constexpr auto dangling = R"(
nodes:
  1: {at: [0.0, 0.0, 0.0], radius: 1.0, source: extracted, links: [2]}
)";

    REQUIRE_THROWS_AS(NodesDataset::decode(dangling), std::runtime_error);
}

TEST_CASE("nodes: a link listed on only one of its nodes is rejected", "[data][nodes]")
{
    constexpr auto oneSided = R"(
nodes:
  1: {at: [0.0, 0.0, 0.0], radius: 1.0, source: extracted, links: [2]}
  2: {at: [9.0, 0.0, 0.0], radius: 1.0, source: extracted, links: []}
)";

    REQUIRE_THROWS_AS(NodesDataset::decode(oneSided), std::runtime_error);
}

TEST_CASE("nodes: a node linking to itself is rejected", "[data][nodes]")
{
    constexpr auto loop = R"(
nodes:
  1: {at: [0.0, 0.0, 0.0], radius: 1.0, source: extracted, links: [1]}
)";

    REQUIRE_THROWS_AS(NodesDataset::decode(loop), std::runtime_error);
}

TEST_CASE("nodes: a link listed twice is rejected", "[data][nodes]")
{
    constexpr auto twice = R"(
nodes:
  1: {at: [0.0, 0.0, 0.0], radius: 1.0, source: extracted, links: [2, 2]}
  2: {at: [9.0, 0.0, 0.0], radius: 1.0, source: extracted, links: [1]}
)";

    REQUIRE_THROWS_AS(NodesDataset::decode(twice), std::runtime_error);
}

TEST_CASE("nodes: East Ronfaure loads with every source present", "[data][nodes]")
{
    const auto records = xi::data::loadZoneFile<NodesDataset>(xi::ZoneId::EastRonfaure);
    REQUIRE(records.has_value());
    REQUIRE(records->size() > 1000);

    for (const auto source : { xi::data::PathNodeSource::Extracted, xi::data::PathNodeSource::Recorded, xi::data::PathNodeSource::Navmesh })
    {
        REQUIRE(std::ranges::any_of(*records, [source](const auto& node)
                                    {
                                        return node.Source == source;
                                    }));
    }
}
