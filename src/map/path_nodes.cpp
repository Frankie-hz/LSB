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

#include "path_nodes.h"

#include <common/utils.h>

#include <algorithm>
#include <cmath>
#include <limits>

namespace
{

constexpr float kCellSize = 16.0f;

auto cellIndex(const float coordinate) -> int32
{
    return static_cast<int32>(std::floor(coordinate / kCellSize));
}

auto cellKey(const int32 cellX, const int32 cellZ) -> uint64
{
    return (static_cast<uint64>(static_cast<uint32>(cellX)) << 32) | static_cast<uint32>(cellZ);
}

} // namespace

PathNodes::PathNodes(const xi::data::PathNodeList& records)
{
    FlatHashMap<uint32, uint32> indexById;
    indexById.reserve(records.size());
    nodes_.reserve(records.size());
    for (const auto& record : records)
    {
        const auto index = static_cast<uint32>(nodes_.size());
        indexById.emplace(record.Id, index);
        nodes_.push_back(Node{
            .position = position_t(record.At[0], record.At[1], record.At[2], 0, 0),
            .radius   = record.Radius,
            .source   = record.Source,
            .id       = record.Id,
        });
        cells_[cellKey(cellIndex(record.At[0]), cellIndex(record.At[2]))].push_back(index);
    }

    linkOffsets_.reserve(records.size() + 1);
    for (const auto& record : records)
    {
        linkOffsets_.push_back(static_cast<uint32>(links_.size()));
        for (const auto link : record.Links)
        {
            links_.push_back(indexById.at(link));
        }
    }
    linkOffsets_.push_back(static_cast<uint32>(links_.size()));
}

auto PathNodes::size() const -> std::size_t
{
    return nodes_.size();
}

auto PathNodes::node(const uint32 index) const -> const Node&
{
    return nodes_[index];
}

auto PathNodes::neighbours(const uint32 index) const -> std::span<const uint32>
{
    return std::span<const uint32>(links_).subspan(linkOffsets_[index], linkOffsets_[index + 1] - linkOffsets_[index]);
}

template <class Visit>
void PathNodes::forEachNear(const position_t& position, const float reach, Visit&& visit) const
{
    const auto bounded = std::clamp(reach, 0.0f, kMaxQueryDistance);
    const auto minX    = cellIndex(position.x - bounded);
    const auto maxX    = cellIndex(position.x + bounded);
    const auto minZ    = cellIndex(position.z - bounded);
    const auto maxZ    = cellIndex(position.z + bounded);
    for (auto cellX = minX; cellX <= maxX; ++cellX)
    {
        for (auto cellZ = minZ; cellZ <= maxZ; ++cellZ)
        {
            const auto cell = cells_.find(cellKey(cellX, cellZ));
            if (cell == cells_.end())
            {
                continue;
            }

            for (const auto index : cell->second)
            {
                visit(index);
            }
        }
    }
}

auto PathNodes::nearest(const position_t& position, const float maxDistance) const -> Maybe<uint32>
{
    Maybe<uint32> best;
    auto          bestDistance = square(std::min(maxDistance, kMaxQueryDistance));
    forEachNear(position, maxDistance, [&](const uint32 index)
                {
                    const auto nodeDistance = distanceSquared(position, nodes_[index].position);
                    if (nodeDistance <= bestDistance)
                    {
                        bestDistance = nodeDistance;
                        best         = index;
                    }
                });

    return best;
}

auto PathNodes::within(const position_t& position, const float radius) const -> std::vector<uint32>
{
    std::vector<uint32> found;
    const auto          reach = square(std::min(radius, kMaxQueryDistance));
    forEachNear(position, radius, [&](const uint32 index)
                {
                    if (distanceSquared(position, nodes_[index].position) <= reach)
                    {
                        found.push_back(index);
                    }
                });

    return found;
}
