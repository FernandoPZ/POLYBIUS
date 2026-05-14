-- entities/player.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Player = {}

Player.ship = { angle = 0, speed = 3, radius = 260, size = 15 }
Player.bullets = {}
local MAX_BULLETS = 100

local shootCooldown = 0
local fireRate = 0.15

function Player.load()
    Player.ship.angle = 0
    shootCooldown = 0
    Player.bullets = {}

    for i = 1, MAX_BULLETS do
        table.insert(Player.bullets, {
            active = false,
            angle = 0,
            distance = 0,
            speed = 0
        })
    end
end

local function getInactiveBullet()
    for i = 1, MAX_BULLETS do
        if not Player.bullets[i].active then
            return Player.bullets[i]
        end
    end
    return nil
end

function Player.update(dt)
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
            if b.distance < 0 then
                b.active = false
            end
        end
    end
end

function Player.draw()
    love.graphics.setColor(1, 1, 0)
    for i = 1, MAX_BULLETS do
        local b = Player.bullets[i]
        if b.active then
            local bx = _G.CenterX + math.cos(b.angle) * b.distance
            local by = _G.CenterY + math.sin(b.angle) * b.distance
            love.graphics.circle("fill", bx, by, 3)
        end
    end

    local shipX = _G.CenterX + math.cos(Player.ship.angle) * Player.ship.radius
    local shipY = _G.CenterY + math.sin(Player.ship.angle) * Player.ship.radius

    love.graphics.setColor(1, 1, 0.7)
    love.graphics.push()
        love.graphics.translate(shipX, shipY)
        love.graphics.rotate(Player.ship.angle - math.pi/2)
        love.graphics.polygon("line", 0, -Player.ship.size, -Player.ship.size/2, Player.ship.size, Player.ship.size/2, Player.ship.size)
    love.graphics.pop()
end

return Player