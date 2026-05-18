-- main.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Menu = require("states.menu")
local Game = require("states.game")
local GameOver = require("states.gameover")
local Audio = require("systems.audio")

-- Diccionario de estados
local states = {
    menu = Menu,
    play = Game,
    gameover = GameOver
}

local activeState = nil
local mainCanvas = nil
local crtShader = nil
local globalTime = 0

-- Variables globales esenciales
_G.ScreenW = love.graphics.getWidth()
_G.ScreenH = love.graphics.getHeight()
_G.CenterX = _G.ScreenW / 2
_G.CenterY = _G.ScreenH / 2

-- Función global para cambiar de estado
function _G.ChangeState(stateName, ...)
    if states[stateName] then
        activeState = states[stateName]
        if activeState.load then activeState.load(...) end
    end
end

function love.load()
    Audio.init()
    -- Configuración del Canvas y Shader
    mainCanvas = love.graphics.newCanvas(_G.ScreenW, _G.ScreenH)

    local crtCode = [[
        extern vec2 resolution;
        extern float time;

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
            if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) return vec4(0.0, 0.0, 0.0, 1.0);

            float r = Texel(texture, uv + vec2(0.003, 0.0)).r;
            float g = Texel(texture, uv).g;
            float b = Texel(texture, uv - vec2(0.003, 0.0)).b;

            float scanline = sin(uv.y * resolution.y * 1.5 + time * 5.0) * 0.04;
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
    crtShader:send("resolution", {_G.ScreenW, _G.ScreenH})

    for _, state in pairs(states) do
        if state.init then state.init() end
    end

    ChangeState("menu")
end

function love.update(dt)
    globalTime = globalTime + dt
    if crtShader and crtShader:hasExtern("time") then crtShader:send("time", globalTime) end

    if activeState and activeState.update then
        activeState.update(dt)
    end
end

function love.draw()
    love.graphics.setCanvas(mainCanvas)
    love.graphics.clear()

    if activeState and activeState.draw then
        activeState.draw()
    end

    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(crtShader)
    love.graphics.draw(mainCanvas, 0, 0)
    love.graphics.setShader()
end

function love.keypressed(key)
    if activeState and activeState.keypressed then
        activeState.keypressed(key)
    end
end