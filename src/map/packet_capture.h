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

#include <fstream>
#include <string>
#include <string_view>

class CBasicPacket;

// Writes one .cap file per zone visit, each record is direction (1 byte), epoch ms (8), size (2), payload
class PacketCapture
{
public:
    void start(uint32 charId, std::string_view charName);
    void stop();
    auto isActive() const -> bool;

    void recordIncoming(CBasicPacket& packet);
    void recordOutgoing(CBasicPacket& packet);

private:
    void record(uint8 direction, CBasicPacket& packet);

    std::string   filename_;
    std::ofstream file_;
};
