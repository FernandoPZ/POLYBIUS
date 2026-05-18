-- states/options.lua
-- Modificado (2026-05-18)
-- Autor: Fernando Pérez S.

local Settings = require("systems.settings")
local Options = {}

local selection = 1
local menuItems = {"music", "sfx", "crt", "back"}

function Options.load()
    selection = 1
end

function Options.update(dt) end

function Options.draw()
    -- Fondo oscurecido
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, _G.ScreenW, _G.ScreenH)

    love.graphics.setColor(0, 1, 0.3)
    love.graphics.printf("CONFIGURACION_DEL_SISTEMA", 0, _G.CenterY - 120, _G.ScreenW, "center")

    local yOffset = _G.CenterY - 40
    local spacing = 40

    for i, item in ipairs(menuItems) do
        local text = ""
        if item == "music" then
            text = "VOLUMEN MUSICA: < " .. math.floor(Settings.data.music * 10) .. " >"
        elseif item == "sfx" then
            text = "VOLUMEN SFX:  < " .. math.floor(Settings.data.sfx * 10) .. " >"
        elseif item == "crt" then
            text = "FILTRO CRT:   < " .. (Settings.data.crt and "ACTIVADO" or "APAGADO") .. " >"
        elseif item == "back" then
            text = "GUARDAR DATOS Y VOLVER"
        end

        if i == selection then
            love.graphics.setColor(1, 1, 0)
            text = "> " .. text .. " <"
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        love.graphics.printf(text, 0, yOffset + (i * spacing), _G.ScreenW, "center")
    end
end

function Options.keypressed(key)
    if key == "up" then
        selection = selection - 1
        if selection < 1 then selection = #menuItems end
    elseif key == "down" then
        selection = selection + 1
        if selection > #menuItems then selection = 1 end
    elseif key == "left" or key == "right" then
        -- Cambiar valores con izquierda/derecha
        local dir = (key == "right") and 1 or -1
        local item = menuItems[selection]

        if item == "music" then
            Settings.data.music = math.max(0, math.min(1, Settings.data.music + (dir * 0.1)))
        elseif item == "sfx" then
            Settings.data.sfx = math.max(0, math.min(1, Settings.data.sfx + (dir * 0.1)))
        elseif item == "crt" then
            Settings.data.crt = not Settings.data.crt
        end
    elseif key == "return" then
        if menuItems[selection] == "back" then
            Settings.save() -- Guarda al disco antes de salir
            _G.ChangeState("menu")
        end
    end
end

return Options