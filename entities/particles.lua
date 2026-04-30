Particles = {}

function Particles.load()
    Particles.list = {}
end

function Particles.spawn(x, y, colorType)
    local count = colorType == "grande" and 25 or 10
    for i = 1, count do
        local angle = math.random() * math.pi * 2
        local speed = math.random(50, 250)
        table.insert(Particles.list, {
            x = x, y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = 1.0,
            maxLife = 1.0,
            type = colorType
        })
    end
end

function Particles.update(dt)
    for i = #Particles.list, 1, -1 do
        local p = Particles.list[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt * 2.5
        if p.life <= 0 then
            table.remove(Particles.list, i)
        end
    end
end

function Particles.draw()
    for _, p in ipairs(Particles.list) do
        local alpha = p.life / p.maxLife

        if p.type == "grande" then love.graphics.setColor(0.6, 0.1, 0.9, alpha)
        elseif p.type == "nave" then love.graphics.setColor(1, 0.5, 0, alpha)
        else love.graphics.setColor(1, 0.2, 0.2, alpha) end

        love.graphics.line(p.x, p.y, p.x - p.vx * 0.04, p.y - p.vy * 0.04)
    end
end

-- entities/particles.lua
-- Modificado (30/04/2026)
-- Autor: Fernando Pérez S.