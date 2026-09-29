-----------------------------------
-- Node roaming in East Ronfaure.
--
-- Retail mobs walk between the zone's path nodes and turn for the next one as soon as they are inside its radius,
-- so every roam trip ends one radius short of the spot the mob aims at beside a node's center.
-- A mob roaming to random navmesh points lands on such a ring only by chance.
-----------------------------------

describe('East Ronfaure node roaming', function()
    -- Must match pathfind::aimOffset in node_route.cpp.
    local maxAimOffset         = 2.0
    local aimOffsetRadiusShare = 0.4
    local aimOffsetSteps       = 4
    local goldenAngle          = 2.39996323

    -- Stops land within the stop-short slack of the radius; a navmesh snap of the end point adds a little.
    local tolerance            = 0.5
    local tripsWanted          = 8

    local function loadNodes()
        local file = io.open('data/zones/east_ronfaure/nodes.yaml', 'r')
        assert(file, 'data/zones/east_ronfaure/nodes.yaml should exist')

        local nodes = {}
        for line in file:lines() do
            local x, y, z, radius = line:match('^%s*%d+:%s*{at: %[([%-%d%.]+), ([%-%d%.]+), ([%-%d%.]+)%], radius: ([%d%.]+)')
            if x then
                table.insert(nodes, { x = tonumber(x), y = tonumber(y), z = tonumber(z), radius = tonumber(radius) })
            end
        end

        file:close()
        return nodes
    end

    local function aimed(node, mobId)
        local step   = ((mobId % aimOffsetSteps) + 1) / aimOffsetSteps
        local length = math.min(maxAimOffset * step, aimOffsetRadiusShare * node.radius)
        local angle  = (mobId % 360) * goldenAngle

        return { x = node.x + length * math.cos(angle), y = node.y, z = node.z + length * math.sin(angle) }
    end

    local function distance(a, b)
        local dx, dy, dz = a.x - b.x, a.y - b.y, a.z - b.z
        return math.sqrt(dx * dx + dy * dy + dz * dz)
    end

    -- Whether `pos` sits on the ring one radius out from where this mob aims beside some node,
    -- or from the center when that spot is off the navmesh.
    local function onNodeRing(nodes, pos, mobId)
        for _, node in ipairs(nodes) do
            if math.abs(node.x - pos.x) < 12 and math.abs(node.z - pos.z) < 12 then
                for _, aim in ipairs({ aimed(node, mobId), node }) do
                    if math.abs(distance(pos, aim) - node.radius) <= tolerance then
                        return true
                    end
                end
            end
        end

        return false
    end

    ---@type CClientEntityPair
    local player = nil

    before_each(function()
        player = xi.test.world:spawnPlayer({ zone = xi.zone.EAST_RONFAURE })
    end)

    it('ends each roam trip one radius short of a node', function()
        local nodes = loadNodes()
        assert(#nodes > 1000, string.format('expected the East Ronfaure nodes, read %d', #nodes))

        local rabbits = player:getZone():queryEntitiesByName('Wild_Rabbit')
        assert(#rabbits > 0, 'no Wild Rabbit found in East Ronfaure')

        local mob = player.entities:get(rabbits[1]:getID())
        mob:respawn()

        local trips      = 0
        local onRing     = 0
        local wasWalking = false
        for _ = 1, 1500 do
            xi.test.world:skipTime(1)
            xi.test.world:tickEntity(mob)

            local walking = mob:isFollowingPath()
            if wasWalking and not walking then
                trips = trips + 1
                if onNodeRing(nodes, mob:getPos(), mob:getID()) then
                    onRing = onRing + 1
                end
            end

            wasWalking = walking
            if trips >= tripsWanted then
                break
            end
        end

        assert(trips >= tripsWanted, string.format('mob should have finished %d roam trips, finished %d', tripsWanted, trips))
        assert(onRing >= trips - 1, string.format('%d of %d roam trips ended on a node ring', onRing, trips))
    end)
end)
