local M = {
    state = vim.deepcopy(require("diffthis.state").default_state, true),
    autocmd = nil,
    cfg = require("diffthis.config"),
    keys = require("diffthis.keys"),
    window = require("diffthis.window"),
    git = require("diffthis.git"),
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

    local loc_buffer = M.window.create_buffer_with_content(M.git.get_local(file))
    local rem_buffer = M.window.create_buffer_with_content(M.git.get_remote(file))

    local loc_win = M.window.create_window_with_diff(loc_buffer, true)
    local rem_win = M.window.create_window_with_diff(rem_buffer, false)

    vim.api.nvim_win_close(current_window, true)

    M.state.wnd_obj.left.loc.buffer = loc_buffer
    M.state.wnd_obj.left.loc.window = loc_win
    M.state.wnd_obj.left.remote.buffer = rem_buffer
    M.state.wnd_obj.left.remote.buffer = rem_win
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

    M.window.close_window(M.wnd_obj.left.loc.window)
    M.window.close_window(M.wnd_obj.left.remote.window)

    if #M.state.last_action > 0 then
        vim.api.nvim_buf_set_lines(M.state.original_buffer, 0, -1, true,
            vim.api.nvim_buf_get_lines(M.wnd_obj.left.loc.buffer, 0, -1, true))
        vim.cmd("w!")
    end

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
