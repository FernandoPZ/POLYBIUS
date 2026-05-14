-- entities/tunnel.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Tunnel = {}

local ringSpacing = 60
local ringSpeed = 150

function Tunnel.load()
    -- Listo por si necesitas reiniciar propiedades del túnel en el futuro
end

function Tunnel.applyDistortion(timer, distortion)
    local offsetX = math.sin(timer * 2) * (distortion.intensity * 2)
    local offsetY = math.cos(timer * 1.5) * (distortion.intensity * 2)

    if distortion.shake > 0 then
        offsetX = offsetX + math.random(-distortion.shake, distortion.shake) * 5
        offsetY = offsetY + math.random(-distortion.shake, distortion.shake) * 5
    end

    love.graphics.translate(offsetX, offsetY)
end

function Tunnel.draw(timer, distortion)
    local colorGlitch = math.random() > 0.95 - (distortion.intensity * 0.01)
    if colorGlitch then love.graphics.setColor(1, 1, 1) else love.graphics.setColor(0.85, 0.85, 0.85) end

    local tunnelRotation = timer * 0.5
    for i = 0, 7 do
        local lineAngle = i * (math.pi / 4) + tunnelRotation
        love.graphics.line(_G.CenterX, _G.CenterY, _G.CenterX + math.cos(lineAngle) * 1000, _G.CenterY + math.sin(lineAngle) * 1000)
    end

    local offset = (timer * ringSpeed) % ringSpacing
    love.graphics.push()
    love.graphics.translate(_G.CenterX, _G.CenterY)
    love.graphics.rotate(tunnelRotation)

    for i = 0, 12 do
        local radius = (i * ringSpacing) + offset
        local alpha = math.min(1, radius / 200)
        if colorGlitch then love.graphics.setColor(1, 1, 1, alpha) else love.graphics.setColor(0.85, 0.85, 0.85, alpha) end
        love.graphics.circle("line", 0, 0, radius, 8)
    end

    love.graphics.pop()
end

function Tunnel.drawFog()
    for r = 80, 0, -10 do
        local alpha = 1 - (r / 80)
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.circle("fill", _G.CenterX, _G.CenterY, r)
    end
end

return Tunnel