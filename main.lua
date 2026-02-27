local color = 26 / 255
local blockSize = 32
local headerHeight = 30
local grid = {
    x = 10,
    y = 20,
    canvas = nil
}

local window = {
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
}

local game = {
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
    shouldRepeat = false,
}

local inputMap = {
    up = "up",
    left = "left",
    down = "down",
    right = "right",
    rotate = {
        left = "z",
        right = "x"
    },
    quit = { "q", "esc" },
}

local tetrominos = {
    -- I
    {
        { 0, 0, 0, 0 },
        { 1, 1, 1, 1 },
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 },
        color = { 0, 255, 255 }, -- cyan
    },
    -- O
    {
        { 1, 1 },
        { 1, 1 },
        color = { 255, 255, 0 }, -- yellow
    },
    -- T
    {
        { 0, 1, 0 },
        { 1, 1, 1 },
        { 0, 0, 0 },
        color = { 128, 0, 128 }, -- purple
    },
    -- S
    {
        { 0, 1, 1 },
        { 1, 1, 0 },
        { 0, 0, 0 },
        color = { 0, 255, 0 }, -- green
    },
    -- Z
    {
        { 1, 1, 0 },
        { 0, 1, 1 },
        { 0, 0, 0 },
        color = { 255, 0, 0 }, -- red
    },
    -- J
    {
        { 1, 0, 0 },
        { 1, 1, 1 },
        { 0, 0, 0 },
        color = { 0, 0, 255 }, -- blue
    },
    -- L
    {
        { 0, 0, 1 },
        { 1, 1, 1 },
        { 0, 0, 0 },
        color = { 255, 165, 0 } -- orange
    }
}

local function timeConvert(t)
    local min = t / (60 * 60)
    local sec = t - min * 60

    return {
        min = min,
        sec = sec,
    }
end

local function tableCopy(t)
    local newT = {}
    for i = 1, #t do
        newT[i] = t[i]
    end

    return newT
end

local function newBag()
    local tbl = tableCopy(tetrominos)

    local j
    for i = #tbl, 2, -1 do
        j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end

    return tbl
end

function love.load()
    math.randomseed(os.time())
    love.graphics.setBackgroundColor(
        color,
        color,
        color
    )
    love.graphics.setDefaultFilter('nearest', 'nearest')
    game.canvas = love.graphics.newCanvas(800, 600)
    grid.canvas = love.graphics.newCanvas(10 * blockSize, 20 * blockSize)

    game.bag.current = newBag()
    game.bag.next = newBag()

    game.font = love.graphics.newImageFont("res/imagefont.png",
        " 0123456789L:|."
    )
    love.graphics.setFont(game.font)
end

local function drawGrid()
    for x = 0, 9 * blockSize, blockSize do
        for y = 0, blockSize * 2, blockSize do
            love.graphics.rectangle("line", x, y, blockSize, blockSize)
        end
    end

end


local function drawGame()
    love.graphics.setLineWidth(2)
    love.graphics.line(0, headerHeight, game.width, headerHeight)

    love.graphics.circle("fill", game.width / 2, game.height / 2, 50)
    local time = timeConvert(game.timeElapsed)
    love.graphics.setFont(game.font)
    local str = string.format("%dL %.25f", game.linesCleared, time.sec)
    love.graphics.print(string.sub(str, 0, 30), 0, 0, 0, 6)

    love.graphics.setCanvas(grid.canvas)
    drawGrid()
    love.graphics.setCanvas(game.canvas)
    local gridXStart = game.width / 2 - 5 * blockSize
    local gridXEnd = game.width / 2 + 5 * blockSize
    love.graphics.line(gridXStart, headerHeight, gridXStart, game.height)
    love.graphics.draw(grid.canvas, gridXStart, headerHeight)
    love.graphics.line(gridXEnd, headerHeight, gridXEnd, game.height)
end

function love.draw()
    love.graphics.setCanvas(game.canvas)
    love.graphics.clear()
    drawGame()
    love.graphics.setCanvas()

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
    game.timeElapsed = game.timeElapsed + dt

    if game.shouldGetPiece then
        game.currentPiece = table.remove(game.bag.current)
        game.shouldGetPiece = false
    end

    if love.keyboard.isDown(inputMap.up) then
    end
end
