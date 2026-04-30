Enemies = {}

function Enemies.load()
    Enemies.list = {}
    Enemies.spawnTimer = 0
    Enemies.spawnRate = 2.0
end

function Enemies.update(dt)
    Enemies.spawnTimer = Enemies.spawnTimer + dt
    if Enemies.spawnTimer >= Enemies.spawnRate then
        local enemy = {
            angle = math.random() * math.pi * 2,
            distance = 0,
            speed = 60,
            size = 2
        }
        table.insert(Enemies.list, enemy)
        Enemies.spawnTimer = 0
        Enemies.spawnRate = math.max(0.5, Enemies.spawnRate - 0.02)
    end

    distortion.intensity = #Enemies.list * 0.5

    for i = #Enemies.list, 1, -1 do
        local e = Enemies.list[i]
        e.distance = e.distance + e.speed * dt
        e.size = (e.distance / Player.ship.radius) * 20


        -- 1. DETECCIÓN DE COLISIÓN CON LA NAVE
        if math.abs(e.distance - Player.ship.radius) < 15 then
            local angleDiff = math.abs((e.angle % (math.pi*2)) - (Player.ship.angle % (math.pi*2)))
            if angleDiff < 0.2 or angleDiff > (math.pi * 2 - 0.2) then
                gameState = "gameover"
                distortion.shake = 4
            end
        end

        -- 2. DETECCIÓN DE COLISIÓN CON BALAS
        local enemyKilled = false
        for j = #Player.bullets, 1, -1 do
            local b = Player.bullets[j]
            local distDiff = math.abs(b.distance - e.distance)
            local angleDiff = math.abs((b.angle % (math.pi*2)) - (e.angle % (math.pi*2)))

            if distDiff < 20 and (angleDiff < 0.2 or angleDiff > (math.pi*2 - 0.2)) then
                score = score + 100
                scoreScale = 2

                distortion.shake = 1

                table.remove(Player.bullets, j)
                enemyKilled = true
                break
            end
        end

        -- Limpieza de enemigos
        if enemyKilled then
            table.remove(Enemies.list, i)
        elseif e.distance > Player.ship.radius + 100 then
            table.remove(Enemies.list, i)
        end
    end
end

function Enemies.draw()
    love.graphics.setColor(1, 0.2, 0.2)
    for _, e in ipairs(Enemies.list) do
        local ex = centerX + math.cos(e.angle) * e.distance
        local ey = centerY + math.sin(e.angle) * e.distance

        love.graphics.push()
            love.graphics.translate(ex, ey)
            love.graphics.rotate(e.angle + timer * 2)
            love.graphics.rectangle("line", -e.size/2, -e.size/2, e.size, e.size)
        love.graphics.pop()
    end
end