local M = {
    state = vim.deepcopy(require("diffthis.state").default_state, true),
    autocmd = nil,
    cfg = require("diffthis.config"),
    keys = require("diffthis.keys"),
    window = require("diffthis.window"),
    git = require("diffthis.git"),
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

---@param file string
M.open_file = function(file)
    local current_window = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_get_current_buf()

    local filetype = vim.api.nvim_get_option_value("filetype", { buf = current_buf })

    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, true)

    local rem_buffer = M.window.create_buffer_with_content(M.markers.get_remote(lines), "REMOTE")
    local loc_buffer = M.window.create_buffer_with_content(M.markers.get_local(lines), "LOCAL")

    -- vim.api.nvim_set_option_value("modifiable", false, { buf = loc_buffer })
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = loc_buffer })
    vim.api.nvim_set_option_value("readonly", true, { buf = loc_buffer })
    vim.api.nvim_set_option_value("buflisted", false, { buf = loc_buffer })
    vim.api.nvim_set_option_value("bufhidden", "delete", { buf = loc_buffer })
    vim.api.nvim_set_option_value("filetype", filetype, { buf = loc_buffer })

    vim.api.nvim_set_option_value("readonly", true, { buf = rem_buffer })
    vim.api.nvim_set_option_value("buflisted", false, { buf = rem_buffer })
    vim.api.nvim_set_option_value("bufhidden", "delete", { buf = rem_buffer })
    vim.api.nvim_set_option_value("filetype", filetype, { buf = rem_buffer })

    local loc_win = M.window.create_window_with_diff(loc_buffer, true)
    local rem_win = M.window.create_window_with_diff(rem_buffer, true)

    vim.api.nvim_win_close(current_window, true)

    M.state.wnd_obj.loc.buffer = loc_buffer
    M.state.wnd_obj.loc.window = loc_win
    M.state.wnd_obj.remote.buffer = rem_buffer
    M.state.wnd_obj.remote.window = rem_win
end

local open = function()
    M.state.original_buffer = vim.api.nvim_get_current_buf()
    M.state.original_file = vim.api.nvim_buf_get_name(0)

    M.open_file(vim.fn.expand('%'))
    M.keys.set_keys()
end

local close = function()
    local w = vim.api.nvim_open_win(M.state.original_buffer, true, { vertical = true, focusable = true })
    vim.api.nvim_set_current_buf(M.state.original_buffer)
    vim.api.nvim_set_current_win(w)


    -- if #M.state.last_action > 0 then

    vim.api.nvim_buf_set_lines(M.state.original_buffer, 0, -1, true,
        vim.api.nvim_buf_get_lines(M.state.wnd_obj.remote.buffer, 0, -1, true))
    vim.cmd("w!")

    M.window.close_window(M.state.wnd_obj.loc.window)
    M.window.close_window(M.state.wnd_obj.remote.window)

    -- end

    M.state = vim.deepcopy(require("diffthis.state").default_state, true)
    M.keys.unset_keys()
end

M.toggle = function()
    if M.state.original_file == "" then
        open()
    else
        close()
    end
end

return M
