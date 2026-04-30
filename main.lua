require("states.menu")
require("states.game")
require("states.gameover")
require("entities.tunnel")
require("entities.player")
require("entities.enemies")

function love.load()
    -- Variables globales útiles para todos los archivos
    ScreenW = love.graphics.getWidth()
    ScreenH = love.graphics.getHeight()
    CenterX = ScreenW / 2
    CenterY = ScreenH / 2

    -- Inicializamos todas las escenas
    Menu.load()
    Game.load()
    GameOver.load()

    -- Variable de control de estado
    currentState = "menu" -- Opciones: "menu", "play", "gameover", "pause"
end

function love.update(dt)
    if currentState == "menu" then
        Menu.update(dt)
    elseif currentState == "play" then
        Game.update(dt)
    elseif currentState == "gameover" then
        GameOver.update(dt)
    end
end

function love.draw()
    if currentState == "menu" then
        Menu.draw()
    elseif currentState == "play" then
        Game.draw()
    elseif currentState == "gameover" then
        GameOver.draw()
    end
end

function love.keypressed(key)
    if currentState == "menu" then
        Menu.keypressed(key)
    elseif currentState == "play" then
        Game.keypressed(key)
    elseif currentState == "gameover" then
        GameOver.keypressed(key)
    end
end

-- main.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.