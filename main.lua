local utils = require("utils")

local game

local color = 26 / 255

local window = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
}


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    game = require("game")
    print(game)
    love.graphics.setBackgroundColor(
        color,
        color,
        color
    )
end

function love.draw()
    game:draw()

    window.width = love.graphics.getWidth()
    window.height = love.graphics.getHeight()

    local scale = math.min(
        window.width / game.width,
        window.height / game.height
    )

    local offsetX = (window.width - game.width * scale) / 2
    local offsetY = (window.height - game.height * scale) / 2

    love.graphics.draw(game.canvas, offsetX, offsetY, 0, scale, scale)
end

function love.update(dt)
    game:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
    game:keypressed(key, scancode, isrepeat)
end
