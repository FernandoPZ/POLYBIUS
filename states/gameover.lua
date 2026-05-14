-- states/gameover.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local GameOver = {}

local finalScore = 0
local highScore = 0
local isNewRecord = false

function GameOver.init()
    if love.filesystem.getInfo("highscore.txt") then
        highScore = tonumber(love.filesystem.read("highscore.txt")) or 0
    end
end

function GameOver.load(score)
    finalScore = score or 0
    isNewRecord = false

    if finalScore > highScore then
        highScore = finalScore
        isNewRecord = true
        love.filesystem.write("highscore.txt", tostring(highScore))
    end
end

function GameOver.update(dt)
end

function GameOver.draw()
    love.graphics.setColor(1, 0, 0, 0.2)
    love.graphics.rectangle("fill", 0, 0, _G.ScreenW, _G.ScreenH)

    if isNewRecord then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("¡NUEVO RÉCORD DE DATOS!", 0, _G.CenterY - 80, _G.ScreenW, "center")
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("NAVE DESTRUIDA\nPUNTOS: " .. finalScore .. "\nRÉCORD MÁXIMO: " .. highScore .. "\n\nPresiona 'R' para Reiniciar\nPresiona 'ESC' para salir al menú",
        0, _G.CenterY - 40, _G.ScreenW, "center")
end

function GameOver.keypressed(key)
    if key == "r" then
        _G.ChangeState("play")
    elseif key == "escape" then
        _G.ChangeState("menu")
    end
end

return GameOver