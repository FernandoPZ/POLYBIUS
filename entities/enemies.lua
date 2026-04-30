Enemies = {}

function Enemies.load()
    Enemies.list = {}
    Enemies.spawnTimer = 0
    Enemies.spawnRate = 2.0
end

function Enemies.update(dt)
    Enemies.spawnTimer = Enemies.spawnTimer + dt

    if Enemies.spawnTimer >= Enemies.spawnRate then
        local roll = math.random()
        local enemy = { angle = math.random() * math.pi * 2, distance = 0, flashTimer = 0 }

        if roll > 0.9 then
            enemy.type = "grande"
            enemy.hp = 10
            enemy.speed = 30
            enemy.sizeBase = 8
            enemy.scoreValue = 1000
        elseif roll > 0.6 then
            enemy.type = "nave"
            enemy.hp = 3
            enemy.speed = 50
            enemy.sizeBase = 4
            enemy.scoreValue = 300
        else
            enemy.type = "meteorito"
            enemy.hp = 1
            enemy.speed = 60
            enemy.sizeBase = 2
            enemy.scoreValue = 100
            enemy.vertices = {}
            local numPoints = math.random(5, 8)
            for v = 1, numPoints do
                local a = (v / numPoints) * math.pi * 2
                local r = math.random(60, 140) / 100
                table.insert(enemy.vertices, math.cos(a) * r)
                table.insert(enemy.vertices, math.sin(a) * r)
            end
        end

        table.insert(Enemies.list, enemy)
        Enemies.spawnTimer = 0
        Enemies.spawnRate = math.max(0.5, Enemies.spawnRate - 0.02)
    end

    distortion.intensity = #Enemies.list * 0.5

    for i = #Enemies.list, 1, -1 do
        local e = Enemies.list[i]
        e.distance = e.distance + e.speed * dt
        e.size = (e.distance / Player.ship.radius) * 20 * e.sizeBase

        if e.flashTimer > 0 then e.flashTimer = e.flashTimer - dt end

        if math.abs(e.distance - Player.ship.radius) < 15 then
            local angleDiff = math.abs((e.angle % (math.pi*2)) - (Player.ship.angle % (math.pi*2)))
            if angleDiff < 0.2 or angleDiff > (math.pi * 2 - 0.2) then
                currentState = "gameover"
                distortion.shake = 4
            end
        end

        for j = #Player.bullets, 1, -1 do
            local b = Player.bullets[j]
            local distDiff = math.abs(b.distance - e.distance)
            local angleDiff = math.abs((b.angle % (math.pi*2)) - (e.angle % (math.pi*2)))
            local hitThreshold = 10 + (e.sizeBase * 2)

            if distDiff < hitThreshold and (angleDiff < 0.2 or angleDiff > (math.pi*2 - 0.2)) then
                e.hp = e.hp - 1
                e.flashTimer = 0.05
                table.remove(Player.bullets, j)

                if e.hp <= 0 then
                    score = score + e.scoreValue
                    scoreScale = 2
                    distortion.shake = 1

                    -- LLUVIA DE METEOROS
                    if e.type == "grande" then
                        for m = 1, 5 do
                            local meteor = {
                                type = "meteorito", hp = 1, speed = e.speed * 2, sizeBase = 2,
                                scoreValue = 50, distance = e.distance,
                                angle = e.angle + (math.random() - 0.5) * 1.5, flashTimer = 0, vertices = {}
                            }
                            local numPoints = math.random(5, 8)
                            for v = 1, numPoints do
                                local a = (v / numPoints) * math.pi * 2
                                local r = math.random(60, 140) / 100
                                table.insert(meteor.vertices, math.cos(a) * r)
                                table.insert(meteor.vertices, math.sin(a) * r)
                            end
                            table.insert(Enemies.list, meteor)
                        end
                    end
                    table.remove(Enemies.list, i)
                else
                    distortion.shake = 0.2
                end
                break
            end
        end

        if Enemies.list[i] and e.distance > Player.ship.radius + 100 then
            table.remove(Enemies.list, i)
        end
    end
end

function Enemies.draw()
    for _, e in ipairs(Enemies.list) do
        local ex = CenterX + math.cos(e.angle) * e.distance
        local ey = CenterY + math.sin(e.angle) * e.distance

        love.graphics.push()
            love.graphics.translate(ex, ey)
            love.graphics.rotate(e.angle + timer * 2)

            if e.flashTimer > 0 then
                love.graphics.setColor(1, 1, 1)
            else
                if e.type == "grande" then love.graphics.setColor(0.6, 0.1, 0.9)
                elseif e.type == "nave" then love.graphics.setColor(1, 0.5, 0)
                else love.graphics.setColor(1, 0.2, 0.2) end
            end

            if e.type == "meteorito" then
                local points = {}
                for v = 1, #e.vertices, 2 do
                    table.insert(points, e.vertices[v] * (e.size / 2))
                    table.insert(points, e.vertices[v+1] * (e.size / 2))
                end
                love.graphics.polygon("line", points)
            elseif e.type == "nave" then
                love.graphics.polygon("line", 0, e.size/2, -e.size/2, -e.size/2, -e.size/2, e.size/2, -e.size/2)
            elseif e.type == "grande" then
                -- DISEÑO ALIENÍGENA
                local w, h = e.size, e.size / 1.5
                love.graphics.rectangle("line", -w/2, -h/2, w, h)
                love.graphics.rectangle("line", -w/4, -h/4, w/2, h/2)
                love.graphics.line(-w/2, 0, -w, -h/2)
                love.graphics.line(-w/2, 0, -w, h/2)
                love.graphics.line(w/2, 0, w, -h/2)
                love.graphics.line(w/2, 0, w, h/2)
            end
        love.graphics.pop()
    end
end

-- enemies.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.