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

#include "packet_capture.h"

#include "common/earth_time.h"
#include "common/logging.h"
#include "common/settings.h"
#include "packets/basic.h"

#include <chrono>
#include <filesystem>
#include <fmt/chrono.h>

void PacketCapture::start(const uint32 charId, const std::string_view charName)
{
    const auto captureDir = settings::get<std::string>("logging.PACKET_CAPTURE_DIR");

    std::error_code ec;
    std::filesystem::create_directories(captureDir, ec);
    if (ec)
    {
        ShowErrorFmt("PacketCapture: Failed to create directory {}: {}", captureDir, ec.message());
        return;
    }

    filename_ = fmt::format("{}/{}_{:%Y%m%d_%H%M%S}.cap", captureDir, charId, earth_time::to_utc_tm());
    file_     = std::ofstream(filename_, std::ios::binary);

    if (!file_.is_open())
    {
        ShowWarningFmt("PacketCapture: Failed to open {} for {} ({})", filename_, charName, charId);
        return;
    }

    ShowInfoFmt("PacketCapture: Capturing {} ({}) -> {}", charName, charId, filename_);
}

void PacketCapture::stop()
{
    file_.close();
    ShowInfoFmt("PacketCapture: Stopped capture -> {}", filename_);
}

auto PacketCapture::isActive() const -> bool
{
    return file_.is_open();
}

void PacketCapture::recordIncoming(CBasicPacket& packet)
{
    record(0x00, packet);
}

void PacketCapture::recordOutgoing(CBasicPacket& packet)
{
    record(0x01, packet);
}

void PacketCapture::record(const uint8 direction, CBasicPacket& packet)
{
    const auto timestamp = static_cast<uint64>(std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count());
    const auto size      = static_cast<uint16>(packet.getSize());

    file_.write(reinterpret_cast<const char*>(&direction), sizeof(direction));
    file_.write(reinterpret_cast<const char*>(&timestamp), sizeof(timestamp));
    file_.write(reinterpret_cast<const char*>(&size), sizeof(size));
    file_.write(reinterpret_cast<const char*>(static_cast<uint8*>(packet)), size);
}
