-- entities/particles.lua
-- Modificado (2026-05-14)
-- Autor: Fernando Pérez S.

local Particles = {}

Particles.pool = {}
local MAX_PARTICLES = 300

function Particles.load()
    Particles.pool = {}
    for i = 1, MAX_PARTICLES do
        table.insert(Particles.pool, {
            active = false,
            x = 0, y = 0, vx = 0, vy = 0,
            life = 0, maxLife = 1.0, type = ""
        })
    end
end

local function getInactiveParticle()
    for i = 1, MAX_PARTICLES do
        if not Particles.pool[i].active then
            return Particles.pool[i]
        end
    end
    return nil
end

function Particles.spawn(x, y, colorType)
    local count = colorType == "grande" and 25 or 10
    for i = 1, count do
        local p = getInactiveParticle()
        if p then
            local angle = math.random() * math.pi * 2
            local speed = math.random(50, 250)

            p.active = true
            p.x = x
            p.y = y
            p.vx = math.cos(angle) * speed
            p.vy = math.sin(angle) * speed
            p.life = 1.0
            p.maxLife = 1.0
            p.type = colorType
        else
            break
        end
    end
end

function Particles.update(dt)
    for i = 1, MAX_PARTICLES do
        local p = Particles.pool[i]
        if p.active then
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            p.life = p.life - dt * 2.5
            if p.life <= 0 then
                p.active = false
            end
        end
    end
end

function Particles.draw()
    for i = 1, MAX_PARTICLES do
        local p = Particles.pool[i]
        if p.active then
            local alpha = p.life / p.maxLife

            if p.type == "grande" then love.graphics.setColor(0.6, 0.1, 0.9, alpha)
            elseif p.type == "nave" then love.graphics.setColor(1, 0.5, 0, alpha)
            else love.graphics.setColor(1, 0.2, 0.2, alpha) end

            love.graphics.line(p.x, p.y, p.x - p.vx * 0.04, p.y - p.vy * 0.04)
        end
    end
end

return Particles