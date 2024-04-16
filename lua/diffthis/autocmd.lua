local M = {}

local state = require("diffthis.state")
local queue = require("diffthis.undo_queue")
local undo = require("diffthis.undo")

M.setup = function(bufnr)
    -- vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    --     buffer = bufnr,
    --     callback = function(a)
    --     end,
    -- })

    vim.api.nvim_create_autocmd({ "InsertLeave" }, {
        buffer = bufnr,
        callback = function()

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
