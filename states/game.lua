require("entities.particles")

Game = {}

function Game.load()
    timer = 0
    score = 0
    scoreScale = 1
    distortion = { shake = 0, intensity = 0 }

    Game.hitStopTimer = 0

    highScore = 0
    if love.filesystem.getInfo("highscore.txt") then
        local data = love.filesystem.read("highscore.txt")
        highScore = tonumber(data) or 0
    end

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

    timer = timer + dt
    scoreScale = math.max(1, scoreScale - dt * 5)
    distortion.shake = math.max(0, distortion.shake - dt * 5)

    Player.update(dt)
    Enemies.update(dt)
    Particles.update(dt)
end

function Game.draw()
    love.graphics.push()
        Tunnel.applyDistortion()

        Tunnel.draw()
        Enemies.draw()
        Particles.draw()
        Player.draw()

        Tunnel.drawFog()

        if math.random() > 0.98 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("OBEY", math.random(0,200), math.random(0,200), 0, 2, 2)
        end
    love.graphics.pop()

    love.graphics.setColor(1, 1, 1)
    local scoreText = "SUJETO_DATA: " .. score
    love.graphics.print(scoreText, 20, 20, 0, scoreScale, scoreScale)
end

function Game.keypressed(key)
    if key == "escape" then
        -- Futuro menú de pausa
    end
end

-- states/game.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.