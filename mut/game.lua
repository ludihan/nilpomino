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
    timeHoldingPiece = 0,
    linesCleared = 0,
    shouldGetPiece = false,
    bag = {
        current = nil,
        next = nil,
    },
    currentPiece = nil,
    ghost = nil,
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
    speed = 1,
    das = 0.133,
    arr = 0.5,
    shouldRepeat = false,
    timePressingDirection = 0,
}

local function newBag()
    local keys = { "I", "O", "T", "S", "Z", "J", "L" }

    for i = #keys, 2, -1 do
        local j = math.random(i)
        keys[i], keys[j] = keys[j], keys[i]
    end

    return keys
end

local function createPieceBlocks(pieceType, offsetX, offsetY)
    local shape = tetromino.shape[pieceType]
    local blocks = {}
    for y = 1, #shape do
        for x = 1, #shape[y] do
            if shape[y][x] then
                table.insert(blocks, {
                    x = x + offsetX,
                    y = y + offsetY,
                    type = pieceType
                })
            end
        end
    end
    return blocks
end

function M:getNewPiece()
    local piece = table.remove(self.bag.current)
    if #self.bag.current == 0 then
        self.bag.current = self.bag.next
        self.bag.next = newBag()
    end
    self:spawnPiece(piece)
end

function M:spawnPiece(piece)
    self.currentPiece = createPieceBlocks(piece, 3, 0)
    self.ghost = self:cordsGhostPiece()
end

function M:tryMoveLeft()
    if not self.currentPiece then return end

    for _, v in ipairs(self.currentPiece) do
        if v.x - 1 < 1 then
            return
        end
        if self.grid.area[v.y] and self.grid.area[v.y][v.x - 1] then
            return
        end
    end

    for _, v in ipairs(self.currentPiece) do
        v.x = v.x - 1
    end

    self.ghost = self:cordsGhostPiece()
end

function M:tryMoveRight()
    if not self.currentPiece then return end

    for _, v in ipairs(self.currentPiece) do
        if v.x + 1 > 10 then
            return
        end
        if self.grid.area[v.y] and self.grid.area[v.y][v.x + 1] then
            return
        end
    end

    for _, v in ipairs(self.currentPiece) do
        v.x = v.x + 1
    end

    self.ghost = self:cordsGhostPiece()
end

function M:update(dt)
    self.timeElapsed = self.timeElapsed + dt
    self.timeHoldingPiece = self.timeHoldingPiece + dt

    if self.shouldGetPiece then
        self:placePiece()
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

    if self.timeHoldingPiece >= self.speed then
        M:pieceDescent()
        self.timeHoldingPiece = 0
    end
end

function M:pieceDescent()
    if not self.currentPiece then return end

    for _, v in ipairs(self.currentPiece) do
        if v.y + 1 > 20 then
            self.shouldGetPiece = true
            return
        end
        if self.grid.area[v.y + 1] and self.grid.area[v.y + 1][v.x] then
            self.shouldGetPiece = true
            return
        end
    end

    for _, v in ipairs(self.currentPiece) do
        v.y = v.y + 1
    end

    self.ghost = self:cordsGhostPiece()
end

function M:placePiece()
    if not self.currentPiece then return end

    for _, v in ipairs(self.currentPiece) do
        if v.y >= 1 and v.y <= 20 and v.x >= 1 and v.x <= 10 then
            self.grid.area[v.y][v.x] = v.type
        end
    end
    self.currentPiece = nil
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
            if v then
                love.graphics.setColor(tetromino.color[v])
                love.graphics.rectangle("fill", (x - 1) * blockSize, (y - 1) * blockSize, blockSize, blockSize)
            end
        end
    end

    if self.ghost then
        for _, v in ipairs(self.ghost) do
            local c = {
                tetromino.color[v.type][1],
                tetromino.color[v.type][2],
                tetromino.color[v.type][3],
                0.9
            }
            love.graphics.setColor(c)
            love.graphics.rectangle("fill", (v.x - 1) * blockSize, (v.y - 1) * blockSize, blockSize, blockSize)
        end
    end

    if self.currentPiece then
        for _, v in ipairs(self.currentPiece) do
            love.graphics.setColor(tetromino.color[v.type])
            love.graphics.rectangle("fill", (v.x - 1) * blockSize, (v.y - 1) * blockSize, blockSize, blockSize)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function M:cordsGhostPiece()
    if not self.currentPiece then return nil end

    local cords = {}
    for _, v in ipairs(self.currentPiece) do
        table.insert(cords, { x = v.x, y = v.y, type = v.type })
    end

    local canMove = true
    while canMove do
        for _, v in ipairs(cords) do
            if v.y + 1 > 20 then
                canMove = false
                break
            end
            if self.grid.area[v.y + 1] and self.grid.area[v.y + 1][v.x] then
                canMove = false
                break
            end
        end
        if canMove then
            for _, v in ipairs(cords) do
                v.y = v.y + 1
            end
        else
            break
        end
    end
    return cords
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
