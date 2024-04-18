local M = {}

local state = require("diffthis.state")
local queue = require("diffthis.undo_queue")
local undo = require("diffthis.undo")

M.setup = function(bufnr)
    vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        buffer = bufnr,
        callback = function()
            if state.current_state.undo.in_undo then
                return
            end

            local previous_content = queue.get_previous(
                state.current_state.undo.queues,
                state.current_state.undo.sorting,
                bufnr
            )

            local current_content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)

            if vim.deep_equal(previous_content, current_content) then
                return
            end

            local cursor = vim.api.nvim_win_get_cursor(0)

            queue.push(
                state.current_state.undo.queues,
                state.current_state.undo.queues[bufnr],
                state.current_state.undo.sorting,
                {
                    buffer = bufnr,
                    buffer_content = current_content,
                    window = vim.api.nvim_get_current_win(),
                    cursor = cursor
                }
            )
        end
    })

    vim.api.nvim_create_user_command("DiffThisUndo", function()
        undo.undo()
    end, {})

    vim.api.nvim_create_user_command("DiffThisRedo", function()
        undo.redo()
    end, {})
end

return M
