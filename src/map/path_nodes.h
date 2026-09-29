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
#include <common/types/flat_hash_map.h>
#include <common/types/maybe.h>
#include <common/types/position.h>

#include "data/datasets/zones/nodes/dataset.h"

#include <span>
#include <vector>

// A zone's path nodes: the points retail mobs walk between, joined by the links they may walk along.
// Nodes are addressed by index; the yaml id is kept for logs.
class PathNodes
{
public:
    struct Node
    {
        position_t               position;
        float                    radius;
        xi::data::PathNodeSource source;
        uint32                   id;
    };

    // queries reach at most this far, so a grid walk stays bounded
    static constexpr float kMaxQueryDistance = 256.0f;

    explicit PathNodes(const xi::data::PathNodeList& records);

    auto size() const -> std::size_t;
    auto node(uint32 index) const -> const Node&;
    auto neighbours(uint32 index) const -> std::span<const uint32>;

    // closest node within `maxDistance`, height included so a floor above or below does not win
    auto nearest(const position_t& position, float maxDistance) const -> Maybe<uint32>;

    // every node within `radius`, height included
    auto within(const position_t& position, float radius) const -> std::vector<uint32>;

    // every node whose arrival radius the flat segment from `from` to `to` enters, on the floor of `from`
    auto touchedBy(const position_t& from, const position_t& to) const -> std::vector<uint32>;

private:
    template <class Visit>
    void forEachNear(const position_t& position, float reach, Visit&& visit) const;

    std::vector<Node> nodes_;
    float             maxRadius_{ 0.0f };

    // node i links to links_[linkOffsets_[i]] up to links_[linkOffsets_[i + 1]]
    std::vector<uint32> linkOffsets_;
    std::vector<uint32> links_;

    FlatHashMap<uint64, std::vector<uint32>> cells_;
};
