local utils = require("utils")

local Game

local color = 26 / 255

local window = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
}


function love.load()
    math.randomseed(os.time())
    Game = require("game").newGame()
    love.graphics.setBackgroundColor(
        color,
        color,
        color
    )
    love.graphics.setDefaultFilter('nearest', 'nearest')
    GameCanvas = love.graphics.newCanvas(800, 600)
end

function love.draw()
    love.graphics.setCanvas(GameCanvas)
    love.graphics.clear()
    Game:drawGame()
    love.graphics.setCanvas()

    window.width = love.graphics.getWidth()
    window.height = love.graphics.getHeight()

    local scale = math.min(
        window.width / Game.width,
        window.height / Game.height
    )

    local offsetX = (window.width - Game.width * scale) / 2
    local offsetY = (window.height - Game.height * scale) / 2

    love.graphics.draw(Game.canvas, offsetX, offsetY, 0, scale, scale)
end

function love.update(dt)
    Game:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    Game:keypressed(key, scancode, isrepeat)
end
