Game = {}

function Game.load()
    -- Variables específicas de la partida
    timer = 0
    score = 0
    scoreScale = 1
    distortion = { shake = 0, intensity = 0 }
    -- Cargar las entidades
    Tunnel.load()
    Player.load()
    Enemies.load()
end

function Game.update(dt)
    timer = timer + dt
    scoreScale = math.max(1, scoreScale - dt * 5)
    distortion.shake = math.max(0, distortion.shake - dt * 5)

    Player.update(dt)
    Enemies.update(dt)
end

function Game.draw()
    love.graphics.push()
        Tunnel.applyDistortion()

        Tunnel.draw()
        Enemies.draw()
        Player.draw()

        Tunnel.drawFog()

        if math.random() > 0.98 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("OBEY", math.random(0,200), math.random(0,200), 0, 2, 2)
        end
    love.graphics.pop()

    -- Marcador
    love.graphics.setColor(1, 1, 1)
    local scoreText = "SUJETO_DATA: " .. score
    love.graphics.print(scoreText, 20, 20, 0, scoreScale, scoreScale)
end

function Game.keypressed(key)
    if key == "escape" then
    end
end

-- game.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.