---@class DiffState
---@field original_buffer number
---@field original_file string
---@field wnd_obj DiffWindowObjects
---@field code_snapshot string[]

---@class DiffWindowObjects
---@field loc DiffWindowObject
---@field remote DiffWindowObject

---@class DiffWindowObject
---@field buffer number
---@field window number
---@field label string

local default_state = {
    original_buffer = -1,
    original_file = "",
    wnd_obj = {
        loc = {
            buffer = -1,
            window = -1,
            label = "",
            undo = {
                queue = {},
            },
        },
        remote = {
            buffer = -1,
            window = -1,
            label = "",
            undo = {
                queue = {},
            },
        }
    },
    undo = {
        queues = {},
        sorting = {
            queue = {},
            undos = {},
        },
        in_undo = false,
    },
    code_snapshot = {},
    ignore_changes = false,
}

return {
    ---@type DiffState
    default_state = default_state,
    current_state = vim.deepcopy(default_state, true),
}
