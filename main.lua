-- Configuración inicial
function love.load()
    -- Variables de la nave
    ship = {}
    ship.angle = 0          -- Ángulo en radianes
    ship.speed = 4          -- Velocidad de rotación
    ship.radius = 200       -- Distancia desde el centro
    ship.size = 15          -- Tamaño del triángulo
    
    -- Centro de la pantalla
    centerX = love.graphics.getWidth() / 2
    centerY = love.graphics.getHeight() / 2
    
    -- Colores para el efecto "flashing"
    timer = 0
end

function love.update(dt)
    -- Control de movimiento (Flechas)
    if love.keyboard.isDown("left") then
        ship.angle = ship.angle - ship.speed * dt
    elseif love.keyboard.isDown("right") then
        ship.angle = ship.angle + ship.speed * dt
    end

    -- Actualizar timer para efectos visuales
    timer = timer + dt
end

function love.draw()
    -- 1. Dibujar el fondo "hipnótico" (Túnel)
    love.graphics.setLineWidth(2)
    for i = 0, 7 do
        -- Cambia el color basándose en el tiempo para el efecto Polybius
        local colorMod = (math.floor(timer * 10) + i) % 2
        if colorMod == 0 then
            love.graphics.setColor(0, 1, 0) -- Verde neón
        else
            love.graphics.setColor(0, 0.2, 0) -- Verde oscuro
        end
        
        -- Dibujamos líneas que salen del centro
        local lineAngle = i * (math.pi / 4) + (timer * 0.5)
        local targetX = centerX + math.cos(lineAngle) * 1000
        local targetY = centerY + math.sin(lineAngle) * 1000
        love.graphics.line(centerX, centerY, targetX, targetY)
    end

    -- 2. Calcular posición de la nave
    local shipX = centerX + math.cos(ship.angle) * ship.radius
    local shipY = centerY + math.sin(ship.angle) * ship.radius

    -- 3. Dibujar la nave (un triángulo que apunta al centro)
    love.graphics.setColor(1, 1, 1) -- Blanco
    love.graphics.push()
        love.graphics.translate(shipX, shipY)
        love.graphics.rotate(ship.angle + math.pi/2) -- Rotar para que "mire" al centro
        love.graphics.polygon("line", 0, -ship.size, -ship.size, ship.size, ship.size, ship.size)
    love.graphics.pop()
    
    -- 4. El toque misterioso: Mensaje fugaz
    if math.random() > 0.98 then
        love.graphics.print("OBEY", 10, 10, 0, 2, 2)
    end
end