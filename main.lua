-- Importar módulos
require("tunnel")
require("player")
require("enemies")

function love.load()
    -- Variables globales de estado
    gameState = "play"
    centerX = love.graphics.getWidth() / 2
    centerY = love.graphics.getHeight() / 2
    timer = 0
    score = 0
    scoreScale = 1
    distortion = { shake = 0, intensity = 0 }

    -- Cargar sistemas
    Tunnel.load()
    Player.load()
    Enemies.load()
end

function love.update(dt)
    if gameState ~= "play" then return end

    timer = timer + dt
    scoreScale = math.max(1, scoreScale - dt * 5)
    distortion.shake = math.max(0, distortion.shake - dt * 5)

    -- Actualizar sistemas
    Player.update(dt)
    Enemies.update(dt)
end

function love.draw()
    -- EFECTOS Y GRÁFICOS DEL JUEGO
    love.graphics.push()
        Tunnel.applyDistortion()

        Tunnel.draw()      -- Dibuja el tubo, telaraña y fondo
        Enemies.draw()     -- Dibuja los cuadrados rojos
        Player.draw()      -- Dibuja balas y nave

        Tunnel.drawFog()   -- Dibuja el degradado negro al centro

        -- Toque subliminal
        if math.random() > 0.98 then
            love.graphics.setColor(1,1,1)
            love.graphics.print("OBEY", math.random(0,200), math.random(0,200), 0, 2, 2)
        end
    love.graphics.pop()

    -- INTERFAZ DE USUARIO
    love.graphics.setColor(1, 1, 1)
    local scoreText = "SUJETO_DATA: " .. score
    love.graphics.print(scoreText, 20, 20, 0, scoreScale, scoreScale)

    -- Pantalla de Game Over
    if gameState == "gameover" then
        love.graphics.setColor(1, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("RECOLECCIÓN FINALIZADA\nPUNTOS: " .. score .. "\n\nPresiona 'R' para Reiniciar",
            0, centerY - 40, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if key == "r" and gameState == "gameover" then
        love.load()
    end
end