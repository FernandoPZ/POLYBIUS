-- systems/audio.lua
local Audio = {}

Audio.sfx = {}
Audio.music = {}
local currentMusic = nil

function Audio.init()
    -- Aquí cargaremos los archivos. 
    -- Se asume que crearás una carpeta 'assets/sounds/' en el futuro.

    -- EJEMPLOS DE CARGA (Comentados para que el juego no falle si no tienes los archivos aún):
    -- Audio.sfx.shoot = love.audio.newSource("assets/sounds/shoot.wav", "static")
    -- Audio.sfx.explosion = love.audio.newSource("assets/sounds/explosion.wav", "static")
    -- Audio.sfx.hit = love.audio.newSource("assets/sounds/hit.wav", "static")

    -- Audio.music.game_bgm = love.audio.newSource("assets/sounds/bgm.ogg", "stream")
end

-- Reproducir Efectos de Sonido
function Audio.playSFX(name)
    if Audio.sfx[name] then
        -- Clonamos la fuente de sonido para que los disparos rápidos se superpongan
        local sound = Audio.sfx[name]:clone()
        love.audio.play(sound)
    end
end

-- Reproducir Música de Fondo
function Audio.playMusic(name, loop)
    if Audio.music[name] then
        -- Si ya hay una canción sonando, la detenemos
        if currentMusic then
            love.audio.stop(currentMusic)
        end

        currentMusic = Audio.music[name]
        currentMusic:setLooping(loop == nil and true or loop) -- Por defecto hace loop
        love.audio.play(currentMusic)
    end
end

-- Detener Música
function Audio.stopMusic()
    if currentMusic then
        love.audio.stop(currentMusic)
    end
end

return Audio