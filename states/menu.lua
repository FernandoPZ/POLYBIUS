-- states/menu.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Menu = {}

function Menu.load()
end

function Menu.update(dt)
end

function Menu.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.push()
        love.graphics.translate(_G.CenterX, _G.CenterY - 50)
        love.graphics.scale(3, 3)
        love.graphics.printf("POLYBIUS", -_G.ScreenW/2, 0, _G.ScreenW, "center")
    love.graphics.pop()

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.printf("Presiona ENTER para comenzar", 0, _G.CenterY + 50, _G.ScreenW, "center")
end

function Menu.keypressed(key)
    if key == "return" then
        _G.ChangeState("play")
    end
end

return Menu