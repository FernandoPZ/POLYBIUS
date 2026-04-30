GameOver = {}

function GameOver.load()
end

function GameOver.update(dt)
end

function GameOver.draw()
    Game.draw()
    love.graphics.setColor(1, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, ScreenW, ScreenH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("NAVE DESTRUIDA\nPUNTOS: " .. score .. "\n\nPresiona 'R' para Reiniciar\nPresiona 'ESC' para salir al menú",
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

-- gameover.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.