-----------------------------------
-- Path nodes in East Ronfaure.
--
-- Retail mobs walk between the zone's path nodes and turn for the next one as soon as they are inside its radius,
-- so every roam trip ends one radius short of the spot the mob aims at beside a node's center.
-- A mob roaming to random navmesh points lands on such a ring only by chance.
-- A chasing mob that runs into a node's radius veers to its center before carrying on after its target.
-----------------------------------

describe('East Ronfaure node roaming', function()
    -- Must match pathfind::aimOffset in node_route.cpp.
    local maxAimOffset         = 2.0
    local aimOffsetRadiusShare = 0.4
    local aimOffsetSteps       = 4
    local goldenAngle          = 2.39996323

    -- Stops land within the stop-short slack of the radius; a navmesh snap of the end point adds a little.
    local tolerance            = 0.5
    -- A region mob that stands where no node can be reached without leaving its region roams the navmesh for that trip,
    -- so a trip can miss. Seeded, node roaming lands 16 of 16 and navmesh roaming 7.
    local tripsWanted          = 16
    local ringsWanted          = 12

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

    local function flatDistanceToSegment(point, from, to)
        local lengthX = to.x - from.x
        local lengthZ = to.z - from.z
        local lengthSquared = lengthX * lengthX + lengthZ * lengthZ
        local along = 0
        if lengthSquared > 0 then
            along = math.max(0, math.min(1, ((point.x - from.x) * lengthX + (point.z - from.z) * lengthZ) / lengthSquared))
        end

        local dx = point.x - (from.x + lengthX * along)
        local dz = point.z - (from.z + lengthZ * along)
        return math.sqrt(dx * dx + dz * dz)
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

        xi.test.world:setSeed(4242)
        local mob = player.entities:get(rabbits[1]:getID())
        mob:respawn()

        local trips      = 0
        local onRing     = 0
        local wasWalking = false
        for _ = 1, 3000 do
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
        assert(onRing >= ringsWanted, string.format('%d of %d roam trips ended on a node ring, wanted %d', onRing, trips, ringsWanted))
    end)

    it('veers to the center of a node its chase runs through', function()
        xi.test.world:setSeed(4242)
        local nodes   = loadNodes()
        local zone    = player:getZone()
        local rabbits = zone:queryEntitiesByName('Wild_Rabbit')
        local mob     = player.entities:get(rabbits[1]:getID())
        mob:respawn()
        mob:clearPath()

        -- a straight chase from one side of a node to the other passes half a radius off its center
        local node = nil
        local from = nil
        local to   = nil
        for _, candidate in ipairs(nodes) do
            if candidate.radius >= 2.5 and candidate.radius <= 6 then
                local side  = candidate.radius / 2
                local start = { x = candidate.x - candidate.radius - 6, y = candidate.y, z = candidate.z + side }
                local stand = { x = candidate.x + candidate.radius + 10, y = candidate.y, z = candidate.z + side }
                if zone:isNavigablePoint(start) and zone:isNavigablePoint(stand) then
                    node = candidate
                    from = start
                    to   = stand
                    break
                end
            end
        end

        assert(node, 'no node with navigable ground on both sides')
        mob:setPos(from.x, from.y, from.z)
        player:setPos(to.x, to.y, to.z)
        mob:updateEnmity(player)

        -- a tick can reach the center and carry on past it, so measure the walked line between samples, not the samples
        local closest = math.huge
        local last    = mob:getPos()
        for _ = 1, 40 do
            xi.test.world:skipTime(1)
            xi.test.world:tickEntity(mob)

            local pos = mob:getPos()
            closest   = math.min(closest, flatDistanceToSegment(node, last, pos))
            last      = pos
            if distance(pos, player:getPos()) < 4 then
                break
            end
        end

        -- a straight chase keeps half a radius off the center the whole way
        local side = node.radius / 2
        assert(closest < side / 2, string.format('the chase should bend through the node center; it kept %.2f off it (a straight line keeps %.2f)', closest, side))
    end)
end)
