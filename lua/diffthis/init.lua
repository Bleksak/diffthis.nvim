local state = require("diffthis.state")

local M = {
    autocmd = require("diffthis.autocmd"),
    cfg = require("diffthis.config"),
    keys = require("diffthis.keys"),
    window = require("diffthis.window"),
    markers = require("diffthis.markers"),
}

---@param opts? DiffThisConfiguration
M.setup = function(opts)
    require("diffthis.config").setup(opts)

    local keys = require("diffthis.config").config.keys

    vim.keymap.set("n", keys.toggle, function()
        M.toggle()
    end)
end

M.open_file = function()
    local current_window = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_get_current_buf()

    local filetype = vim.api.nvim_get_option_value("filetype", { buf = current_buf })

    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, true)

    local rem_buffer = M.window.create_buffer_with_content(M.markers.get_remote(lines), "REMOTE")
    local loc_buffer = M.window.create_buffer_with_content(M.markers.get_local(lines), "LOCAL")

    vim.api.nvim_set_option_value("buftype", "nofile", { buf = loc_buffer })
    -- vim.api.nvim_set_option_value("readonly", true, { buf = loc_buffer })
    vim.api.nvim_set_option_value("buflisted", false, { buf = loc_buffer })
    vim.api.nvim_set_option_value("bufhidden", "delete", { buf = loc_buffer })
    vim.api.nvim_set_option_value("filetype", filetype, { buf = loc_buffer })

    -- vim.api.nvim_set_option_value("readonly", true, { buf = rem_buffer })
    vim.api.nvim_set_option_value("buflisted", false, { buf = rem_buffer })
    vim.api.nvim_set_option_value("bufhidden", "delete", { buf = rem_buffer })
    vim.api.nvim_set_option_value("filetype", filetype, { buf = rem_buffer })

    local loc_win = M.window.create_window_with_diff(loc_buffer, true)
    local rem_win = M.window.create_window_with_diff(rem_buffer, true)

    vim.api.nvim_win_close(current_window, true)

    state.current_state.wnd_obj.loc.buffer = loc_buffer
    state.current_state.wnd_obj.loc.window = loc_win
    state.current_state.wnd_obj.remote.buffer = rem_buffer
    state.current_state.wnd_obj.remote.window = rem_win

    state.current_state.undo.queues[loc_buffer] = {
        { buffer = loc_buffer, buffer_content = vim.api.nvim_buf_get_lines(loc_buffer, 0, -1, true), cursor = vim.api.nvim_win_get_cursor(loc_win), window = loc_win },
    }

    state.current_state.undo.queues[rem_buffer] = {
        { buffer = rem_buffer, buffer_content = vim.api.nvim_buf_get_lines(rem_buffer, 0, -1, true), cursor = vim.api.nvim_win_get_cursor(rem_win), window = rem_win },
    }

    state.current_state.undo.sorting.queue = {
        { buffer = loc_buffer },
        { buffer = rem_buffer },
    }

    state.current_state.undo.sorting.undos[loc_buffer] = 0
    state.current_state.undo.sorting.undos[rem_buffer] = 0

    M.keys.set_keys(loc_buffer, false)
    M.keys.set_keys(rem_buffer, true)

    M.autocmd.setup(loc_buffer)
    M.autocmd.setup(rem_buffer)
end

local open = function()
    state.current_state.original_buffer = vim.api.nvim_get_current_buf()
    state.current_state.original_file = vim.api.nvim_buf_get_name(0)

    M.open_file()
end

local close = function()
    local w = vim.api.nvim_open_win(state.current_state.original_buffer, true, { vertical = true, focusable = true })
    vim.api.nvim_set_current_buf(state.current_state.original_buffer)
    vim.api.nvim_set_current_win(w)


    vim.api.nvim_buf_set_lines(state.current_state.original_buffer, 0, -1, true,
        vim.api.nvim_buf_get_lines(state.current_state.wnd_obj.remote.buffer, 0, -1, true))
    vim.cmd("w!")

    M.window.close_window(state.current_state.wnd_obj.loc.window)
    M.window.close_window(state.current_state.wnd_obj.remote.window)

    state.current_state = vim.deepcopy(state.default_state, true)
end

M.toggle = function()
    if state.current_state.original_file == "" then
        open()
    else
        close()
    end
end

return M
