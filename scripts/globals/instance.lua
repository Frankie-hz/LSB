-----------------------------------
-- Instance
-----------------------------------
-- TOAU storyline missions
-- Salvage
-- WOTG storyline missions
-- Certain Campaign Ops
-- Moblin Maze Mongers
-- The Notorious Monster battles that occur when Sandworm sucks in players using Doomvoid
--
-- Instance zones:
-- - ILRUSI_ATOLL                    = 55,
-- - PERIQIA                         = 56,
-- - THE_ASHU_TALIF                  = 60,
-- - LEBROS_CAVERN                   = 63,
-- - MAMOOL_JA_TRAINING_GROUNDS      = 66,
-- - LEUJAOAM_SANCTUM                = 69,
-- - ZHAYOLM_REMNANTS                = 73,
-- - ARRAPAGO_REMNANTS               = 74,
-- - BHAFLAU_REMNANTS                = 75,
-- - SILVER_SEA_REMNANTS             = 76,
-- - NYZUL_ISLE                      = 77,
-- - EVERBLOOM_HOLLOW                = 86,
-- - RUHOTZ_SILVERMINES              = 93,
-- - GHOYUS_REVERIE                  = 129,
-- - MAQUETTE_ABDHALJS_LEGION_A      = 183,
-- - RALA_WATERWAYS_U                = 259,
-- - YORCIA_WEALD_U                  = 264,
-- - CIRDAS_CAVERNS_U                = 271,
-- - OUTER_RAKAZNAR_U1               = 275,
-- - MAQUETTE_ABDHALJS_LEGION_B      = 287, -- See: ambuscade.lua
-- - DYNAMIS_SAN_DORIA_D             = 294,
-- - DYNAMIS_BASTOK_D                = 295,
-- - DYNAMIS_WINDURST_D              = 296,
-- - DYNAMIS_JEUNO_D                 = 297,
-----------------------------------
xi = xi or {}
xi.instance = {}

-----------------------------------
-- Entrance protocols
-----------------------------------
-- Every entrance event ends with the client asking the server to register the party, but the
-- client waits for the answer in one of three ways:
--
-- REGISTRATION: the client sends one event update with the choices it made and blocks until a
--   0x0BF registration packet arrives. Result 4 plays the transport animation and finishes the
--   event with option 4, any other result ends the event with that value and no message.
--   ToAU staging points, Salvage gates, the WOTG doors, Moblin Maze Mongers.
--
-- POLL_NYZUL: the client polls through event updates and reads the answer from the eighth
--   event parameter. Bits 22-25 of the option carry its state: 0 is the initial request,
--   1 means it is waiting for the instance. The update reply must echo the start parameters
--   and only set the eighth one. Nyzul Isle.
--
-- POLL_SOA: same loop with the state in bits 12-15 and different codes. Rala Waterways [U].
xi.instance.protocol =
{
    REGISTRATION = 1,
    POLL_NYZUL   = 2,
    POLL_SOA     = 3,
}

-- 0x0BF results. Only ACCEPTED is the client's contract, anything else ends the event silently.
xi.instance.registration =
{
    DENIED      = 1,
    LOAD_FAILED = 3,
    ACCEPTED    = 4,
}

-- Eighth event parameter of the update reply, by protocol
xi.instance.pollCode =
{
    [xi.instance.protocol.POLL_NYZUL] =
    {
        REGISTERED = 1,  -- request accepted, the client moves on to waiting
        BUSY       = 2,  -- "You cannot enter at this time", retried up to 5 times
        CANCEL     = 3,  -- silent cancel (3 to 10, 12 and 13 all cancel)
        READY      = 11, -- transport animation, event finishes with option 4
        RETRY      = 14, -- "You cannot enter at this time", retried up to 15 times
    },

    [xi.instance.protocol.POLL_SOA] =
    {
        REGISTERED = 1,
        BUSY       = 2,
        CANCEL     = 3,  -- 3 to 7, 9 and 10 all cancel
        READY      = 8,  -- transport animation, event finishes with option 8
        RETRY      = 11,
    },
}

local pollState =
{
    REQUEST = 0,
    WAITING = 1,
}

-- Bit of the update option the polling protocols keep their state in
local pollStateShift =
{
    [xi.instance.protocol.POLL_NYZUL] = 22,
    [xi.instance.protocol.POLL_SOA]   = 12,
}

xi.instance.vars =
{
    INSTANCE_ID = 'INSTANCE_ID',
    READY       = 'INSTANCE_READY',
    POLLING     = 'INSTANCE_POLLING',
}

-----------------------------------
-- Entrances
-----------------------------------
--[[
    [instance zone id] =
    {
        {
            instanceId  = instance_list id,
            entryEvent  = { csid, p0, ... } for the registrant, unpacked into player:startEvent
            confirm     = { csid, option } the client finishes the entry event with on success
            memberEvent = { csid, p0, ... } for party members joining
            protocol    = xi.instance.protocol, REGISTRATION when omitted
            menuIndex   = objective the client must have picked (bits 18-21 of the update), unchecked when omitted
        },
    },

    The ToAU events pick the zone name shown by the client from p4:
    Leujaoam 0, Mamool Ja 1, Lebros 2, Periqia 3, Ilrusi 4, Nyzul 5, Ashu Talif 6,
    Zhayolm 7, Arrapago 8, Bhaflau 9, Silver Sea 10.
--]]

xi.instance.lookup =
{
    [xi.zone.ILRUSI_ATOLL] =
    {
        -- Assault: Golden Salvage
        -- Assault: Lamia No.13
        -- Assault: Extermination
        -- Assault: Demolition Duty
        -- Assault: Searat Salvation
        -- Assault: Apkallu Seizure
        -- Assault: Lost and Found
        -- Assault: Deserter
        -- Assault: Desperately Seeking Cephalopods
        -- Assault: Bellerophon's Bliss
    },

    [xi.zone.PERIQIA] =
    {
        -- Shades of Vengeance (TOAU31)
        {
            instanceId  = 5600,
            entryEvent  = { 143, 79, -6, 0, 99, 3, 0 },
            confirm     = { 143, 4 },
            memberEvent = { 147, 3 },
            menuIndex   = 2,
        },
        -- Assault: Seagull Grounded (scripts/assaults/Periqia/seagull_grounded.lua)
        -- Assault: Requiem (scripts/assaults/Periqia/requiem.lua)
        -- Assault: Saving Private Ryaaf
        -- Assault: Shooting Down the Baron
        -- Assault: Stop the Bloodshed
        -- Assault: Defuse the Threat
        -- Assault: Operation: Snake Eyes
        -- Assault: Wake the Puppet
        -- Assault: The Price is Right
    },

    [xi.zone.THE_ASHU_TALIF] =
    {
        -- The Black Coffin (TOAU 15)
        {
            instanceId  = 6000,
            entryEvent  = { 221, 53, -6, 0, 99, 6, 0 },
            confirm     = { 221, 4 },
            memberEvent = { 222, 6 },
            menuIndex   = 2,
        },
        -- Against All Odds
        {
            instanceId  = 6001,
            entryEvent  = { 221, 54, -9, 0, 99, 6, 0 },
            confirm     = { 221, 4 },
            memberEvent = { 222, 6 },
            menuIndex   = 3,
        },
        -- Testing the Waters (TOAU 34)
        -- Legacy of the Lost (TOAU 35)
        -- Assault: Royal Painter Escort
        -- Assault: Scouting the Ashu Talif
        -- Assault: Targeting the Captain
    },

    [xi.zone.LEBROS_CAVERN] =
    {
        -- Assault: Excavation Duty
        {
            instanceId  = 6300,
            entryEvent  = { 203, 21, -4, 0, 50, 0, 1 },
            confirm     = { 203, 4 },
            memberEvent = { 208, 0 },
            menuIndex   = 1,
        },
        -- Assault: Lebros Supplies
        -- Assault: Troll Fugitives
        -- Assault: Evade and Escape
        -- Assault: Siegemaster Assassination
        -- Assault: Apkallu Breeding
        -- Assault: Wamoura Farm Raid
        -- Assault: Egg Conservation
        -- Assault: Operation: Black Pearl
        -- Assault: Better Than One
    },

    [xi.zone.MAMOOL_JA_TRAINING_GROUNDS] =
    {
        -- Assault: Imperial Agent Rescue
        {
            instanceId  = 6600,
            entryEvent  = { 505, 11, -4, 0, 60, 0, 1 },
            confirm     = { 505, 4 },
            memberEvent = { 511, 0 },
            menuIndex   = 1,
        },
        -- Assault: Preemptive Strike
        -- Assault: Sagelord Elimination
        -- Assault: Breaking Morale
        -- Assault: The Double Agent
        -- Assault: Imperial Treasure Retrieval
        -- Assault: Blitzkrieg
        -- Assault: Marids in the Mist
        -- Assault: Azure Ailments
        -- Assault: The Susanoo Shuffle
    },

    [xi.zone.LEUJAOAM_SANCTUM] =
    {
        -- Assault: Leujaoam Cleansing
        {
            instanceId  = 6900,
            entryEvent  = { 140, 1, -4, 0, 50, 0, 1 },
            confirm     = { 140, 4 },
            memberEvent = { 147, 0 },
            menuIndex   = 1,
        },
        -- Assault: Orichalcum Survey
        -- Assault: Escort Professor Chanoix
        -- Assault: Shanarha Grass Conservation
        -- Assault: Counting Sheep
        -- Assault: Supplies Recovery
        -- Assault: Azure Experiments
        -- Assault: Imperial Code
        -- Assault: Red Versus Blue
        -- Assault: Bloody Rondo
    },

    [xi.zone.ZHAYOLM_REMNANTS] =
    {
        -- Salvage I, Zhayolm Remnants
        {
            instanceId  = 7300,
            entryEvent  = { 407, 0, -6, 0, 0, 7 },
            confirm     = { 407, 4 },
            memberEvent = { 411, 7 },
            menuIndex   = 2,
        },
    },

    [xi.zone.ARRAPAGO_REMNANTS] =
    {
        -- Salvage I, Arrapago Remnants
        {
            instanceId  = 7400,
            entryEvent  = { 408, 0, -6, 0, 0, 8 },
            confirm     = { 408, 4 },
            memberEvent = { 411, 8 },
            menuIndex   = 2,
        },
    },

    [xi.zone.BHAFLAU_REMNANTS] =
    {
        -- Salvage I, Bhaflau Remnants
        {
            instanceId  = 7500,
            entryEvent  = { 409, 0, -6, 0, 0, 9 },
            confirm     = { 409, 4 },
            memberEvent = { 411, 9 },
            menuIndex   = 2,
        },
    },

    [xi.zone.SILVER_SEA_REMNANTS] =
    {
        -- Salvage I, Silver Sea Remnants
        {
            instanceId  = 7600,
            entryEvent  = { 410, 0, -6, 0, 0, 10 },
            confirm     = { 410, 4 },
            memberEvent = { 411, 10 },
            menuIndex   = 2,
        },
    },

    [xi.zone.NYZUL_ISLE] =
    {
        -- Path of Darkness
        {
            instanceId  = 7700,
            entryEvent  = { 405, 58, -6, 0, 99, 5, 0 },
            confirm     = { 405, 4 },
            memberEvent = { 411, 5 },
            protocol    = xi.instance.protocol.POLL_NYZUL,
            menuIndex   = 2,
        },
        -- Nashmeira's Plea
        {
            instanceId  = 7701,
            entryEvent  = { 405, 59, -10, 0, 99, 5, 0 },
            confirm     = { 405, 4 },
            memberEvent = { 411, 5 },
            protocol    = xi.instance.protocol.POLL_NYZUL,
            menuIndex   = 3,
        },
        -- Waking the Colossus/Divine Interference, p6 picks the objective name
        {
            instanceId  = 7702,
            entryEvent  = { 405, 60, -34, 0, 99, 5, 1, 0, 14 },
            confirm     = { 405, 4 },
            memberEvent = { 411, 5 },
            protocol    = xi.instance.protocol.POLL_NYZUL,
            menuIndex   = 5,
            entryParams = function(player, entryEvent)
                if player:getQuestStatus(xi.questLog.AHT_URHGAN, xi.quest.id.ahtUrhgan.DIVINE_INTERFERENCE) >= xi.questStatus.QUEST_ACCEPTED then
                    entryEvent[8] = 1
                end
            end,
        },
        -- Forging a New Myth
        -- Nyzul Isle Investigation
        {
            instanceId  = 7704,
            entryEvent  = { 405, 51, -4, 0, 75, 5, 1 },
            confirm     = { 405, 4 },
            memberEvent = { 411, 5 },
            protocol    = xi.instance.protocol.POLL_NYZUL,
            menuIndex   = 1,
        },
    },

    [xi.zone.EVERBLOOM_HOLLOW] =
    {
        -- Honor Under Fire
        -- Bonds That Never Die
        -- A Nation on the Brink
        -- Dungeons and Dancers
        -- Campaign Ops:
        -- Brave Dawn I (San d'Oria)
        -- Brave Dawn II (San d'Oria)
        -- Brave Dawn III (San d'Oria)
        -- Granite Rose I (San d'Oria)
        -- Granite Rose II (San d'Oria)
        -- Granite Rose III (San d'Oria)
        -- Pit Spider I (San d'Oria)
        -- Pit Spider II (San d'Oria)
        -- Pit Spider III (San d'Oria)
        -- Doomvoid - King Arthro
        -- Doomvoid - Lambton Worm
        -- Moblin Maze Mongers
    },

    [xi.zone.RUHOTZ_SILVERMINES] =
    {
        -- The WOTG doors take the objective id in the update (512 + quest id) and pick the
        -- zone name from it client-side.
        -- Light in the Darkness (WOTG Bastok Quest 3)
        {
            instanceId  = 9300,
            entryEvent  = { 3, 0, 0, 19 },
            confirm     = { 3, 4 },
            memberEvent = { 4, 1 },
        },
        -- Fire in the Hole (WOTG Bastok Quest 6)
        {
            instanceId  = 9301,
            entryEvent  = { 203, 0, 0, 36 },
            confirm     = { 203, 4 },
            memberEvent = { 201, 1 },
        },
        -- { 0, { 0,  0, 34 } }, -- Seeing Blood-red (SCH AF3)
        -- { 0, { 0, 23,  0 } }, -- Distorter of Time
        -- Campaign Ops:
        -- Brave Dawn I (Bastok)
        -- Brave Dawn II (Bastok)
        -- Brave Dawn III (Bastok)
        -- By Light of Fire I (Bastok)
        -- Granite Rose I (Bastok)
        -- Granite Rose II (Bastok)
        -- Granite Rose III (Bastok)
        -- Pit Spider I (Bastok)
        -- Pit Spider II (Bastok)
        -- Doomvoid - Lambton Worm
        -- Doomvoid - Guivre
        -- Moblin Maze Mongers
    },

    [xi.zone.GHOYUS_REVERIE] =
    {
        -- A Feast for Gnats
        -- A Manifest Problem
        -- In a Haze of Glory
        -- Sins of the Mothers
        -- Campaign Ops:
        -- Brave Dawn I (Windurst)
        -- Brave Dawn II (Windurst)
        -- Brave Dawn III (Windurst)
        -- Granite Rose I (Windurst)
        -- Granite Rose II (Windurst)
        -- Pit Spider I (Windurst)
        -- Pit Spider II (Windurst)
        -- Doomvoid - Lambton Worm
        -- Doomvoid - Serket
    },

    [xi.zone.MAQUETTE_ABDHALJS_LEGION_A] =
    {
        -- Hall of An (Leader entry: { 8009, 0, 0, 0, 0, 6, 1 }, Party entry: { 8003, 0, 0, 0, 0, 6, 1 })
        -- Hall of Ki
        -- Hall of Im
        -- Hall of Muru
        -- Hall of Mul
    },

    [xi.zone.RALA_WATERWAYS_U] =
    {
        -- {  0, 0 }, -- Endeavoring to Awaken
        -- {  1, 0 }, -- Endeavoring to Awaken
        -- -- Blank
        -- Behind the Sluices
        {
            instanceId  = 25900,
            entryEvent  = { 5511, 258, 8 },
            confirm     = { 5511, 8 },
            memberEvent = { 258, 8 },
            protocol    = xi.instance.protocol.POLL_SOA,
        },
        -- {  4, 0 }, -- Stonewalled
        -- {  5, 0 }, -- The Gates
        -- {  6, 0 }, -- Saved by the Bell
        -- {  7, 0 }, -- Quiescence
        -- {  8, 0 }, -- The Charlatan
        -- {  9, 0 }, -- Yggdrasil Beckons
        -- { 10, 0 }, -- Yggdrasil Beckons
        -- { 11, 0 }, -- Watery Grave
        -- { 12, 0 }, -- Mistress of Ceremonies
        -- { 13, 0 }, -- A Barrel of Laughs
        -- { 14, 0 }, -- Sinister Reign
        -- { 15, 0 }, -- The Ygnas Directive 6
        -- { 16, 0 }, -- Skirmishes
        -- { 17, 0 }, -- Fractures
        -- { 18, 0 }, -- Alluvion skirmishes
        -- { 19, 0 }, -- The Silent Forest
        -- { 20, 0 }, -- Wind of Eternity
    },

    [xi.zone.YORCIA_WEALD_U] =
    {

    },

    [xi.zone.CIRDAS_CAVERNS_U] =
    {

    },

    [xi.zone.OUTER_RAKAZNAR_U1] =
    {

    },

    [xi.zone.DYNAMIS_SAN_DORIA_D] =
    {

    },

    [xi.zone.DYNAMIS_BASTOK_D] =
    {

    },

    [xi.zone.DYNAMIS_WINDURST_D] =
    {

    },

    [xi.zone.DYNAMIS_JEUNO_D] =
    {

    },
}

-- Entrances by instance id, filled from the lookup table and by the assault containers
xi.instance.entries = {}

xi.instance.registerEntry = function(entry)
    entry.protocol = entry.protocol or xi.instance.protocol.REGISTRATION

    xi.instance.entries[entry.instanceId] = entry

    return entry
end

for _, zoneEntries in pairs(xi.instance.lookup) do
    for _, entry in ipairs(zoneEntries) do
        xi.instance.registerEntry(entry)
    end
end

-----------------------------------
-- Requirements
-----------------------------------

-- Party leader registering
local checkRegistryReqs = function(player, instanceId)
    local instanceObj = GetCachedInstanceScript(instanceId)
    if type(instanceObj.registryRequirements) == 'function' then
        return instanceObj.registryRequirements(player)
    else
        print('xi.instance: checkReqs: registryRequirements function not set for instance: ' .. instanceId)
        return false
    end
end

-- Further players joining
local checkEntryReqs = function(player, instanceId)
    local instanceObj = GetCachedInstanceScript(instanceId)
    if type(instanceObj.entryRequirements) == 'function' then
        return instanceObj.entryRequirements(player)
    else
        print('xi.instance: checkReqs: entryRequirements function not set for instance: ' .. instanceId)
        return false
    end
end

-----------------------------------
-- Replies to the client
-----------------------------------

-- Update reply for the polling protocols: the start parameters again, with the code in the eighth slot
local replyPoll = function(player, entry, code)
    local params = { unpack(entry.entryEvent, 2, 8) }
    for i = 1, 7 do
        params[i] = params[i] or 0
    end

    params[8] = code

    player:updateEvent(unpack(params))
end

local deny = function(player, npc, entry)
    if entry.protocol == xi.instance.protocol.REGISTRATION then
        player:instanceEntry(npc, xi.instance.registration.DENIED)
    else
        replyPoll(player, entry, xi.instance.pollCode[entry.protocol].CANCEL)
    end
end

local accept = function(player, npc, entry)
    if entry.protocol == xi.instance.protocol.REGISTRATION then
        player:instanceEntry(npc, xi.instance.registration.ACCEPTED)
    else
        replyPoll(player, entry, xi.instance.pollCode[entry.protocol].READY)
    end
end

local clearEntryVars = function(player)
    player:setLocalVar(xi.instance.vars.INSTANCE_ID, 0)
    player:setLocalVar(xi.instance.vars.READY, 0)
    player:setLocalVar(xi.instance.vars.POLLING, 0)
end

-- Moves the party members standing with the player into the instance zone
local enterParty = function(player, instance)
    local playerZoneId = player:getZoneID()

    for _, member in ipairs(player:getParty()) do
        if member:getZoneID() == playerZoneId then
            member:setPos(0, 0, 0, 0, instance:getZone():getID())
        end
    end
end

-----------------------------------
-- Entry flow
-----------------------------------

-- Clear up after possible failed loads
xi.instance.clearInstance = function(player)
    clearEntryVars(player)

    local existingInstance = player:getInstance()
    if existingInstance then
        existingInstance:fail()
    end
end

xi.instance.onTrade = function(player, npc, trade)
end

xi.instance.onTrigger = function(player, npc, instanceZoneID)
    local zoneLookup = xi.instance.lookup[instanceZoneID]

    xi.instance.clearInstance(player)

    -- Find the first instance you're valid for
    -- TODO: Handle being valid for multiple instances from the same entrance
    local chosenEntry
    for _, entry in ipairs(zoneLookup) do
        if checkRegistryReqs(player, entry.instanceId) then
            chosenEntry = entry
            break
        end
    end

    if not chosenEntry then
        return false
    end

    player:setLocalVar(xi.instance.vars.INSTANCE_ID, chosenEntry.instanceId)

    local entryEvent = { unpack(chosenEntry.entryEvent) }
    if chosenEntry.entryParams then
        chosenEntry.entryParams(player, entryEvent)
    end

    player:startEvent(unpack(entryEvent))

    return true
end

-- Everyone who will be pulled in has to qualify and stand nearby
local checkParty = function(player, npc, entry)
    local playerId     = player:getID()
    local playerZoneId = player:getZoneID()
    local ID           = zones[playerZoneId]

    for _, member in ipairs(player:getParty()) do
        if
            member:getID() ~= playerId and
            member:getZoneID() == playerZoneId
        then
            if not checkEntryReqs(member, entry.instanceId) then
                player:messageText(npc, ID.text.MEMBER_NO_REQS, false)
                return false
            end

            if member:checkDistance(player) > 50 then
                player:messageText(npc, ID.text.MEMBER_TOO_FAR, false)
                return false
            end
        end
    end

    return true
end

-- Registration request from the entrance event. Returns true when the request was taken.
xi.instance.onEventUpdate = function(player, csid, option, npc)
    local entry = xi.instance.entries[player:getLocalVar(xi.instance.vars.INSTANCE_ID)]
    if not entry or csid ~= entry.entryEvent[1] then
        return false
    end

    if entry.protocol ~= xi.instance.protocol.REGISTRATION then
        local state = bit.band(bit.rshift(option, pollStateShift[entry.protocol]), 0xF)

        if state == pollState.WAITING then
            -- The client blocks on this update until the instance is ready
            if player:getLocalVar(xi.instance.vars.READY) == 1 then
                accept(player, npc, entry)
            else
                player:setLocalVar(xi.instance.vars.POLLING, 1)
            end

            return true
        elseif state ~= pollState.REQUEST then
            deny(player, npc, entry)
            return false
        end
    end

    -- The menu choice sits in bits 18-21 of the update
    if entry.menuIndex and bit.band(bit.rshift(option, 18), 0xF) ~= entry.menuIndex then
        deny(player, npc, entry)
        return false
    end

    if not checkParty(player, npc, entry) then
        deny(player, npc, entry)
        return false
    end

    player:setLocalVar(xi.instance.vars.READY, 0)
    player:setLocalVar(xi.instance.vars.POLLING, 0)
    player:createInstance(entry.instanceId)

    if entry.protocol ~= xi.instance.protocol.REGISTRATION then
        replyPoll(player, entry, xi.instance.pollCode[entry.protocol].REGISTERED)
    end

    return true
end

-- 'Default' behavior. It's up to each instance whether or not they want to use this logic
-- Can pass instance entrance information directly if accessible from container, otherwise
-- will try and find it from the instance id
xi.instance.onInstanceCreatedCallback = function(player, instance, entryInfo)
    local npc = player:getEventTarget()

    -- The instance failed to load: release the requester from the entrance event
    if not instance then
        local entry = entryInfo or xi.instance.entries[player:getLocalVar(xi.instance.vars.INSTANCE_ID)]

        if entry and npc then
            if entry.protocol == xi.instance.protocol.REGISTRATION then
                player:instanceEntry(npc, xi.instance.registration.LOAD_FAILED)
            else
                replyPoll(player, entry, xi.instance.pollCode[entry.protocol].CANCEL)
            end
        end

        clearEntryVars(player)

        return
    end

    local entry        = entryInfo or xi.instance.entries[instance:getID()]
    local playerId     = player:getID()
    local playerZoneId = player:getZoneID()

    -- If you're in the official entrance zone, try and playout the
    -- entrance animation. Otherwise: go straight to the instance
    if playerZoneId == instance:getEntranceZoneID() and entry then
        -- join initiating player as commander
        player:setInstance(instance)

        for _, member in ipairs(player:getParty()) do
            if
                member:getID() ~= playerId and
                member:getZoneID() == playerZoneId
            then
                member:release()
                member:startEvent(unpack(entry.memberEvent))
                member:setInstance(instance)
            end
        end

        -- Failsafe: a lost event packet would leave the party in the entrance zone
        -- with an instance waiting. A clean entry zones everyone well before this.
        player:timer(35000, function(playerArg)
            local pending = playerArg:getInstance()
            if pending and playerArg:getZoneID() == pending:getEntranceZoneID() then
                enterParty(playerArg, pending)
            end
        end)

        -- The registrant is released once the client's entry event reports back
        if not npc then
            return
        end

        if entry.protocol == xi.instance.protocol.REGISTRATION then
            accept(player, npc, entry)
        else
            player:setLocalVar(xi.instance.vars.READY, 1)

            if player:getLocalVar(xi.instance.vars.POLLING) == 1 then
                accept(player, npc, entry)
            end
        end
    else
        for _, member in ipairs(player:getParty()) do
            member:setInstance(instance)
            member:setPos(0, 0, 0, 0, instance:getZone():getID())
        end
    end
end

-- The client finishes the entry event with the confirm option once the transport animation
-- played. Can pass the confirm pair directly if accessible from a container.
xi.instance.onEventFinish = function(player, csid, option, npc, confirm)
    local instance = player:getInstance()
    if not instance then
        return false
    end

    if not confirm then
        local entry = xi.instance.entries[instance:getID()]
        if not entry then
            return false
        end

        confirm = entry.confirm
    end

    if csid ~= confirm[1] or option ~= confirm[2] then
        return false
    end

    clearEntryVars(player)
    enterParty(player, instance)

    return true
end

-----------------------------------
-- Instance time
-----------------------------------

local function setInstanceLastTimeUpdateMessage(instance, players, remainingTimeLimit, text)
    local message        = 0
    local lastTimeUpdate = instance:getLastTimeUpdate()

    if lastTimeUpdate == 0 and remainingTimeLimit < 600 then
        message = 600
    elseif lastTimeUpdate == 600 and remainingTimeLimit < 300 then
        message = 300
    elseif lastTimeUpdate == 300 and remainingTimeLimit < 60 then
        message = 60
    elseif lastTimeUpdate == 60 and remainingTimeLimit < 30 then
        message = 30
    elseif lastTimeUpdate == 30 and remainingTimeLimit < 10 then
        message = 10
    end

    if message ~= 0 then
        for i, player in pairs(players) do
            if remainingTimeLimit >= 60 then
                player:messageSpecial(text.TIME_REMAINING_MINUTES, message / 60)
            else
                player:messageSpecial(text.TIME_REMAINING_SECONDS, message)
            end
        end

        instance:setLastTimeUpdate(message)
    end
end

xi.instance.updateInstanceTime = function(instance, elapsed, text)
    local players            = instance:getChars()
    local remainingTimeLimit = instance:getTimeLimit() - elapsed
    local wipeTime           = instance:getWipeTime()

    if
        remainingTimeLimit < 0 or
        (wipeTime ~= 0 and elapsed - wipeTime > 180
        )
    then
        instance:fail()

        return
    end

    if wipeTime == 0 then
        local wipe = true

        for i, player in pairs(players) do
            if player:getHP() ~= 0 then
                wipe = false
                break
            end
        end

        if wipe then
            for i, player in pairs(players) do
                player:messageSpecial(text.PARTY_FALLEN, 3)
            end

            instance:setWipeTime(elapsed)
        end
    else
        for i, player in pairs(players) do
            if player:getHP() ~= 0 then
                instance:setWipeTime(0)
                break
            end
        end
    end

    setInstanceLastTimeUpdateMessage(instance, players, remainingTimeLimit, text)
end
