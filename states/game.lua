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

-- Variables del Sistema de Combos
Game.combo = 0
Game.comboTimer = 0
Game.maxComboTimer = 2.5
Game.multiplier = 1

-- Variables para el control de Pausa
local isPaused = false
local pauseSelection = 1
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

    -- Reseteamos combos y pausa al iniciar
    Game.combo = 0
    Game.comboTimer = 0
    Game.multiplier = 1
    isPaused = false
    pauseSelection = 1

    Tunnel.load()
    Player.load()
    Enemies.load()
    Particles.load()
end

function Game.update(dt)
    if isPaused then return end

    if Game.hitStopTimer > 0 then
        Game.hitStopTimer = Game.hitStopTimer - dt
        return
    end

    Game.timer = Game.timer + dt
    Game.scoreScale = math.max(1, Game.scoreScale - dt * 5)
    Game.distortion.shake = math.max(0, Game.distortion.shake - dt * 5)

    -- LÓGICA DE DECADENCIA DEL COMBO
    if Game.comboTimer > 0 then
        Game.comboTimer = Game.comboTimer - dt
        if Game.comboTimer <= 0 then
            Game.combo = 0
            Game.multiplier = 1
        end
    end

    Player.update(dt)
    Enemies.update(dt, Game)
    Particles.update(dt)
end

function Game.draw()
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

    -- UI DEL GAMEPLAY (PUNTAJE Y COMBO)
    love.graphics.setColor(1, 1, 1)
    local scoreText = "SUJETO_DATA: " .. Game.score
    love.graphics.print(scoreText, 20, 20, 0, Game.scoreScale, Game.scoreScale)

    if Game.combo > 0 then
        -- Dibujar el número de combo
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("RÁFAGA: " .. Game.combo, 20, 50, 0, 1.5, 1.5)

        -- Dibujar el multiplicador (Si es mayor a 1, brillamos en rojo)
        if Game.multiplier > 1 then love.graphics.setColor(1, 0.2, 0.2) else love.graphics.setColor(1, 0.5, 0) end
        love.graphics.print("MULTIPLICADOR: x" .. Game.multiplier, 20, 75, 0, 1.2, 1.2)

        -- Dibujar la barra de tiempo decreciente
        local barWidth = 150 * (Game.comboTimer / Game.maxComboTimer)
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", 20, 100, barWidth, 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", 20, 100, 150, 10)
    end

    -- OVERLAY DE PAUSA
    if isPaused then
        love.graphics.setColor(0, 0, 0, 0.75)
        love.graphics.rectangle("fill", 0, 0, _G.ScreenW, _G.ScreenH)

        love.graphics.setColor(0, 1, 0.3)
        love.graphics.printf("SISTEMA_EN_ESPERA (PAUSA)", 0, _G.CenterY - 80, _G.ScreenW, "center")

        for i = 1, #pauseOptions do
            if i == pauseSelection then
                love.graphics.setColor(1, 1, 0)
                love.graphics.printf("> " .. pauseOptions[i] .. " <", 0, _G.CenterY - 10 + (i * 30), _G.ScreenW, "center")
            else
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.printf(pauseOptions[i], 0, _G.CenterY - 10 + (i * 30), _G.ScreenW, "center")
            end
        end
    end
end

function Game.keypressed(key)
    if key == "escape" or key == "p" then
        isPaused = not isPaused
        pauseSelection = 1
        return
    end

    if isPaused then
        if key == "up" then
            pauseSelection = pauseSelection - 1
            if pauseSelection < 1 then pauseSelection = #pauseOptions end
        elseif key == "down" then
            pauseSelection = pauseSelection + 1
            if pauseSelection > #pauseOptions then pauseSelection = 1 end
        elseif key == "return" then
            if pauseSelection == 1 then
                isPaused = false
            elseif pauseSelection == 2 then
                _G.ChangeState("menu")
            end
        end
    end
end

return Game