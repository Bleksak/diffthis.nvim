local config = require("diffthis.config")
local M = {}

local state = require("diffthis.state")
local undo = require("diffthis.undo")
local undo_queue = require("diffthis.undo_queue")

M.set_keys = function(bufnr, is_remote)
    local keys = config.config.keys

    if is_remote then
        vim.keymap.set("n", keys.obtain, function()
            vim.cmd("diffget")
            undo_queue.push(state.current_state.undo.queues, state.current_state.undo.queues[bufnr], state.current_state.undo.sorting,
                { buffer = bufnr, buffer_content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true) })
        end, { buffer = bufnr })

        vim.keymap.set("n", keys.put, function()
            vim.cmd("diffput")
            undo_queue.push(state.current_state.undo.queues, state.current_state.undo.queues[state.current_state.wnd_obj.loc.buffer], state.current_state.undo.sorting,
                { buffer = state.current_state.wnd_obj.loc.buffer, buffer_content = vim.api.nvim_buf_get_lines(state.current_state.wnd_obj.loc.buffer, 0, -1, true) })
        end, { buffer = bufnr })
    else
        vim.keymap.set("n", keys.obtain, function()
            vim.cmd("diffput")
            undo_queue.push(state.current_state.undo.queues, state.current_state.undo.queues[bufnr], state.current_state.undo.sorting,
                { buffer = bufnr, buffer_content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true) })
        end, { buffer = bufnr })

        vim.keymap.set("n", keys.put, function()
            vim.cmd("diffget")
            undo_queue.push(state.current_state.undo.queues, state.current_state.undo.queues[state.current_state.wnd_obj.remote.buffer], state.current_state.undo.sorting,
                { buffer = state.current_state.wnd_obj.remote.buffer, buffer_content = vim.api.nvim_buf_get_lines(state.current_state.remote.loc.buffer, 0, -1, true) })
        end, { buffer = bufnr })
    end

    vim.keymap.set("n", keys.prev, "[c", { buffer = bufnr })
    vim.keymap.set("n", keys.next, "]c", { buffer = bufnr })

    local noautocmd = function(cmd)
        return function()
            vim.cmd("noautocmd " .. cmd)
        end
    end

    vim.keymap.set("n", "u", noautocmd("DiffThisUndo"), { buffer = bufnr })
    vim.keymap.set("n", "U", noautocmd("DiffThisUndo"), { buffer = bufnr })
    vim.keymap.set("n", "<C-r>", noautocmd("DiffThisRedo"), { buffer = bufnr })
end

return M
