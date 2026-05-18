-- systems/physics.lua
-- Motor de Físicas y Colisiones Polares
-- Modificado (2026-05-18)
-- Autor: Fernando Pérez S.

local Physics = {}

local function normalizeAngle(angle)
    return angle % (math.pi * 2)
end

function Physics.getAngleDifference(a1, a2)
    local diff = math.abs(normalizeAngle(a1) - normalizeAngle(a2))
    if diff > math.pi then
        diff = (math.pi * 2) - diff
    end
    return diff
end

function Physics.checkPolarCollision(obj1, obj2, distThreshold, angleThreshold)
    local distDiff = math.abs(obj1.distance - obj2.distance)

    if distDiff < distThreshold then
        local angleDiff = Physics.getAngleDifference(obj1.angle, obj2.angle)

        if angleDiff < angleThreshold then
            return true
        end
    end

    return false
end

return Physics