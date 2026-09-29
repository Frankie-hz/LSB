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

#include "map/path_nodes.h"

#include <catch2/catch_test_macros.hpp>

#include <algorithm>
#include <iterator>
#include <vector>

namespace
{

using xi::data::PathNodeData;
using xi::data::PathNodeSource;

auto node(const uint32 id, const float x, const float y, const float z, std::vector<uint32> links) -> PathNodeData
{
    return PathNodeData{ .Id = id, .At = { x, y, z }, .Radius = 2.0f, .Source = PathNodeSource::Extracted, .Links = std::move(links) };
}

// A square with one diagonal, a node on the floor below the corner at 20/20, and one across a cell border at 16 y.
auto graph() -> PathNodes
{
    return PathNodes({
        node(10, 0.0f, 0.0f, 0.0f, { 11, 13, 12 }),
        node(11, 20.0f, 0.0f, 0.0f, { 10, 12 }),
        node(12, 20.0f, 0.0f, 20.0f, { 11, 13, 10 }),
        node(13, 0.0f, 0.0f, 20.0f, { 12, 10 }),
        node(14, 20.0f, -30.0f, 20.0f, {}),
        node(15, 15.9f, 0.0f, 0.0f, {}),
    });
}

auto idOf(const PathNodes& nodes, const uint32 index) -> uint32
{
    return nodes.node(index).id;
}

} // namespace

TEST_CASE("path nodes: links resolve to the linked nodes", "[path_nodes]")
{
    const auto nodes = graph();

    REQUIRE(nodes.size() == 6);

    const auto          corner = nodes.neighbours(0);
    std::vector<uint32> ids;
    std::ranges::transform(corner, std::back_inserter(ids), [&](const uint32 index)
                           {
                               return idOf(nodes, index);
                           });
    REQUIRE(ids == std::vector<uint32>{ 11, 13, 12 });

    REQUIRE(nodes.neighbours(4).empty());
}

TEST_CASE("path nodes: nearest finds the closest node within reach", "[path_nodes]")
{
    const auto nodes = graph();

    const auto close = nodes.nearest(position_t(19.0f, 0.0f, 18.5f, 0, 0), 5.0f);
    REQUIRE(close.has_value());
    REQUIRE(idOf(nodes, *close) == 12);

    REQUIRE_FALSE(nodes.nearest(position_t(10.0f, 0.0f, 10.0f, 0, 0), 5.0f).has_value());
}

TEST_CASE("path nodes: nearest prefers the node on the same floor", "[path_nodes]")
{
    const auto nodes = graph();

    const auto below = nodes.nearest(position_t(20.0f, -29.0f, 19.0f, 0, 0), 10.0f);
    REQUIRE(below.has_value());
    REQUIRE(idOf(nodes, *below) == 14);
}

TEST_CASE("path nodes: queries reach across cell borders", "[path_nodes]")
{
    const auto nodes = graph();

    const auto across = nodes.nearest(position_t(16.1f, 0.0f, 0.0f, 0, 0), 1.0f);
    REQUIRE(across.has_value());
    REQUIRE(idOf(nodes, *across) == 15);

    auto found = nodes.within(position_t(18.0f, 0.0f, 0.0f, 0, 0), 3.0f);
    std::ranges::sort(found);
    REQUIRE(found.size() == 2);
    REQUIRE(idOf(nodes, found[0]) == 11);
    REQUIRE(idOf(nodes, found[1]) == 15);
}

TEST_CASE("path nodes: touchedBy finds the nodes whose radius a flat segment enters on the same floor", "[path_nodes]")
{
    const auto nodes = graph();
    const auto at    = [](const float x, const float y, const float z)
    {
        return position_t(x, y, z, 0, 0);
    };

    const auto inside = nodes.touchedBy(at(1.5f, 0.5f, 0.0f), at(1.5f, 0.5f, 0.0f));
    REQUIRE(inside.size() == 1);
    REQUIRE(idOf(nodes, inside.front()) == 10);

    const auto crossing = nodes.touchedBy(at(-5.0f, 0.0f, 1.0f), at(5.0f, 0.0f, 1.0f));
    REQUIRE(crossing.size() == 1);
    REQUIRE(idOf(nodes, crossing.front()) == 10);

    REQUIRE(nodes.touchedBy(at(3.0f, 0.0f, 0.0f), at(3.0f, 0.0f, 0.0f)).empty());
    REQUIRE(nodes.touchedBy(at(0.0f, 10.0f, 0.0f), at(0.0f, 10.0f, 0.0f)).empty());
}
