local M = {}

M.get_local = function(file)
    return vim.fn.systemlist("git show HEAD:" .. file)
end

M.get_remote = function(file)
    return vim.fn.systemlist("git show MERGE_HEAD:" .. file)
end

return M
