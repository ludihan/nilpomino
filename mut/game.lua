local utils = require("utils")
local inputMap = require("data.inputMap")
local tetromino = require("data.tetromino")

local M = {}

local headerHeight = 30
local blockSize = 28.5

local function defaultGrid()
    local t = {}
    for y = 1, 20, 1 do
        t[y] = {}
        for x = 1, 10, 1 do
            t[y][x] = false
        end
    end
    t[2][4] = "S*"
    t[3][3] = "S*"
    t[3][4] = "S*"
    t[3][5] = "S*"
    return t
end


local defaultGame = {
    grid = {
        area = defaultGrid(),
        canvas = nil,
    },
    width = 800,
    height = 600,
    canvas = nil,
    font = nil,
    timeElapsed = 0,
    linesCleared = 0,
    shouldGetPiece = false,
    bag = {
        current = nil,
        next = nil,
    },
    input = {
        up = false,
        left = false,
        down = false,
        right = false,
        rotate = {
            left = false,
            right = false
        }
    },
    speed = 1000,
    das = 0.133,
    arr = 0.5,
    shouldRepeat = false,
    timePressingDirection = 0,
}

function M:tryMoveLeft()
    local new = self.grid.area
    for y = 1, #new, 1 do
        for x = 1, #new[y], 1 do
            local v = new[y][x]
            if x - 1 >= 1 and v and type(v) == "string" and v:sub(2, 2) == "*" and not new[y][x - 1] then --moving piece
                print('l')
                new[y][x + 0] = false
                new[y][x - 1] = v
                break
            end
        end
    end
end

function M:tryMoveRight()
    local new = self.grid.area
    for y = 1, #new, 1 do
        for x = 1, #new[y], 1 do
            local v = new[y][x]
            if x + 1 <= 10 and v and type(v) == "string" and v:sub(2, 2) == "*" and not new[y][x + 1] then --moving piece
                print('r')
                new[y][x - 1] = false
                new[y][x + 0] = false
                new[y][x + 1] = v
                break
            end
        end
    end
end

local function newBag()
    local keys = { "I", "O", "T", "S", "Z", "J", "L" }

    for i = #keys, 2, -1 do
        local j = math.random(i)
        keys[i], keys[j] = keys[j], keys[i]
    end

    return keys
end

function M:getNewPiece()
    local piece = table.remove(self.bag.current)
    self.bag.current[#self.bag.current] = table.remove(self.bag.next)
    if #self.bag.next == 0 then
        self.bag.next = newBag()
    end
end

function M:update(dt)
    self.timeElapsed = self.timeElapsed + dt

    if self.shouldGetPiece then
        self:getNewPiece()
        self.shouldGetPiece = false
    end


    if self.timePressingDirection >= self.das then
        if self.lastPressed == inputMap.left then
            self:tryMoveLeft()
        elseif self.lastPressed == inputMap.right then
            self:tryMoveRight()
        end
    end

    if self.lastPressed then
        self.timePressingDirection = self.timePressingDirection + dt
    end

    if not love.keyboard.isDown(inputMap.right) and not love.keyboard.isDown(inputMap.left) then
        self.lastPressed = nil
        self.timePressingDirection = 0
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

    for y = 1, #self.grid.area, 1 do
        for x = 1, #self.grid.area[y], 1 do
            local v = self.grid.area[y][x]
            if type(v) == "string" then
                love.graphics.setColor(tetromino.color[v:sub(1, 1)])
                love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize, blockSize)
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function M:draw()
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear()

    love.graphics.setColor(1, 1, 1, 1)

    local time = utils.secAndMinFromTime(self.timeElapsed)
    love.graphics.setFont(self.font)
    local str = string.format("%dL %.25f", self.linesCleared, time.sec)
    love.graphics.print(string.sub(str, 0, 30), 0, 0, 0, 6)

    love.graphics.setCanvas(self.grid.canvas)
    love.graphics.clear()
    self:drawGrid()

    love.graphics.setCanvas(self.canvas)
    local gridXStart = self.width / 2 - 5 * blockSize
    local gridXEnd = self.width / 2 + 5 * blockSize
    love.graphics.draw(self.grid.canvas, gridXStart, headerHeight)

    love.graphics.setCanvas()
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
        self.shouldRepeat = false
        self.timePressingDirection = 0
        self.lastPressed = inputMap.left
        self:tryMoveLeft()
    end

    if key == inputMap.right then
        self.shouldRepeat = false
        self.timePressingDirection = 0
        self.lastPressed = inputMap.right
        self:tryMoveRight()
    end
end

local function start()
    local newGame = utils.tableCopy(defaultGame)
    newGame.grid.canvas = love.graphics.newCanvas(11 * blockSize, 21 * blockSize)

    newGame.bag.current = newBag()
    newGame.bag.next = newBag()

    newGame.font = love.graphics.newImageFont("res/imagefont.png",
        " 0123456789L:|."
    )
    love.graphics.setFont(newGame.font)

    for k, v in pairs(newGame) do
        M[k] = v
    end

    M.canvas = love.graphics.newCanvas(800, 600)

    M.shouldGetPiece = true
end

start()

return M
