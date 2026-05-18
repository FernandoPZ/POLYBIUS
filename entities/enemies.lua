-- entities/enemies.lua
-- Modificado (2026-05-18)
-- Autor: Fernando Pérez S.

local Player = require("entities.player")
local Particles = require("entities.particles")
local Physics = require("systems.physics")

local Enemies = {}
Enemies.pool = {}
local MAX_ENEMIES = 150

-- Variables del Gestor de Olas
local waveTimer = 0
local waveDelay = 3.0
local currentDifficulty = 1

function Enemies.load()
    Enemies.pool = {}
    waveTimer = 2.0 -- Tiempo antes de la primera ola
    waveDelay = 3.0
    currentDifficulty = 1

    -- PRE-ALLOCATION
    for i = 1, MAX_ENEMIES do
        local history = {}
        for h = 1, 5 do table.insert(history, {angle = 0, distance = 0}) end

        table.insert(Enemies.pool, {
            active = false, type = "", hp = 0, speed = 0, sizeBase = 0, scoreValue = 0,
            angle = 0, distance = 0, flashTimer = 0, size = 0, vertices = {},
            history = history
        })
    end
end

local function getInactiveEnemy()
    for i = 1, MAX_ENEMIES do
        if not Enemies.pool[i].active then return Enemies.pool[i] end
    end
    return nil
end

-- Función auxiliar para invocar un enemigo específico
local function spawnEnemy(eType, angle, distOffset)
    local enemy = getInactiveEnemy()
    if not enemy then return end

    enemy.active = true
    enemy.angle = angle
    enemy.distance = distOffset or 0
    enemy.flashTimer = 0
    enemy.vertices = {}

    if eType == "grande" then
        enemy.type = "grande"; enemy.hp = 10; enemy.speed = 30; enemy.sizeBase = 8; enemy.scoreValue = 1000
    elseif eType == "nave" then
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

    for h = 1, 5 do
        enemy.history[h].angle = angle
        enemy.history[h].distance = distOffset or 0
    end
end

-- DICCIONARIO DE PATRONES
local Patterns = {}

-- Anillo de meteoritos con un hueco para escapar
function Patterns.ring()
    local count = math.min(8 + math.floor(currentDifficulty), 16)
    local gapIndex = math.random(1, count)
    local baseAngle = math.random() * math.pi * 2

    for i = 1, count do
        if i ~= gapIndex and i ~= (gapIndex % count) + 1 then
            local angle = baseAngle + (i / count) * math.pi * 2
            spawnEnemy("meteorito", angle, 0)
        end
    end
end

-- Espiral de naves rápidas
function Patterns.spiral()
    local count = math.min(5 + math.floor(currentDifficulty / 2), 12)
    local baseAngle = math.random() * math.pi * 2

    for i = 1, count do
        local angle = baseAngle + (i * 0.4)
        local dist = -(i * 40) -- Spawnean más lejos secuencialmente
        spawnEnemy("nave", angle, dist)
    end
end

-- Muro blindado (Enemigo grande escoltado)
function Patterns.wall()
    local baseAngle = math.random() * math.pi * 2
    spawnEnemy("grande", baseAngle, 0)
    spawnEnemy("nave", baseAngle + 0.3, -50)
    spawnEnemy("nave", baseAngle - 0.3, -50)
end

-- Lluvia aleatoria clásica
function Patterns.randomScatter()
    local count = math.random(3, 6)
    for i = 1, count do
        spawnEnemy("meteorito", math.random() * math.pi * 2, -math.random(0, 150))
    end
end

local patternList = {Patterns.ring, Patterns.spiral, Patterns.wall, Patterns.randomScatter}

-- ==========================================

function Enemies.update(dt, gameContext)
    -- Lógica del Gestor de Olas
    waveTimer = waveTimer - dt
    if waveTimer <= 0 then
        -- Patron al azar
        local chosenPattern = patternList[math.random(1, #patternList)]
        chosenPattern()

        -- Dificultad progresiva
        currentDifficulty = currentDifficulty + 0.2
        waveDelay = math.max(1.2, waveDelay - 0.05)
        waveTimer = waveDelay
    end

    local activeCount = 0

    for i = 1, MAX_ENEMIES do
        local e = Enemies.pool[i]

        if e.active then
            -- GUARDAMOS EL HISTORIAL ANTES DE MOVERLO
            for h = 5, 2, -1 do
                e.history[h].distance = e.history[h-1].distance
                e.history[h].angle = e.history[h-1].angle
            end
            e.history[1].distance = e.distance
            e.history[1].angle = e.angle

            activeCount = activeCount + 1
            e.distance = e.distance + e.speed * dt
            e.size = (e.distance / Player.ship.radius) * 20 * e.sizeBase

            if e.flashTimer > 0 then e.flashTimer = e.flashTimer - dt end

            -- Colisión con Jugador (LIMPIO CON PHYSICS)
            if Physics.checkPolarCollision(e, Player.ship, 15, 0.2) then
                gameContext.distortion.shake = 4
                _G.ChangeState("gameover", gameContext.score)
                return
            end

            -- Colisión con Balas (LIMPIO CON PHYSICS)
            for j = 1, #Player.bullets do
                local b = Player.bullets[j]
                if b.active then
                    local threshold = 10 + (e.sizeBase * 2)

                    if Physics.checkPolarCollision(e, b, threshold, 0.2) then
                        e.hp = e.hp - 1
                        e.flashTimer = 0.05
                        b.active = false

                        if e.hp <= 0 then
                            -- LÓGICA DE COMBO Y MULTIPLICADOR
                            gameContext.combo = gameContext.combo + 1
                            gameContext.comboTimer = gameContext.maxComboTimer
                            -- El multiplicador sube de 1 en 1 por cada 5 enemigos destruidos, límite en x10
                            gameContext.multiplier = math.min(10, 1 + math.floor(gameContext.combo / 5))

                            -- Sumamos el puntaje multiplicado
                            gameContext.score = gameContext.score + (e.scoreValue * gameContext.multiplier)
                            gameContext.scoreScale = 2

                            gameContext.distortion.shake = 1 + (gameContext.multiplier * 0.5)

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

            -- Desactivar si se sale de la pantalla
            if e.active and e.distance > Player.ship.radius + 100 then
                e.active = false
            end
        end
    end

    gameContext.distortion.intensity = activeCount * 0.5
end

-- Función auxiliar para dibujar las formas sin repetir código
local function drawEnemyShape(eType, size, vertices)
    if eType == "meteorito" then
        love.graphics.push()
        love.graphics.scale(size / 2, size / 2)
        love.graphics.polygon("line", vertices)
        love.graphics.pop()
    elseif eType == "nave" then
        love.graphics.polygon("line", 0, size/2, -size/2, -size/2, size/2, -size/2)
    elseif eType == "grande" then
        local w, h = size, size / 1.5
        love.graphics.rectangle("line", -w/2, -h/2, w, h)
    end
end

function Enemies.draw(timer)
    for i = 1, MAX_ENEMIES do
        local e = Enemies.pool[i]

        if e.active then
            -- 1. DIBUJAMOS LA ESTELA (De la más vieja a la más nueva)
            for h = 5, 1, -1 do
                local hist = e.history[h]
                local hx = _G.CenterX + math.cos(hist.angle) * hist.distance
                local hy = _G.CenterY + math.sin(hist.angle) * hist.distance
                local hSize = (hist.distance / Player.ship.radius) * 20 * e.sizeBase
                local alpha = (1 - (h / 5)) * 0.4 -- Opacidad reducida

                love.graphics.push()
                    love.graphics.translate(hx, hy)
                    love.graphics.rotate(hist.angle + timer * 2)

                    if e.type == "grande" then love.graphics.setColor(0.6, 0.1, 0.9, alpha)
                    elseif e.type == "nave" then love.graphics.setColor(1, 0.5, 0, alpha)
                    else love.graphics.setColor(1, 0.2, 0.2, alpha) end

                    drawEnemyShape(e.type, hSize, e.vertices)
                love.graphics.pop()
            end

            -- 2. DIBUJAMOS EL ENEMIGO PRINCIPAL (Opacidad total)
            local ex = _G.CenterX + math.cos(e.angle) * e.distance
            local ey = _G.CenterY + math.sin(e.angle) * e.distance

            love.graphics.push()
                love.graphics.translate(ex, ey)
                love.graphics.rotate(e.angle + timer * 2)

                if e.flashTimer > 0 then love.graphics.setColor(1, 1, 1, 1)
                elseif e.type == "grande" then love.graphics.setColor(0.6, 0.1, 0.9, 1)
                elseif e.type == "nave" then love.graphics.setColor(1, 0.5, 0, 1)
                else love.graphics.setColor(1, 0.2, 0.2, 1) end

                drawEnemyShape(e.type, e.size, e.vertices)
            love.graphics.pop()
        end
    end
end

return Enemies