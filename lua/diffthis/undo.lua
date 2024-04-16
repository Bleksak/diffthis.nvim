local M = {}

local state = require("diffthis.state")
local queue = require("diffthis.undo_queue")

M.undo = function()
    local undo_state = queue.undo(state.current_state.undo.queues, state.current_state.undo.sorting)
    if not undo_state then
        return
    end

    vim.api.nvim_buf_set_lines(undo_state.buffer, 0, -1, true, undo_state.buffer_content)
end

M.redo = function()
    -- local redo_state = queue.redo(state.current_state.undo_sort)
    -- if not redo_state then
    --     return
    -- end
    --
    -- vim.api.nvim_buf_set_lines(redo_state.buffer, 0, -1, true, redo_state.buffer_content)
end

return M
