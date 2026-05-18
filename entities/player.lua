-- entities/player.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Player = {}

Player.ship = { angle = 0, speed = 3, radius = 260, size = 15 }
Player.bullets = {}
local MAX_BULLETS = 100
-- Variables de la estela
Player.trail = {}
local TRAIL_LENGTH = 8

local shootCooldown = 0
local fireRate = 0.15

function Player.load()
    Player.ship.angle = 0
    shootCooldown = 0
    Player.bullets = {}
    Player.trail = {}

    -- PRE-ALLOCATION de Balas
    for i = 1, MAX_BULLETS do
        table.insert(Player.bullets, { active = false, angle = 0, distance = 0, speed = 0 })
    end

    -- PRE-ALLOCATION del Historial de la Estela
    for i = 1, TRAIL_LENGTH do
        table.insert(Player.trail, 0) -- Solo necesitamos guardar el ángulo
    end
end

local function getInactiveBullet()
    for i = 1, MAX_BULLETS do
        if not Player.bullets[i].active then return Player.bullets[i] end
    end
    return nil
end

function Player.update(dt)
    -- Guardamos el historial para la estela antes de movernos
    for i = TRAIL_LENGTH, 2, -1 do
        Player.trail[i] = Player.trail[i-1]
    end
    Player.trail[1] = Player.ship.angle

    if love.keyboard.isDown("left") then
        Player.ship.angle = Player.ship.angle - Player.ship.speed * dt
    elseif love.keyboard.isDown("right") then
        Player.ship.angle = Player.ship.angle + Player.ship.speed * dt
    end

    shootCooldown = shootCooldown - dt
    if love.keyboard.isDown("space") and shootCooldown <= 0 then
        local b = getInactiveBullet()
        if b then
            b.active = true
            b.angle = Player.ship.angle
            b.distance = Player.ship.radius
            b.speed = 500
            shootCooldown = fireRate
        end
    end

    for i = 1, MAX_BULLETS do
        local b = Player.bullets[i]
        if b.active then
            b.distance = b.distance - b.speed * dt
            if b.distance < 0 then b.active = false end
        end
    end
end

function Player.draw()
    -- 1. Dibujamos las balas
    love.graphics.setColor(1, 1, 0)
    for i = 1, MAX_BULLETS do
        local b = Player.bullets[i]
        if b.active then
            local bx = _G.CenterX + math.cos(b.angle) * b.distance
            local by = _G.CenterY + math.sin(b.angle) * b.distance
            love.graphics.circle("fill", bx, by, 3)
        end
    end

    -- 2. Dibujamos la estela del jugador
    for i = TRAIL_LENGTH, 1, -1 do
        local alpha = (1 - (i / TRAIL_LENGTH)) * 0.5 -- Va desapareciendo
        love.graphics.setColor(1, 1, 0.7, alpha)

        local tAngle = Player.trail[i]
        local tx = _G.CenterX + math.cos(tAngle) * Player.ship.radius
        local ty = _G.CenterY + math.sin(tAngle) * Player.ship.radius

        love.graphics.push()
            love.graphics.translate(tx, ty)
            love.graphics.rotate(tAngle - math.pi/2)
            love.graphics.polygon("line", 0, -Player.ship.size, -Player.ship.size/2, Player.ship.size, Player.ship.size/2, Player.ship.size)
        love.graphics.pop()
    end

    -- 3. Dibujamos la nave principal (con opacidad total)
    local shipX = _G.CenterX + math.cos(Player.ship.angle) * Player.ship.radius
    local shipY = _G.CenterY + math.sin(Player.ship.angle) * Player.ship.radius

    love.graphics.setColor(1, 1, 0.7, 1)
    love.graphics.push()
        love.graphics.translate(shipX, shipY)
        love.graphics.rotate(Player.ship.angle - math.pi/2)
        love.graphics.polygon("line", 0, -Player.ship.size, -Player.ship.size/2, Player.ship.size, Player.ship.size/2, Player.ship.size)
    love.graphics.pop()
end

return Player