/*
===========================================================================
  Copyright (c) 2021-2023 Eden Dev Teams
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

#include "spawn_slot.h"

#include "ai/ai_container.h"
#include "entities/mob_entity.h"
#include "spawn_handler.h"
#include "zone.h"

#include <algorithm>

namespace
{

auto isLotteryEntry(const SpawnSlotEntry& entry) -> bool
{
    return entry.spawnChance > 0 && (entry.mob->m_SpawnType & xi::SpawnType::Lottery) != xi::SpawnType::Normal;
}

} // namespace

void SpawnSlot::AddMob(CMobEntity* mob, const uint16 spawnChance, const timer::duration cooldown)
{
    entries.push_back({ .mob = mob, .spawnChance = spawnChance, .cooldown = cooldown });
    mob->SetSpawnSlot(this);
}

void SpawnSlot::RemoveMob(const CMobEntity* mob)
{
    std::erase_if(entries, [mob](const SpawnSlotEntry& entry)
                  {
                      return entry.mob == mob;
                  });
}

auto SpawnSlot::TrySpawn(const Maybe<uint32> specificMobId, const SlotRoll roll) -> bool
{
    // Get SpawnHandler from first mob's zone for condition checking
    SpawnHandler* spawnHandler = nullptr;
    if (!entries.empty() && entries[0].mob->loc.zone)
    {
        spawnHandler = &entries[0].mob->loc.zone->spawnHandler();
    }

    // Check if a specific mob should respawn (deaggro case)
    if (specificMobId.has_value())
    {
        auto it = std::ranges::find_if(entries, [id = *specificMobId](const auto& entry)
                                       {
                                           return entry.mob->id == id;
                                       });

        if (it == entries.end())
        {
            return false;
        }

        if (!it->mob->PAI->IsSpawned() && (!spawnHandler || spawnHandler->canSpawnNow(it->mob)))
        {
            it->mob->m_AllowRespawn = true;
            it->mob->Spawn();
            return true;
        }

        return false;
    }

    // Determine which of the mobs in the group can be spawned, and if there's one spawned already
    std::vector<std::tuple<uint32, CMobEntity*>> chanceSpawns;
    std::vector<CMobEntity*>                     remainingSpawns;

    CMobEntity* allowedSpawn = nullptr;

    uint32 totalChance = 0;

    const auto now = timer::now();

    for (auto&& entry : entries)
    {
        if (entry.mob->PAI->IsSpawned())
        {
            allowedSpawn = entry.mob;
            break;
        }

        // Use SpawnHandler to check spawn conditions (time, weather, etc.)
        if (spawnHandler && !spawnHandler->canSpawnNow(entry.mob))
        {
            continue;
        }

        // A lottery NM sits out the first roll after a restart and every roll during its cooldown.
        if (isLotteryEntry(entry) && (roll == SlotRoll::Boot || entry.readyAt > now))
        {
            continue;
        }

        if (entry.spawnChance > 0)
        {
            totalChance += entry.spawnChance;
            chanceSpawns.emplace_back(entry.spawnChance, entry.mob);
        }
        else
        {
            remainingSpawns.push_back(entry.mob);
        }
    }

    // Don't spawn if there's another mob in this slot already spawned.
    if (allowedSpawn)
    {
        return false;
    }

    // If there are no spawnable mobs at all, bail out
    if (chanceSpawns.empty() && remainingSpawns.empty())
    {
        return false;
    }

    // Check for chance spawns
    if (totalChance > 0)
    {
        // With nothing unweighted to fall back on, or weights past the whole roll, the eligible weights share it in proportion.
        const auto rollRange = [&]() -> uint32
        {
            if (remainingSpawns.empty())
            {
                return totalChance;
            }

            return std::max<uint32>(totalChance, 1000);
        }();

        const uint32 rolled = xirand::GetRandomNumber(rollRange);

        // Check if roll is low enough number to make one of the chance mobs to spawn.
        if (rolled < totalChance)
        {
            // Find the chance spawn which matches the roll
            uint32 accumulatedRoll = 0;

            for (auto&& entry : chanceSpawns)
            {
                const auto mob = std::get<1>(entry);
                accumulatedRoll += std::get<0>(entry);
                if (rolled < accumulatedRoll)
                {
                    allowedSpawn = mob;
                    break;
                }
            }
        }
    }

    if (!allowedSpawn)
    {
        if (!remainingSpawns.empty())
        {
            // Pick a random mob from the non-chance spawns
            allowedSpawn = xirand::GetRandomElement(remainingSpawns);
        }
        else
        {
            return false;
        }
    }

    // Finally spawn the mob
    for (auto&& entry : entries)
    {
        if (entry.mob == allowedSpawn)
        {
            entry.mob->m_AllowRespawn = true;
            entry.mob->Spawn();
            break;
        }
    }

    return allowedSpawn != nullptr;
}

auto SpawnSlot::IsEmpty() const -> bool
{
    return entries.empty();
}

auto SpawnSlot::GetEntries() const -> const std::vector<SpawnSlotEntry>&
{
    return entries;
}

auto SpawnSlot::IsLotteryMember(const CMobEntity* mob) const -> bool
{
    return std::ranges::any_of(entries, [mob](const SpawnSlotEntry& entry)
                               {
                                   return entry.mob == mob && isLotteryEntry(entry);
                               });
}

// Every copy of the NM in this slot shares the wait, so a second spawn point cant bring it straight back.
void SpawnSlot::StartCooldown(const CMobEntity* mob)
{
    const auto despawned = std::ranges::find(entries, mob, &SpawnSlotEntry::mob);
    if (despawned == entries.end())
    {
        return;
    }

    const auto readyAt = timer::now() + despawned->cooldown;
    for (auto& entry : entries)
    {
        if (isLotteryEntry(entry) && entry.mob->getName() == mob->getName())
        {
            entry.readyAt = readyAt;
        }
    }
}

auto SpawnSlot::PlaceholderRespawnTime() const -> Maybe<timer::duration>
{
    const auto placeholder = std::ranges::find_if(entries, [](const SpawnSlotEntry& entry)
                                                  {
                                                      return !isLotteryEntry(entry);
                                                  });

    if (placeholder == entries.end())
    {
        return std::nullopt;
    }

    return placeholder->mob->m_RespawnTime;
}
