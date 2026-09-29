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

#pragma once

#include "map/ai/helpers/pathfind/path_owner.h"
#include "map/navmesh/navmesh.h"

#include <string>

namespace pathfind_fakes
{

// flat ground everywhere: every path is the straight line to its end
class FlatNavMesh final : public NavMesh
{
public:
    auto findPath(const position_t&, const position_t& end, float) -> Maybe<PathResult> override
    {
        return PathResult{ { pathpoint_t{ end, 0s, false } }, false };
    }

    auto findRandomPosition(const position_t& start, float) const -> Maybe<position_t> override
    {
        return start;
    }

    auto validPosition(const position_t&) const -> bool override
    {
        return true;
    }

    auto findClosestValidPoint(const position_t& position) const -> Maybe<position_t> override
    {
        return position;
    }

    auto findFurthestValidPoint(const position_t&, const position_t& endPosition) const -> Maybe<position_t> override
    {
        return endPosition;
    }

    auto snapToValidPosition(position_t&) const -> void override
    {
    }

    auto moveAlongSurface(const position_t&, const position_t& end, position_t& result) const -> bool override
    {
        result = end;
        return true;
    }
};

class StubOwner final : public pathfind::PathOwner
{
public:
    StubOwner(position_t position, NavMesh& navMesh)
    : position_(position)
    , navMesh_(navMesh)
    {
    }

    auto position() -> position_t& override
    {
        return position_;
    }

    auto position() const -> const position_t& override
    {
        return position_;
    }

    auto navMesh() -> NavMesh& override
    {
        return navMesh_;
    }

    auto markPositionDirty() -> void override
    {
    }

    auto baseSpeed() const -> uint8 override
    {
        return 40;
    }

    auto updateSpeed(bool) -> uint8 override
    {
        return 40;
    }

    auto isMobEntity() const -> bool override
    {
        return true;
    }

    auto isRoaming() const -> bool override
    {
        return true;
    }

    auto inWater() const -> bool override
    {
        return false;
    }

    auto battleTargetPosition() const -> const position_t* override
    {
        return nullptr;
    }

    auto onPathPoint() -> void override
    {
    }

    auto onPathComplete() -> void override
    {
    }

    auto name() const -> const std::string& override
    {
        return name_;
    }

    auto id() const -> uint32 override
    {
        return 1;
    }

    auto hitboxRadius() const -> float override
    {
        return 0.0f;
    }

private:
    position_t  position_;
    NavMesh&    navMesh_;
    std::string name_{ "stub" };
};

} // namespace pathfind_fakes
