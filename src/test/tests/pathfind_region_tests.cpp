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

#include "map/ai/helpers/pathfind/pathfind.h"
#include "map/roam_region.h"
#include "pathfind_fakes.h"

#include "common/utils.h"

#include <catch2/catch_test_macros.hpp>

#include <memory>

namespace
{

using pathfind_fakes::FlatNavMesh;
using pathfind_fakes::StubOwner;

auto squareWithHole() -> RoamRegion
{
    const RoamRegion::Ring outer{ { 0.0f, -10.0f, 0.0f }, { 100.0f, -10.0f, 0.0f }, { 100.0f, -10.0f, 100.0f }, { 0.0f, -10.0f, 100.0f } };
    const RoamRegion::Ring hole{ { 40.0f, -10.0f, 40.0f }, { 60.0f, -10.0f, 40.0f }, { 60.0f, -10.0f, 60.0f }, { 40.0f, -10.0f, 60.0f } };

    return RoamRegion(outer, { hole });
}

// every yalm of the straight leg from `from` to `to` lies in the region
auto legStaysInside(const RoamRegion& region, const position_t& from, const position_t& to) -> bool
{
    const float length = distance(from, to, true);
    for (float along = 0.0f; along <= length; along += 0.5f)
    {
        const float t = length > 0.0f ? along / length : 0.0f;
        if (!region.contains(from.x + (to.x - from.x) * t, from.z + (to.z - from.z) * t))
        {
            return false;
        }
    }

    return region.contains(to.x, to.z);
}

} // namespace

TEST_CASE("pathdebug snapshots follow the active cursor without querying the navmesh", "[pathdebug][pathfind]")
{
    FlatNavMesh navMesh;
    auto        owner = std::make_unique<StubOwner>(position_t{ 0, -8, 0, 0, 0 }, navMesh);
    CPathFind   path(std::move(owner));
    const auto  now = timer::now();
    CHECK(path.GetDebugSnapshot(now).points.empty());
    REQUIRE(path.PathThrough({ { { 0, -8, 0, 0, 0 }, 0s, false }, { { 100, -18, 0, 0, 0 }, 0s, false } }));
    const auto frozen = path.GetDebugSnapshot(now);
    REQUIRE(frozen.points.size() == 2);
    CHECK(frozen.cursor == 0);
    CHECK(frozen.destination.y == -18);
    path.FollowPath(now);
    CHECK(path.GetDebugSnapshot(now).cursor == 1);
    CHECK(frozen.cursor == 0);
    path.Pause();
    CHECK(path.GetDebugSnapshot(now).paused);
    path.FollowPath(now + 1s);
    CHECK(path.GetDebugSnapshot(now).cursor == 1);
    path.Unpause();
    CHECK_FALSE(path.GetDebugSnapshot(now).paused);
    path.Clear();
    CHECK(path.GetDebugSnapshot(now).points.empty());
    CHECK(frozen.points.size() == 2);
    CHECK(navMesh.queries == 0);
    REQUIRE(path.PathTo({ 200, -10, 50, 0, 0 }));
    const auto queries = navMesh.queries;
    const auto route   = path.GetDebugSnapshot(now);
    CHECK_FALSE(route.points.empty());
    CHECK(route.destination.x == 200);
    CHECK(route.chunks == 1);
    CHECK(navMesh.queries == queries);
}

TEST_CASE("pathdebug snapshots preserve waypoint waits and patrol restarts", "[pathdebug][pathfind]")
{
    FlatNavMesh navMesh;
    auto        owner    = std::make_unique<StubOwner>(position_t{ 0, -8, 0, 0, 0 }, navMesh);
    auto*       position = &owner->position();
    CPathFind   path(std::move(owner));
    const auto  now = timer::now();
    REQUIRE(path.PathThrough({ { { 0, -8, 0, 0, 0 }, 1s, false }, { { 100, -8, 0, 0, 0 }, 0s, false } }, PATHFLAG_PATROL));
    path.FollowPath(now);
    CHECK(path.GetDebugSnapshot(now).waiting);
    CHECK(path.GetDebugSnapshot(now).cursor == 0);
    path.FollowPath(now + 2s);
    CHECK(path.GetDebugSnapshot(now + 2s).cursor == 1);
    *position = { 100, -8, 0, 0, 0 };
    path.FollowPath(now + 3s);
    CHECK(path.GetDebugSnapshot(now + 3s).cursor == 0);
    CHECK(path.GetDebugSnapshot(now + 3s).points.size() == 2);
}

TEST_CASE("pathdebug snapshots distinguish a chunk endpoint from the eventual target", "[pathdebug][pathfind]")
{
    FlatNavMesh navMesh;
    navMesh.partial     = true;
    auto       owner    = std::make_unique<StubOwner>(position_t{ 0, -8, 0, 0, 0 }, navMesh);
    auto*      position = &owner->position();
    CPathFind  path(std::move(owner));
    const auto now = timer::now();
    REQUIRE(path.PathTo({ 200, -8, 0, 0, 0 }));
    const auto snapshot = path.GetDebugSnapshot(now);
    REQUIRE_FALSE(snapshot.points.empty());
    CHECK(snapshot.partial);
    CHECK(snapshot.points.back().position.x == 100);
    CHECK(snapshot.destination.x == 200);
    CHECK(snapshot.chunks == 1);
    const auto queries = navMesh.queries;
    CHECK(path.GetDebugSnapshot(now).destination.x == 200);
    CHECK(navMesh.queries == queries);
    navMesh.partial = false;
    *position       = snapshot.points.back().position;
    path.FollowPath(now);
    const auto next = path.GetDebugSnapshot(now);
    CHECK(next.chunks == 2);
    CHECK_FALSE(next.partial);
    CHECK(next.destination.x == 200);
    REQUIRE_FALSE(next.points.empty());
    CHECK(next.points.back().position.x == 200);
    CHECK(snapshot.points.back().position.x == 100);
}

TEST_CASE("pathfind: a roam leg never crosses out of its region", "[pathfind][region]")
{
    const auto  region = squareWithHole();
    FlatNavMesh navMesh;

    // hard against the hole, where a drawn step is most likely to want to cross it
    for (const auto& start : { position_t{ 39.0f, -10.0f, 50.0f, 0, 0 }, position_t{ 50.0f, -10.0f, 39.0f, 0, 0 }, position_t{ 2.0f, -10.0f, 2.0f, 0, 0 } })
    {
        for (int i = 0; i < 300; ++i)
        {
            auto      owner    = std::make_unique<StubOwner>(start, navMesh);
            auto*     ownerPtr = owner.get();
            CPathFind pathFind(std::move(owner));

            if (!pathFind.RoamAround(start, 30.0f, 1, 1, xi::RoamFlag::None, &region))
            {
                continue;
            }

            REQUIRE(legStaysInside(region, ownerPtr->position(), pathFind.GetDestination()));
        }
    }
}

TEST_CASE("pathfind: a region mob that cannot sample a leg walks back onto its region", "[pathfind][region]")
{
    const auto  region = squareWithHole();
    FlatNavMesh navMesh;

    // outside the outline every sample fails
    const position_t stranded{ -10.0f, -10.0f, 50.0f, 0, 0 };
    auto             owner    = std::make_unique<StubOwner>(stranded, navMesh);
    auto*            ownerPtr = owner.get();
    CPathFind        pathFind(std::move(owner));

    // the failed sample turns into a walk to a point inside, not cut at the outline
    REQUIRE(pathFind.RoamAround(stranded, 10.0f, 1, 1, xi::RoamFlag::None, &region));
    const auto destination = pathFind.GetDestination();
    CHECK(region.contains(destination.x, destination.z));
    CHECK_FALSE(region.contains(ownerPtr->position().x, ownerPtr->position().z));
}
