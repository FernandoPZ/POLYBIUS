-- Configuración inicial
function love.load()

    -- Variables de estado
    gameState = "play"

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

    -- Sistema de enemigos
    enemies = {}
    spawnTimer = 0
    spawnRate = 1.5 -- Crea un enemigo cada 1.5 segundos
end

function love.update(dt)
    if gameState ~= "play" then return end
    -- Control de movimiento (Flechas)
    if love.keyboard.isDown("left") then
        ship.angle = ship.angle - ship.speed * dt
    elseif love.keyboard.isDown("right") then
        ship.angle = ship.angle + ship.speed * dt
    end

    -- Actualizar timer para efectos visuales
    timer = timer + dt

    -- Generar enemigos
    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnRate then
        local enemy = {
            angle = math.random() * math.pi * 2, -- Ángulo aleatorio
            distance = 0,                        -- Empieza en el centro
            speed = 150,                         -- Píxeles por segundo
            size = 2                             -- Tamaño inicial pequeño
        }
        table.insert(enemies, enemy)
        spawnTimer = 0
        -- Aumentar la dificultad sutilmente
        spawnRate = math.max(0.4, spawnRate - 0.01)
    end

    -- Actualizar enemigos
    for i = #enemies, 1, -1 do
        local e = enemies[i]
        e.distance = e.distance + e.speed * dt
        e.size = (e.distance / ship.radius) * 20 -- Crece según se acerca

        -- DETECCIÓN DE COLISIÓN
        if math.abs(e.distance - ship.radius) < 15 then
            local angleDiff = math.abs((e.angle % (math.pi*2)) - (ship.angle % (math.pi*2)))
            if angleDiff < 0.2 or angleDiff > (math.pi * 2 - 0.2) then
                gameState = "gameover"
            end
        end

        -- Limpieza
        if e.distance > ship.radius + 100 then table.remove(enemies, i) end
    end
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

    -- Enemigos
    for _, e in ipairs(enemies) do
        local ex = centerX + math.cos(e.angle) * e.distance
        local ey = centerY + math.sin(e.angle) * e.distance

        -- Color neón para los enemigos (rojo/naranja para contraste)
        love.graphics.setColor(1, 0.2, 0.2)

        -- Dibujar un rombo o cuadrado que rota
        love.graphics.push()
            love.graphics.translate(ex, ey)
            love.graphics.rotate(e.angle + timer * 2)
            love.graphics.rectangle("line", -e.size/2, -e.size/2, e.size, e.size)
        love.graphics.pop()
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

    -- Interfaz de Game Over
    if gameState == "gameover" then
        love.graphics.setColor(1, 0, 0, 0.7) -- Rojo semi-transparente
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("CONEXIÓN PERDIDA\nPresiona 'R' para reintentar", 0, centerY - 20, love.graphics.getWidth(), "center")
    end
end

-- Función para detectar teclas sueltas (Reinicio)
function love.keypressed(key)
    if key == "r" and gameState == "gameover" then
        love.load() -- Reinicia todo el estado
    end
end