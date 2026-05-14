-- entities/player.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Player = {}

-- Atributos públicos
Player.ship = { angle = 0, speed = 3, radius = 260, size = 15 }
Player.bullets = {}

-- Atributos privados
local shootCooldown = 0
local fireRate = 0.15

function Player.load()
    Player.ship.angle = 0
    Player.bullets = {}
    shootCooldown = 0
end

function Player.update(dt)
    if love.keyboard.isDown("left") then
        Player.ship.angle = Player.ship.angle - Player.ship.speed * dt
    elseif love.keyboard.isDown("right") then
        Player.ship.angle = Player.ship.angle + Player.ship.speed * dt
    end

    shootCooldown = shootCooldown - dt
    if love.keyboard.isDown("space") and shootCooldown <= 0 then
        local newBullet = { angle = Player.ship.angle, distance = Player.ship.radius, speed = 500 }
        table.insert(Player.bullets, newBullet)
        shootCooldown = fireRate
    end

    for i = #Player.bullets, 1, -1 do
        local b = Player.bullets[i]
        b.distance = b.distance - b.speed * dt
        if b.distance < 0 then table.remove(Player.bullets, i) end
    end
end

function Player.draw()
    love.graphics.setColor(1, 1, 0)
    for _, b in ipairs(Player.bullets) do
        local bx = _G.CenterX + math.cos(b.angle) * b.distance
        local by = _G.CenterY + math.sin(b.angle) * b.distance
        love.graphics.circle("fill", bx, by, 3)
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