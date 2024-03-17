local config = require("diffthis.config")
local M = {}

M.set_keys = function()
    local keys = config.config.keys

    vim.keymap.set("n", keys.obtain, function()
        vim.cmd("diffget")
    end)

    vim.keymap.set("n", keys.put, function()
        vim.cmd("diffput")
    end)

    vim.keymap.set("n", keys.prev, "[c", { expr = true, })
    vim.keymap.set("n", keys.next, "]c", { expr = true, })
end

M.unset_keys = function()
    local keys = config.config.keys

    vim.keymap.del("n", keys.obtain)
    vim.keymap.del("n", keys.put)
    vim.keymap.del("n", keys.prev)
    vim.keymap.del("n", keys.next)
    -- TODO: add undo support
    -- vim.keymap.del("n", "u")
end

return M
