Enemies = {}

function Enemies.load()
    Enemies.list = {}
    Enemies.spawnTimer = 0
    Enemies.spawnRate = 2.0
end

function Enemies.update(dt)
    Enemies.spawnTimer = Enemies.spawnTimer + dt

    -- SISTEMA DE GENERACIÓN (SPAWNER)
    if Enemies.spawnTimer >= Enemies.spawnRate then
        local roll = math.random() -- Genera un número entre 0 y 1
        local enemy = {
            angle = math.random() * math.pi * 2,
            distance = 0,
            flashTimer = 0 -- Para el efecto de parpadeo al recibir daño
        }

        if roll > 0.9 then
            -- 10% de probabilidad: ENEMIGO GRANDE (10 HP)
            enemy.type = "grande"
            enemy.hp = 10
            enemy.speed = 30
            enemy.sizeBase = 8
            enemy.scoreValue = 1000
        elseif roll > 0.6 then
            -- 30% de probabilidad: NAVE (3 HP)
            enemy.type = "nave"
            enemy.hp = 3
            enemy.speed = 50
            enemy.sizeBase = 4
            enemy.scoreValue = 300
        else
            -- 60% de probabilidad: METEORITO (1 HP)
            enemy.type = "meteorito"
            enemy.hp = 1
            enemy.speed = 60
            enemy.sizeBase = 2
            enemy.scoreValue = 100

            -- Generar una forma irregular aleatoria para el meteorito
            enemy.vertices = {}
            local numPoints = math.random(5, 8) -- Tendrá entre 5 y 8 picos
            for v = 1, numPoints do
                local a = (v / numPoints) * math.pi * 2
                local r = math.random(60, 140) / 100 -- Aleatorizar la distancia del pico
                table.insert(enemy.vertices, math.cos(a) * r)
                table.insert(enemy.vertices, math.sin(a) * r)
            end
        end

        table.insert(Enemies.list, enemy)
        Enemies.spawnTimer = 0
        Enemies.spawnRate = math.max(0.5, Enemies.spawnRate - 0.02)
    end

    distortion.intensity = #Enemies.list * 0.5

    -- ACTUALIZACIÓN Y COLISIONES
    for i = #Enemies.list, 1, -1 do
        local e = Enemies.list[i]
        e.distance = e.distance + e.speed * dt

        -- El tamaño visual depende de su "sizeBase" y la distancia
        e.size = (e.distance / Player.ship.radius) * 20 * e.sizeBase

        -- Reducir temporizador de parpadeo de daño
        if e.flashTimer > 0 then
            e.flashTimer = e.flashTimer - dt
        end

        -- 1. DETECCIÓN DE COLISIÓN CON LA NAVE (GAME OVER)
        if math.abs(e.distance - Player.ship.radius) < 15 then
            local angleDiff = math.abs((e.angle % (math.pi*2)) - (Player.ship.angle % (math.pi*2)))
            if angleDiff < 0.2 or angleDiff > (math.pi * 2 - 0.2) then
                gameState = "gameover"
                distortion.shake = 4
            end
        end

        -- 2. DETECCIÓN DE COLISIÓN CON BALAS Y SISTEMA DE VIDA (HP)
        for j = #Player.bullets, 1, -1 do
            local b = Player.bullets[j]
            local distDiff = math.abs(b.distance - e.distance)
            local angleDiff = math.abs((b.angle % (math.pi*2)) - (e.angle % (math.pi*2)))

            local hitThreshold = 10 + (e.sizeBase * 2)

            if distDiff < hitThreshold and (angleDiff < 0.2 or angleDiff > (math.pi*2 - 0.2)) then
                e.hp = e.hp - 1          -- Restar 1 punto de vida
                e.flashTimer = 0.05      -- Activar el parpadeo blanco
                table.remove(Player.bullets, j) -- Destruir la bala

                -- Checar si el enemigo ha sido destruido
                if e.hp <= 0 then
                    score = score + e.scoreValue
                    scoreScale = 2
                    distortion.shake = 1
                    table.remove(Enemies.list, i)
                else
                    distortion.shake = 0.2 -- Vibración leve al hacer daño, pero no matar
                end
                break -- Salir del bucle de balas para este enemigo
            end
        end

        -- Limpieza si se salen de la pantalla
        if Enemies.list[i] and e.distance > Player.ship.radius + 100 then
            table.remove(Enemies.list, i)
        end
    end
end

function Enemies.draw()
    for _, e in ipairs(Enemies.list) do
        local ex = centerX + math.cos(e.angle) * e.distance
        local ey = centerY + math.sin(e.angle) * e.distance

        love.graphics.push()
            love.graphics.translate(ex, ey)
            love.graphics.rotate(e.angle + timer * 2)

            -- Manejo de colores
            if e.flashTimer > 0 then
                love.graphics.setColor(1, 1, 1) -- Blanco puro al recibir daño
            else
                if e.type == "grande" then
                    love.graphics.setColor(1, 0, 0) -- Rojo intenso
                elseif e.type == "nave" then
                    love.graphics.setColor(1, 0.5, 0) -- Naranja táctico
                else
                    love.graphics.setColor(1, 0.2, 0.2) -- Rojo neón original
                end
            end

            -- Dibujo específico según el tipo de entidad
            if e.type == "meteorito" then
                -- Dibujar el polígono irregular del meteorito
                local points = {}
                for v = 1, #e.vertices, 2 do
                    table.insert(points, e.vertices[v] * (e.size / 2))
                    table.insert(points, e.vertices[v+1] * (e.size / 2))
                end
                love.graphics.polygon("line", points)

            elseif e.type == "nave" then
                -- Dibujar un triángulo estilizado para la nave
                love.graphics.polygon("line", 0, e.size/2, -e.size/2, -e.size/2, e.size/2, -e.size/2)

            elseif e.type == "grande" then
                -- Dibujar un octágono masivo para la amenaza mayor
                love.graphics.circle("line", 0, 0, e.size/2, 8)
            end

        love.graphics.pop()
    end
end