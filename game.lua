local utils = require("utils")

local M = {}

local headerHeight = 30
local blockSize = 28.5

local inputMap = {
    drop = {
        hard = "space",
        soft = "down",
    },
    rotate = {
        left = "a",
        right = "s",
        double = "up",
    },
    left = "left",
    right = "right",
    restart = "r",
    rebind = "f1",
    quit = "escape",
}

local defaultGame = {
    grid = {
        area = {
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
        },
        canvas = nil
    },
    width = 800,
    height = 600,
    canvas = nil,
    font = nil,
    timeElapsed = 0,
    linesCleared = 0,
    currentPiece = nil,
    shouldGetPiece = false,
    bag = {
        current = nil,
        next = nil,
    },
    input = {
        current = nil,
        up = false,
        left = false,
        down = false,
        right = false,
        rotate = {
            left = false,
            right = false
        }
    },
    das = 133,
    arr = 5,
    ticks = 0,
    lastDirection = nil,
    shouldRepeat = false,
}

local function newBag()
    local keys = { "I", "O", "T", "S", "Z", "J", "L" }

    for i = #keys, 2, -1 do
        local j = math.random(i)
        keys[i], keys[j] = keys[j], keys[i]
    end

    return keys
end

function M.newGame()
    local game = utils.tableCopy(defaultGame)
    game.grid.canvas = love.graphics.newCanvas(11 * blockSize, 21 * blockSize)

    game.bag.current = newBag()
    game.bag.next = newBag()

    game.font = love.graphics.newImageFont("res/imagefont.png",
        " 0123456789L:|."
    )
    love.graphics.setFont(game.font)

    return game
end

function M:update(dt)
    self:update(dt)
    self.timeElapsed = self.timeElapsed + dt

    if self.shouldGetPiece then
        self.currentPiece = table.remove(self.bag.current)
        self.shouldGetPiece = false
    end

    if self.lastPressed then
        self.ticks = self.ticks + dt
    end

    if not love.keyboard.isDown(inputMap.right) and not love.keyboard.isDown(inputMap.left) then
        self.lastPressed = nil
        self.ticks = 0
    end
end

function M:drawGrid()
    love.graphics.setColor(1, 1, 1, 0.8)
    for x = 0, 11 * blockSize, blockSize do
        love.graphics.line(x, 0, x, self.height)
    end
    local maxW = 10 * blockSize

    for y = 0, 20 * blockSize, blockSize do
        love.graphics.line(0, y, maxW, y)
    end

    local currentPiece = table.remove(self.bag.current)
end

function M:drawGame()
    -- love.graphics.line(0, headerHeight, game.width, headerHeight)
    love.graphics.setColor(1, 1, 1, 1)

    local time = utils.timeConvert(self.timeElapsed)
    love.graphics.setFont(self.font)
    local str = string.format("%dL %.25f", self.linesCleared, time.sec)
    love.graphics.print(string.sub(str, 0, 30), 0, 0, 0, 6)

    love.graphics.setCanvas(self.grid.canvas)
    self:drawGrid()
    love.graphics.setCanvas(self.canvas)
    local gridXStart = self.width / 2 - 5 * blockSize
    local gridXEnd = self.width / 2 + 5 * blockSize
    love.graphics.draw(self.grid.canvas, gridXStart, headerHeight)
end

local function rebindKeys()
end

function M:keypressed(key, scancode, isrepeat)
    if key == inputMap.quit then
        love.event.quit()
    elseif key == inputMap.restart then
        love.load()
    elseif key == inputMap.rebind then
        rebindKeys()
    end

    if key == inputMap.left then
        self.ticks = 0
        self.lastPressed = inputMap.left
    end

    if key == inputMap.right then
        self.ticks = 0
        self.lastPressed = inputMap.right
    end
end

return M
