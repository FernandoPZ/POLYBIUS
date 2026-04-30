Player = {}

function Player.load()
    Player.ship = {
        angle = 0,
        speed = 3,
        radius = 260,
        size = 15
    }
    Player.bullets = {}
    -- Variables para el auto-disparo
    Player.shootCooldown = 0
    Player.fireRate = 0.15 -- Tiempo entre disparos (menor = más rápido)
end

function Player.update(dt)
    -- Movimiento
    if love.keyboard.isDown("left") then
        Player.ship.angle = Player.ship.angle - Player.ship.speed * dt
    elseif love.keyboard.isDown("right") then
        Player.ship.angle = Player.ship.angle + Player.ship.speed * dt
    end

    -- DISPARO AUTOMÁTICO
    Player.shootCooldown = Player.shootCooldown - dt
    if love.keyboard.isDown("space") and Player.shootCooldown <= 0 then
        local newBullet = {
            angle = Player.ship.angle,
            distance = Player.ship.radius,
            speed = 500
        }
        table.insert(Player.bullets, newBullet)
        Player.shootCooldown = Player.fireRate -- Reiniciar temporizador
    end

    -- Lógica de las Balas
    for i = #Player.bullets, 1, -1 do
        local b = Player.bullets[i]
        b.distance = b.distance - b.speed * dt
        if b.distance < 0 then table.remove(Player.bullets, i) end
    end
end

function Player.draw()
    -- Dibujar Balas
    love.graphics.setColor(1, 1, 0)
    for _, b in ipairs(Player.bullets) do
        local bx = centerX + math.cos(b.angle) * b.distance
        local by = centerY + math.sin(b.angle) * b.distance
        love.graphics.circle("fill", bx, by, 3)
    end

    -- Dibujar Nave
    local shipX = centerX + math.cos(Player.ship.angle) * Player.ship.radius
    local shipY = centerY + math.sin(Player.ship.angle) * Player.ship.radius

    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
        love.graphics.translate(shipX, shipY)
        love.graphics.rotate(Player.ship.angle - math.pi/2)
        love.graphics.polygon("line", 0, -Player.ship.size, -Player.ship.size/2, Player.ship.size, Player.ship.size/2, Player.ship.size)
    love.graphics.pop()
end