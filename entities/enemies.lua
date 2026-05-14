-- entities/enemies.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Player = require("entities.player")
local Particles = require("entities.particles")

local Enemies = {}
Enemies.list = {}
local spawnTimer = 0
local spawnRate = 2.0

function Enemies.load()
    Enemies.list = {}
    spawnTimer = 0
    spawnRate = 2.0
end

function Enemies.update(dt, gameContext)
    spawnTimer = spawnTimer + dt

    if spawnTimer >= spawnRate then
        local roll = math.random()
        local enemy = { angle = math.random() * math.pi * 2, distance = 0, flashTimer = 0 }

        if roll > 0.9 then
            enemy.type = "grande"; enemy.hp = 10; enemy.speed = 30; enemy.sizeBase = 8; enemy.scoreValue = 1000
        elseif roll > 0.6 then
            enemy.type = "nave"; enemy.hp = 3; enemy.speed = 50; enemy.sizeBase = 4; enemy.scoreValue = 300
        else
            enemy.type = "meteorito"; enemy.hp = 1; enemy.speed = 60; enemy.sizeBase = 2; enemy.scoreValue = 100
            enemy.vertices = {}
            local points = math.random(5, 8)
            for v = 1, points do
                local a = (v / points) * math.pi * 2
                local r = math.random(60, 140) / 100
                table.insert(enemy.vertices, math.cos(a) * r)
                table.insert(enemy.vertices, math.sin(a) * r)
            end
        end
        table.insert(Enemies.list, enemy)
        spawnTimer = 0
        spawnRate = math.max(0.5, spawnRate - 0.02)
    end

    gameContext.distortion.intensity = #Enemies.list * 0.5

    for i = #Enemies.list, 1, -1 do
        local e = Enemies.list[i]
        e.distance = e.distance + e.speed * dt
        e.size = (e.distance / Player.ship.radius) * 20 * e.sizeBase

        if e.flashTimer > 0 then e.flashTimer = e.flashTimer - dt end

        -- Colisión con Jugador
        if math.abs(e.distance - Player.ship.radius) < 15 then
            local aDiff = math.abs((e.angle % (math.pi*2)) - (Player.ship.angle % (math.pi*2)))
            if aDiff < 0.2 or aDiff > (math.pi * 2 - 0.2) then
                gameContext.distortion.shake = 4
                ChangeState("gameover", gameContext.score)
                return
            end
        end

        -- Colisión con Balas
        for j = #Player.bullets, 1, -1 do
            local b = Player.bullets[j]
            local dDiff = math.abs(b.distance - e.distance)
            local aDiff = math.abs((b.angle % (math.pi*2)) - (e.angle % (math.pi*2)))
            local threshold = 10 + (e.sizeBase * 2)

            if dDiff < threshold and (aDiff < 0.2 or aDiff > (math.pi*2 - 0.2)) then
                e.hp = e.hp - 1
                e.flashTimer = 0.05
                table.remove(Player.bullets, j)

                if e.hp <= 0 then
                    gameContext.score = gameContext.score + e.scoreValue
                    gameContext.scoreScale = 2
                    gameContext.distortion.shake = 1

                    local ex = CenterX + math.cos(e.angle) * e.distance
                    local ey = CenterY + math.sin(e.angle) * e.distance
                    Particles.spawn(ex, ey, e.type)

                    gameContext.hitStopTimer = (e.type == "grande") and 0.1 or 0.03
                    table.remove(Enemies.list, i)
                end
                break
            end
        end

        if Enemies.list[i] and e.distance > Player.ship.radius + 100 then
            table.remove(Enemies.list, i)
        end
    end
end

function Enemies.draw(timer)
    for _, e in ipairs(Enemies.list) do
        local ex = CenterX + math.cos(e.angle) * e.distance
        local ey = CenterY + math.sin(e.angle) * e.distance

        love.graphics.push()
            love.graphics.translate(ex, ey)
            love.graphics.rotate(e.angle + timer * 2)

            if e.flashTimer > 0 then love.graphics.setColor(1, 1, 1)
            elseif e.type == "grande" then love.graphics.setColor(0.6, 0.1, 0.9)
            elseif e.type == "nave" then love.graphics.setColor(1, 0.5, 0)
            else love.graphics.setColor(1, 0.2, 0.2) end

            if e.type == "meteorito" then
                love.graphics.push()
                love.graphics.scale(e.size / 2, e.size / 2)
                love.graphics.polygon("line", e.vertices)
                love.graphics.pop()
            elseif e.type == "nave" then
                love.graphics.polygon("line", 0, e.size/2, -e.size/2, -e.size/2, e.size/2, -e.size/2)
            elseif e.type == "grande" then
                local w, h = e.size, e.size / 1.5
                love.graphics.rectangle("line", -w/2, -h/2, w, h)
            end
        love.graphics.pop()
    end
end

return Enemies