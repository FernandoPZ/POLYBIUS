-- states/game.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Tunnel = require("entities.tunnel")
local Player = require("entities.player")
local Enemies = require("entities.enemies")
local Particles = require("entities.particles")

local Game = {}

-- Variables de estado
Game.score = 0
Game.scoreScale = 1
Game.hitStopTimer = 0
Game.highScore = 0
Game.timer = 0
Game.distortion = { shake = 0, intensity = 0 }

function Game.init()
    -- Cargar highscore
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

    Tunnel.load()
    Player.load()
    Enemies.load()
    Particles.load()
end

function Game.update(dt)
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
    love.graphics.push()
        Tunnel.applyDistortion(Game.timer, Game.distortion)

        Tunnel.draw(Game.timer, Game.distortion)
        Enemies.draw(Game.timer)
        Particles.draw()
        Player.draw()

        Tunnel.drawFog()

        -- Efecto Subliminal "OBEY"
        if math.random() > 0.98 then
            love.graphics.setColor(1, 1, 1, 0.3)
            love.graphics.print("OBEY", math.random(0,200), math.random(0,200), 0, 2, 2)
        end
    love.graphics.pop()

    -- UI
    love.graphics.setColor(1, 1, 1)
    local scoreText = "SUJETO_DATA: " .. Game.score
    love.graphics.print(scoreText, 20, 20, 0, Game.scoreScale, Game.scoreScale)
end

function Game.keypressed(key)
    if key == "escape" then ChangeState("menu") end
end

return Game