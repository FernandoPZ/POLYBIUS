-- entities/enemies.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Player = require("entities.player")
local Particles = require("entities.particles")

local Enemies = {}
Enemies.pool = {}
local MAX_ENEMIES = 50

local spawnTimer = 0
local spawnRate = 2.0

function Enemies.load()
    Enemies.pool = {}
    spawnTimer = 0
    spawnRate = 2.0

    for i = 1, MAX_ENEMIES do
        table.insert(Enemies.pool, {
            active = false,
            type = "", hp = 0, speed = 0, sizeBase = 0, scoreValue = 0,
            angle = 0, distance = 0, flashTimer = 0, size = 0, vertices = {}
        })
    end
end

local function getInactiveEnemy()
    for i = 1, MAX_ENEMIES do
        if not Enemies.pool[i].active then
            return Enemies.pool[i]
        end
    end
    return nil
end

function Enemies.update(dt, gameContext)
    spawnTimer = spawnTimer + dt

    if spawnTimer >= spawnRate then
        local enemy = getInactiveEnemy()

        if enemy then
            local roll = math.random()
            enemy.active = true
            enemy.angle = math.random() * math.pi * 2
            enemy.distance = 0
            enemy.flashTimer = 0
            enemy.vertices = {}

            if roll > 0.9 then
                enemy.type = "grande"; enemy.hp = 10; enemy.speed = 30; enemy.sizeBase = 8; enemy.scoreValue = 1000
            elseif roll > 0.6 then
                enemy.type = "nave"; enemy.hp = 3; enemy.speed = 50; enemy.sizeBase = 4; enemy.scoreValue = 300
            else
                enemy.type = "meteorito"; enemy.hp = 1; enemy.speed = 60; enemy.sizeBase = 2; enemy.scoreValue = 100
                local points = math.random(5, 8)
                for v = 1, points do
                    local a = (v / points) * math.pi * 2
                    local r = math.random(60, 140) / 100
                    table.insert(enemy.vertices, math.cos(a) * r)
                    table.insert(enemy.vertices, math.sin(a) * r)
                end
            end

            spawnTimer = 0
            spawnRate = math.max(0.5, spawnRate - 0.02)
        end
    end

    local activeCount = 0

    for i = 1, MAX_ENEMIES do
        local e = Enemies.pool[i]

        if e.active then
            activeCount = activeCount + 1
            e.distance = e.distance + e.speed * dt
            e.size = (e.distance / Player.ship.radius) * 20 * e.sizeBase

            if e.flashTimer > 0 then e.flashTimer = e.flashTimer - dt end

            -- Colisión con Jugador
            if math.abs(e.distance - Player.ship.radius) < 15 then
                local aDiff = math.abs((e.angle % (math.pi*2)) - (Player.ship.angle % (math.pi*2)))
                if aDiff < 0.2 or aDiff > (math.pi * 2 - 0.2) then
                    gameContext.distortion.shake = 4
                    _G.ChangeState("gameover", gameContext.score)
                    return
                end
            end

            -- Colisión con Balas
            for j = 1, #Player.bullets do
                local b = Player.bullets[j]

                if b.active then
                    local dDiff = math.abs(b.distance - e.distance)
                    local aDiff = math.abs((b.angle % (math.pi*2)) - (e.angle % (math.pi*2)))
                    local threshold = 10 + (e.sizeBase * 2)

                    if dDiff < threshold and (aDiff < 0.2 or aDiff > (math.pi*2 - 0.2)) then
                        e.hp = e.hp - 1
                        e.flashTimer = 0.05

                        b.active = false

                        if e.hp <= 0 then
                            gameContext.score = gameContext.score + e.scoreValue
                            gameContext.scoreScale = 2
                            gameContext.distortion.shake = 1

                            local ex = _G.CenterX + math.cos(e.angle) * e.distance
                            local ey = _G.CenterY + math.sin(e.angle) * e.distance
                            Particles.spawn(ex, ey, e.type)

                            gameContext.hitStopTimer = (e.type == "grande") and 0.1 or 0.03
                            e.active = false
                        end
                        break
                    end
                end
            end

            if e.active and e.distance > Player.ship.radius + 100 then
                e.active = false
            end
        end
    end

    gameContext.distortion.intensity = activeCount * 0.5
end

function Enemies.draw(timer)
    for i = 1, MAX_ENEMIES do
        local e = Enemies.pool[i]

        if e.active then
            local ex = _G.CenterX + math.cos(e.angle) * e.distance
            local ey = _G.CenterY + math.sin(e.angle) * e.distance

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
end

return Enemies