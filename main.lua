require("states.menu")
require("states.game")
require("states.gameover")
require("entities.tunnel")
require("entities.player")
require("entities.enemies")

function love.load()
    -- Variables globales
    ScreenW = love.graphics.getWidth()
    ScreenH = love.graphics.getHeight()
    CenterX = ScreenW / 2
    CenterY = ScreenH / 2
    mainCanvas = love.graphics.newCanvas(ScreenW, ScreenH)

    -- SHADER CRT
    local crtCode = [[
        extern vec2 resolution;
        extern float time;

        // Función para curvar las coordenadas UV (Efecto lente de tubo)
        vec2 curve(vec2 uv) {
            uv = (uv - 0.5) * 2.0;
            uv *= 1.1;
            uv.x *= 1.0 + pow((abs(uv.y) / 5.0), 2.0);
            uv.y *= 1.0 + pow((abs(uv.x) / 4.0), 2.0);
            uv  = (uv / 2.0) + 0.5;
            uv =  uv * 0.92 + 0.04;
            return uv;
        }

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec2 uv = curve(texture_coords);

            if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
                return vec4(0.0, 0.0, 0.0, 1.0);
            }

            // Aberración Cromática
            float r = Texel(texture, uv + vec2(0.003, 0.0)).r;
            float g = Texel(texture, uv).g;
            float b = Texel(texture, uv - vec2(0.003, 0.0)).b;

            // Scanlines dinámicas que suben suavemente
            float scanline = sin(uv.y * resolution.y * 1.5 + time * 5.0) * 0.04;
            
            // Viñeteado para oscurecer las esquinas
            float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
            vignette = clamp(pow(16.0 * vignette, 0.25), 0.0, 1.0);

            vec4 finalColor = vec4(r, g, b, 1.0);
            finalColor.rgb -= scanline;
            finalColor.rgb *= vignette;
            finalColor.rgb *= 1.2;

            return finalColor * color;
        }
    ]]

    crtShader = love.graphics.newShader(crtCode)
    crtShader:send("resolution", {ScreenW, ScreenH})
    globalTime = 0

    Menu.load()
    Game.load()
    GameOver.load()

    currentState = "menu"
end

function love.update(dt)
    globalTime = globalTime + dt
    crtShader:send("time", globalTime)
    if currentState == "menu" then Menu.update(dt)
    elseif currentState == "play" then Game.update(dt)
    elseif currentState == "gameover" then GameOver.update(dt)
    end
end

function love.draw()
    love.graphics.setCanvas(mainCanvas)
    love.graphics.clear()
    if currentState == "menu" then Menu.draw()
    elseif currentState == "play" then Game.draw()
    elseif currentState == "gameover" then GameOver.draw()
    end
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(crtShader)
    love.graphics.draw(mainCanvas, 0, 0)
    love.graphics.setShader()
end

function love.keypressed(key)
    if currentState == "menu" then Menu.keypressed(key)
    elseif currentState == "play" then Game.keypressed(key)
    elseif currentState == "gameover" then GameOver.keypressed(key)
    end
end

-- main.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.