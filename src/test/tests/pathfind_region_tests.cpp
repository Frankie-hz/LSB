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
