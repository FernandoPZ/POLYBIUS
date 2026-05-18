-- states/menu.lua
-- Modificado (2026-05-18)
-- Autor: Fernando Pérez S.

local Menu = {}
local timer = 0
local subliminalText = ""
local subliminalTimer = 0
local highScore = 0

-- Mensajes subliminales
local messages = {"OBEY", "CONSUME", "SLEEP", "INSERT COIN", "NO ESCAPE", "SYSTEM ERROR"}

function Menu.init()
end

function Menu.load()
    timer = 0
    subliminalText = ""
    subliminalTimer = 0

    -- Consulta del récord almacenado (si existe)
    if love.filesystem.getInfo("highscore.txt") then
        highScore = tonumber(love.filesystem.read("highscore.txt")) or 0
    end
end

function Menu.update(dt)
    timer = timer + dt

    -- Lógica de los mensajes subliminales
    if subliminalTimer > 0 then
        subliminalTimer = subliminalTimer - dt
    else
        -- Un 1% de probabilidad por frame de que aparezca un mensaje
        if math.random() > 0.99 then
            subliminalText = messages[math.random(1, #messages)]
            subliminalTimer = 0.05 -- Se muestra solo durante 50 milisegundos (casi invisible)
        else
            subliminalText = ""
        end
    end
end

function Menu.draw()
    -- 1. FONDO HIPNÓTICO (Hexágonos giratorios)
    love.graphics.push()
    love.graphics.translate(_G.CenterX, _G.CenterY)
    love.graphics.rotate(timer * 0.2)
    for i = 1, 10 do
        local radius = (i * 40) + ((timer * 50) % 40)
        local alpha = 1 - (radius / 400) -- Se desvanecen en los bordes
        if alpha > 0 then
            love.graphics.setColor(0.1, 0.8, 0.2, alpha * 0.3) -- Verde fósforo tenue
            love.graphics.circle("line", 0, 0, radius, 6)
        end
    end
    love.graphics.pop()

    -- 2. TÍTULO CON EFECTO DE LATIDO Y GLITCH
    local scale = 3 + math.sin(timer * 4) * 0.1
    local r, g, b = 1, 1, 1

    -- Probabilidad de Glitch de color
    if math.random() > 0.95 then
        r, g, b = math.random(), math.random(), math.random()
    end

    love.graphics.setColor(r, g, b)
    love.graphics.push()
        love.graphics.translate(_G.CenterX, _G.CenterY - 80)
        love.graphics.scale(scale, scale)

        -- Probabilidad de temblor físico (Shake)
        local shakeX = (math.random() > 0.9) and math.random(-3, 3) or 0
        local shakeY = (math.random() > 0.9) and math.random(-3, 3) or 0

        love.graphics.printf("POLYBIUS", -_G.ScreenW/2 + shakeX, shakeY, _G.ScreenW, "center")
    love.graphics.pop()

    -- 3. TEXTO DE INICIO (Parpadeo Clásico Arcade)
    if math.floor(timer * 2.5) % 2 == 0 then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf("Presiona ENTER para comenzar", 0, _G.CenterY + 80, _G.ScreenW, "center")
    end

    -- 4. MENSAJE SUBLIMINAL (Aparece aleatoriamente)
    if subliminalText ~= "" then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.print(subliminalText, math.random(0, _G.ScreenW - 150), math.random(0, _G.ScreenH - 50), 0, 2, 2)
    end

    -- 5. MOSTRAR EL RÉCORD ACTUAL
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("SUJETO MAX DATA: " .. highScore, 0, _G.ScreenH - 40, _G.ScreenW, "center")
end

function Menu.keypressed(key)
    if key == "return" then
        _G.ChangeState("play")
    elseif key == "escape" then
        love.event.quit() -- Permite salir del juego desde el menú principal
    end
end

return Menu