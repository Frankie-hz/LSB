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

#include <common/cbasetypes.h>
#include <common/mmo.h>

#include <map/ai/helpers/pathfind/pathfind_types.h>

#include <vector>

class PathNodes;
class RoamRegion;

namespace pathfind
{

struct NodeRouteRequest
{
    position_t        from;
    position_t        anchor;
    float             range; // nodes further than this from the anchor are off limits
    uint8             hops;
    const RoamRegion* region; // when set, nodes outside it are off limits
};

struct AimOffset
{
    float x;
    float z;
};

// Joins the graph at the closest allowed node, then walks `hops` random links, turning straight back only at a dead end.
// Empty when no allowed node is close enough to join.
auto findNodeRoute(const PathNodes& nodes, const NodeRouteRequest& request) -> std::vector<RoamTurn>;

// Retail mobs each aim at their own spot beside a node's center, so a group walking the same nodes does not stack.
auto aimOffset(uint32 entityId, float arrivalRadius) -> AimOffset;

} // namespace pathfind
