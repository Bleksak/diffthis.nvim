---@class ConfigSetup
---@field config DiffThisConfiguration
---@field setup function
local M = {}

---@class DiffThisConfiguration
local defaults = {
    keys = {
        toggle = "<leader>dd",
        obtain = "do",
        put = "dp",
        next = "dn",
        prev = "dN",
    }
}

---@class DiffThisConfigurationKeys
---@field toggle string
---@field obtain string
---@field put string
---@field next string
---@field prev string

---@type DiffThisConfiguration
M.config = {}

M.setup = function(opts)
    M.config = vim.tbl_deep_extend("force", defaults, opts or {})
end

return M
