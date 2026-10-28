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

#include "common/xirand.h"
#include "map/entities/mob_entity.h"

#include <catch2/catch_test_macros.hpp>

#include <chrono>
#include <set>

using namespace std::chrono_literals;

namespace
{

TEST_CASE("a respawn range rolls every interval from min to max", "[respawn]")
{
    const auto range = RespawnRange{ .min = 10s, .max = 30s, .interval = 10s };

    xirand::rng().seed(42);

    std::set<timer::duration> rolls;
    for (auto i = 0; i < 500; ++i)
    {
        rolls.insert(range.roll());
    }

    REQUIRE(rolls == std::set<timer::duration>{ 10s, 20s, 30s });
}

TEST_CASE("a fixed respawn never draws from the rng", "[respawn]")
{
    const auto fixed = RespawnRange{ .min = 300s, .max = 300s, .interval = 1s };

    xirand::rng().seed(42);
    const auto expected = xirand::GetRandomNumber<uint32>(1'000'000);

    xirand::rng().seed(42);
    REQUIRE(fixed.roll() == 300s);
    REQUIRE(xirand::GetRandomNumber<uint32>(1'000'000) == expected);
}

} // namespace
