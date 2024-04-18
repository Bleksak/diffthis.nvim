local config = require("diffthis.config")
local M = {}

local state = require("diffthis.state")

M.set_keys = function(bufnr, is_remote)
    local keys = config.config.keys

    if is_remote then
        vim.keymap.set("n", keys.obtain, function()
            vim.cmd("diffget")
            vim.cmd("diffupdate")
        end, { buffer = bufnr })

        vim.keymap.set("n", keys.put, function()
            vim.cmd("diffput")
            vim.cmd("diffupdate")

            -- This is a hack to trigger TextChanged, otherwise
            -- it would get triggered only after changing the window
            -- which is not what we want, because TextChanged controls
            -- the undo queue
            vim.api.nvim_set_current_win(state.current_state.wnd_obj.loc.window)
            vim.cmd("doautocmd TextChanged")
            vim.api.nvim_set_current_win(state.current_state.wnd_obj.remote.window)
        end, { buffer = bufnr })
    else
        vim.keymap.set("n", keys.obtain, function()
            vim.cmd("diffput")
            vim.cmd("diffupdate")

            vim.api.nvim_set_current_win(state.current_state.wnd_obj.remote.window)
            vim.cmd("doautocmd TextChanged")
            vim.api.nvim_set_current_win(state.current_state.wnd_obj.loc.window)
        end, { buffer = bufnr })

        vim.keymap.set("n", keys.put, function()
            vim.cmd("diffget")
            vim.cmd("diffupdate")
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
