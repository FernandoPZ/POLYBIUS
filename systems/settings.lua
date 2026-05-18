-- systems/settings.lua
-- Gestor de Persistencia de Datos
-- Modificado (2026-05-18)
-- Autor: Fernando Pérez S

local Settings = {}

Settings.data = {
    music = 1.0,
    sfx = 1.0,
    crt = true
}

function Settings.load()
    if love.filesystem.getInfo("settings.txt") then
        for line in love.filesystem.lines("settings.txt") do
            local key, value = line:match("^(%w+)=(.+)$")
            if key and value then
                if value == "true" then Settings.data[key] = true
                elseif value == "false" then Settings.data[key] = false
                elseif tonumber(value) then Settings.data[key] = tonumber(value)
                else Settings.data[key] = value end
            end
        end
    end
end

function Settings.save()
    local str = ""
    for k, v in pairs(Settings.data) do
        str = str .. k .. "=" .. tostring(v) .. "\n"
    end
    love.filesystem.write("settings.txt", str)
end

return Settings