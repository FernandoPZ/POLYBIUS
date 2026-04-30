Tunnel = {}

function Tunnel.load()
    Tunnel.ringSpacing = 60
    Tunnel.ringSpeed = 150
end

function Tunnel.applyDistortion()
    local offsetX = math.sin(timer * 2) * (distortion.intensity * 2)
    local offsetY = math.cos(timer * 1.5) * (distortion.intensity * 2)
    if distortion.shake > 0 then
        offsetX = offsetX + math.random(-distortion.shake, distortion.shake) * 5
        offsetY = offsetY + math.random(-distortion.shake, distortion.shake) * 5
    end
    love.graphics.translate(offsetX, offsetY)
end

function Tunnel.draw()

    local colorGlitch = math.random() > 0.95 - (distortion.intensity * 0.01)
    if colorGlitch then love.graphics.setColor(1, 1, 1) else love.graphics.setColor(0.85, 0.85, 0.85) end
    local tunnelRotation = timer * 0.5
    for i = 0, 7 do
        local lineAngle = i * (math.pi / 4) + tunnelRotation
        love.graphics.line(CenterX, CenterY, CenterX + math.cos(lineAngle) * 1000, CenterY + math.sin(lineAngle) * 1000)
    end

    local offset = (timer * Tunnel.ringSpeed) % Tunnel.ringSpacing
    love.graphics.push()
    love.graphics.translate(CenterX, CenterY)
    love.graphics.rotate(tunnelRotation)
    for i = 0, 12 do
        local radius = (i * Tunnel.ringSpacing) + offset
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
        love.graphics.circle("fill", CenterX, CenterY, r)
    end
end

-- tunnel.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.