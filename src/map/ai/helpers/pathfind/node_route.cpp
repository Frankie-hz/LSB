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

#include <map/ai/helpers/pathfind/node_route.h>

#include <common/utils.h>
#include <common/xirand.h>

#include <map/path_nodes.h>
#include <map/roam_region.h>

#include <algorithm>
#include <cmath>
#include <limits>

namespace
{

// how far a mob looks for a node to join the graph at
constexpr float kJoinDistance = 30.0f;

// past a node's radius, still standing on it: the widest aim offset plus slack for the last step
constexpr float kOnNodeSlack = 2.5f;

constexpr float kMaxAimOffset         = 2.0f;
constexpr float kAimOffsetRadiusShare = 0.4f;
constexpr uint8 kAimOffsetSteps       = 4;
constexpr float kGoldenAngle          = 2.39996323f;

auto allowed(const PathNodes& nodes, const uint32 index, const pathfind::NodeRouteRequest& request) -> bool
{
    const auto& position = nodes.node(index).position;
    if (!isWithinDistance(request.anchor, position, request.range, true))
    {
        return false;
    }

    return !request.region || request.region->contains(position.x, position.z);
}

auto joinNode(const PathNodes& nodes, const pathfind::NodeRouteRequest& request) -> Maybe<uint32>
{
    Maybe<uint32> best;
    auto          bestDistance = std::numeric_limits<float>::max();
    for (const auto index : nodes.within(request.from, kJoinDistance))
    {
        if (!allowed(nodes, index, request))
        {
            continue;
        }

        const auto nodeDistance = distanceSquared(request.from, nodes.node(index).position);
        if (nodeDistance < bestDistance)
        {
            bestDistance = nodeDistance;
            best         = index;
        }
    }

    return best;
}

auto turnAt(const PathNodes& nodes, const uint32 index) -> pathfind::RoamTurn
{
    const auto& node = nodes.node(index);
    return pathfind::RoamTurn{ .position = node.position, .arrivalRadius = node.radius };
}

} // namespace

namespace pathfind
{

auto findNodeRoute(const PathNodes& nodes, const NodeRouteRequest& request) -> std::vector<RoamTurn>
{
    const auto start = joinNode(nodes, request);
    if (!start)
    {
        return {};
    }

    std::vector<RoamTurn> turns;
    turns.reserve(request.hops + 1);

    const auto& startNode = nodes.node(*start);
    if (!isWithinDistance(request.from, startNode.position, startNode.radius + kOnNodeSlack))
    {
        turns.push_back(turnAt(nodes, *start));
    }

    auto                current = *start;
    Maybe<uint32>       previous;
    std::vector<uint32> candidates;
    for (uint8 hop = 0; hop < request.hops; ++hop)
    {
        candidates.clear();
        for (const auto next : nodes.neighbours(current))
        {
            if (next != previous && allowed(nodes, next, request))
            {
                candidates.push_back(next);
            }
        }

        if (candidates.empty() && previous && allowed(nodes, *previous, request))
        {
            candidates.push_back(*previous);
        }

        if (candidates.empty())
        {
            break;
        }

        const auto next = candidates[xirand::GetRandomNumber(candidates.size())];
        turns.push_back(turnAt(nodes, next));
        previous = current;
        current  = next;
    }

    return turns;
}

auto aimOffset(const uint32 entityId, const float arrivalRadius) -> AimOffset
{
    const auto step   = static_cast<float>((entityId % kAimOffsetSteps) + 1) / static_cast<float>(kAimOffsetSteps);
    const auto length = std::min(kMaxAimOffset * step, kAimOffsetRadiusShare * arrivalRadius);
    const auto angle  = static_cast<float>(entityId % 360) * kGoldenAngle;

    return AimOffset{ .x = length * std::cos(angle), .z = length * std::sin(angle) };
}

} // namespace pathfind
