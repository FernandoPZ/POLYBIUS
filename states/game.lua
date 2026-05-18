-- states/game.lua
-- Modificado (2026-05-18)
-- Autor: Fernando Pérez S.

local Tunnel = require("entities.tunnel")
local Player = require("entities.player")
local Enemies = require("entities.enemies")
local Particles = require("entities.particles")

local Game = {}

-- Variables de estado del juego
Game.score = 0
Game.scoreScale = 1
Game.hitStopTimer = 0
Game.highScore = 0
Game.timer = 0
Game.distortion = { shake = 0, intensity = 0 }

-- NUEVAS: Variables para el control de Pausa
local isPaused = false
local pauseSelection = 1 -- 1 = Continuar, 2 = Salir
local pauseOptions = {"CONTINUAR_PROCESO", "ABORTAR_MISION"}

function Game.init()
    if love.filesystem.getInfo("highscore.txt") then
        local data = love.filesystem.read("highscore.txt")
        Game.highScore = tonumber(data) or 0
    end
end

function Game.load()
    Game.timer = 0
    Game.score = 0
    Game.scoreScale = 1
    Game.distortion.shake = 0
    Game.distortion.intensity = 0
    Game.hitStopTimer = 0

    -- Reseteamos la pausa cada vez que inicia una partida nueva
    isPaused = false
    pauseSelection = 1

    Tunnel.load()
    Player.load()
    Enemies.load()
    Particles.load()
end

function Game.update(dt)
    -- SI EL JUEGO ESTÁ PAUSADO, SE DETIENE TODA LA LÓGICA
    if isPaused then
        return
    end

    -- Lógica de HitStop (Congelación por impacto)
    if Game.hitStopTimer > 0 then
        Game.hitStopTimer = Game.hitStopTimer - dt
        return
    end

    Game.timer = Game.timer + dt
    Game.scoreScale = math.max(1, Game.scoreScale - dt * 5)
    Game.distortion.shake = math.max(0, Game.distortion.shake - dt * 5)

    Player.update(dt)
    Enemies.update(dt, Game)
    Particles.update(dt)
end

function Game.draw()
    -- 1. DIBUJAMOS EL JUEGO NORMAL EN EL FONDO
    love.graphics.push()
        Tunnel.applyDistortion(Game.timer, Game.distortion)

        Tunnel.draw(Game.timer, Game.distortion)
        Enemies.draw(Game.timer)
        Particles.draw()
        Player.draw()

        Tunnel.drawFog()

        if math.random() > 0.98 and not isPaused then
            love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.print("OBEY", math.random(0,200), math.random(0,200), 0, 2, 2)
        end
    love.graphics.pop()

    -- UI del gameplay
    love.graphics.setColor(1, 1, 1)
    local scoreText = "SUJETO_DATA: " .. Game.score
    love.graphics.print(scoreText, 20, 20, 0, Game.scoreScale, Game.scoreScale)

    -- 2. SI ESTÁ PAUSADO, DIBUJAMOS UNA CAPA SUPERPUESTA (OVERLAY)
    if isPaused then
        -- Capa oscura semitransparente para contrastar el menú
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 0, 0, _G.ScreenW, _G.ScreenH)

        -- Título del menú de pausa
        love.graphics.setColor(0, 1, 0.3) -- Color verde terminal
        love.graphics.printf("SISTEMA_EN_ESPERA (PAUSA)", 0, _G.CenterY - 80, _G.ScreenW, "center")

        -- Dibujamos las opciones del menú
        for i = 1, #pauseOptions do
            if i == pauseSelection then
                -- Opción seleccionada: Brilla en amarillo y tiene un indicador ">"
                love.graphics.setColor(1, 1, 0)
                love.graphics.printf("> " .. pauseOptions[i] .. " <", 0, _G.CenterY - 10 + (i * 30), _G.ScreenW, "center")
            else
                -- Opción normal: Texto gris estático
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.printf(pauseOptions[i], 0, _G.CenterY - 10 + (i * 30), _G.ScreenW, "center")
            end
        end
    end
end

function Game.keypressed(key)
    -- Si presionas ESCAPE o 'P', alternas el estado de pausa
    if key == "escape" or key == "p" then
        isPaused = not isPaused
        pauseSelection = 1 -- Reinicia la selección al pausar
        return
    end

    -- CONTROLES EXCLUSIVOS CUANDO EL JUEGO ESTÁ PAUSADO
    if isPaused then
        if key == "up" then
            pauseSelection = pauseSelection - 1
            if pauseSelection < 1 then pauseSelection = #pauseOptions end
        elseif key == "down" then
            pauseSelection = pauseSelection + 1
            if pauseSelection > #pauseOptions then pauseSelection = 1 end
        elseif key == "return" then
            -- Ejecutar la opción seleccionada al presionar ENTER
            if pauseSelection == 1 then
                isPaused = false -- Continuar juego
            elseif pauseSelection == 2 then
                _G.ChangeState("menu") -- Regresar al menú principal
            end
        end
    end
end

return Game