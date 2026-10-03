/*
===========================================================================
  Copyright (c) 2021 Eden Dev Teams
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
#include <common/timer.h>
#include <common/types/maybe.h>

#include <vector>

class CMobEntity;

struct SpawnSlotEntry
{
    CMobEntity* mob;

    // Chance out of 1000 of this mob spawning out of the mobs sharing the slot.
    // If not all mobs in the slot have a chance defined, then the ones without it
    // will be rolled between equally, if none of the ones with a specified chance succeeds.
    uint16 spawnChance{ 0 };

    // A lottery NM sits out the roll for this long after it despawns.
    timer::duration cooldown{};

    timer::time_point readyAt{};
};

enum class SlotRoll : uint8
{
    Boot,
    Respawn,
};

class SpawnSlot
{
public:
    void AddMob(CMobEntity* mob, uint16 spawnChance, timer::duration cooldown);
    void RemoveMob(const CMobEntity* mob);
    auto TrySpawn(Maybe<uint32> specificMobId, SlotRoll roll) -> bool;
    auto IsEmpty() const -> bool;
    auto GetEntries() const -> const std::vector<SpawnSlotEntry>&;

    // A lottery NM with a chance in this slot, rolled here instead of by its scripts.
    auto IsLotteryMember(const CMobEntity* mob) const -> bool;
    void StartCooldown(const CMobEntity* mob);
    auto PlaceholderRespawnTime() const -> Maybe<timer::duration>;

    // Test hooks for xi_test only.
    void SetChance(const CMobEntity* mob, uint16 spawnChance);
    void SetCooldown(const CMobEntity* mob, timer::duration cooldown); // also ends any wait in progress

private:
    std::vector<SpawnSlotEntry> entries;
};
