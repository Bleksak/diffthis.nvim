local M = {}

local state = require("diffthis.state")
local queue = require("diffthis.undo_queue")

M.undo = function()
    local undo_state = queue.undo(state.current_state.undo.queues, state.current_state.undo.sorting)
    if not undo_state then
        return
    end

    state.current_state.undo.in_undo = true
    vim.api.nvim_buf_set_lines(undo_state.buffer, 0, -1, true, undo_state.buffer_content)
    vim.api.nvim_win_set_cursor(undo_state.window, undo_state.cursor)

    vim.schedule(function()
        state.current_state.undo.in_undo = false
    end)
end

M.redo = function()
    local redo_state = queue.redo(state.current_state.undo.queues, state.current_state.undo.sorting)
    if not redo_state then
        return
    end

    state.current_state.undo.in_undo = true
    vim.api.nvim_buf_set_lines(redo_state.buffer, 0, -1, true, redo_state.buffer_content)
    vim.api.nvim_win_set_cursor(redo_state.window, redo_state.cursor)

    vim.schedule(function()
        state.current_state.undo.in_undo = false
    end)
end

return M
