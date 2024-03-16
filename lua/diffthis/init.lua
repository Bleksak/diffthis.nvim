local M = {}

local original_buffer = nil
local original_file = nil

local last_action = {}

local buffers = {}
local windows = {}

local autocmd = nil

local function restore_mappings()
    local keys = require("diffthis.config").config.keys

    vim.keymap.del("n", keys.obtain)
    vim.keymap.del("n", keys.put)
    vim.keymap.del("n", keys.prev)
    vim.keymap.del("n", keys.next)
    -- TODO: add undo support
   -- vim.keymap.del("n", "u")
end


---@param opts? DiffThisConfiguration
M.setup = function(opts)
    require("diffthis.config").setup(opts)

    local keys = require("diffthis.config").config.keys

    vim.keymap.set("n", keys.toggle, function()
        M.toggle()
    end)
end

local function undo_buffer(buf)
    local current_buf = vim.api.nvim_get_current_buf()
    local current_win = vim.api.nvim_get_current_win()

    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_command("undo!")

    vim.api.nvim_set_current_buf(current_buf)
    vim.api.nvim_set_current_win(current_win)
end

local function set_buffer_mapping()
    local keys = require("diffthis.config").config.keys

    vim.keymap.set("n", keys.obtain, function()
        vim.cmd("diffget")
        last_action[#last_action + 1] = "l"
    end)

    vim.keymap.set("n", keys.put, function()
        vim.cmd("diffput")
        last_action[#last_action + 1] = "r"
    end)

    vim.keymap.set("n", keys.prev, "[c", { expr = true, })
    vim.keymap.set("n", keys.next, "]c", { expr = true, })

    -- vim.keymap.set("n", "u", function()
    --     if #last_action == 0 then
    --         return
    --     end
    --
    --     if table.remove(last_action) == "r" then
    --         undo_buffer(buffers[2])
    --     else
    --         undo_buffer(buffers[1])
    --     end
    -- end)
end

---@param file string
M.open_file = function(file)
    local current_window = vim.api.nvim_get_current_win()

    local local_buf = vim.api.nvim_create_buf(false, true)
    local remote_buf = vim.api.nvim_create_buf(false, true)

    local local_content = vim.fn.systemlist("git show HEAD:" .. file)
    local remote_content = vim.fn.systemlist("git show MERGE_HEAD:" .. file)

    vim.api.nvim_buf_set_lines(local_buf, 0, -1, true, local_content)
    vim.api.nvim_buf_set_lines(remote_buf, 0, -1, true, remote_content)

    local remote_win = vim.api.nvim_open_win(remote_buf, true, { vertical = true, focusable = true })
    local local_win = vim.api.nvim_open_win(local_buf, true, { vertical = true, focusable = true })

    vim.fn.setwinvar(local_win, "&diff", 1)
    vim.fn.setwinvar(remote_win, "&diff", 1)

    vim.api.nvim_win_close(current_window, true)

    buffers = { local_buf, remote_buf }
    windows = { local_win, remote_win }

    -- if autocmd == nil then
    --     autocmd = vim.api.nvim_create_autocmd({"DiffUpdated"}, {
    --         callback = function(event)
    --             if event.buf == buffers[1] then
    --                 last_action[#last_action + 1] = "l"
    --             elseif event.buf == buffers[2] then
    --                 last_action[#last_action + 1] = "r"
    --             end
    --         end
    --     })
    -- end
end

M.toggle = function()
    if original_file == nil then
        original_buffer = vim.api.nvim_get_current_buf()
        original_file = vim.api.nvim_buf_get_name(0)

        local current_file = vim.fn.expand('%')
        M.open_file(current_file)

        set_buffer_mapping()
    else
        if original_buffer then
            local w = vim.api.nvim_open_win(original_buffer, true, { vertical = true, focusable = true })
            vim.api.nvim_set_current_buf(original_buffer)
            vim.api.nvim_set_current_win(w)
        end

        for _, w in ipairs(windows) do
            vim.cmd("diffoff")
            vim.api.nvim_win_close(w, true)
        end

        if #last_action > 0 and original_buffer then
            vim.api.nvim_buf_set_lines(original_buffer, 0, -1, true, vim.api.nvim_buf_get_lines(buffers[1], 0, -1, true))
            vim.cmd("w!")
        end

        original_file = nil
        original_buffer = nil
        last_action = {}
        buffers = {}
        windows = {}

        -- if autocmd then
        --     vim.api.nvim_del_autocmd(autocmd)
        --     autocmd = nil
        -- end

        restore_mappings()
    end
end

return M
