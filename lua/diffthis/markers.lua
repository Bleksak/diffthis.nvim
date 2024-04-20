local M = {}

---@class MarkersReturn
---@field lines string[]
---@field label string

---@param file_lines string[]
---@return MarkersReturn
M.get_local = function(file_lines)
    local remote_pattern_start = vim.regex("^<<<<<<< ")
    local local_pattern_start = vim.regex("^=======\\r\\?$")
    local end_pattern = vim.regex("^>>>>>>>")

    local current_line = 1

    local keep = {}

    local in_remote_marker = false
    local in_local_marker = false

    local label = "LOCAL"

    while current_line <= #file_lines do
        if in_remote_marker then
            if local_pattern_start:match_str(file_lines[current_line]) then
                in_remote_marker = false
                in_local_marker = true
            end
        elseif in_local_marker then
            if end_pattern:match_str(file_lines[current_line]) then
                in_local_marker = false
                -- perform a substring on the current line

                label = string.sub(file_lines[current_line], #">>>>>>> ", -1)
            else
                table.insert(keep, file_lines[current_line])
            end
        else
            if remote_pattern_start:match_str(file_lines[current_line]) then
                in_remote_marker = true
            else
                table.insert(keep, file_lines[current_line])
            end
        end

        current_line = current_line + 1
    end

    return {
        lines = keep,
        label = label,
    }
end

---@param file_lines string[]
---@return MarkersReturn
M.get_remote = function(file_lines)
    local remote_pattern_start = vim.regex("^<<<<<<< ")
    local local_pattern_start = vim.regex("^=======\\r\\?$")
    local end_pattern = vim.regex("^>>>>>>>")

    local current_line = 1

    local keep = {}

    local in_remote_marker = false
    local in_local_marker = false

    local label = "REMOTE"

    while current_line <= #file_lines do
        if in_remote_marker then
            if local_pattern_start:match_str(file_lines[current_line]) then
                in_remote_marker = false
                in_local_marker = true
            else
                table.insert(keep, file_lines[current_line])
            end
        elseif in_local_marker then
            if end_pattern:match_str(file_lines[current_line]) then
                in_local_marker = false
            end
        else
            if remote_pattern_start:match_str(file_lines[current_line]) then
                in_remote_marker = true
                label = string.sub(file_lines[current_line], #"<<<<<<< ", -1)
            else
                table.insert(keep, file_lines[current_line])
            end
        end

        current_line = current_line + 1
    end

    return {
        lines = keep,
        label = label,
    }
end

return M
