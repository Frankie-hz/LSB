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

#include "data/datasets/zones/nodes/dataset.h"

#include "data/datasets/zones/nodes/yaml.h"
#include "data/yaml/read.h"

#include <fmt/format.h>

#include <algorithm>
#include <cmath>
#include <stdexcept>
#include <string_view>
#include <utility>

namespace xi::data::datasets::zones::nodes
{

namespace
{

auto convertSource(const uint32 id, const std::string_view source) -> PathNodeSource
{
    if (source == "extracted")
    {
        return PathNodeSource::Extracted;
    }

    if (source == "recorded")
    {
        return PathNodeSource::Recorded;
    }

    if (source == "navmesh")
    {
        return PathNodeSource::Navmesh;
    }

    throw std::runtime_error(fmt::format("node {} has unknown source '{}'", id, source));
}

auto convertNode(const uint32 id, const wire::Node& source) -> PathNodeData
{
    if (source.at.size() != 3)
    {
        throw std::runtime_error(fmt::format("node {} has {} values in at, not x, y, z", id, source.at.size()));
    }

    if (!std::isfinite(source.radius) || source.radius < 0.0f)
    {
        throw std::runtime_error(fmt::format("node {} has radius {}, not zero or more", id, source.radius));
    }

    return PathNodeData{
        .Id     = id,
        .At     = { source.at[0], source.at[1], source.at[2] },
        .Radius = source.radius,
        .Source = convertSource(id, source.source),
        .Links  = source.links,
    };
}

void checkLinks(const wire::Document& document)
{
    for (const auto& [id, node] : document.nodes)
    {
        for (auto it = node.links.begin(); it != node.links.end(); ++it)
        {
            const auto link = *it;
            if (link == id)
            {
                throw std::runtime_error(fmt::format("node {} links to itself", id));
            }

            if (std::find(node.links.begin(), it, link) != it)
            {
                throw std::runtime_error(fmt::format("node {} links to {} twice", id, link));
            }

            const auto other = document.nodes.find(link);
            if (other == document.nodes.end())
            {
                throw std::runtime_error(fmt::format("node {} links to {}, which does not exist", id, link));
            }

            if (std::ranges::find(other->second.links, id) == other->second.links.end())
            {
                throw std::runtime_error(fmt::format("node {} links to {}, but {} does not link back", id, link, link));
            }
        }
    }
}

} // namespace

auto Dataset::decode(const std::string_view text) -> Records
{
    const auto document = yaml::read<YamlDocument>(text);

    checkLinks(document);

    Records records;
    records.reserve(document.nodes.size());
    for (const auto& [id, source] : document.nodes)
    {
        records.push_back(convertNode(id, source));
    }

    return records;
}

} // namespace xi::data::datasets::zones::nodes
