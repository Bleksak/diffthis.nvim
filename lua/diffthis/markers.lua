local M = {}

M.get_local = function(file_lines)
    local remote_pattern_start = vim.regex("^<<<<<<< ")
    local local_pattern_start = vim.regex("^=======\\r\\?$")
    local end_pattern = vim.regex("^>>>>>>>")

    local current_line = 1

    local keep = {}

    local in_remote_marker = false
    local in_local_marker = false

    while current_line <= #file_lines do
        if in_remote_marker then
            if local_pattern_start:match_str(file_lines[current_line]) then
                in_remote_marker = false
                in_local_marker = true
            end
        elseif in_local_marker then
            if end_pattern:match_str(file_lines[current_line]) then
                in_local_marker = false
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

    return keep
end

M.get_remote = function(file_lines)
    local remote_pattern_start = vim.regex("^<<<<<<< ")
    local local_pattern_start = vim.regex("^=======\\r\\?$")
    local end_pattern = vim.regex("^>>>>>>>")

    local current_line = 1

    local keep = {}

    local in_remote_marker = false
    local in_local_marker = false

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
            else
                table.insert(keep, file_lines[current_line])
            end
        end

        current_line = current_line + 1
    end

    return keep
end

return M
