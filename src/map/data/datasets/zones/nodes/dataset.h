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

#include "common/cbasetypes.h"

#include <array>
#include <string_view>
#include <vector>

namespace xi::data
{

enum class PathNodeSource : uint8
{
    Extracted,
    Recorded,
    Navmesh,
};

struct PathNodeData
{
    uint32               Id;
    std::array<float, 3> At;
    float                Radius;
    PathNodeSource       Source;
    std::vector<uint32>  Links;
};

using PathNodeList = std::vector<PathNodeData>;

} // namespace xi::data

namespace xi::data::datasets::zones::nodes::wire
{

struct Document;

}

namespace xi::data::datasets::zones::nodes
{

struct Dataset
{
    using Records      = xi::data::PathNodeList;
    using YamlDocument = wire::Document;

    static constexpr std::string_view kDataPath{ "nodes" };
    static constexpr std::string_view kTitle{ "Zone path nodes" };
    static constexpr std::string_view kDescription{ "Points mobs walk between when they roam or chase, and the links they may walk along, for one zone." };

    static auto decode(std::string_view text) -> Records;
};

} // namespace xi::data::datasets::zones::nodes
