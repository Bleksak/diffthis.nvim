---@class DiffThisUndoItem
---@field buffer number
---@field buffer_content string[]
---@field window number
---@field cursor CursorPos

---@class CursorPos
---@field row number
---@field col number

---@class DiffThisUndoSort
---@field queue DiffThisUndoSortItem[] -- queue of buffers
---@field undos number[] -- number of undos for each buffer

---@class DiffThisUndoSortItem
---@field buffer number

local M = {}

local function get_total_undos(sorting)
    local total = 0

    for _, v in pairs(sorting.undos) do
        total = total + v
    end

    return total
end

local state = require("diffthis.state")

---@param queues DiffThisUndoItem[][]
---@param sorting DiffThisUndoSort
---@param buffer number
M.get_previous = function(queues, sorting, buffer)
    local buffer_undos = sorting.undos[buffer]
    local queue = queues[buffer]
    local queue_item = queue[#queue - buffer_undos]

    return queue_item.buffer_content
end

---@param queue DiffThisUndoItem[]
---@param sorting DiffThisUndoSort
---@param item DiffThisUndoItem
M.push = function(queues, queue, sorting, item)
    local total = get_total_undos(sorting)

    while total > 0 do
        local sort_item = table.remove(sorting.queue, #sorting.queue)
        table.remove(queues[sort_item.buffer], #queues[sort_item.buffer])

        total = total - 1
    end

    sorting.undos[state.current_state.wnd_obj.remote.buffer] = 0
    sorting.undos[state.current_state.wnd_obj.loc.buffer] = 0

    sorting.queue[#sorting.queue + 1] = { buffer = item.buffer }
    queue[#queue + 1] = item
end

---@param queues DiffThisUndoItem[][]
---@param sorting DiffThisUndoSort
M.undo = function(queues, sorting)
    local total = get_total_undos(sorting)

    if total == #sorting.queue - 2 then
        return nil
    end

    local buffer = sorting.queue[#sorting.queue - total].buffer
    local undos = sorting.undos[buffer]
    sorting.undos[buffer] = sorting.undos[buffer] + 1

    local queue_size = #queues[buffer]
    local value = queues[buffer][queue_size - undos - 1]

    return value
end

---@param queues DiffThisUndoItem[][]
---@param sorting DiffThisUndoSort
M.redo = function(queues, sorting)
    local total = get_total_undos(sorting)

    if total == 0 then
        return nil
    end

    local buffer = sorting.queue[#sorting.queue - total].buffer
    local undos = sorting.undos[buffer]
    sorting.undos[buffer] = sorting.undos[buffer] - 1

    local queue_size = #queues[buffer]
    local value = queues[buffer][queue_size - undos + 1]

    return value
end

return M
