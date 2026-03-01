local M = {}

function M.tableCopy(t)
    local newT = {}
    for i, v in pairs(t) do
        newT[i] = v
    end

    return newT
end

function M.timeConvert(t)
    local min = t / (60 * 60)
    local sec = t - min * 60

    return {
        min = min,
        sec = sec,
    }
end

return M
