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

#include "map/ai/helpers/pathfind/node_route.h"
#include "map/ai/helpers/pathfind/pathfind.h"
#include "map/path_nodes.h"
#include "map/roam_region.h"
#include "pathfind_fakes.h"

#include "common/timer.h"
#include "common/utils.h"

#include <catch2/catch_test_macros.hpp>

#include <algorithm>
#include <cmath>
#include <memory>
#include <vector>

namespace
{

using pathfind_fakes::FlatNavMesh;
using pathfind_fakes::StubOwner;
using xi::data::PathNodeData;
using xi::data::PathNodeSource;

constexpr float kSpacing = 10.0f;
constexpr float kRadius  = 3.0f;

// nodes 0 to 4 along the x axis, each linked to the next
auto line() -> PathNodes
{
    xi::data::PathNodeList records;
    for (uint32 id = 0; id < 5; ++id)
    {
        std::vector<uint32> links;
        if (id > 0)
        {
            links.push_back(id - 1);
        }

        if (id < 4)
        {
            links.push_back(id + 1);
        }

        records.push_back(PathNodeData{ .Id = id, .At = { static_cast<float>(id) * kSpacing, 0.0f, 0.0f }, .Radius = kRadius, .Source = PathNodeSource::Extracted, .Links = std::move(links) });
    }

    return PathNodes(records);
}

auto at(const float x) -> position_t
{
    return position_t(x, 0.0f, 0.0f, 0, 0);
}

auto xs(const std::vector<pathfind::RoamTurn>& turns) -> std::vector<float>
{
    std::vector<float> result;
    for (const auto& turn : turns)
    {
        result.push_back(turn.position.x);
    }

    return result;
}

} // namespace

TEST_CASE("node route: walks links from the node it stands on", "[pathfind][nodes]")
{
    const auto nodes = line();

    const auto turns = pathfind::findNodeRoute(nodes, { .from = at(0.5f), .anchor = at(0.0f), .range = 100.0f, .hops = 3, .region = nullptr });

    REQUIRE(xs(turns) == std::vector<float>{ 10.0f, 20.0f, 30.0f });
    REQUIRE(turns.front().arrivalRadius == kRadius);
}

TEST_CASE("node route: walks to the nearest node first when it stands off the graph", "[pathfind][nodes]")
{
    const auto nodes = line();

    const auto turns = pathfind::findNodeRoute(nodes, { .from = position_t(19.0f, 0.0f, 12.0f, 0, 0), .anchor = at(20.0f), .range = 100.0f, .hops = 0, .region = nullptr });

    REQUIRE(xs(turns) == std::vector<float>{ 20.0f });
}

TEST_CASE("node route: stays within range of its anchor, turning back at the edge", "[pathfind][nodes]")
{
    const auto nodes = line();

    const auto turns = pathfind::findNodeRoute(nodes, { .from = at(0.0f), .anchor = at(0.0f), .range = 15.0f, .hops = 3, .region = nullptr });

    REQUIRE(xs(turns) == std::vector<float>{ 10.0f, 0.0f, 10.0f });
}

TEST_CASE("node route: keeps to its region", "[pathfind][nodes]")
{
    const auto       nodes = line();
    const RoamRegion region({ { -5.0f, 0.0f, -5.0f }, { 25.0f, 0.0f, -5.0f }, { 25.0f, 0.0f, 5.0f }, { -5.0f, 0.0f, 5.0f } }, {});

    const auto turns = pathfind::findNodeRoute(nodes, { .from = at(10.0f), .anchor = at(10.0f), .range = 100.0f, .hops = 8, .region = &region });

    REQUIRE_FALSE(turns.empty());
    for (const auto& turn : turns)
    {
        REQUIRE(region.contains(turn.position.x, turn.position.z));
    }
}

TEST_CASE("node route: skips a link whose straight line leaves the region", "[pathfind][nodes]")
{
    xi::data::PathNodeList records;
    records.push_back(PathNodeData{ .Id = 0, .At = { 0.0f, 0.0f, 0.0f }, .Radius = kRadius, .Source = PathNodeSource::Extracted, .Links = { 1 } });
    records.push_back(PathNodeData{ .Id = 1, .At = { 20.0f, 0.0f, 0.0f }, .Radius = kRadius, .Source = PathNodeSource::Extracted, .Links = { 0 } });
    const PathNodes nodes(records);

    // a U: both nodes sit in its arms, and the straight line between them crosses the notch
    const RoamRegion region({ { -5.0f, 0.0f, -5.0f }, { 25.0f, 0.0f, -5.0f }, { 25.0f, 0.0f, 5.0f }, { 15.0f, 0.0f, 5.0f }, { 15.0f, 0.0f, -2.0f }, { 5.0f, 0.0f, -2.0f }, { 5.0f, 0.0f, 5.0f }, { -5.0f, 0.0f, 5.0f } }, {});

    REQUIRE(region.contains(0.0f, 0.0f));
    REQUIRE(region.contains(20.0f, 0.0f));
    REQUIRE(pathfind::findNodeRoute(nodes, { .from = at(0.0f), .anchor = at(0.0f), .range = 100.0f, .hops = 1, .region = &region }).empty());
    REQUIRE(xs(pathfind::findNodeRoute(nodes, { .from = at(0.0f), .anchor = at(0.0f), .range = 100.0f, .hops = 1, .region = nullptr })) == std::vector<float>{ 20.0f });
}

TEST_CASE("node route: finds nothing when no node is near enough to join", "[pathfind][nodes]")
{
    const auto nodes = line();

    REQUIRE(pathfind::findNodeRoute(nodes, { .from = position_t(20.0f, 0.0f, 100.0f, 0, 0), .anchor = at(20.0f), .range = 100.0f, .hops = 2, .region = nullptr }).empty());
}

TEST_CASE("node route: aim offsets stay small and spread mobs apart", "[pathfind][nodes]")
{
    const auto first  = pathfind::aimOffset(100, 5.0f);
    const auto second = pathfind::aimOffset(101, 5.0f);

    REQUIRE(std::hypot(first.x, first.z) <= 2.0f);
    REQUIRE(std::hypot(pathfind::aimOffset(7, 1.0f).x, pathfind::aimOffset(7, 1.0f).z) <= 0.4f + 0.001f);
    REQUIRE(std::hypot(first.x - second.x, first.z - second.z) > 0.1f);
}

TEST_CASE("chase node: a mob inside a node's radius veers to its center when that closes on the target", "[pathfind][nodes]")
{
    const auto nodes = line();

    const auto node = pathfind::findChaseNode(nodes, position_t(9.0f, 0.0f, 1.0f, 0, 0), at(40.0f), 0.0f, std::nullopt);
    REQUIRE(node.has_value());
    REQUIRE(nodes.node(*node).position.x == 10.0f);

    // the node it just touched does not pull it back
    REQUIRE_FALSE(pathfind::findChaseNode(nodes, position_t(9.0f, 0.0f, 1.0f, 0, 0), at(40.0f), 0.0f, node).has_value());
}

TEST_CASE("chase node: a radius the next step runs into counts, so a fast mob does not step over a node", "[pathfind][nodes]")
{
    const auto nodes = line();
    const auto from  = position_t(5.0f, 0.0f, 1.0f, 0, 0);

    const auto node = pathfind::findChaseNode(nodes, from, position_t(40.0f, 0.0f, 1.0f, 0, 0), 3.5f, std::nullopt);
    REQUIRE(node.has_value());
    REQUIRE(nodes.node(*node).position.x == 10.0f);

    REQUIRE_FALSE(pathfind::findChaseNode(nodes, from, position_t(40.0f, 0.0f, 1.0f, 0, 0), 1.0f, std::nullopt).has_value());
}

TEST_CASE("chase node: no veer outside every radius or away from the target", "[pathfind][nodes]")
{
    const auto nodes = line();

    REQUIRE_FALSE(pathfind::findChaseNode(nodes, at(5.0f), at(40.0f), 0.0f, std::nullopt).has_value());
    REQUIRE_FALSE(pathfind::findChaseNode(nodes, at(9.0f), at(0.0f), 0.0f, std::nullopt).has_value());
}

TEST_CASE("pathfind: a node roam turns for the next node inside the arrival radius", "[pathfind][nodes]")
{
    const auto  nodes = line();
    FlatNavMesh navMesh;

    auto      owner    = std::make_unique<StubOwner>(at(0.0f), navMesh);
    auto*     ownerPtr = owner.get();
    CPathFind pathFind(std::move(owner));

    REQUIRE(pathFind.RoamNodes(nodes, at(0.0f), 100.0f, 2, 2, xi::RoamFlag::None, nullptr));

    auto farthest = 0.0f;
    for (int step = 0; step < 200 && pathFind.IsFollowingPath(); ++step)
    {
        pathFind.FollowPath(timer::now());
        farthest = std::max(farthest, ownerPtr->position().x);
    }

    // two hops from node 0 end at node 2, stopping short of its center by about the radius
    REQUIRE_FALSE(pathFind.IsFollowingPath());
    const auto stopped = distance(ownerPtr->position(), at(2.0f * kSpacing));
    CHECK(stopped >= kRadius - 1.5f);
    CHECK(stopped <= kRadius + 1.5f);
    CHECK(farthest < 2.0f * kSpacing);
}
