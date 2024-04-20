local M = {}

M.create_window_with_diff = function(buf, enter)
    local win = vim.api.nvim_open_win(buf, enter, { vertical = true, focusable = true })
    vim.fn.setwinvar(win, "&diff", 1)
    vim.api.nvim_set_option_value("cursorbind", true, { win = win })
    return win
end

M.create_buffer_with_content = function(content, filetype)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, content)
    vim.api.nvim_buf_set_name(buf, vim.fn.tempname())
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
    vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
    vim.api.nvim_set_option_value("bufhidden", "delete", { buf = buf })
    vim.api.nvim_set_option_value("filetype", filetype, { buf = buf })
    return buf
end

M.close_window = function(win)
    vim.cmd("diffoff")
    vim.api.nvim_win_close(win, true)
end

M.undo = function(bufnr)
    local current_buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_command("undo!")
    vim.api.nvim_set_current_buf(current_buf)
end

return M
