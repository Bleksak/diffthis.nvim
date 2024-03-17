---@class DiffState
---@field original_buffer number
---@field original_file string
---@field last_action string
---@field wnd_obj DiffWindowObjects

---@class DiffWindowObjects
---@field left DiffWindowObject
---@field right DiffWindowObject

---@class DiffWindowObject
---@field loc number
---@field remote number

return {
    default_state = {
        original_buffer = -1,
        original_file = "",
        last_action = {},
        wnd_obj = {
            left = {
                loc = {
                    buffer = -1,
                    window = -1,
                },
                remote = {
                    buffer = -1,
                    window = -1,
                }
            },
        },
    }
}
