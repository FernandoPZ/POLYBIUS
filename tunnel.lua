Tunnel = {}

function Tunnel.load()
    -- Variables para los anillos de profundidad
    Tunnel.ringSpacing = 60
    Tunnel.ringSpeed = 150
end

function Tunnel.applyDistortion()
    -- 1. Movimiento suave
    local offsetX = math.sin(timer * 2) * (distortion.intensity * 2)
    local offsetY = math.cos(timer * 1.5) * (distortion.intensity * 2)
    -- 2. Sacudida violenta
    if distortion.shake > 0 then
        offsetX = offsetX + math.random(-distortion.shake, distortion.shake) * 5
        offsetY = offsetY + math.random(-distortion.shake, distortion.shake) * 5
    end
    love.graphics.translate(offsetX, offsetY)
end

function Tunnel.draw()
    local colorGlitch = math.random() > 0.95 - (distortion.intensity * 0.01)
    -- Color base del túnel
    if colorGlitch then love.graphics.setColor(1, 0, 1) else love.graphics.setColor(0, 1, 0) end
    -- 1. DIBUJA LÍNEAS RADIALES
    local tunnelRotation = timer * 0.5
    for i = 0, 7 do
        local lineAngle = i * (math.pi / 4) + tunnelRotation
        love.graphics.line(centerX, centerY, centerX + math.cos(lineAngle) * 1000, centerY + math.sin(lineAngle) * 1000)
    end
    -- 2. DIBUJAR ANILLOS DE PROFUNDIDAD
    local offset = (timer * Tunnel.ringSpeed) % Tunnel.ringSpacing

    love.graphics.push()
    love.graphics.translate(centerX, centerY)
    love.graphics.rotate(tunnelRotation) -- Rotar igual que las líneas para que encajen

    for i = 0, 12 do
        local radius = (i * Tunnel.ringSpacing) + offset

        -- Los anillos son más transparentes cuando están lejos (en el centro)
        local alpha = math.min(1, radius / 200)
        if colorGlitch then love.graphics.setColor(1, 0, 1, alpha) else love.graphics.setColor(0, 1, 0, alpha) end

        love.graphics.circle("line", 0, 0, radius, 8)
    end
    love.graphics.pop()
end

function Tunnel.drawFog()
    -- 3. EFECTO DE DIFUMINACIÓN CENTRAL
    for r = 80, 0, -10 do
        local alpha = 1 - (r / 80)
        love.graphics.setColor(0, 0, 0, alpha)
        love.graphics.circle("fill", centerX, centerY, r)
    end
end

