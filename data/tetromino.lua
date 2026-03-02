local M = {}

local f = false
local T = true

M.shape = {
    I = {
        { f, f, f, f },
        { T, T, T, T },
        { f, f, f, f },
        { f, f, f, f },
    },
    O = {
        { f, T, T, f },
        { f, T, T, f },
    },
    T = {
        { f, T, f },
        { T, T, T },
        { f, f, f },
    },
    S = {
        { f, T, T },
        { T, T, f },
        { f, f, f },
    },
    Z = {
        { T, T, f },
        { f, T, T },
        { f, f, f },
    },
    J = {
        { T, f, f },
        { T, T, T },
        { f, f, f },
    },
    L = {
        { f, f, T },
        { T, T, T },
        { f, f, f },
    },
}

M.color = {
    I = { 0, 255, 255 }, -- cyan
    O = { 255, 255, 0 }, -- yellow
    T = { 128, 0, 128 }, -- purple
    S = { 0, 255, 0 },   -- green
    Z = { 255, 0, 0 },   -- red
    J = { 0, 0, 255 },   -- blue
    L = { 255, 165, 0 }, -- orange
}

return M
