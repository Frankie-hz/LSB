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
#include "data/yaml/schema_annotations.h"

#include <glaze/glaze.hpp>

#include <map>
#include <string>
#include <string_view>
#include <vector>

namespace xi::data::datasets::zones::nodes::wire
{

struct Node
{
    std::vector<float>  at;
    float               radius;
    std::string         source;
    std::vector<uint32> links;
};

struct Document
{
    std::map<uint32, Node> nodes;

    using YamlRoot = yaml::DatasetRoot<&Document::nodes>;
};

} // namespace xi::data::datasets::zones::nodes::wire

template <>
struct glz::json_schema<xi::data::datasets::zones::nodes::wire::Node>
{
    glz::schema at{ .description = "Node center as x, y, z. Y is the ground under it." };
    glz::schema radius{ .description = "A mob walking at this node turns for the next one once it is this close to the center." };
    glz::schema source{
        .description = "Where the node came from. extracted: retail roam traces meet here. recorded: placed on ground retail mobs were seen walking. navmesh: placed on the LSB navmesh where nothing was recorded.",
        .enumeration = std::vector<std::string_view>{ "extracted", "recorded", "navmesh" },
    };
    glz::schema links{ .description = "Ids of the nodes a mob may walk to from here. Every link is listed on both of its nodes." };
};

template <>
struct glz::json_schema<xi::data::datasets::zones::nodes::wire::Document>
{
    glz::schema nodes{ .description = "Path nodes keyed by id, unique within the zone." };
};
