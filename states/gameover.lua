GameOver = {}

function GameOver.load()
    isNewRecord = false
end

function GameOver.checkRecord()
    isNewRecord = false
    if score > highScore then
        highScore = score
        isNewRecord = true
        love.filesystem.write("highscore.txt", tostring(highScore))
    end
end

function GameOver.update(dt)
end

function GameOver.draw()
    Game.draw()

    love.graphics.setColor(1, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, ScreenW, ScreenH)

    love.graphics.setColor(1, 1, 1)

    -- Notificacion de nuevo record
    if isNewRecord then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("¡NUEVO RÉCORD DE DATOS!", 0, CenterY - 80, ScreenW, "center")
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("NAVE DESTRUIDA\nPUNTOS: " .. score .. "\nRÉCORD MÁXIMO: " .. highScore .. "\n\nPresiona 'R' para Reiniciar\nPresiona 'ESC' para salir al menú",
        0, CenterY - 40, ScreenW, "center")
end

function GameOver.keypressed(key)
    if key == "r" then
        Game.load()
        currentState = "play"
    elseif key == "escape" then
        currentState = "menu"
    end
end

-- states/gameover.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.