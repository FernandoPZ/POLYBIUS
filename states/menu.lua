Menu = {}

function Menu.load()
    -- Logos y musica pendientes
end

function Menu.update(dt)
    -- Efectos del menu
end

function Menu.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
        love.graphics.translate(CenterX, CenterY - 50)
        love.graphics.scale(3, 3)
        love.graphics.printf("POLYBIUS", -ScreenW/2, 0, ScreenW, "center")
    love.graphics.pop()
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Presiona ENTER para comenzar", 0, CenterY + 50, ScreenW, "center")
end

function Menu.keypressed(key)
    if key == "return" then
        Game.load()
        currentState = "play"
    end
end

-- menu.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.